variable "aws_region" {
  description = "Target AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment identifier"
  type        = string
  default     = "production"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability zone for public subnet"
  type        = string
  default     = "us-east-1a"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
  default     = "ami-0c55b159cbfafe1f0"
}

variable "bucket_name" {
  description = "Name for the S3 bucket"
  type        = string
  default     = "final-devops-project-storage-vault"
}

variable "enable_versioning" {
  description = "Enable S3 versioning"
  type        = bool
  default     = true
}

variable "aws_endpoint" {
  description = "Endpoint for local AWS emulation. Set to null for real AWS"
  type        = string
  default     = "http://localhost:5000"
}

variable "aws_access_key" {
  type      = string
  default   = "mock_key"
}

variable "aws_secret_key" {
  type      = string
  default   = "mock_secret"
  sensitive = true
}

variable "skip_credentials_validation" {
  type    = bool
  default = true
}

variable "skip_metadata_api_check" {
  type    = bool
  default = true
}

variable "skip_requesting_account_id" {
  type    = bool
  default = true
}

variable "s3_use_path_style" {
  type    = bool
  default = true
}
