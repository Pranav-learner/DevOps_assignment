output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "The ID of the public subnet"
  value       = aws_subnet.public_subnet.id
}

output "security_group_id" {
  description = "The ID of the web security group"
  value       = aws_security_group.web_sg.id
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.web.public_ip
}

output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.storage.arn
}

output "s3_bucket_id" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.storage.id
}
