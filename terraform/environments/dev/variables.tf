# =============================================================================
# Common (required for both AWS and Azure)
# =============================================================================

variable "cloud_provider" {
  description = "Target cloud: aws or azure."
  type        = string
}

variable "region" {
  description = "AWS region or Azure location."
  type        = string
}

variable "vms" {
  description = "Map of VMs to provision. Key is a stable identifier."
  type = map(object({
    hostname      = string
    instance_type = string
    subnet_id     = string
  }))
}

variable "tags" {
  description = "Required tags for all VMs."
  type        = map(string)

  validation {
    condition = alltrue([
      for key in ["Team", "Application", "CostCentre"] :
      contains(keys(var.tags), key) && trimspace(var.tags[key]) != ""
    ])
    error_message = "tags must include non-empty values for: Team, Application, CostCentre."
  }
}

# =============================================================================
# AWS (required when cloud_provider = "aws")
# =============================================================================

variable "aws_config" {
  description = "AWS settings. Omit ami_id to use the latest Amazon Linux 2023 AMI."
  type = object({
    ami_id                 = optional(string)
    vpc_security_group_ids = list(string)
    key_name               = optional(string)
    iam_instance_profile   = optional(string)
    root_volume_size       = optional(number, 30)
    root_volume_type       = optional(string, "gp3")
  })
  default = null
}

# =============================================================================
# Azure (required when cloud_provider = "azure")
# =============================================================================

variable "azure_config" {
  description = "Azure settings. Defaults to Amazon Linux 2023 marketplace image."
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
    plan_name           = optional(string, "ntg_amzn_linux_2023_gen2")
    plan_product        = optional(string, "ntg_amzn_linux_2023")
    plan_publisher      = optional(string, "ntegralinc1586961136942")
  })
  default = null
}
