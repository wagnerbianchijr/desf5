#: ALB variables
variable "load_balancer_name" {
  type = string
}
variable "load_balancer_internal" {
  type = bool
}
variable "load_balancer_type" {
  type = string
}
variable "load_balancer_security_groups" {
  type = list(string)
}
variable "load_balancer_subnets" {
  type = list(string)
}
variable "target_group_name" {
  type = string
}
variable "target_group_port" {
  type = number
}
variable "target_group_protocol" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "target_type" {
  type = string
}
variable "health_check_healthy_threshold" {
  type = number
}
variable "health_check_unhealthy_threshold" {
  type = number
}
variable "health_check_interval" {
  type = number
}
variable "health_check_path" {
  type = string
}
variable "health_check_port" {
  type = string
}
variable "health_check_protocol" {
  type = string
}
variable "health_check_timeout" {
  type = number
}
variable "listener_port" {
  type = number
}
variable "listener_name" {
  type = string
}
variable "listener_protocol" {
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