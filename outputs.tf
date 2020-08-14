output "name" {
  value      = azurerm_linux_virtual_machine.VM.name
}

output "id" {
  value      = azurerm_linux_virtual_machine.VM.id
}
output "vm" {
  value      = azurerm_linux_virtual_machine.VM
}

output "pip" {
  depends_on = [azurerm_public_ip.VM-EXT-PubIP[0]]
  value      = var.public_ip ? azurerm_public_ip.VM-EXT-PubIP[0] : null
}

output "nic" {
  value      = azurerm_network_interface.NIC
}