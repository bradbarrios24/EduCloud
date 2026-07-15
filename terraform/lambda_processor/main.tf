###############################################################################
# Lambda: lambda_processor
# Ubicada en la raíz de terraform/ (fuera de modules/) porque cada Lambda del
# proyecto se instancia como su propia carpeta hermana aquí mismo. Consume
# mensajes de SQS y envía correos vía SES, desplegada dentro de la subred
# privada de la VPC.
###############################################################################

# --- Empaquetado automático del código fuente --------------------------------

data "archive_file" "lambda_source" {
  count       = var.lambda_zip_path == null ? 1 : 0
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/dist/lambda_processor.zip"
}

locals {
  lambda_zip_path = var.lambda_zip_path != null ? var.lambda_zip_path : data.archive_file.lambda_source[0].output_path
  lambda_zip_hash = var.lambda_zip_path != null ? filebase64sha256(var.lambda_zip_path) : data.archive_file.lambda_source[0].output_base64sha256
}

# --- Rol de ejecución IAM de la Lambda -------------------------------------

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_exec" {
  name               = "${var.function_name}-exec-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = merge(
    var.tags,
    {
      Environment = var.environment
    }
  )
}

# Permisos: consumir/eliminar mensajes de SQS.
data "aws_iam_policy_document" "sqs_consume" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
    ]
    resources = [var.sqs_queue_arn]
  }
}

resource "aws_iam_role_policy" "sqs_consume" {
  name   = "${var.function_name}-sqs-consume"
  role   = aws_iam_role.lambda_exec.id
  policy = data.aws_iam_policy_document.sqs_consume.json
}

# Permisos: enviar correos via SES.
data "aws_iam_policy_document" "ses_send" {
  statement {
    effect    = "Allow"
    actions   = ["ses:SendEmail", "ses:SendRawEmail"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ses_send" {
  name   = "${var.function_name}-ses-send"
  role   = aws_iam_role.lambda_exec.id
  policy = data.aws_iam_policy_document.ses_send.json
}

# Permisos estandar de ejecucion en VPC (crear/gestionar ENIs).
resource "aws_iam_role_policy_attachment" "vpc_access" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# Permisos basicos de logs en CloudWatch.
resource "aws_iam_role_policy_attachment" "basic_execution" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# --- Espera de propagación de IAM --------------------------------------------
# AWS IAM tiene consistencia eventual: adjuntar politicas a un rol no es
# instantaneo. Si la Lambda (sobre todo con VPC config) se crea inmediatamente
# despues de adjuntar AWSLambdaVPCAccessExecutionRole, puede fallar con
# "InsufficientRolePermissions" porque el permiso todavia no propago.
# Este recurso fuerza una espera de 15s antes de crear la funcion.

resource "time_sleep" "wait_for_iam_propagation" {
  depends_on = [
    aws_iam_role_policy_attachment.vpc_access,
    aws_iam_role_policy_attachment.basic_execution,
    aws_iam_role_policy.sqs_consume,
    aws_iam_role_policy.ses_send,
  ]

  create_duration = "15s"
}

# --- Función Lambda ----------------------------------------------------------

resource "aws_lambda_function" "processor" {
  function_name = var.function_name
  role          = aws_iam_role.lambda_exec.arn
  runtime       = var.runtime
  handler       = var.handler
  memory_size   = var.memory_size
  timeout       = var.timeout

  filename         = local.lambda_zip_path
  source_code_hash = local.lambda_zip_hash

  vpc_config {
    subnet_ids         = [var.private_subnet_id]
    security_group_ids = [var.security_group_id]
  }

  environment {
    variables = var.environment_variables
  }

  tags = merge(
    var.tags,
    {
      Environment = var.environment
    }
  )

  depends_on = [
    time_sleep.wait_for_iam_propagation,
  ]
}

# --- Trigger: Event Source Mapping (SQS -> Lambda) --------------------------

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = var.sqs_queue_arn
  function_name    = aws_lambda_function.processor.arn
  batch_size       = var.batch_size
  enabled          = true
}