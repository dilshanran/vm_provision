# ---------------------------------------------------------------------------
# Common interface — callers pass the same variables regardless of cloud.
# Cloud-specific settings live in aws_config / azure_config objects.
# ---------------------------------------------------------------------------

variable "cloud_provider" {
  description = "Target cloud: aws or azure."
  type        = string

  validation {
    condition     = contains(["aws", "azure"], var.cloud_provider)
    error_message = "cloud_provider must be \"aws\" or \"azure\"."
  }
}

variable "hostname" {
  description = "Desired hostname / server name for the VM."
  type        = string
}

variable "environment" {
  description = "Deployment environment (dev, test, uat, prod)."
  type        = string

  validation {
    condition     = contains(["dev", "test", "uat", "prod"], var.environment)
    error_message = "environment must be one of: dev, test, uat, prod."
  }
}

variable "instance_type" {
  description = "Compute size: AWS instance type (e.g. t3.medium) or Azure VM size (e.g. Standard_B2s)."
  type        = string
}

variable "region" {
  description = "Cloud region / location (e.g. us-east-1, eastus)."
  type        = string
}

variable "subnet_id" {
  description = "Subnet to attach the VM network interface to."
  type        = string
}

variable "tags" {
  description = "Common resource tags applied to all created resources."
  type        = map(string)
  default     = {}
}

variable "aws_config" {
  description = "AWS-specific settings. Required when cloud_provider = aws."
  type = object({
    ami_id                 = string
    vpc_security_group_ids = list(string)
    key_name               = optional(string)
    iam_instance_profile   = optional(string)
    root_volume_size       = optional(number, 30)
    root_volume_type       = optional(string, "gp3")
  })
  default = null

  validation {
    condition     = var.cloud_provider != "aws" || var.aws_config != null
    error_message = "aws_config is required when cloud_provider is \"aws\"."
  }
}

variable "azure_config" {
  description = "Azure-specific settings. Required when cloud_provider = azure."
  type = object({
    resource_group_name = string
    admin_username      = string
    ssh_public_key      = string
    image_publisher     = optional(string, "Canonical")
    image_offer         = optional(string, "0001-com-ubuntu-server-jammy")
    image_sku           = optional(string, "22_04-lts-gen2")
    image_version       = optional(string, "latest")
    os_disk_size_gb     = optional(number, 30)
    os_disk_type        = optional(string, "Standard_LRS")
  })
  default = null

  validation {
    condition     = var.cloud_provider != "azure" || var.azure_config != null
    error_message = "azure_config is required when cloud_provider is \"azure\"."
  }
}
