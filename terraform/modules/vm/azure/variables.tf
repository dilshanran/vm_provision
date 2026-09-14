variable "hostname" {
  type = string
}

variable "environment" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "region" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "tags" {
  type = map(string)
}

variable "resource_group_name" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "image_publisher" {
  type = string
}

variable "image_offer" {
  type = string
}

variable "image_sku" {
  type = string
}

variable "image_version" {
  type = string
}

variable "os_disk_size_gb" {
  type = number
}

variable "os_disk_type" {
  type = string
}

variable "enable_public_ip" {
  description = "Attach a public IP and SSH NSG for direct internet access (demo/testing)."
  type        = bool
  default     = false
}

variable "plan_name" {
  description = "Marketplace plan name (required for third-party images). Leave null for first-party images."
  type        = string
  default     = null
}

variable "plan_product" {
  description = "Marketplace plan product / offer."
  type        = string
  default     = null
}

variable "plan_publisher" {
  description = "Marketplace plan publisher. Defaults to image_publisher when null."
  type        = string
  default     = null
}

variable "enable_syslog_collector" {
  description = "Install and configure rsyslog to receive remote syslog on UDP 514, and open the port to syslog_source_address_prefixes."
  type        = bool
  default     = false
}

variable "syslog_source_address_prefixes" {
  description = "Source CIDRs allowed to send syslog on UDP 514 (e.g. Nasuni Edge Appliances). UDP 514 is unauthenticated, so never use \"*\"."
  type        = list(string)
  default     = []

  validation {
    condition     = !contains(var.syslog_source_address_prefixes, "*")
    error_message = "syslog_source_address_prefixes must not contain \"*\"; list the sending appliances explicitly."
  }
}

variable "enable_monitor_agent" {
  description = "Attach a system-assigned identity and install the Azure Monitor Agent so a Data Collection Rule can ship logs."
  type        = bool
  default     = false
}
