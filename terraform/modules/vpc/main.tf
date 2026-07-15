###############################################################################
# Módulo: vpc
# Crea la VPC principal, subredes pública/privada, Internet Gateway, NAT
# Gateway, tablas de rutas y el Security Group para la Lambda procesadora.
###############################################################################

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-vpc"
      Environment = var.environment
    }
  )
}

# Subred privada: sin ruta directa a Internet Gateway. Aquí vivirá la Lambda.
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = var.availability_zone

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-private-subnet"
      Environment = var.environment
      Tier        = "private"
    }
  )
}

# Subred pública: tiene ruta a Internet Gateway. Aloja el NAT Gateway.
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block               = var.public_subnet_cidr
  availability_zone        = var.availability_zone
  map_public_ip_on_launch  = true

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-public-subnet"
      Environment = var.environment
      Tier        = "public"
    }
  )
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-igw"
      Environment = var.environment
    }
  )
}

# Elastic IP requerida por el NAT Gateway.
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-nat-eip"
      Environment = var.environment
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# NAT Gateway ubicado dentro de la subred pública.
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-nat-gateway"
      Environment = var.environment
    }
  )

  depends_on = [aws_internet_gateway.main]
}

# Tabla de rutas privada: 0.0.0.0/0 -> NAT Gateway.
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-private-rt"
      Environment = var.environment
    }
  )
}

# Tabla de rutas pública: 0.0.0.0/0 -> Internet Gateway.
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-public-rt"
      Environment = var.environment
    }
  )
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security Group para la Lambda: egress hacia SES/SQS, ingress solo desde
# dentro de la VPC.
resource "aws_security_group" "lambda" {
  name        = "${var.environment}-lambda-sg"
  description = "Security Group para la Lambda procesadora (SES/SQS)"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "Salida hacia SES/SQS y otros servicios AWS"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Trafico entrante solo desde dentro de la VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment}-lambda-sg"
      Environment = var.environment
    }
  )
}