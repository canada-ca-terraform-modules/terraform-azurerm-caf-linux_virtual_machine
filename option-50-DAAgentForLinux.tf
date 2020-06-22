/* required for service map to work */
variable "dependancyAgent" {
  description = "Should the VM be include the dependancy agent"
  default     = false
  type = bool
}

resource "azurerm_virtual_machine_extension" "DAAgentForLinux" {

  count                      = var.dependancyAgent == true && var.deploy ? 1 : 0
  name                       = "DAAgentForLinux"
  virtual_machine_id         = azurerm_linux_virtual_machine.VM[0].id
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentLinux"
  type_handler_version       = "9.5"
  auto_upgrade_minor_version = true
  depends_on                 = [
    azurerm_template_deployment.autoshutdown,
    azurerm_virtual_machine_extension.OmsAgentForLinux
  ]
}
