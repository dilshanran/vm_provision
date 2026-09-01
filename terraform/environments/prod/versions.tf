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

# Both providers are always declared. On AWS runs, credentials come from
# GitHub OIDC / AWS CLI. On Azure-only runs the workflow stubs unused AWS
# credentials so this provider can still configure.
provider "aws" {
  region                      = var.region
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
}

# Azure credentials come from GitHub OIDC / Azure CLI (ARM_* env vars).
provider "azurerm" {
  features {}
}
