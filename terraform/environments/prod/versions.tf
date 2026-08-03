terraform {
  required_version = ">= 1.5.0"

  required_providers {
    # AWS disabled while Azure-only. Uncomment when enabling AWS.
    # aws = {
    #   source  = "hashicorp/aws"
    #   version = ">= 5.0"
    # }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0"
    }
  }
}

# --- AWS provider (uncomment when enabling AWS) ---
# provider "aws" {
#   region = var.region
#
#   default_tags {
#     tags = {
#       Environment = "prod"
#       Project     = "vm-provision"
#       ManagedBy   = "terraform"
#     }
#   }
# }

provider "azurerm" {
  features {}
}
