output "vpc_id" {
  description = "ID de la VPC"
  value       = aws_vpc.main.id
}

output "private_subnet_id" {
  description = "ID de la subred privada (donde vive la Lambda)"
  value       = aws_subnet.private.id
}

output "public_subnet_id" {
  description = "ID de la subred publica (donde vive el NAT Gateway)"
  value       = aws_subnet.public.id
}

output "lambda_security_group_id" {
  description = "ID del Security Group de la Lambda"
  value       = aws_security_group.lambda.id
}

output "nat_gateway_id" {
  description = "ID del NAT Gateway"
  value       = aws_nat_gateway.main.id
}