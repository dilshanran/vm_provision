locals {
  nic_name = "${var.hostname}-nic"
  vm_name  = var.hostname
  nsg_name = "${var.hostname}-nsg"
  pip_name = "${var.hostname}-pip"
}

resource "azurerm_public_ip" "vm" {
  count = var.enable_public_ip ? 1 : 0

  name                = local.pip_name
  location            = var.region
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = var.tags
}

resource "azurerm_network_security_group" "vm" {
  count = local.nsg_required ? 1 : 0

  name                = local.nsg_name
  location            = var.region
  resource_group_name = var.resource_group_name

  dynamic "security_rule" {
    for_each = var.enable_public_ip ? [1] : []

    content {
      name                       = "AllowSSH"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
    }
  }

  dynamic "security_rule" {
    for_each = local.syslog_rule_required ? [1] : []

    content {
      name                       = "AllowSyslogUDP"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Udp"
      source_port_range          = "*"
      destination_port_range     = "514"
      source_address_prefixes    = var.syslog_source_address_prefixes
      destination_address_prefix = "*"
    }
  }

  tags = var.tags
}

resource "azurerm_network_interface" "vm" {
  name                = local.nic_name
  location            = var.region
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.enable_public_ip ? azurerm_public_ip.vm[0].id : null
  }

  tags = var.tags
}

resource "azurerm_network_interface_security_group_association" "vm" {
  count = local.nsg_required ? 1 : 0

  network_interface_id      = azurerm_network_interface.vm.id
  network_security_group_id = azurerm_network_security_group.vm[0].id
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

  # Bootstraps rsyslog for remote reception. Changing this replaces the VM.
  custom_data = var.enable_syslog_collector ? base64encode(local.syslog_cloud_init) : null

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  # Azure Monitor Agent authenticates with a managed identity.
  dynamic "identity" {
    for_each = var.enable_monitor_agent ? [1] : []

    content {
      type = "SystemAssigned"
    }
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

  # Required for third-party Azure Marketplace images (e.g. Amazon Linux 2023).
  dynamic "plan" {
    for_each = var.plan_name != null && var.plan_name != "" ? [1] : []
    content {
      name      = var.plan_name
      product   = var.plan_product
      publisher = var.plan_publisher != null && var.plan_publisher != "" ? var.plan_publisher : var.image_publisher
    }
  }

  computer_name = substr(replace(var.hostname, "-", ""), 0, 15)

  tags = var.tags
}

# Amazon Linux 2023 support requires agent 1.33.1 or later.
resource "azurerm_virtual_machine_extension" "monitor_agent" {
  count = var.enable_monitor_agent ? 1 : 0

  name                       = "AzureMonitorLinuxAgent"
  virtual_machine_id         = azurerm_linux_virtual_machine.vm.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.33"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true

  tags = var.tags
}
