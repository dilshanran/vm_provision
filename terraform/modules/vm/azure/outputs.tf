output "instance_id" {
  value = azurerm_linux_virtual_machine.vm.id
}

output "private_ip" {
  value = azurerm_network_interface.vm.private_ip_address
}

output "hostname" {
  value = local.resolved_hostname
}
