# Partial remote state backend — Azure-only for now.
#
#   terraform init -reconfigure -backend-config=backend/azure.hcl
#   ../../scripts/init-backend.sh azure
#
terraform {
  backend "azurerm" {}
}

# --- AWS S3 backend (uncomment when enabling AWS; comment azurerm block above) ---
# terraform {
#   backend "s3" {}
# }
