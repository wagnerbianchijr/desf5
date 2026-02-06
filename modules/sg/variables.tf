variable "vpc_id" {
  type    = string
  default = "my-vpc"
}

variable "sg_name" {
  type    = string
  default = "my-sg"
}

variable "ingress_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "egress_rules" {
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
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