# ============================================
# MÓDULO: Grafana en ECS Fargate (demo, sin persistencia)
# ============================================

resource "aws_security_group" "grafana" {
  name        = "grafana-sg-${var.environment}"
  description = "Acceso a Grafana solo desde IPs permitidas"
  vpc_id      = var.vpc_id

  ingress {
    description = "Grafana UI"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "grafana" {
  name              = "/ecs/grafana-${var.environment}"
  retention_in_days = 1 # demo — no necesitas retención larga

  tags = var.tags
}

resource "aws_ecs_task_definition" "grafana" {
  family                   = "grafana-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "grafana"
      image     = "grafana/grafana:latest"
      essential = true
      portMappings = [{
        containerPort = 3000
        protocol      = "tcp"
      }]
      environment = [
        { name = "GF_SECURITY_ADMIN_USER", value = var.admin_user },
        { name = "GF_SECURITY_ADMIN_PASSWORD", value = var.admin_password },
        # Sin volumen persistente: al reiniciar la tarea se pierden dashboards
        # custom que no estén provisionados por config. Aceptable para demo.
        { name = "GF_AUTH_ANONYMOUS_ENABLED", value = "false" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.grafana.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "grafana"
        }
      }
    }
  ])

  tags = var.tags
}

resource "aws_ecs_service" "grafana" {
  name            = "grafana-${var.environment}"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.grafana.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [var.subnet_id]
    security_groups  = [aws_security_group.grafana.id]
    assign_public_ip = true # necesario: sin ALB, la tarea necesita IP pública propia
  }

  tags = var.tags
}