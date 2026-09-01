terraform {
  required_version = ">= 1.5.0"

  required_providers {
    # ---------------------------------------------------------------------------
    # AWS
    # ---------------------------------------------------------------------------
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }

    # ---------------------------------------------------------------------------
    # Azure
    # ---------------------------------------------------------------------------
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
}

# AWS — real credentials from env on AWS runs (GitHub OIDC / AWS CLI).
# On Azure-only runs the workflow stubs unused AWS env credentials so this
# provider can configure (both providers are always declared).
provider "aws" {
  region                      = var.region
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
}

# Azure — credentials from env (GitHub OIDC / Azure CLI).
provider "azurerm" {
  features {}
}
