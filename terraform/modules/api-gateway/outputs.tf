output "api_id" {
  description = "ID del API Gateway"
  value       = aws_api_gateway_rest_api.this.id
}

output "api_arn" {
  description = "ARN del API Gateway"
  value       = aws_api_gateway_rest_api.this.execution_arn
}

output "invoke_url" {
  description = "URL para invocar el API"
  value       = aws_api_gateway_stage.this.invoke_url
}

output "health_url" {
  description = "URL del endpoint de salud"
  value       = "${aws_api_gateway_stage.this.invoke_url}/api/health"
}

output "cursos_url" {
  description = "URL del endpoint de cursos"
  value       = "${aws_api_gateway_stage.this.invoke_url}/api/cursos"
}

output "mensajes_url" {
  description = "URL del endpoint de mensajes"
  value       = "${aws_api_gateway_stage.this.invoke_url}/api/mensajes"
}

output "apigw_sqs_role_arn" {
  description = "ARN del rol IAM usado por API Gateway para enviar mensajes a SQS"
  value       = aws_iam_role.apigw_sqs_send.arn
}

output "execution_arn" {
  description = "Execution ARN del API Gateway, usado para políticas IAM (execute-api:Invoke)"
  value       = aws_api_gateway_rest_api.this.execution_arn
}

output "rest_api_arn" {
  description = "ARN del REST API (para acciones de administración tipo apigateway:*, no execute-api:Invoke)"
  value       = aws_api_gateway_rest_api.this.arn
}