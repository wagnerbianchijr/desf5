variable "region" {
  type = string
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