# EC2 Cloud Compute Instance
resource "aws_instance" "web" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              echo "Bootstrapping Final DevOps Cloud Compute Instance..."
              mkdir -p /var/www/html
              echo "<h1>Final DevOps Project - Cloud Platform Active</h1>" > /var/www/html/index.html
              EOF

  depends_on = [
    aws_internet_gateway.gw,
    aws_s3_bucket.storage,
    aws_route_table_association.public_assoc
  ]

  tags = {
    Name = "final-devops-ec2"
    Tier = "Compute"
  }
}
