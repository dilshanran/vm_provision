locals {
  common_tags = merge(
    var.tags,
    {
      Environment = var.environment
      Hostname    = var.hostname
      ManagedBy   = "terraform-vm-provision"
    }
  )
}

# Select AWS or Azure submodule from cloud_provider.
module "aws" {
  source = "./aws"
  count  = var.cloud_provider == "aws" ? 1 : 0

  hostname               = var.hostname
  environment            = var.environment
  instance_type          = var.instance_type
  region                 = var.region
  subnet_id              = var.subnet_id
  tags                   = local.common_tags
  ami_id                 = try(var.aws_config.ami_id, null)
  vpc_security_group_ids = try(var.aws_config.vpc_security_group_ids, [])
  key_name               = try(var.aws_config.key_name, null)
  iam_instance_profile   = try(var.aws_config.iam_instance_profile, null)
  root_volume_size       = try(var.aws_config.root_volume_size, 30)
  root_volume_type       = try(var.aws_config.root_volume_type, "gp3")
}

module "azure" {
  source = "./azure"
  count  = var.cloud_provider == "azure" ? 1 : 0

  hostname            = var.hostname
  environment         = var.environment
  instance_type       = var.instance_type
  region              = var.region
  subnet_id           = var.subnet_id
  tags                = local.common_tags
  resource_group_name = try(var.azure_config.resource_group_name, "")
  admin_username      = try(var.azure_config.admin_username, "")
  ssh_public_key      = try(var.azure_config.ssh_public_key, "")
  image_publisher     = try(var.azure_config.image_publisher, "")
  image_offer         = try(var.azure_config.image_offer, "")
  image_sku           = try(var.azure_config.image_sku, "")
  image_version       = try(var.azure_config.image_version, "latest")
  os_disk_size_gb     = try(var.azure_config.os_disk_size_gb, 30)
  os_disk_type        = try(var.azure_config.os_disk_type, "Standard_LRS")
  enable_public_ip    = try(var.azure_config.enable_public_ip, false)
  plan_name           = try(var.azure_config.plan_name, null)
  plan_product        = try(var.azure_config.plan_product, null)
  plan_publisher      = try(var.azure_config.plan_publisher, null)
}
