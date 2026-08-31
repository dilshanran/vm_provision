locals {
  # AWS uses the Name tag and private DNS for hostname resolution.
  name_tag          = var.hostname
  resolved_hostname = var.hostname
  ami_id            = var.ami_id != null ? var.ami_id : data.aws_ami.al2023[0].id
}
