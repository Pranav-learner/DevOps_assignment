# Output values for downstream infrastructure & verification

output "vpc_id" {
  description = "The ID of the provisioned Virtual Private Cloud."
  value       = aws_vpc.main.id
}

output "vpc_cidr" {
  description = "The CIDR block allocated to the VPC."
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_id" {
  description = "The ID of the public subnet where the EC2 instance resides."
  value       = aws_subnet.public_subnet.id
}

output "security_group_id" {
  description = "The ID of the security group protecting the EC2 web server."
  value       = aws_security_group.web_sg.id
}

output "s3_bucket_name" {
  description = "The name of the created S3 storage bucket."
  value       = aws_s3_bucket.app_storage.id
}

output "s3_bucket_arn" {
  description = "The ARN of the S3 storage bucket."
  value       = aws_s3_bucket.app_storage.arn
}

output "ec2_instance_id" {
  description = "The ID of the deployed EC2 instance."
  value       = aws_instance.web.id
}

output "ec2_public_ip" {
  description = "The public IPv4 address assigned to the EC2 web instance."
  value       = aws_instance.web.public_ip
}

output "ec2_private_ip" {
  description = "The internal VPC private IP address of the EC2 instance."
  value       = aws_instance.web.private_ip
}

output "web_endpoint_url" {
  description = "The HTTP access URL for the deployed web application."
  value       = "http://${aws_instance.web.public_ip}"
}
