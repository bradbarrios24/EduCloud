# ============================================
# MÓDULO: SonarQube en ECS Fargate (demo, Postgres sidecar, sin persistencia)
# ============================================

resource "aws_security_group" "sonarqube" {
  name        = "sonarqube-sg-${var.environment}"
  description = "Acceso a SonarQube solo desde IPs permitidas"
  vpc_id      = var.vpc_id

  ingress {
    description = "SonarQube UI"
    from_port   = 9000
    to_port     = 9000
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

resource "aws_cloudwatch_log_group" "sonarqube" {
  name              = "/ecs/sonarqube-${var.environment}"
  retention_in_days = 1

  tags = var.tags
}

resource "aws_ecs_task_definition" "sonarqube" {
  family                   = "sonarqube-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024 # SonarQube + Postgres necesitan esto como mínimo para arrancar
  memory                   = 3072
  execution_role_arn       = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "postgres"
      image     = "postgres:15-alpine"
      essential = true
      portMappings = [{ containerPort = 5432, protocol = "tcp" }]
      environment = [
        { name = "POSTGRES_USER", value = "sonar" },
        { name = "POSTGRES_PASSWORD", value = var.db_password },
        { name = "POSTGRES_DB", value = "sonarqube" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.sonarqube.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "postgres"
        }
      }
    },
    {
      name      = "sonarqube"
      image     = "sonarqube:community"
      essential = true
      portMappings = [{ containerPort = 9000, protocol = "tcp" }]
      environment = [
        { name = "SONAR_JDBC_URL", value = "jdbc:postgresql://localhost:5432/sonarqube" },
        { name = "SONAR_JDBC_USERNAME", value = "sonar" },
        { name = "SONAR_JDBC_PASSWORD", value = var.db_password },
        # Desactiva los chequeos de Elasticsearch (vm.max_map_count, ulimits)
        # que Fargate no permite ajustar a nivel de kernel del host.
        # SOLO para demo — en producción se ajustan esos límites en EC2/on-prem.
        { name = "SONAR_ES_BOOTSTRAP_CHECKS_DISABLE", value = "true" }
      ]
      dependsOn = [
        { containerName = "postgres", condition = "START" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.sonarqube.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "sonarqube"
        }
      }
    }
  ])

  tags = var.tags
}

resource "aws_ecs_service" "sonarqube" {
  name            = "sonarqube-${var.environment}"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.sonarqube.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [var.subnet_id]
    security_groups  = [aws_security_group.sonarqube.id]
    assign_public_ip = true
  }

  tags = var.tags
}