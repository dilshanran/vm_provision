locals {
  nic_name = "${var.hostname}-nic"
  vm_name  = var.hostname
}

resource "azurerm_network_interface" "vm" {
  name                = local.nic_name
  location            = var.region
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = local.vm_name
  location            = var.region
  resource_group_name = var.resource_group_name
  size                = var.instance_type
  admin_username      = var.admin_username

  network_interface_ids = [
    azurerm_network_interface.vm.id,
  ]

  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    name                 = "${var.hostname}-os"
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  computer_name = substr(replace(var.hostname, "-", ""), 0, 15)

  tags = var.tags

  lifecycle {
    ignore_changes = [source_image_reference]
  }
}
