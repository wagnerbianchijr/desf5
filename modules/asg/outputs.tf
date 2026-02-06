output "target_group_arns" {
  value       = [aws_autoscaling_group.this.target_group_arns]
  description = "List of Target Group ARNs"
}