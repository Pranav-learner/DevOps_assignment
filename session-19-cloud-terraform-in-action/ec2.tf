# EC2 Web Application Server
resource "aws_instance" "web" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.web_sg.id]
  associate_public_ip_address = true

  # Cloud-Init User Data script bootstrapping web service
  user_data = <<-EOF
              #!/bin/bash
              echo "Starting Cloud Server Provisioning..."
              mkdir -p /var/www/html
              cat << 'PAGE' > /var/www/html/index.html
              <!DOCTYPE html>
              <html>
              <head><title>Session 19: Cloud & Terraform in Action</title></head>
              <body style="font-family: sans-serif; background: #0f172a; color: #f8fafc; text-align: center; padding: 50px;">
                <h1>Cloud Infrastructure Deployed via Terraform</h1>
                <p>Architecture: VPC + Public Subnet + Security Group + EC2 Web Server + S3 Storage</p>
                <p>Status: All 7 Cloud Resources Active</p>
              </body>
              </html>
              PAGE
              EOF

  # Explicit Resource Dependencies:
  # The EC2 instance explicitly depends on the Internet Gateway (for internet routing)
  # and the S3 Application Storage Bucket (for backend data availability).
  depends_on = [
    aws_internet_gateway.gw,
    aws_s3_bucket.app_storage,
    aws_route_table_association.public_assoc
  ]

  tags = {
    Name = "${var.project_name}-web-server"
    Role = "WebServer"
    Tier = "Compute"
  }
}
