module "vm" {
  source   = "../../modules/vm"
  for_each = var.vms

  cloud_provider = var.cloud_provider
  hostname       = each.value.hostname
  environment    = "uat"
  instance_type  = each.value.instance_type
  region         = var.region
  subnet_id      = each.value.subnet_id
  tags           = var.tags
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

