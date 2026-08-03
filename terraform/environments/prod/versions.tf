terraform {
  required_version = ">= 1.5.0"

  required_providers {
    # Still required by modules/vm (aws submodule uses count = 0 for Azure).
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

# Stub AWS provider for Azure-only runs.
# The root module must configure aws because modules/vm declares it, even when
# no AWS resources are created. Replace with real auth when enabling AWS.
provider "aws" {
  region                      = "us-east-1"
  access_key                  = "mock"
  secret_key                  = "mock"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true
}

provider "azurerm" {
  features {}
}
