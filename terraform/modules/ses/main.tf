###############################################################################
# Módulo: ses
# Configura la identidad de envío en Amazon SES (dominio o email), genera
# los registros DNS necesarios (DKIM/SPF) y, opcionalmente, un Configuration
# Set para tracking de entregas/rebotes.
#
# NOTA (sandbox de SES): si la cuenta AWS esta en modo sandbox, los
# destinatarios tambien deben estar verificados hasta solicitar la salida
# del sandbox (AWS Support -> "Request production access").
###############################################################################

# --- Verificacion por DOMINIO (si var.domain esta definido) -----------------

resource "aws_ses_domain_identity" "this" {
  count  = var.domain != null ? 1 : 0
  domain = var.domain
}

resource "aws_ses_domain_dkim" "this" {
  count  = var.domain != null ? 1 : 0
  domain = aws_ses_domain_identity.this[0].domain
}

# --- Verificacion por EMAIL (si var.email esta definido) --------------------

resource "aws_ses_email_identity" "this" {
  count = var.email != null ? 1 : 0
  email = var.email
}

# --- Configuration Set opcional (tracking de entregas/rebotes) --------------

resource "aws_ses_configuration_set" "this" {
  count = var.enable_configuration_set ? 1 : 0
  name  = "${var.environment}-ses-config-set"
}

resource "aws_ses_event_destination" "cloudwatch" {
  count                  = var.enable_configuration_set ? 1 : 0
  name                   = "${var.environment}-ses-cloudwatch-destination"
  configuration_set_name = aws_ses_configuration_set.this[0].name
  enabled                = true
  matching_types         = ["send", "reject", "bounce", "complaint", "delivery"]

  cloudwatch_destination {
    default_value  = "default"
    dimension_name = "ses-event-type"
    value_source   = "messageTag"
  }
}