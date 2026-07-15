###############################################################################
# Módulo: vpc_endpoints
# (Opcional pero recomendado) Crea un VPC Endpoint tipo Interface para SES
# dentro de la subred privada, evitando que la Lambda dependa del NAT
# Gateway para enviar correos. Reduce superficie de exposicion y puede
# abaratar costos de NAT en escenarios de alto trafico.
###############################################################################

resource "aws_vpc_endpoint" "ses" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.${var.region}.email-smtp"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [var.private_subnet_id]
  security_group_ids  = [var.security_group_id]
  private_dns_enabled = true

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-ses-vpc-endpoint"
      Environment = var.environment
    }
  )
}