data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "gateway" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.gateway.id]
  key_name               = var.key_pair_name

  tags = { Name = "alchemyst-gateway" }
}

resource "aws_eip" "gateway" {
  instance = aws_instance.gateway.id
  domain   = "vpc"
  tags     = { Name = "alchemyst-gateway-eip" }
}

resource "aws_instance" "inference" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "m7i-flex.large"
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.inference.id]
  key_name               = var.key_pair_name

  tags = { Name = "alchemyst-inference" }
}
