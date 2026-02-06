resource "aws_launch_template" "this" {
  name_prefix            = var.asg_prefix
  image_id               = var.asg_ami
  instance_type          = var.asg_instance_type
  vpc_security_group_ids = [var.security_group_id]

  #user_data = base64encode(templatefile("${path.module}/user_data.sh",
  #  {
  #    server_port = var.server_port
  #}))

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
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


resource "aws_autoscaling_group" "this" {
  target_group_arns   = var.target_group_arns
  vpc_zone_identifier = var.public_subnets_cidr_blocks

  desired_capacity = var.asg_desired_capacity
  max_size         = var.asg_max_size
  min_size         = var.asg_min_size

  launch_template {
    id      = aws_launch_template.this.id
    version = "$Latest"
  }
}
