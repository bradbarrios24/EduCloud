output "service_name" {
  value = aws_ecs_service.jenkins.name
}

output "security_group_id" {
  value = aws_security_group.jenkins.id
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.jenkins.name
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.jenkins.arn
}