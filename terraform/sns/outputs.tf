output "topic_arn" {
  description = "ARN del tópico SNS"
  value       = aws_sns_topic.this.arn
}

output "topic_name" {
  description = "Nombre del tópico SNS"
  value       = aws_sns_topic.this.name
}