/*
Example:

monitoringAgent = {
  workspace_id       = "someid"
  primary_shared_key = "somekey"
}

*/

variable "monitoringAgent" {
  description = "Should the VM be monitored. If yes provide the appropriate object as described. See option-40-OmsAgentForLinux.tf file for example"
  type = object({
    workspace_id       = string
    primary_shared_key = string
  })
  default = null
}

resource "azurerm_virtual_machine_extension" "OmsAgentForLinux" {

  count = var.monitoringAgent != null ? 1 : 0
  name  = "OmsAgentForLinux"
  depends_on = [
    azurerm_resource_group_template_deployment.autoshutdown
  ]
  virtual_machine_id         = azurerm_linux_virtual_machine.VM.id
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  type                       = "OmsAgentForLinux"
  type_handler_version       = "1.13"
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



