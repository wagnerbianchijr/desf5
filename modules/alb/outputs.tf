output "target_group_arns" {
  value = [aws_lb_target_group.this.arn]
}

output "aws_lb_endpoint" {
  value = aws_lb.this.dns_name
}