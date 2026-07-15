terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
}

provider "aws" {
  region = var.cloud_provider == "aws" ? var.region : "us-east-1"

  default_tags {
    tags = {
      Environment = "prod"
      Project     = "vm-provision"
      ManagedBy   = "terraform"
    }
  }
}

provider "azurerm" {
  features {}
}
