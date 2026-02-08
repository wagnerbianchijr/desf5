variable "asg_project_name" {
  type        = string
  description = "ASG instances name"
}

variable "asg_prefix" {
  type        = string
  description = "Prefix for instances Name tag"
}

variable "asg_ami" {
  type        = string
  description = "Linux AMI we're gonna use"
}

variable "asg_instance_type" {
  type        = string
  description = "Instance type for ASG boxes"
}

variable "asg_desired_capacity" {
  type        = number
  description = "ASG desired capacity"
}

variable "asg_max_size" {
  type        = number
  description = "ASG maximum size"
}

variable "asg_min_size" {
  type        = number
  description = "ASG minimum size"
}

#variable "server_port" {
#  type        = number
#  description = "Instances port for the httpd"
#}

#variable "security_group_name" {
#  type        = string
#  description = "Security Group name to be attached to the ASG instances"
#}

variable "target_group_arns" {
  description = "ARN of the ALB target group to attach to ASG"
  type        = list(string)
}

variable "security_group_id" {
  type        = string
  description = "Security Group ID to be attached to the ASG instances"
}

#variable "public_subnets_cidr_blocks" {
#  type        = list(string)
#  description = "Mapa de CIDR blocks para subnets publicas"
#}

variable "private_subnets_cidr_blocks" {
  type        = list(string)
  description = "Mapa de CIDR blocks para subnets privadas"
}

#variable "availability_zones" {
#  type        = list(string)
#  description = "Lista de zonas de disponibilidade"
#}

# -----------------------------------------------------------------
#: tags variables
# -----------------------------------------------------------------
variable "project_owner_tag" {
  type        = string
  description = "Project's owner"
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