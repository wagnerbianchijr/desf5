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