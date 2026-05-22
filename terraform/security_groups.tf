resource "aws_security_group" "gateway" {
  name   = "alchemyst-gateway-sg"
  vpc_id = aws_vpc.main.id

  # HTTP API - public access
  ingress {
    from_port   = 3111
    to_port     = 3111
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "iii HTTP API"
  }

  # SSH - restricted to your IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.your_ip]
    description = "SSH from my IP only"
  }

  # iii engine WebSocket - only from within VPC
  # The inference worker connects TO this port from the private subnet
  ingress {
    from_port   = 49134
    to_port     = 49134
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
    description = "iii engine WebSocket from VPC"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "sg-gateway" }
}

resource "aws_security_group" "inference" {
  name   = "alchemyst-inference-sg"
  vpc_id = aws_vpc.main.id

  # SSH via gateway bastion only - no direct public access
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.gateway.id]
    description     = "SSH via gateway only"
  }

  # No inbound rule for 49134 - the inference worker makes outbound
  # connections to the gateway engine; nothing connects inbound here

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "sg-inference" }
}
