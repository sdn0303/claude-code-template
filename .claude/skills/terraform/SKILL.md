---
name: terraform
description: Terraform best practices for infrastructure as code. Use when writing or reviewing Terraform configurations for AWS, GCP, or Azure.
---

# Terraform Development Skill

Best practices for Infrastructure as Code with Terraform.

## Project Structure

```
terraform/
├── environments/
│   ├── dev/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── terraform.tfvars
│   │   └── backend.tf
│   ├── staging/
│   └── prod/
├── modules/
│   ├── networking/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── compute/
│   └── database/
└── README.md
```

## Module Structure

```
module/
├── main.tf           # Primary resources
├── variables.tf      # Input variables
├── outputs.tf        # Output values
├── versions.tf       # Provider constraints
├── README.md         # Documentation
├── examples/         # Usage examples
│   └── basic/
│       └── main.tf
└── tests/           # Module tests
```

## Naming Conventions

### Resources
```hcl
# Use underscores, be descriptive
resource "aws_s3_bucket" "main" {}
resource "aws_s3_bucket" "logs" {}

# For single resource of type, use "main"
resource "google_compute_network" "main" {}

# For multiple, use descriptive names
resource "google_compute_subnetwork" "private" {}
resource "google_compute_subnetwork" "public" {}
```

### Variables
```hcl
variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "enable_apis" {
  description = "Whether to enable required APIs"
  type        = bool
  default     = true
}
```

### Outputs
```hcl
output "vpc_id" {
  description = "ID of the created VPC"
  value       = google_compute_network.main.id
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value = {
    for name, subnet in google_compute_subnetwork.subnets :
    name => subnet.id
  }
}
```

## Version Constraints

```hcl
# versions.tf
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0.0, < 6.0.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

## Backend Configuration

```hcl
# backend.tf
terraform {
  backend "gcs" {
    bucket = "project-terraform-state"
    prefix = "environments/dev"
  }
}

# For AWS
terraform {
  backend "s3" {
    bucket         = "project-terraform-state"
    key            = "environments/dev/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

## Module Usage

### Using Public Modules
```hcl
# GCP
module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 9.0"

  project_id   = var.project_id
  network_name = "main-vpc"
  
  subnets = [
    {
      subnet_name   = "private"
      subnet_ip     = "10.0.0.0/24"
      subnet_region = var.region
    }
  ]
}

# AWS
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "main-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-1a", "us-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]
}
```

### Creating Custom Modules
```hcl
# modules/gke-cluster/main.tf
resource "google_container_cluster" "main" {
  name     = var.cluster_name
  location = var.region
  
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.network
  subnetwork = var.subnetwork

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_cidr
  }
}

# modules/gke-cluster/variables.tf
variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
}

variable "network" {
  description = "VPC network self_link"
  type        = string
}
```

## Best Practices

### State Management
```hcl
# Use remote state for teams
# Never commit .tfstate files
# Enable state locking

# Reference remote state
data "terraform_remote_state" "networking" {
  backend = "gcs"
  config = {
    bucket = "project-terraform-state"
    prefix = "networking"
  }
}
```

### Resource Dependencies
```hcl
# Implicit (preferred)
resource "google_compute_instance" "web" {
  network_interface {
    network = google_compute_network.main.id  # Implicit dependency
  }
}

# Explicit (when needed)
resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
}

resource "google_compute_instance" "web" {
  depends_on = [google_project_service.compute]
}
```

### Data Sources
```hcl
# Fetch existing resources
data "google_project" "current" {}

data "google_compute_zones" "available" {
  region = var.region
}

# Use in resources
resource "google_compute_instance" "web" {
  zone = data.google_compute_zones.available.names[0]
}
```

### Locals
```hcl
locals {
  environment = var.environment
  project     = var.project_id
  
  common_labels = {
    environment = local.environment
    managed_by  = "terraform"
    project     = local.project
  }
  
  name_prefix = "${local.project}-${local.environment}"
}

resource "google_compute_network" "main" {
  name = "${local.name_prefix}-vpc"
}
```

## Security

### Secret Management
```hcl
# Never hardcode secrets
# Use secret manager
data "google_secret_manager_secret_version" "db_password" {
  secret = "db-password"
}

# Or environment variables
variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}
```

### IAM Best Practices
```hcl
# Use least privilege
resource "google_project_iam_member" "service_account" {
  project = var.project_id
  role    = "roles/storage.objectViewer"  # Specific role
  member  = "serviceAccount:${google_service_account.main.email}"
}
```

## Commands

```bash
# Initialize
terraform init

# Validate
terraform validate

# Format
terraform fmt -recursive

# Plan
terraform plan -out=tfplan

# Apply
terraform apply tfplan

# Destroy (careful!)
terraform destroy

# State management
terraform state list
terraform state show <resource>
terraform import <resource> <id>
```

## Testing

```hcl
# tests/main.tftest.hcl
run "validate_vpc" {
  command = plan

  assert {
    condition     = google_compute_network.main.name == "test-vpc"
    error_message = "VPC name mismatch"
  }
}
```
