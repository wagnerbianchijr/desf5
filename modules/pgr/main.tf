/*
  =============================================================================
  Module:        pgr
  File:          main.tf
  Owner:         Wagner “Bianchi” Bianchi
  Role:          Database & Cloud Infrastructure
  Repository:    https://github.com/wagnerbianchijr/desf5
  Documentation: https://github.com/wagnerbianchijr/desf5
  License:       GPL-3.0 license

  Purpose:
    This module provisions a PostgreSQL RDS Parameter Group in AWS. It allows 
    you to define custom parameters for your RDS instances, which can be applied 
    to enhance performance, security, and functionality based on your specific 
    requirements.
    
  Usage Notes:
    - Ensure that the parameter group family specified in the variables is 
      compatible with the RDS engine version you are using.
    - After creating or modifying a parameter group, you may need to reboot your 
      RDS instances for the changes to take effect, especially for parameters 
      that require a pending reboot.
    - This module does not include the RDS instance itself; it should be used in 
      conjunction with a module that provisions RDS instances.
      
  Compatibility:
    Terraform:    >= 1.14.2
    Providers:    AWS
    Tested On:    1.14.2

  Contact:
    For questions or issues, please open an issue in the GitHub repository or 
    contact the owner directly.
  =============================================================================
*/

resource "aws_db_parameter_group" "this" {
  name        = var.parameter_group_name
  family      = var.parameter_group_family
  region      = var.parameter_group_region
  description = var.parameter_group_description

  #: default custom parameters for PostgreSQL
  parameter {
    name         = "rds.logical_replication"
    value        = "1"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "max_wal_senders"
    value        = "20"
    apply_method = "pending-reboot"
  }

  parameter {
    name         = "max_replication_slots"
    value        = "20"
    apply_method = "pending-reboot"
  }

  tags = {
    "Project"     = var.project_owner_tag
    "CreatedBy"   = var.created_by_tag
    "Environment" = var.environment_tag
    "CostCenter"  = var.cost_center_tag
    "Terraformed" = tostring(var.terraformed_tag)
  }
}