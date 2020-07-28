output "name" {
  depends_on = [azurerm_linux_virtual_machine.VM[0]]
  value      = var.deploy ? azurerm_linux_virtual_machine.VM[0].name : null
}

output "id" {
  depends_on = [azurerm_linux_virtual_machine.VM[0]]
  value      = var.deploy ? azurerm_linux_virtual_machine.VM[0].id : null
}

output "vm" {
  depends_on = [azurerm_linux_virtual_machine.VM[0]]
  value      = var.deploy ? azurerm_linux_virtual_machine.VM[0] : null
}

output "pip" {
  depends_on = [azurerm_public_ip.VM-EXT-PubIP[0]]
  value      = var.deploy ? azurerm_public_ip.VM-EXT-PubIP[0] : null
}

output "nic" {
  depends_on = [azurerm_network_interface.NIC[0]]
  value      = var.deploy ? azurerm_network_interface.NIC[0] : null
}