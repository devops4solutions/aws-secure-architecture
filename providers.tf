terraform {
  backend "s3" {}
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Automation = true
      Team       = "DevOps"
      User       = "Managed by Terraform"
    }
  }
}