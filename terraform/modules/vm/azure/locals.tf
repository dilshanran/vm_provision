locals {
  # Azure computer_name is truncated to 15 chars; callers receive the logical hostname.
  resolved_hostname = var.hostname
}
