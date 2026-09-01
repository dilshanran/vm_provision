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

# AWS — credentials from env (GitHub OIDC / AWS CLI).
# Skip checks so Azure-only runs can still init without AWS credentials.
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
