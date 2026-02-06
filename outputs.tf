output "aws_lb_endpoint_primary" {
  value = module.alb_primary.aws_lb_endpoint
}

output "sg_primary_id" {
  value       = module.sg_primary.security_group_id
  description = "ID do security group primário"
}

output "private_subnets_ids" {
  value       = module.vpc_primary.private_subnets_ids
  description = "IDs das subnets privadas"
}