output "vpc_endpoint_id" {
  description = "ID del VPC Endpoint creado para SES"
  value       = aws_vpc_endpoint.ses.id
}