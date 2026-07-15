locals {
  # AWS uses the Name tag and private DNS for hostname resolution.
  resolved_hostname = var.hostname
}
