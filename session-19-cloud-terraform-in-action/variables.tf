variable "aws_region" {
  description = "Target AWS Region for provisioning infrastructure."
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment identifier (e.g. dev, staging, production)."
  type        = string
  default     = "production"
}

variable "project_name" {
  description = "Project name tag for resource organization and governance."
  type        = string
  default     = "Cloud-IaC-In-Action"
}

# --- VPC & Networking Variables ---
variable "vpc_cidr" {
  description = "IPv4 CIDR block allocated to the Virtual Private Cloud."
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "IPv4 CIDR block allocated to the public subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone" {
  description = "Availability Zone mapped to the public subnet."
  type        = string
  default     = "us-east-1a"
}

# --- Compute Variables ---
variable "instance_type" {
  description = "EC2 instance size / type."
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "Amazon Machine Image (AMI) ID for launching the EC2 web instance."
  type        = string
  default     = "ami-0c55b159cbfafe1f0"
}

# --- Storage Variables ---
variable "bucket_name" {
  description = "Globally unique name for the S3 cloud storage bucket."
  type        = string
  default     = "devops-session19-cloud-assets"
}

variable "enable_versioning" {
  description = "Flag to enable S3 bucket object versioning."
  type        = bool
  default     = true
}

# --- Local Emulation / Provider Credentials ---
variable "aws_endpoint" {
  description = "Custom AWS endpoint for local development (Moto / LocalStack). Set to null for real AWS."
  type        = string
  default     = "http://localhost:5000"
}

variable "aws_access_key" {
  description = "AWS Access Key ID."
  type        = string
  default     = "mock_access_key"
}

variable "aws_secret_key" {
  description = "AWS Secret Access Key."
  type        = string
  default     = "mock_secret_key"
  sensitive   = true
}

variable "skip_credentials_validation" {
  description = "Skip AWS credentials validation."
  type        = bool
  default     = true
}

variable "skip_metadata_api_check" {
  description = "Skip AWS metadata API check."
  type        = bool
  default     = true
}

variable "skip_requesting_account_id" {
  description = "Skip AWS account ID lookup."
  type        = bool
  default     = true
}

variable "s3_use_path_style" {
  description = "Enable S3 path-style URL addressing."
  type        = bool
  default     = true
}
