output "name" {
  description = "The name of the VM"
  value       = azurerm_linux_virtual_machine.VM.name
}

output "id" {
  description = "The id of the VM"
  value       = azurerm_linux_virtual_machine.VM.id
}

output "vm" {
  description = "The VM object"
  value       = azurerm_linux_virtual_machine.VM
}

output "pip" {
  description = "The VM public ip if defined"
  depends_on  = [azurerm_public_ip.VM-EXT-PubIP[0]]
  value       = var.public_ip ? azurerm_public_ip.VM-EXT-PubIP[0] : null
}

output "nic" {
  description = "The VM nic object"
  value       = azurerm_network_interface.NIC
}