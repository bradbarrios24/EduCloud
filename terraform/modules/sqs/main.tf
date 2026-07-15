###############################################################################
# Módulo: sqs
# Crea la cola principal SQS y su Dead Letter Queue (DLQ), configura la
# política de redrive (tras N reintentos -> DLQ) y, opcionalmente, la
# política de acceso para que API Gateway pueda invocar SendMessage.
###############################################################################

# Dead Letter Queue: recibe los mensajes que fallaron tras N reintentos.
resource "aws_sqs_queue" "dlq" {
  name                      = var.dlq_name
  message_retention_seconds = var.message_retention_seconds

  tags = merge(
    var.tags,
    {
      Name        = var.dlq_name
      Environment = var.environment
    }
  )
}

# Cola principal: recibe los mensajes desde API Gateway y dispara la Lambda.
resource "aws_sqs_queue" "main" {
  name                       = var.queue_name
  message_retention_seconds  = var.message_retention_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds

  # Tras N reintentos (maxReceiveCount) el mensaje se mueve a la DLQ.
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount      = var.max_receive_count
  })

  tags = merge(
    var.tags,
    {
      Name        = var.queue_name
      Environment = var.environment
    }
  )
}

# Política de acceso opcional: permite que el rol de API Gateway envíe
# mensajes (SendMessage) a la cola principal.
data "aws_iam_policy_document" "queue_policy" {
  count = var.api_gateway_role_arn != null ? 1 : 0

  statement {
    sid    = "AllowApiGatewaySendMessage"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [var.api_gateway_role_arn]
    }

    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.main.arn]
  }
}

resource "aws_sqs_queue_policy" "main" {
  count     = var.api_gateway_role_arn != null ? 1 : 0
  queue_url = aws_sqs_queue.main.id
  policy    = data.aws_iam_policy_document.queue_policy[0].json
}