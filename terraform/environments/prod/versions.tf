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

# Real AWS provider. Credentials come from the environment (GitHub OIDC / AWS CLI).
# Skip validation so Azure-only runs (aws module count = 0) still init without AWS creds.
provider "aws" {
  region                      = var.region
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
}

provider "azurerm" {
  features {}
}
