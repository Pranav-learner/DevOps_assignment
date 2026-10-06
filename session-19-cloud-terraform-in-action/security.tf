# Security Group for EC2 Web Server
resource "aws_security_group" "web_sg" {
  name        = "${var.project_name}-web-sg"
  description = "Controls inbound HTTP and SSH traffic, permits all outbound traffic"
  vpc_id      = aws_vpc.main.id

  # HTTP Ingress (Port 80)
  ingress {
    description = "Allow inbound HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH Ingress (Port 22)
  ingress {
    description = "Allow inbound SSH for administration"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound Egress (All Traffic)
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-web-sg"
    Tier = "Security"
  }
}
