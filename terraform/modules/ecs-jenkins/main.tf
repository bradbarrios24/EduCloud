# ============================================
# MÓDULO: Jenkins en ECS Fargate (demo, sin persistencia)
# ============================================

resource "aws_security_group" "jenkins" {
  name        = "jenkins-sg-${var.environment}"
  description = "Acceso a Jenkins solo desde IPs permitidas"
  vpc_id      = var.vpc_id

  ingress {
    description = "Jenkins UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  ingress {
    description = "Jenkins agent (JNLP)"
    from_port   = 50000
    to_port     = 50000
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

resource "aws_cloudwatch_log_group" "jenkins" {
  name              = "/ecs/jenkins-${var.environment}"
  retention_in_days = 1 # demo — no necesitas retención larga

  tags = var.tags
}

resource "aws_ecs_task_definition" "jenkins" {
  family                   = "jenkins-${var.environment}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = var.execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "jenkins"
      image     = "jenkins/jenkins:lts"
      essential = true
      portMappings = [
        { containerPort = 8080, protocol = "tcp" },
        { containerPort = 50000, protocol = "tcp" }
      ]
      environment = [
        # Evita que Jenkins muestre el wizard de plugins sugeridos en cada
        # reinicio de la tarea. Sin volumen persistente, cada vez que la
        # tarea se recrea, Jenkins vuelve a estado inicial (aceptable para demo).
        { name = "JAVA_OPTS", value = "-Djenkins.install.runSetupWizard=${var.skip_setup_wizard ? "false" : "true"}" }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.jenkins.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "jenkins"
        }
      }
    }
  ])

  tags = var.tags
}

resource "aws_ecs_service" "jenkins" {
  name            = "jenkins-${var.environment}"
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.jenkins.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [var.subnet_id]
    security_groups  = [aws_security_group.jenkins.id]
    assign_public_ip = true # necesario: sin ALB, la tarea necesita IP pública propia
  }

  tags = var.tags
}