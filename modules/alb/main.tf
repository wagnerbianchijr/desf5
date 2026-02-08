/*
  =============================================================================
  Module:        alb
  File:          main.tf
  Owner:         Wagner “Bianchi” Bianchi
  Role:          Database & Cloud Infrastructure
  Repository:    https://github.com/wagnerbianchijr/desf5
  Documentation: https://github.com/wagnerbianchijr/desf5
  License:       GPL-3.0 license

  Purpose:
    This module provisions an Application Load Balancer (ALB) in AWS, along 
    with a target group and listener. It is used to distribute traffic across 
    instances in an Auto Scaling Group.

  Usage Notes:
    - Ensure that the VPC and subnets specified in the variables exist before 
    applying this module.
    - The security groups attached to the ALB should allow inbound traffic on 
    the listener port and outbound traffic to the target group instances.
    - The target group should be configured with appropriate health check 
    settings to ensure proper monitoring of instance health.
    - This module does not include the Auto Scaling Group or EC2 instances; it 
    should be used in conjunction with a module that provisions those resources.

  Compatibility:
    Terraform:    >= 1.14.2
    Providers:    AWS
    Tested On:    1.14.2

  Contact:
    For questions or issues, please open an issue in the GitHub repository or 
    contact the owner directly.
  =============================================================================
*/

resource "aws_lb" "this" {
  name               = var.load_balancer_name
  internal           = var.load_balancer_internal
  load_balancer_type = var.load_balancer_type
  security_groups    = var.load_balancer_security_groups
  subnets            = var.load_balancer_subnets

  tags = {
    Name         = "${var.load_balancer_name}-xpe"
    CreatedBy    = var.created_by_tag
    Terraformed  = var.terraformed_tag
    Environment  = var.environment_tag
    CostCenter   = var.cost_center_tag
    ProjectOwner = var.project_owner_tag
  }
}

resource "aws_lb_target_group" "this" {
  name        = var.target_group_name
  port        = var.target_group_port
  protocol    = var.target_group_protocol
  vpc_id      = var.vpc_id
  target_type = var.target_type

  health_check {
    enabled             = true
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
    interval            = var.health_check_interval
    path                = var.health_check_path
    port                = var.health_check_port
    protocol            = var.health_check_protocol
    timeout             = var.health_check_timeout
  }

  tags = {
    Name         = "${var.target_group_name}-xpe"
    CreatedBy    = var.created_by_tag
    Terraformed  = var.terraformed_tag
    Environment  = var.environment_tag
    CostCenter   = var.cost_center_tag
    ProjectOwner = var.project_owner_tag
  }
}

resource "aws_lb_listener" "this" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.listener_port
  protocol          = var.listener_protocol

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }

  tags = {
    Name         = "${var.listener_name}-xpe"
    CreatedBy    = var.created_by_tag
    Terraformed  = var.terraformed_tag
    Environment  = var.environment_tag
    CostCenter   = var.cost_center_tag
    ProjectOwner = var.project_owner_tag
  }
}