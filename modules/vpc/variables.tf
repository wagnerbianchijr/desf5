variable "vpc_name" {
  type    = string
  default = "my-vpc"
}

variable "igw_name" {
  type    = string
  default = "my-igw"
}

variable "rt_name" {
  type    = string
  default = "my-rt"
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR Block used on this VPC"
}

variable "public_subnets_cidr_blocks" {
  type        = list(string)
  description = "Mapa de CIDR blocks para subnets publicas"
}

variable "private_subnets_cidr_blocks" {
  type        = list(string)
  description = "Mapa de CIDR blocks para subnets privadas"
}

variable "availability_zones" {
  type        = list(string)
  description = "Lista de zonas de disponibilidade"
}

variable "kms_key_id" {
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