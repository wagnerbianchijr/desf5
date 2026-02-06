# -----------------------------------------------------------
#: VPC creation
# -----------------------------------------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name         = "${var.vpc_name}-xpe"
    CreatedBy    = var.created_by_tag
    Terraformed  = var.terraformed_tag
    Environment  = var.environment_tag
    CostCenter   = var.cost_center_tag
    ProjectOwner = var.project_owner_tag
  }
}

resource "aws_iam_role" "flow_logs_role" {
  name = "${var.vpc_name}-flow-logs-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name         = "${var.vpc_name}-flow-logs-role"
    CreatedBy    = var.created_by_tag
    Terraformed  = var.terraformed_tag
    Environment  = var.environment_tag
    CostCenter   = var.cost_center_tag
    ProjectOwner = var.project_owner_tag
  }
}

resource "aws_iam_role_policy" "flow_logs_policy" {
  name = "${var.vpc_name}-flow-logs-policy"
  role = aws_iam_role.flow_logs_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/${var.vpc_name}-flow-logs"
  retention_in_days = 7
  skip_destroy      = false
  kms_key_id        = var.kms_key_id

  tags = {
    Name         = "${var.vpc_name}-flow-logs"
    CreatedBy    = var.created_by_tag
    Terraformed  = var.terraformed_tag
    Environment  = var.environment_tag
    CostCenter   = var.cost_center_tag
    ProjectOwner = var.project_owner_tag
  }
}

resource "aws_flow_log" "vpc_flow_log" {
  iam_role_arn         = aws_iam_role.flow_logs_role.arn
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs.arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id

  depends_on = [aws_iam_role_policy.flow_logs_policy]

  tags = {
    Name         = "${var.vpc_name}-flowlog"
    CreatedBy    = var.created_by_tag
    Terraformed  = var.terraformed_tag
    Environment  = var.environment_tag
    CostCenter   = var.cost_center_tag
    ProjectOwner = var.project_owner_tag
  }
}

# -----------------------------------------------------------
#: Internet Gateway
# -----------------------------------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name         = "${var.igw_name}-xpe"
    CreatedBy    = var.created_by_tag
    Terraformed  = var.terraformed_tag
    Environment  = var.environment_tag
    CostCenter   = var.cost_center_tag
    ProjectOwner = var.project_owner_tag
  }
}

# -----------------------------------------------------------
#: Public Subnets
# -----------------------------------------------------------
resource "aws_subnet" "public" {
  count = length(var.public_subnets_cidr_blocks)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnets_cidr_blocks, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name         = "xpe-public-subnets-${count.index + 1}-${element(var.availability_zones, count.index)}"
    CreatedBy    = var.created_by_tag
    Terraformed  = var.terraformed_tag
    Environment  = var.environment_tag
    CostCenter   = var.cost_center_tag
    ProjectOwner = var.project_owner_tag
  }
}

# -----------------------------------------------------------
#: Private Subnets
# -----------------------------------------------------------
resource "aws_subnet" "private" {
  count = length(var.private_subnets_cidr_blocks)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.private_subnets_cidr_blocks, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name         = "xpe-private-subnet-${count.index + 1}-${element(var.availability_zones, count.index)}"
    CreatedBy    = var.created_by_tag
    Terraformed  = var.terraformed_tag
    Environment  = var.environment_tag
    CostCenter   = var.cost_center_tag
    ProjectOwner = var.project_owner_tag
  }
}

# -----------------------------------------------------------
#: public route table
# -----------------------------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name         = "xpe-${var.rt_name}-public"
    CreatedBy    = var.created_by_tag
    Terraformed  = var.terraformed_tag
    Environment  = var.environment_tag
    CostCenter   = var.cost_center_tag
    ProjectOwner = var.project_owner_tag
  }
}

# -----------------------------------------------------------
#: internet gateway
# -----------------------------------------------------------
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_cidr_blocks)
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

# -----------------------------------------------------------
#: Private Route Table
# -----------------------------------------------------------
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name         = "xpe-${var.rt_name}-private"
    CreatedBy    = var.created_by_tag
    Terraformed  = var.terraformed_tag
    Environment  = var.environment_tag
    CostCenter   = var.cost_center_tag
    ProjectOwner = var.project_owner_tag
  }
}

# -----------------------------------------------------------
#: Private Routes
# -----------------------------------------------------------
resource "aws_route_table_association" "private" {
  count = length(var.private_subnets_cidr_blocks)

  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = aws_route_table.private.id
}