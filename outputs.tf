output "name" {
  depends_on = [azurerm_linux_virtual_machine.VM[0]]

  value = azurerm_linux_virtual_machine.VM[0].name
}

output "id" {
  depends_on = [azurerm_linux_virtual_machine.VM[0]]

  value = azurerm_linux_virtual_machine.VM[0].id
}

output "vm" {
  depends_on = [azurerm_linux_virtual_machine.VM]

  value = azurerm_linux_virtual_machine.VM
}

output "pip" {
  depends_on = [ azurerm_public_ip.VM-EXT-PubIP ]

  value = azurerm_public_ip.VM-EXT-PubIP
}

output "nic" {
  depends_on = [azurerm_network_interface.NIC]
  value = azurerm_network_interface.NIC
}