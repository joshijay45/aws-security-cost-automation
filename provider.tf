terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region


    default_tags {
        tags = {
            project = var.project_name
            enviornment = var.enviornment
            Managedby = "Terraform"
        }
    }
}