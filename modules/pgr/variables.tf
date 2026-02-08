variable "parameter_group_name" {
  type        = string
  description = "Name of the RDS Parameter Group"
}

variable "parameter_group_family" {
  type        = string
  description = "Family of the RDS Parameter Group"
}

variable "parameter_group_region" {
  type        = string
  description = "Region of the RDS Parameter Group"
}

variable "parameter_group_description" {
  type        = string
  description = "Description of the RDS Parameter Group"
}

# -----------------------------------------------------------------
#: tags variables
# -----------------------------------------------------------------
variable "project_owner_tag" {
  type        = string
  description = "Project's owner"
  default     = "Terraform Team"
}

variable "created_by_tag" {
  type        = string
  description = "The resources creator"
}

variable "environment_tag" {
  type        = string
  description = "Primary or Secondary (DR) environment"
}

variable "cost_center_tag" {
  type        = string
  description = "Cost center"
}

variable "terraformed_tag" {
  type    = bool
  default = true
}