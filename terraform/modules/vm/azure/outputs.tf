output "instance_id" {
  value = azurerm_linux_virtual_machine.vm.id
}

output "private_ip" {
  value = azurerm_network_interface.vm.private_ip_address
}

output "public_ip" {
  value = var.enable_public_ip ? azurerm_public_ip.vm[0].ip_address : null
}

output "hostname" {
  value = local.resolved_hostname
}
