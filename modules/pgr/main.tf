# -----------------------------------------------------------
#: RDS Parameter Group
# -----------------------------------------------------------
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