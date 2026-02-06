# -----------------------------------------------------------
#: Security Group
# -----------------------------------------------------------
resource "aws_security_group" "this" {
  name        = var.sg_name
  description = "Allow SSH and HTTP"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = var.egress_rules
    content {
      description = egress.value.description
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = {
    Name         = "xpe-${var.sg_name}"
    CreatedBy    = var.created_by_tag
    Terraformed  = var.terraformed_tag
    Environment  = var.environment_tag
    CostCenter   = var.cost_center_tag
    ProjectOwner = var.project_owner_tag
  }

}