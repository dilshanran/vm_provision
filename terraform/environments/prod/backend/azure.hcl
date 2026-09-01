# Azure remote state (Storage account)
# Used by: ../../scripts/init-backend.sh azure

resource_group_name  = "SYSENG-TFSTATE-rg"
storage_account_name = "unixvmtest"
container_name       = "tfstate"
key                  = "vm-provision/prod/terraform.tfstate"
use_azuread_auth     = true
