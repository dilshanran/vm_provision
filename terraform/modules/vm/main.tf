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

module "aws" {
  source = "./aws"
  count  = var.cloud_provider == "aws" ? 1 : 0

  hostname               = var.hostname
  environment            = var.environment
  instance_type          = var.instance_type
  region                 = var.region
  subnet_id              = var.subnet_id
  tags                   = local.common_tags
  ami_id                 = var.aws_config.ami_id
  vpc_security_group_ids = var.aws_config.vpc_security_group_ids
  key_name               = var.aws_config.key_name
  iam_instance_profile   = var.aws_config.iam_instance_profile
  root_volume_size       = var.aws_config.root_volume_size
  root_volume_type       = var.aws_config.root_volume_type
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
  resource_group_name = var.azure_config.resource_group_name
  admin_username      = var.azure_config.admin_username
  ssh_public_key      = var.azure_config.ssh_public_key
  image_publisher     = var.azure_config.image_publisher
  image_offer         = var.azure_config.image_offer
  image_sku           = var.azure_config.image_sku
  image_version       = var.azure_config.image_version
  os_disk_size_gb     = var.azure_config.os_disk_size_gb
  os_disk_type        = var.azure_config.os_disk_type
}
