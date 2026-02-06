#:--------------------------------------------------------------
#: Main Terraform configuration file
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

#: calling the VPC module for creating a VPC the primary VPC
module "vpc_primary" {
  source                      = "./modules/vpc"
  vpc_name                    = "vpc-primary"
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

#: creating a security group in the primary VPC
module "sg_primary" {
  source  = "./modules/sg"
  vpc_id  = module.vpc_primary.vpc_id
  sg_name = "xpe-sg-primary"

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

#: ASG primary in the primary VPC
module "asg_primary" {
  source = "./modules/asg"

  asg_project_name  = "asg-primary"
  asg_prefix        = "asg-primary"
  asg_ami           = "ami-02f8dc66e304ef92d"
  asg_instance_type = "t3.micro"
  #server_port       = 80

  #: the security group id will be available only if you execute the complete terraform apply
  #: if you try to run only this module, it will not work as expected as you need to inform the
  #: security group id created in the VPC module manually
  #security_group_id = ""
  security_group_id = module.sg_primary.security_group_id #: output from sg module

  asg_desired_capacity = 3
  asg_max_size         = 5
  asg_min_size         = 1

  availability_zones          = ["us-east-1a", "us-east-1b", "us-east-1c"] /* unused */
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

#: creating the ALB in the primary VPC
module "alb_primary" {
  source = "./modules/alb"

  load_balancer_name            = "alb-primary"
  load_balancer_internal        = false
  load_balancer_type            = "application"
  load_balancer_security_groups = [module.sg_primary.security_group_id]
  load_balancer_subnets         = module.vpc_primary.public_subnets_ids
  target_group_name             = "tg-primary"
  target_group_port             = 80
  target_group_protocol         = "HTTP"
  vpc_id                        = module.vpc_primary.vpc_id

  target_type                      = "instance"
  health_check_healthy_threshold   = 2
  health_check_unhealthy_threshold = 2
  health_check_interval            = 30
  health_check_path                = "/health"
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