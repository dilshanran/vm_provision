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

variable "ami_id" {
  description = "Optional AMI ID. When null, the latest Amazon Linux 2023 x86_64 AMI is resolved automatically."
  type        = string
  default     = null
}

variable "vpc_security_group_ids" {
  type = list(string)
}

variable "key_name" {
  type    = string
  default = null
}

variable "iam_instance_profile" {
  type    = string
  default = null
}

variable "root_volume_size" {
  type = number
}

variable "root_volume_type" {
  type = string
}
