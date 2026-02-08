/*
  =============================================================================
  Module:        sg
  File:          main.tf
  Owner:         Wagner “Bianchi” Bianchi
  Role:          Database & Cloud Infrastructure
  Repository:    https://github.com/wagnerbianchijr/desf5
  Documentation: https://github.com/wagnerbianchijr/desf5
  License:       GPL-3.0 license

  Purpose:
    This module provisions a Security Group in AWS, which is used to control 
    inbound and outbound traffic for resources such as EC2 instances and RDS 
    databases. The security group is configured with dynamic ingress and egress 
    rules based on the variables provided.

  Usage Notes:
    - Ensure that the VPC specified in the variables exists before applying this 
      module.
    - The ingress and egress rules should be defined in the variables as lists of 
      maps, with each map containing the necessary parameters for the rule.
    - This module does not include the resources that will use the security group; 
      it should be used in conjunction with modules that provision those resources.

  Compatibility:
    Terraform:    >= 1.14.2
    Providers:    AWS
    Tested On:    1.14.2

  Contact:
    For questions or issues, please open an issue in the GitHub repository or 
    contact the owner directly.
  =============================================================================
*/

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