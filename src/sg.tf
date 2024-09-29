resource "aws_security_group" "sg" {
  name        = "SG-${local.aws_project_name}"
  description = "Usado no EKS com 6/7SOAT"
  vpc_id      = data.aws_vpc.vpc.id

  # Inbound
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
  }

  ingress {
    description = "HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["172.31.0.0/16"]
  }

  # Outbound
  egress {
    description = "All"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
