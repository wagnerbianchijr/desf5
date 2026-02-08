output "aws_lb_endpoint_primary" {
  value = module.alb_primary.aws_lb_endpoint
}

output "sg_primary_asg_id" {
  value       = module.sg_primary_asg.security_group_id
  description = "ID do security group primário para ASG"
}

output "sg_primary_db_id" {
  value       = module.sg_primary_db.security_group_id
  description = "ID do security group primário para DB"
}

output "public_subnets_ids" {
  value       = module.vpc_primary.public_subnets_ids
  description = "IDs das subnets públicas"
}

output "private_subnets_ids" {
  value       = module.vpc_primary.private_subnets_ids
  description = "IDs das subnets privadas"
}

output "jumphost_ip" {
  value       = "ssh -A ubuntu@${aws_instance.jumpbox.public_ip}"
  description = "IP público do jumphost para acesso via SSH"
}