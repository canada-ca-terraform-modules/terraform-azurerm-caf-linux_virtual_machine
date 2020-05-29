/*
Example:

monitoringAgent = {
  log_analytics_workspace_name                = "somename"
  log_analytics_workspace_resource_group_name = "someRGName"
}

*/

variable "monitoringAgent" {
  description = "Should the VM be monitored"
  default     = null
}

resource "azurerm_virtual_machine_extension" "OmsAgentForLinux" {

  count                      = var.monitoringAgent == null ? 0 : 1
  name                       = "OmsAgentForLinux"
  depends_on                 = [azurerm_template_deployment.autoshutdown]
  virtual_machine_id         = azurerm_linux_virtual_machine.VM.id
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  type                       = "OmsAgentForLinux"
  type_handler_version       = "1.12"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
        {  
          "workspaceId": "${var.monitoringAgent.workspace_id}"
        }
  SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
        {
          "workspaceKey": "${var.monitoringAgent.primary_shared_key}"
        }
  PROTECTED_SETTINGS
}



