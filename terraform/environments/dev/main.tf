# =============================================================================
# Dev — VM provisioning (AWS or Azure)
#
# Set cloud_provider in tfvars / TF_VARS:
#   "aws"   → uses aws_config
#   "azure" → uses azure_config
# =============================================================================

module "vm" {
  source   = "../../modules/vm"
  for_each = var.vms

  cloud_provider = var.cloud_provider
  hostname       = each.value.hostname
  environment    = "dev"
  instance_type  = each.value.instance_type
  region         = var.region
  subnet_id      = each.value.subnet_id
  tags           = var.tags

  # Cloud-specific (only the matching block is used)
  aws_config   = var.aws_config
  azure_config = var.azure_config
}

output "vms" {
  description = "Provisioned VM details keyed by VM identifier."
  value = {
    for key, vm in module.vm : key => {
      instance_id    = vm.instance_id
      private_ip     = vm.private_ip
      public_ip      = vm.public_ip
      hostname       = vm.hostname
      cloud_provider = vm.cloud_provider
    }
  }
}
