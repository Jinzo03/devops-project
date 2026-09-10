terraform {
  cloud {
    organization = "fastapi-aws-devops"

    workspaces {
      name = "fastapi-aws-devops"
    }
  }

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

  default_tags {
    tags = {
      Environment = var.environment
      Project     = "fastapi-devops-aws"
      ManagedBy   = "terraform"
    }
  }
}