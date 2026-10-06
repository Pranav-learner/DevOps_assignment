variable "aws_region" {
  description = "The target AWS Region where resources will be provisioned."
  type        = string
  default     = "us-east-1"
}

variable "bucket_name" {
  description = "Globally unique name for the S3 bucket."
  type        = string
  default     = "devops-session18-terraform-s3-demo"
}

variable "environment" {
  description = "Environment identifier (e.g., dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name tag for resource management."
  type        = string
  default     = "DevOps-Assignment-Session-18"
}

variable "enable_versioning" {
  description = "Whether to enable S3 bucket versioning."
  type        = bool
  default     = true
}

# Optional endpoint parameters for local testing (Moto / LocalStack)
variable "s3_endpoint" {
  description = "Custom S3 endpoint URL for local emulation. Leave null when deploying to real AWS."
  type        = string
  default     = "http://localhost:5000"
}

variable "aws_access_key" {
  description = "AWS Access Key ID (mock value for local development, real value or env var for AWS)."
  type        = string
  default     = "mock_access_key"
}

variable "aws_secret_key" {
  description = "AWS Secret Access Key (mock value for local development, real value or env var for AWS)."
  type        = string
  default     = "mock_secret_key"
  sensitive   = true
}

variable "skip_credentials_validation" {
  description = "Skip credentials validation against STS (useful for local mocks)."
  type        = bool
  default     = true
}

variable "skip_metadata_api_check" {
  description = "Skip metadata API check (useful for local development)."
  type        = bool
  default     = true
}

variable "skip_requesting_account_id" {
  description = "Skip requesting AWS account ID."
  type        = bool
  default     = true
}

variable "s3_use_path_style" {
  description = "Force path-style S3 requests (required for local S3 emulators)."
  type        = bool
  default     = true
}
