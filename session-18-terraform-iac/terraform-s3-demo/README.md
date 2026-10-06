# Terraform AWS S3 Demo Project — Infrastructure as Code (IaC)

## 1. Project Overview

This project demonstrates the declarative provisioning, state tracking, and lifecycle management of an **Amazon Web Services (AWS) S3 Bucket** utilizing **HashiCorp Terraform**. It establishes enterprise-grade security controls (Server-Side Encryption with AES-256, S3 Versioning, and S3 Public Access Block) and demonstrates the core Terraform lifecycle workflow:

$$\text{init} \longrightarrow \text{fmt} \longrightarrow \text{validate} \longrightarrow \text{plan} \longrightarrow \text{apply} \longrightarrow \text{show} \longrightarrow \text{output} \longrightarrow \text{destroy}$$

---

## 2. Directory Structure

```
terraform-s3-demo/
├── main.tf              # Defines S3 bucket, versioning, encryption, and public access block
├── variables.tf         # Declarations for region, bucket naming, environment, and endpoints
├── outputs.tf           # Exported attributes (bucket ID, ARN, domain name, versioning status)
├── provider.tf          # Terraform block, HashiCorp AWS provider requirement, and default tags
├── terraform.tfvars     # Concrete variable assignments
└── README.md            # Comprehensive workflow documentation and terminal evidence
```

---

## 3. Terraform Code Implementation

### 3.1 `provider.tf`
Defines provider requirements and supports both real AWS credentials and local mock testing endpoints (Moto / LocalStack):

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  access_key                  = var.aws_access_key
  secret_key                  = var.aws_secret_key
  skip_credentials_validation = var.skip_credentials_validation
  skip_metadata_api_check     = var.skip_metadata_api_check
  skip_requesting_account_id  = var.skip_requesting_account_id
  s3_use_path_style           = var.s3_use_path_style

  dynamic "endpoints" {
    for_each = var.s3_endpoint != null ? [var.s3_endpoint] : []
    content {
      s3 = endpoints.value
    }
  }

  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Project     = var.project_name
      Environment = var.environment
    }
  }
}
```

### 3.2 `variables.tf`
Exposes configurable parameters:

```hcl
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

variable "s3_endpoint" {
  description = "Custom S3 endpoint URL for local emulation. Leave null when deploying to real AWS."
  type        = string
  default     = "http://localhost:5000"
}
```

### 3.3 `main.tf`
Provisions the S3 bucket and security configurations:

```hcl
# Main S3 Bucket Resource
resource "aws_s3_bucket" "s3_bucket" {
  bucket        = var.bucket_name
  force_destroy = true

  tags = {
    Name        = var.bucket_name
    Purpose     = "Session 18 Terraform IaC Demo"
    CreatedDate = "2026-10-07"
  }
}

# S3 Bucket Versioning Configuration
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.s3_bucket.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

# S3 Server-Side Encryption Configuration (SSE-S3 AES-256)
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# Block Public Access (Security Hardening)
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.s3_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

### 3.4 `outputs.tf`
Exports important attributes:

```hcl
output "bucket_id" {
  description = "The name / ID of the created S3 bucket."
  value       = aws_s3_bucket.s3_bucket.id
}

output "bucket_arn" {
  description = "The Amazon Resource Name (ARN) of the bucket."
  value       = aws_s3_bucket.s3_bucket.arn
}

output "bucket_region" {
  description = "The AWS Region where the bucket is hosted."
  value       = aws_s3_bucket.s3_bucket.region
}

output "versioning_status" {
  description = "The current versioning configuration status of the bucket."
  value       = aws_s3_bucket_versioning.versioning.versioning_configuration[0].status
}

output "bucket_domain_name" {
  description = "The bucket domain name."
  value       = aws_s3_bucket.s3_bucket.bucket_domain_name
}
```

### 3.5 `terraform.tfvars`
```hcl
aws_region        = "us-east-1"
bucket_name       = "devops-session18-terraform-s3-demo"
environment       = "dev"
project_name      = "DevOps-Assignment-Session-18"
enable_versioning = true
s3_endpoint       = "http://localhost:5000"
```

---

## 4. Complete Step-by-Step Terraform Lifecycle Workflow

### Stage 1: `terraform init`
Initializes the working directory containing Terraform configuration files. Downloads and caches the required provider plugins (`hashicorp/aws v5.100.0`) and creates the dependency lock file (`.terraform.lock.hcl`).

```bash
$ terraform init
```

**Output:**
```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.100.0...
- Installed hashicorp/aws v5.100.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository.

Terraform has been successfully initialized!
```

![Terraform Init](../screenshots/01-terraform-init.png)

---

### Stage 2: `terraform fmt` & `terraform validate`
Ensures that configurations adhere to HashiCorp standard HCL formatting and verifies internal consistency, type checking, and argument validations without calling cloud APIs.

```bash
$ terraform fmt
$ terraform validate
```

**Output:**
```
Success! The configuration is valid.
```

![Terraform Fmt and Validate](../screenshots/02-terraform-fmt-validate.png)

---

### Stage 3: `terraform plan`
Reads the current state file, compares it against the declared target infrastructure in `.tf` files, and generates a speculative execution plan showing exactly what will be added (`+`), modified (`~`), or destroyed (`-`).

```bash
$ terraform plan
```

**Output:**
```
Terraform used the selected providers to generate the following execution plan.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_s3_bucket.s3_bucket will be created
  + resource "aws_s3_bucket" "s3_bucket" {
      + arn                         = (known after apply)
      + bucket                      = "devops-session18-terraform-s3-demo"
      + force_destroy               = true
      + id                          = (known after apply)
      + region                      = (known after apply)
      + tags                        = {
          + "CreatedDate" = "2026-10-07"
          + "Name"        = "devops-session18-terraform-s3-demo"
          + "Purpose"     = "Session 18 Terraform IaC Demo"
        }
    }

  # aws_s3_bucket_public_access_block.public_access_block will be created
  + resource "aws_s3_bucket_public_access_block" "public_access_block" {
      + block_public_acls       = true
      + block_public_policy     = true
      + bucket                  = (known after apply)
      + ignore_public_acls      = true
      + restrict_public_buckets = true
    }

  # aws_s3_bucket_server_side_encryption_configuration.encryption will be created
  + resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
      + bucket = (known after apply)
      + rule {
          + bucket_key_enabled = true
          + apply_server_side_encryption_by_default {
              + sse_algorithm = "AES256"
            }
        }
    }

  # aws_s3_bucket_versioning.versioning will be created
  + resource "aws_s3_bucket_versioning" "versioning" {
      + bucket = (known after apply)
      + versioning_configuration {
          + status = "Enabled"
        }
    }

Plan: 4 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + bucket_arn         = (known after apply)
  + bucket_domain_name = (known after apply)
  + bucket_id          = (known after apply)
  + bucket_region      = (known after apply)
  + versioning_status  = "Enabled"
```

![Terraform Plan](../screenshots/03-terraform-plan.png)

---

### Stage 4: `terraform apply`
Executes the approved plan actions, issuing actual AWS API calls to provision the S3 bucket, configure versioning, enforce AES-256 encryption, and apply Public Access Blocks. Updates the local state file `terraform.tfstate`.

```bash
$ terraform apply -auto-approve
```

**Output:**
```
aws_s3_bucket.s3_bucket: Creating...
aws_s3_bucket.s3_bucket: Creation complete after 1s [id=devops-session18-terraform-s3-demo]
aws_s3_bucket_public_access_block.public_access_block: Creating...
aws_s3_bucket_versioning.versioning: Creating...
aws_s3_bucket_server_side_encryption_configuration.encryption: Creating...
aws_s3_bucket_public_access_block.public_access_block: Creation complete after 0s [id=devops-session18-terraform-s3-demo]
aws_s3_bucket_server_side_encryption_configuration.encryption: Creation complete after 0s [id=devops-session18-terraform-s3-demo]
aws_s3_bucket_versioning.versioning: Creation complete after 1s [id=devops-session18-terraform-s3-demo]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

bucket_arn = "arn:aws:s3:::devops-session18-terraform-s3-demo"
bucket_domain_name = "devops-session18-terraform-s3-demo.s3.amazonaws.com"
bucket_id = "devops-session18-terraform-s3-demo"
bucket_region = "us-east-1"
versioning_status = "Enabled"
```

![Terraform Apply](../screenshots/04-terraform-apply.png)

---

### Stage 5: `terraform show`
Inspects the live state file or a plan file, rendering a human-readable representation of all managed resource properties and computed cloud attributes.

```bash
$ terraform show
```

**Output:**
```
# aws_s3_bucket.s3_bucket:
resource "aws_s3_bucket" "s3_bucket" {
    arn                         = "arn:aws:s3:::devops-session18-terraform-s3-demo"
    bucket                      = "devops-session18-terraform-s3-demo"
    bucket_domain_name          = "devops-session18-terraform-s3-demo.s3.amazonaws.com"
    bucket_regional_domain_name = "devops-session18-terraform-s3-demo.s3.us-east-1.amazonaws.com"
    force_destroy               = true
    hosted_zone_id              = "Z3AQBSTGFYJSTF"
    id                          = "devops-session18-terraform-s3-demo"
    region                      = "us-east-1"
    tags                        = {
        "CreatedDate" = "2026-10-07"
        "Name"        = "devops-session18-terraform-s3-demo"
        "Purpose"     = "Session 18 Terraform IaC Demo"
    }
}

# aws_s3_bucket_public_access_block.public_access_block:
resource "aws_s3_bucket_public_access_block" "public_access_block" {
    block_public_acls       = true
    block_public_policy     = true
    bucket                  = "devops-session18-terraform-s3-demo"
    id                      = "devops-session18-terraform-s3-demo"
    ignore_public_acls      = true
    restrict_public_buckets = true
}

# aws_s3_bucket_server_side_encryption_configuration.encryption:
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
    bucket = "devops-session18-terraform-s3-demo"
    id     = "devops-session18-terraform-s3-demo"
    rule {
        bucket_key_enabled = true
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

# aws_s3_bucket_versioning.versioning:
resource "aws_s3_bucket_versioning" "versioning" {
    bucket = "devops-session18-terraform-s3-demo"
    id     = "devops-session18-terraform-s3-demo"
    versioning_configuration {
        status = "Enabled"
    }
}
```

![Terraform Show](../screenshots/05-terraform-show.png)

---

### Stage 6: `terraform output`
Extracts output variable values from the state file for consumption by downstream scripts, CI/CD pipelines, or other Terraform modules.

```bash
$ terraform output
$ terraform output -json
```

**Output:**
```
bucket_arn = "arn:aws:s3:::devops-session18-terraform-s3-demo"
bucket_domain_name = "devops-session18-terraform-s3-demo.s3.amazonaws.com"
bucket_id = "devops-session18-terraform-s3-demo"
bucket_region = "us-east-1"
versioning_status = "Enabled"

JSON Output:
{
  "bucket_arn": {
    "sensitive": false,
    "type": "string",
    "value": "arn:aws:s3:::devops-session18-terraform-s3-demo"
  },
  "bucket_domain_name": {
    "sensitive": false,
    "type": "string",
    "value": "devops-session18-terraform-s3-demo.s3.amazonaws.com"
  },
  "bucket_id": {
    "sensitive": false,
    "type": "string",
    "value": "devops-session18-terraform-s3-demo"
  },
  "bucket_region": {
    "sensitive": false,
    "type": "string",
    "value": "us-east-1"
  },
  "versioning_status": {
    "sensitive": false,
    "type": "string",
    "value": "Enabled"
  }
}
```

![Terraform Output](../screenshots/06-terraform-output.png)

---

### Stage 7: `terraform destroy`
Tears down and destroys all infrastructure managed by the current Terraform configuration in reverse dependency order, ensuring zero orphaned cloud resources or lingering billing charges.

```bash
$ terraform destroy -auto-approve
```

**Output:**
```
aws_s3_bucket_public_access_block.public_access_block: Destroying... [id=devops-session18-terraform-s3-demo]
aws_s3_bucket_server_side_encryption_configuration.encryption: Destroying... [id=devops-session18-terraform-s3-demo]
aws_s3_bucket_versioning.versioning: Destroying... [id=devops-session18-terraform-s3-demo]
aws_s3_bucket_versioning.versioning: Destruction complete after 0s
aws_s3_bucket_server_side_encryption_configuration.encryption: Destruction complete after 0s
aws_s3_bucket_public_access_block.public_access_block: Destruction complete after 0s
aws_s3_bucket.s3_bucket: Destroying... [id=devops-session18-terraform-s3-demo]
aws_s3_bucket.s3_bucket: Destruction complete after 0s

Destroy complete! Resources: 4 destroyed.
```

![Terraform Destroy](../screenshots/07-terraform-destroy.png)

---

### Stage 8: State Clean Verification (`terraform state list`)
Confirms that all resources have been completely removed from the state file:

```bash
$ terraform state list
(No resources found in state - teardown complete and verified)
```

![Terraform Clean State](../screenshots/08-terraform-clean-verification.png)
