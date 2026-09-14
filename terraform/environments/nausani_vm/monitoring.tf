# Ships Nasuni syslog from the collector VM into Log Analytics.
#
# Flow: Nasuni Edge Appliance -> UDP 514 -> rsyslog on the VM ->
#       Azure Monitor Agent -> this Data Collection Rule -> Syslog table.
#
# Created only when log_analytics_workspace_id is set. The workspace may live
# in another subscription; the rule itself must be in the VM's region.

locals {
  syslog_enabled = var.cloud_provider == "azure" && var.log_analytics_workspace_id != null
}

resource "azurerm_monitor_data_collection_rule" "syslog" {
  count = local.syslog_enabled ? 1 : 0

  name                = "dcr-nausani-syslog"
  resource_group_name = var.azure_config.resource_group_name
  location            = var.region
  description         = "Collects Nasuni syslog from the nausani_vm collector."

  destinations {
    log_analytics {
      workspace_resource_id = var.log_analytics_workspace_id
      name                  = "syslog-workspace"
    }
  }

  data_sources {
    syslog {
      name           = "nasuni-syslog"
      streams        = ["Microsoft-Syslog"]
      facility_names = var.syslog_facility_names
      log_levels     = var.syslog_log_levels
    }
  }

  data_flow {
    streams      = ["Microsoft-Syslog"]
    destinations = ["syslog-workspace"]
  }

  tags = var.tags
}

# A rule can only be associated with resources in its own region.
resource "azurerm_monitor_data_collection_rule_association" "syslog" {
  for_each = local.syslog_enabled ? module.vm : {}

  name                    = "dcra-nausani-syslog"
  target_resource_id      = each.value.instance_id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.syslog[0].id
  description             = "Binds the collector VM to the Nasuni syslog rule."
}

output "syslog_data_collection_rule_id" {
  description = "Data Collection Rule shipping syslog to Log Analytics, or null when disabled."
  value       = local.syslog_enabled ? azurerm_monitor_data_collection_rule.syslog[0].id : null
}
