/*
  =============================================================================
  Module:        asg
  File:          main.tf
  Owner:         Wagner “Bianchi” Bianchi
  Role:          Database & Cloud Infrastructure
  Repository:    https://github.com/wagnerbianchijr/desf5
  Documentation: https://github.com/wagnerbianchijr/desf5
  License:       GPL-3.0 license

  Purpose:
    This module provisions an Auto Scaling Group (ASG) in AWS, along with a 
    launch template and a scaling policy. The ASG is used to automatically 
    manage the number of EC2 instances based on demand, ensuring high 
    availability and scalability for applications.

  Usage Notes:
    - Ensure that the target group ARNs and security group IDs specified in the 
      variables exist before applying this module.
    - The ASG will be associated with the specified target groups, so ensure 
      that the health checks are properly configured for those target groups.
    - The scaling policy is set to scale up based on CPU utilization; adjust 
      the target value as needed for your application.
    - This module does not include the ALB or EC2 instances; it should be used 
      in conjunction with modules that provision those resources.

  Compatibility:
    Terraform:    >= 1.14.2
    Providers:    AWS
    Tested On:    1.14.2

  Contact:
    For questions or issues, please open an issue in the GitHub repository or 
    contact the owner directly.
  =============================================================================
*/

resource "aws_launch_template" "this" {
  name_prefix            = var.asg_prefix
  image_id               = var.asg_ami
  instance_type          = var.asg_instance_type
  vpc_security_group_ids = [var.security_group_id]

  #user_data = base64encode(<<-EOT
  #  #!/bin/bash
  #  set -e
  #
  #  echo "==== Inicializando configuração EC2 ===="
  #
  #  apt-get update -y
  #  apt-get upgrade -y
  #  apt-get install -y apache2
  #
  #  cat <<'HTML' > /var/www/html/index.html
  #  <html>
  #    <head>
  #      <title>Health Check</title>
  #    </head>
  #    <body>
  #      <h1>I am healthy!</h1>
  #      <p>Deployed via Terraform</p>
  #    </body>
  #  </html>
  #  HTML
  #
  #  systemctl enable apache2
  #  systemctl start apache2
  #
  #  echo "==== Fim da configuração ===="
  #EOT
  #)

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name              = var.asg_project_name
      environment_tag   = var.environment_tag
      created_by_tag    = var.created_by_tag
      project_owner_tag = var.project_owner_tag
      cost_center_tag   = var.cost_center_tag
      terraformed_tag   = var.terraformed_tag
    }
  }
}

#:--------------------------------------------------------------------------------
#: Auto Scaling Group
#:--------------------------------------------------------------------------------
resource "aws_autoscaling_group" "this" {
  target_group_arns   = var.target_group_arns
  vpc_zone_identifier = var.private_subnets_cidr_blocks

  desired_capacity = var.asg_desired_capacity
  max_size         = var.asg_max_size
  min_size         = var.asg_min_size

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }
}

#:--------------------------------------------------------------------------------
#: Auto Scaling Policy - Scale Up based on CPU Utilization
#:--------------------------------------------------------------------------------
resource "aws_autoscaling_policy" "cpu_scale_up_policy" {
  name                   = "scale-up-cpu"
  autoscaling_group_name = aws_autoscaling_group.this.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 60.0
  }
}