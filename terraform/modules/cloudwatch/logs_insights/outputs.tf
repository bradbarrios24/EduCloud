output "log_group_name" {
  value = aws_cloudwatch_log_group.api_gateway.name
}

output "log_group_arn" {
  value = aws_cloudwatch_log_group.api_gateway.arn
}