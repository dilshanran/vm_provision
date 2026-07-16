resource_group_name  = "SYSENG-TFSTATE-rg" #azure resource group name
storage_account_name = "sysengtfstate01" #azure storage account name
container_name       = "tfstate" #Blob container name
key                  = "vm_provision\terraform\environments\dev\backend\azure.hcl" #terraform state file name
