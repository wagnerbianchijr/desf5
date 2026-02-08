/*
  =============================================================================
  Root Module (Composition Layer): main.tf
  Owner:         Wagner “Bianchi” Bianchi
  Role:          Database & Cloud Infrastructure
  Repository:    https://github.com/wagnerbianchijr/desf5
  Environment:   <dev|staging|prod> | Workspace: ${terraform.workspace}

  What this file is:
    This is the orchestration entrypoint that wires modules together and defines
    how the stack composes as a whole (not where deep resource logic lives).

  Design rules:
    Keep resource-heavy logic inside modules.
    Keep providers, backend/remote-state, and cross-module wiring here.
    Pass only what’s needed: prefer explicit variables/outputs over ad-hoc refs.

  Execution:
    terraform init
    terraform plan  -var-file=<env>.tfvars
    terraform apply -var-file=<env>.tfvars
  =============================================================================
*/



#:--------------------------------------------------------------
#: KMS Key for encrypting resources in the primary VPC
#:--------------------------------------------------------------
module "kms_primary" {
  source = "./modules/kms"
  region = "us-east-1"

  project_owner_tag = "Terraform Team"
  environment_tag   = "primary"
  cost_center_tag   = "CC1001"
  created_by_tag    = "Bianchi"
  terraformed_tag   = true

  providers = {
    aws = aws.aws_primary
  }
}

#:--------------------------------------------------------------------------------
#: Primary VPC
#:--------------------------------------------------------------------------------
module "vpc_primary" {
  source                      = "./modules/vpc"
  vpc_name                    = "xpe-vpc-primary"
  igw_name                    = "igw-primary"
  rt_name                     = "rt-primary"
  vpc_cidr_block              = "10.10.0.0/16"
  public_subnets_cidr_blocks  = ["10.10.0.0/24", "10.10.2.0/24", "10.10.4.0/24"]
  private_subnets_cidr_blocks = ["10.10.1.0/24", "10.10.3.0/24", "10.10.5.0/24"]
  availability_zones          = ["us-east-1a", "us-east-1b", "us-east-1c"]
  kms_key_id                  = module.kms_primary.kms_key_id

  #: resource tags
  project_owner_tag = "Terraform Team"
  environment_tag   = "primary"
  cost_center_tag   = "CC1001"
  created_by_tag    = "Bianchi"
  terraformed_tag   = true

  #: provider aliasing for the primary VPC
  providers = {
    aws = aws.aws_primary
  }
}

#:--------------------------------------------------------------------------------
#: Security Group: Instances do ASG
#:--------------------------------------------------------------------------------
module "sg_primary_asg" {
  source  = "./modules/sg"
  vpc_id  = module.vpc_primary.vpc_id
  sg_name = "xpe-sg-primary-asg"

  #: resource tags
  project_owner_tag = "Terraform Team"
  environment_tag   = "primary"
  cost_center_tag   = "CC1001"
  created_by_tag    = "Bianchi"
  terraformed_tag   = true

  ingress_rules = [
    {
      description = "Allow SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      description = "Allow HTTP"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
  ]

  egress_rules = [
    {
      description = "Allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  providers = {
    aws = aws.aws_primary
  }
}

#:--------------------------------------------------------------------------------
#: Security Group: Postgres Database
#:--------------------------------------------------------------------------------
module "sg_primary_db" {
  source  = "./modules/sg"
  vpc_id  = module.vpc_primary.vpc_id
  sg_name = "xpe-sg-primary-db"

  #: resource tags
  project_owner_tag = "Terraform Team"
  environment_tag   = "primary"
  cost_center_tag   = "CC1001"
  created_by_tag    = "Bianchi"
  terraformed_tag   = true

  ingress_rules = [
    {
      description = "Allow Postgres only from app/public subnets"
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  egress_rules = [
    {
      description = "Allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  providers = {
    aws = aws.aws_primary
  }
}

#:--------------------------------------------------------------------------------
#: Security Group: Jump Box
#:--------------------------------------------------------------------------------
module "sg_jumpbox" {
  source  = "./modules/sg"
  vpc_id  = module.vpc_primary.vpc_id
  sg_name = "xpe-sg-jumpbox"

  #: resource tags
  project_owner_tag = "Terraform Team"
  environment_tag   = "primary"
  cost_center_tag   = "CC1001"
  created_by_tag    = "Bianchi"
  terraformed_tag   = true

  ingress_rules = [
    {
      description = "Allow SSH from anywhere"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  egress_rules = [
    {
      description = "Allow all outbound traffic"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  providers = {
    aws = aws.aws_primary
  }
}

#:--------------------------------------------------------------------------------
#: Auto Scaling Group
#:--------------------------------------------------------------------------------
module "asg_primary" {
  source = "./modules/asg"

  asg_project_name  = "xpe-asg-primary"
  asg_prefix        = "xpe-asg-primary"
  asg_ami           = "ami-0445fdc83749c553e" #: custom AMI (Apache + PHP) created for this project
  asg_instance_type = "t3.micro"
  #server_port       = 80

  #: the security group id will be available only if you execute the complete terraform apply
  #: if you try to run only this module, it will not work as expected as you need to inform the
  #: security group id created in the VPC module manually
  #security_group_id = ""
  security_group_id = module.sg_primary_asg.security_group_id #: output from sg module

  asg_desired_capacity = 3
  asg_max_size         = 10
  asg_min_size         = 3

  availability_zones          = ["us-east-1a", "us-east-1b", "us-east-1c"]
  target_group_arns           = module.alb_primary.target_group_arns   #: output from alb module
  public_subnets_cidr_blocks  = module.vpc_primary.public_subnets_ids  #: output from vpc module
  private_subnets_cidr_blocks = module.vpc_primary.private_subnets_ids #: output from vpc module

  #: resource tags
  project_owner_tag = "Terraform Team"
  environment_tag   = "primary"
  cost_center_tag   = "CC1001"
  created_by_tag    = "Bianchi"
  terraformed_tag   = true

  providers = {
    aws = aws.aws_primary
  }
}

#:--------------------------------------------------------------------------------
#: Application Load Balancer
#:--------------------------------------------------------------------------------
module "alb_primary" {
  source = "./modules/alb"

  load_balancer_name            = "alb-primary"
  load_balancer_internal        = false
  load_balancer_type            = "application"
  load_balancer_security_groups = [module.sg_primary_asg.security_group_id]
  load_balancer_subnets         = module.vpc_primary.public_subnets_ids
  target_group_name             = "tg-primary"
  target_group_port             = 80
  target_group_protocol         = "HTTP"
  vpc_id                        = module.vpc_primary.vpc_id

  target_type                      = "instance"
  health_check_healthy_threshold   = 2
  health_check_unhealthy_threshold = 2
  health_check_interval            = 30
  health_check_path                = "/"
  health_check_port                = "traffic-port"
  health_check_protocol            = "HTTP"
  health_check_timeout             = 5

  listener_port     = 80
  listener_name     = "listener-primary"
  listener_protocol = "HTTP"

  #: resource tags
  project_owner_tag = "Terraform Team"
  environment_tag   = "primary"
  cost_center_tag   = "CC1001"
  created_by_tag    = "Bianchi"
  terraformed_tag   = true

  providers = {
    aws = aws.aws_primary
  }
}

#:--------------------------------------------------------------------------------
#: RDS Instances Parameter Groups
#:--------------------------------------------------------------------------------
module "parameter_group_primary_db" {
  source = "./modules/pgr"

  parameter_group_name        = "xpe-pg17-logical-primary"
  parameter_group_family      = "postgres17"
  parameter_group_region      = "us-east-1"
  parameter_group_description = "RDS PG17 logical replication"

  #: resource tags
  project_owner_tag = "Terraform Team"
  environment_tag   = "primary"
  cost_center_tag   = "CC1001"
  created_by_tag    = "Bianchi"
  terraformed_tag   = true

  providers = {
    aws = aws.aws_primary
  }
}

module "parameter_group_secondary_db" {
  source = "./modules/pgr"

  parameter_group_name        = "xpe-pg17-logical-secondary"
  parameter_group_family      = "postgres17"
  parameter_group_region      = "us-east-1"
  parameter_group_description = "RDS PG17 logical replication"

  #: resource tags
  project_owner_tag = "Terraform Team"
  environment_tag   = "primary"
  cost_center_tag   = "CC1001"
  created_by_tag    = "Bianchi"
  terraformed_tag   = true

  providers = {
    aws = aws.aws_primary
  }
}

#:--------------------------------------------------------------------------------
#: RDS Subnet Group
#:--------------------------------------------------------------------------------
resource "aws_db_subnet_group" "db_subnet_group" {
  region      = "us-east-1"
  name        = "rds-subnet-group"
  description = "Subnet group for RDS instances"
  subnet_ids = [
    module.vpc_primary.private_subnets_ids[0],
    module.vpc_primary.private_subnets_ids[1],
    module.vpc_primary.private_subnets_ids[2]
  ]

  tags = {
    Name            = "rds-subnet-group"
    EnvironmentTag  = "primary"
    ProjectOwnerTag = "Terraform Team"
    TerraformedTag  = true
  }
}

#:--------------------------------------------------------------------------------
#: RDS Instances
#:--------------------------------------------------------------------------------
resource "aws_db_instance" "primary_db" {
  region               = "us-east-1"
  identifier           = "primary-db"
  engine               = "postgres"
  engine_version       = "17.6"
  instance_class       = "db.t3.medium"
  allocated_storage    = 20
  username             = "postgres"
  password             = "postgres"
  skip_final_snapshot  = true
  multi_az             = true
  publicly_accessible  = false
  storage_encrypted    = true
  kms_key_id           = module.kms_primary.kms_key_id
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  parameter_group_name = module.parameter_group_primary_db.parameter_group_name

  vpc_security_group_ids = [module.sg_primary_db.security_group_id]

  backup_retention_period = 14
  backup_window           = "01:00-03:00"
  maintenance_window      = "mon:03:00-mon:06:00"

  depends_on = [module.parameter_group_primary_db.parameter_group_name]

  tags = {
    ProjectOwnerTag = "Terraform Team"
    EnvironmentTag  = "primary"
    CostCenterTag   = "CC1001"
    CreatedByTag    = "Bianchi"
    TerraformedTag  = true
  }
}

resource "aws_db_instance" "secondary_db" {
  region               = "us-east-1"
  identifier           = "secondary-db"
  instance_class       = "db.t3.medium"
  replicate_source_db  = aws_db_instance.primary_db.arn
  skip_final_snapshot  = true
  publicly_accessible  = false
  storage_encrypted    = true
  kms_key_id           = module.kms_primary.kms_key_id
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  parameter_group_name = module.parameter_group_secondary_db.parameter_group_name

  vpc_security_group_ids = [module.sg_primary_db.security_group_id]
  depends_on             = [module.parameter_group_secondary_db.parameter_group_name]

  tags = {
    ProjectOwnerTag = "Terraform Team"
    EnvironmentTag  = "secondary"
    CostCenterTag   = "CC1001"
    CreatedByTag    = "Bianchi"
    TerraformedTag  = true
  }
}

#:--------------------------------------------------------------------------------
#: NAT Gateway and Route for Private Subnets
#:--------------------------------------------------------------------------------
resource "aws_eip" "nat_eip" {
  provider = aws.aws_primary
  domain   = "vpc"

  tags = {
    Name            = "xpe-nat-eip"
    ProjectOwnerTag = "Terraform Team"
    EnvironmentTag  = "secondary"
    CostCenterTag   = "CC1001"
    CreatedByTag    = "Bianchi"
    TerraformedTag  = true
  }
}

resource "aws_nat_gateway" "nat_gw" {
  provider      = aws.aws_primary
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = module.vpc_primary.public_subnets_ids[0]

  tags = {
    Name            = "xpe-nat-gw"
    ProjectOwnerTag = "Terraform Team"
    EnvironmentTag  = "secondary"
    CostCenterTag   = "CC1001"
    CreatedByTag    = "Bianchi"
    TerraformedTag  = true
  }

  depends_on = [module.vpc_primary]
}

resource "aws_route" "private_default_via_nat_single" {
  provider               = aws.aws_primary
  route_table_id         = module.vpc_primary.private_route_table_ids[0]
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id

  depends_on = [aws_nat_gateway.nat_gw]
}

#:-------------------------------------------------------------------------------------------------
#: Jump Box - it is just SSH Key based access, needs Hashicorp Vault or similar for production use
#:-------------------------------------------------------------------------------------------------
resource "aws_instance" "jumpbox" {
  provider                    = aws.aws_primary
  ami                         = "ami-0445fdc83749c553e"
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  subnet_id                   = module.vpc_primary.public_subnets_ids[0]
  vpc_security_group_ids      = [module.sg_jumpbox.security_group_id]

  tags = {
    Name            = "xpe-jumpbox"
    ProjectOwnerTag = "Terraform Team"
    EnvironmentTag  = "secondary"
    CostCenterTag   = "CC1001"
    CreatedByTag    = "Bianchi"
    TerraformedTag  = true
  }
}
