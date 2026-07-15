# ============================================
# IAM: rol para que API Gateway invoque SQS SendMessage
# Distinto del rol de ejecución de lambda_processor (ese consume la cola;
# este solo tiene permiso de encolar mensajes).
# ============================================

data "aws_iam_policy_document" "apigw_sqs_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "apigw_sqs_send" {
  name               = "${var.api_name}-apigw-sqs-send-role"
  assume_role_policy = data.aws_iam_policy_document.apigw_sqs_assume_role.json

  tags = var.tags
}

data "aws_iam_policy_document" "apigw_sqs_send_policy" {
  statement {
    effect    = "Allow"
    actions   = ["sqs:SendMessage"]
    resources = [var.sqs_queue_arn] # cola principal únicamente, nunca la DLQ ni "*"
  }
}

resource "aws_iam_role_policy" "apigw_sqs_send" {
  name   = "${var.api_name}-apigw-sqs-send-policy"
  role   = aws_iam_role.apigw_sqs_send.id
  policy = data.aws_iam_policy_document.apigw_sqs_send_policy.json
}