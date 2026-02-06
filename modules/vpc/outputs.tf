#: exposiong vpc_id output from vpc module so
#: other modules can use it (e.g., sg module)
output "vpc_id" {
  value       = aws_vpc.main.id
  description = "vpc_id"
}

#: internet gateway id
output "internet_gateway_id" {
  value       = aws_internet_gateway.igw.id
  description = "Internet Gateway ID"
}

#: public route table id
output "public_route_table_id" {
  value       = aws_route_table.public.id
  description = "Public Route Table ID"
}

#: private route table ids
output "private_route_table_ids" {
  value       = aws_route_table.private[*].id
  description = "List of Private Route Table IDs"
}

#: public subnets ids
output "public_subnets_ids" {
  value       = aws_subnet.public[*].id
  description = "List of public subnets ids"
}

#: private subnets ids
output "private_subnets_ids" {
  value       = aws_subnet.private[*].id
  description = "List of private subnets ids"
}

