locals {
  # Azure computer_name is truncated to 15 chars; callers receive the logical hostname.
  resolved_hostname = var.hostname

  syslog_rule_required = var.enable_syslog_collector && length(var.syslog_source_address_prefixes) > 0
  nsg_required         = var.enable_public_ip || local.syslog_rule_required

  # Amazon Linux 2023 ships journald only, so rsyslog must be installed before
  # anything can bind 514. The Azure Monitor Agent wires up its own forwarding
  # rule at /etc/rsyslog.d/10-azuremonitoragent-omfwd.conf but never enables
  # network reception, so imudp is configured here.
  # python3 and which are Azure Monitor Agent prerequisites.
  syslog_cloud_init = <<-EOT
    #cloud-config
    packages:
      - rsyslog
      - python3
      - which

    write_files:
      - path: /etc/rsyslog.d/00-remote-udp.conf
        permissions: '0644'
        owner: root:root
        content: |
          module(load="imudp")
          input(type="imudp" port="514")

    runcmd:
      - [ systemctl, enable, --now, rsyslog ]
  EOT
}
