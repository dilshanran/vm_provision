# Shared VM interface for AWS and Azure.
# Callers pass common fields plus aws_config or azure_config.

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
  description = "Deployment environment (dev, test, stage, uat, prod)."
  type        = string

  validation {
    condition     = contains(["dev", "test", "stage", "uat", "prod"], var.environment)
    error_message = "environment must be one of: dev, test, stage, uat, prod."
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
  description = "AWS-specific settings. Required when cloud_provider = aws. AMI defaults to Amazon Linux 2023 when ami_id is omitted."
  type = object({
    ami_id                 = optional(string)
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
    image_publisher     = optional(string, "ntegralinc1586961136942")
    image_offer         = optional(string, "ntg_amzn_linux_2023")
    image_sku           = optional(string, "ntg_amzn_linux_2023_gen2")
    image_version       = optional(string, "latest")
    os_disk_size_gb     = optional(number, 30)
    os_disk_type        = optional(string, "Standard_LRS")
    enable_public_ip    = optional(bool, false)
    # Marketplace plan (needed for third-party images like Amazon Linux 2023)
    plan_name      = optional(string, "ntg_amzn_linux_2023_gen2")
    plan_product   = optional(string, "ntg_amzn_linux_2023")
    plan_publisher = optional(string, "ntegralinc1586961136942")
  })
  default = null

  validation {
    condition     = var.cloud_provider != "azure" || var.azure_config != null
    error_message = "azure_config is required when cloud_provider is \"azure\"."
  }
}
