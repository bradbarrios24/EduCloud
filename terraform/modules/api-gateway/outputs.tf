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