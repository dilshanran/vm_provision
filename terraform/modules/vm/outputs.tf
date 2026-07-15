output "instance_id" {
  description = "Cloud-native instance identifier (AWS instance ID or Azure VM resource ID)."
  value       = var.cloud_provider == "aws" ? module.aws[0].instance_id : module.azure[0].instance_id
}

output "private_ip" {
  description = "Primary private IP address of the VM."
  value       = var.cloud_provider == "aws" ? module.aws[0].private_ip : module.azure[0].private_ip
}

output "hostname" {
  description = "Configured hostname of the VM."
  value       = var.cloud_provider == "aws" ? module.aws[0].hostname : module.azure[0].hostname
}

output "cloud_provider" {
  description = "Cloud where the VM was provisioned."
  value       = var.cloud_provider
}
