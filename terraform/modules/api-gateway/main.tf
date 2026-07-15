# ============================================
# MÓDULO: API Gateway REST con Cognito Authorizer
# ============================================

# 1. REST API
resource "aws_api_gateway_rest_api" "this" {
  name        = var.api_name
  description = var.api_description

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = var.tags
}

# 2. COGNITO AUTHORIZER
resource "aws_api_gateway_authorizer" "cognito" {
  name                   = "cognito-authorizer"
  rest_api_id            = aws_api_gateway_rest_api.this.id
  type                   = "COGNITO_USER_POOLS"
  identity_source        = "method.request.header.Authorization"
  provider_arns          = [var.cognito_user_pool_arn]
}

# 3. RECURSO /api
resource "aws_api_gateway_resource" "api" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "api"
}

# 4. RECURSO /api/health (público, sin auth)
resource "aws_api_gateway_resource" "health" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.api.id
  path_part   = "health"
}

resource "aws_api_gateway_method" "health_get" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.health.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "health_get" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.health.id
  http_method             = aws_api_gateway_method.health_get.http_method
  type                    = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "health_get_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.health.id
  http_method = aws_api_gateway_method.health_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "health_get" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.health.id
  http_method = aws_api_gateway_method.health_get.http_method
  status_code = "200"

  response_templates = {
    "application/json" = "{\"status\": \"ok\", \"service\": \"EduCloud API\"}"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  depends_on = [aws_api_gateway_integration.health_get]
}

# 5. RECURSO /api/cursos (protegido con Cognito)
resource "aws_api_gateway_resource" "cursos" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.api.id
  path_part   = "cursos"
}

resource "aws_api_gateway_method" "cursos_get" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.cursos.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito.id
}

resource "aws_api_gateway_integration" "cursos_get" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.cursos.id
  http_method             = aws_api_gateway_method.cursos_get.http_method
  type                    = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "cursos_get_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.cursos.id
  http_method = aws_api_gateway_method.cursos_get.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "cursos_get" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.cursos.id
  http_method = aws_api_gateway_method.cursos_get.http_method
  status_code = "200"

  response_templates = {
    "application/json" = "{\"cursos\": [], \"message\": \"Lista de cursos EduCloud\"}"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  depends_on = [aws_api_gateway_integration.cursos_get]
}

# 6. CORS OPTIONS para /api/cursos
resource "aws_api_gateway_method" "cursos_options" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.cursos.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "cursos_options" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.cursos.id
  http_method = aws_api_gateway_method.cursos_options.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "cursos_options_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.cursos.id
  http_method = aws_api_gateway_method.cursos_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "cursos_options" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.cursos.id
  http_method = aws_api_gateway_method.cursos_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [aws_api_gateway_integration.cursos_options]
}

# 7. DEPLOYMENT
resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.api,
      aws_api_gateway_resource.health,
      aws_api_gateway_resource.cursos,
      aws_api_gateway_resource.mensajes,
      aws_api_gateway_method.health_get,
      aws_api_gateway_method.cursos_get,
      aws_api_gateway_method.cursos_options,
      aws_api_gateway_method.mensajes_post,
      aws_api_gateway_method.mensajes_options,
      aws_api_gateway_integration.mensajes_post,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

depends_on = [
    aws_api_gateway_integration.health_get,
    aws_api_gateway_integration.cursos_get,
    aws_api_gateway_integration.cursos_options,
    aws_api_gateway_integration.mensajes_post,
    aws_api_gateway_integration.mensajes_options,
  ]
}

# 8. STAGE
resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = var.stage_name

  xray_tracing_enabled = var.xray_tracing_enabled

  dynamic "access_log_settings" {
    for_each = var.log_group_arn != null ? [1] : []
    content {
      destination_arn = var.log_group_arn
      format = jsonencode({
        requestId       = "$context.requestId"
        ip               = "$context.identity.sourceIp"
        status           = "$context.status"
        path             = "$context.path"
        responseLatency  = "$context.responseLatency"
      })
    }
  }

  tags = var.tags
}

# ============================================
# 9. RECURSO /api/mensajes -> SQS (integración AWS, no proxy)
# ============================================

locals {
  # arn:aws:sqs:{region}:{account_id}:{queue_name}
  sqs_arn_parts   = split(":", var.sqs_queue_arn)
  sqs_region      = local.sqs_arn_parts[3]
  sqs_account_id  = local.sqs_arn_parts[4]
  sqs_queue_name  = local.sqs_arn_parts[5]
}

resource "aws_api_gateway_resource" "mensajes" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_resource.api.id
  path_part   = "mensajes"
}

resource "aws_api_gateway_method" "mensajes_post" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.mensajes.id
  http_method   = "POST"
  authorization = var.mensajes_requires_cognito_auth ? "COGNITO_USER_POOLS" : "NONE"
  authorizer_id = var.mensajes_requires_cognito_auth ? aws_api_gateway_authorizer.cognito.id : null
}

resource "aws_api_gateway_integration" "mensajes_post" {
  rest_api_id             = aws_api_gateway_rest_api.this.id
  resource_id             = aws_api_gateway_resource.mensajes.id
  http_method             = aws_api_gateway_method.mensajes_post.http_method
  type                    = "AWS" # Service integration, NO AWS_PROXY
  integration_http_method = "POST" # SQS siempre se invoca via POST, sin importar el método expuesto
  uri                     = "arn:aws:apigateway:${local.sqs_region}:sqs:path/${local.sqs_account_id}/${local.sqs_queue_name}"
  credentials             = aws_iam_role.apigw_sqs_send.arn
  passthrough_behavior    = "NEVER"

  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
  }

  request_templates = {
    "application/json" = file("${path.module}/templates/sqs_send_message_request.vtl")
  }
}

resource "aws_api_gateway_method_response" "mensajes_post_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.mensajes.id
  http_method = aws_api_gateway_method.mensajes_post.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "mensajes_post" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.mensajes.id
  http_method = aws_api_gateway_method.mensajes_post.http_method
  status_code = "200"

  response_templates = {
    "application/json" = "{\"message\": \"Mensaje encolado correctamente\"}"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }

  depends_on = [aws_api_gateway_integration.mensajes_post]
}

# CORS OPTIONS para /api/mensajes (mismo patrón que /api/cursos)
resource "aws_api_gateway_method" "mensajes_options" {
  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.mensajes.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "mensajes_options" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.mensajes.id
  http_method = aws_api_gateway_method.mensajes_options.http_method
  type        = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "mensajes_options_200" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.mensajes.id
  http_method = aws_api_gateway_method.mensajes_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "mensajes_options" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.mensajes.id
  http_method = aws_api_gateway_method.mensajes_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    "method.response.header.Access-Control-Allow-Methods" = "'POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [aws_api_gateway_integration.mensajes_options]
}