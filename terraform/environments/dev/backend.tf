terraform {
  backend "s3" {
    bucket         = "unix-team-terraform-state"
    key            = "vm-provision/dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "unix-team-terraform-locks"
  }
}

# Alternative Azure-native backend (uncomment and comment S3 block above when using Azure-only state):
#
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "rg-terraform-state"
#     storage_account_name = "unixteamtfstate"
#     container_name       = "tfstate"
#     key                  = "vm-provision/dev/terraform.tfstate"
#   }
# }
