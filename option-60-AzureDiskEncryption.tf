/*
Example:

encryptDisks = {
  KeyVaultResourceId = azurerm_key_vault.test-keyvault.id
  KeyVaultURL        = azurerm_key_vault.test-keyvault.vault_uri
}

*/

variable "encryptDisks" {
  description = "Should the VM disks be encrypted. See option-30-AzureDiskEncryption.tf file for example"
  type = object({
    KeyVaultResourceId = string
    KeyVaultURL        = string
  })
  default = null
}

resource "random_uuid" "SequenceVersion" {}

resource "azurerm_virtual_machine_extension" "AzureDiskEncryption" {

  count = var.encryptDisks != null ? 1 : 0
  name  = "AzureDiskEncryption"
  depends_on = [
    azurerm_template_deployment.autoshutdown,
    azurerm_virtual_machine_extension.OmsAgentForLinux,
    azurerm_virtual_machine_extension.DAAgentForLinux,
    azurerm_virtual_machine_data_disk_attachment.data_disks
  ]
  virtual_machine_id         = azurerm_linux_virtual_machine.VM.id
  publisher                  = "Microsoft.Azure.Security"
  type                       = "AzureDiskEncryptionForLinux"
  type_handler_version       = "1.1"
  auto_upgrade_minor_version = true

  settings = <<SETTINGS
        {  
          "EncryptionOperation": "EnableEncryption",
          "KeyVaultResourceId": "${var.encryptDisks.KeyVaultResourceId}",
          "KeyVaultURL": "${var.encryptDisks.KeyVaultURL}",
          "KeyEncryptionAlgorithm": "",
          "VolumeType": "All",
          "ResizeOSDisk": false,
          "SequenceVersion": "${random_uuid.SequenceVersion.result}"
        }
  SETTINGS
}
