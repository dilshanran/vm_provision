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

  # aws_config = var.aws_config  # AWS disabled — Azure-only testing
  azure_config = var.azure_config
}

output "vms" {
  description = "Provisioned VM details keyed by VM identifier."
  value = {
    for key, vm in module.vm : key => {
      instance_id    = vm.instance_id
      private_ip     = vm.private_ip
      hostname       = vm.hostname
      cloud_provider = vm.cloud_provider
    }
  }
}
