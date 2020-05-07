terraform {
  required_version = ">= 0.12.1"
}
provider "azurerm" {
  version = ">= 1.32.0"
  features {}
}

locals {
  template_name = "basiclinuxvm"
}

data "azurerm_client_config" "current" {}

data "template_file" "cloudconfig" {
  template = file("serverconfig/test-init.sh")
}

data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content = data.template_file.cloudconfig.rendered
  }
}
/*
module "test-basiclinuxvm" {
  source = "../."

  name                    = "test1"
  resource_group_name     = azurerm_resource_group.test-RG.name
  admin_username          = "azureadmin"
  admin_password          = "Canada123!"
  custom_data             = data.template_cloudinit_config.config.rendered
  nic_subnetName          = azurerm_subnet.subnet1.name
  nic_vnetName            = azurerm_virtual_network.test-VNET.name
  nic_resource_group_name = azurerm_resource_group.test-RG.name
  vm_size                 = "Standard_B2ms"
  storage_image_reference = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  encryptDisks = {
    KeyVaultResourceId = azurerm_key_vault.test-keyvault.id
    KeyVaultURL        = azurerm_key_vault.test-keyvault.vault_uri
  }
  public_ip = true
}
*/

module "test-basiclinuxvm2" {
  source                          = "../."
  vm_depends_on                   = [azurerm_log_analytics_workspace.logAnalyticsWS.name]
  name                            = "test2"
  resource_group_name             = azurerm_resource_group.test-RG.name
  admin_username                  = "azureadmin"
  admin_password                  = "Canada123!"
  disable_password_authentication = true
  nic_subnetName                  = azurerm_subnet.subnet1.name
  nic_vnetName                    = azurerm_virtual_network.test-VNET.name
  nic_resource_group_name         = azurerm_resource_group.test-RG.name
  dnsServers                      = ["168.63.129.16"]
  vm_size            = "Standard_D2s_v3"
  data_disk_sizes_gb = ["40", "60"]
  priority           = "Spot"
  /*
  monitoringAgent = {
    workspace_id       = azurerm_log_analytics_workspace.logAnalyticsWS.workspace_id
    primary_shared_key = azurerm_log_analytics_workspace.logAnalyticsWS.primary_shared_key
  }
  shutdownConfig = {
    autoShutdownStatus             = "Enabled"
    autoShutdownTime               = "17:00"
    autoShutdownTimeZone           = "Eastern Standard Time"
    autoShutdownNotificationStatus = "Disabled"
  }
  */
  nic_ip_configuration = {
    private_ip_address            = ["10.10.10.10"]
    private_ip_address_allocation = ["Static"]
  }
  public_ip = true
  ssh_key   = file("ssh/rsa_id.pub")
}

/*
module "test-basiclinuxvm3" {
  source = "../."

  name                = "testssh"
  resource_group_name = azurerm_resource_group.test-RG.name
  admin_username      = "azureadmin"
  admin_password      = "Canada123!"
  #disable_password_authentication = true
  nic_subnetName          = azurerm_subnet.subnet1.name
  nic_vnetName            = azurerm_virtual_network.test-VNET.name
  nic_resource_group_name = azurerm_resource_group.test-RG.name
  vm_size                 = "Standard_B2ms"
  public_ip               = true
  ssh_key                 = file("ssh/rsa_id.pub")
}

module "test-basiclinuxvm4" {
  source = "../."

  name                    = "testnossh"
  resource_group_name     = azurerm_resource_group.test-RG.name
  admin_username          = "azureadmin"
  admin_password          = "Canada123!"
  nic_subnetName          = azurerm_subnet.subnet1.name
  nic_vnetName            = azurerm_virtual_network.test-VNET.name
  nic_resource_group_name = azurerm_resource_group.test-RG.name
  vm_size                 = "Standard_B2ms"
  public_ip               = true
}

module "test-basiclinuxv3-plan" {
  source = "../."

  vm_depends_on           = [module.test-basiclinuxvm.vm]
  name                    = "testplan"
  resource_group_name     = azurerm_resource_group.test-RG.name
  admin_username          = "azureadmin"
  admin_password          = azurerm_key_vault_secret.serverPassword.value
  nic_subnetName          = azurerm_subnet.subnet1.name
  nic_vnetName            = azurerm_virtual_network.test-VNET.name
  nic_resource_group_name = azurerm_resource_group.test-RG.name
  vm_size                 = "Standard_DS2_v2"
  storage_image_reference = {
    publisher = "fortinet"
    offer     = "fortinet-fortimanager"
    sku       = "fortinet-fortimanager"
    version   = "latest"
  }
  data_disk_sizes_gb = [1023]
  plan = {
    name = "fortinet-fortimanager"
    publisher = "fortinet"
    product = "fortinet-fortimanager"
  }
}
*/
