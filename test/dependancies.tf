resource "azurerm_resource_group" "test-RG" {
  name     = "test-${local.template_name}-rg"
  location = var.location
}

resource "azurerm_virtual_network" "test-VNET" {
  name                = "test-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.test-RG.name
  address_space       = ["10.10.10.0/23"]
}
resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1-snet"
  virtual_network_name = azurerm_virtual_network.test-VNET.name
  resource_group_name  = azurerm_resource_group.test-RG.name
  address_prefixes     = ["10.10.10.0/27"]
}

resource "azurerm_key_vault" "test-keyvault" {
  name                            = "test-${substr(sha1("${data.azurerm_client_config.current.subscription_id}${azurerm_resource_group.test-RG.name}"), 0, 8)}-kv"
  location                        = var.location
  resource_group_name             = azurerm_resource_group.test-RG.name
  sku_name                        = "standard"
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
}

/*
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.service_principal_object_id
    #object_id = "267cced3-2154-43ff-b79b-b12c331ad1d1"
    key_permissions = [
      "Get",
      "List",
      "Update",
      "Create",
      "Import",
      "Delete",
      "Recover",
      "Backup",
      "Restore",
    ]
    secret_permissions = [
      "Get",
      "List",
      "Set",
      "Delete",
      "Recover",
      "Backup",
      "Restore",
    ]
    certificate_permissions = [
      "Get",
      "List",
      "Update",
      "Create",
      "Import",
      "Delete",
      "Recover",
      "Backup",
      "Restore",
      "ManageContacts",
      "ManageIssuers",
      "GetIssuers",
      "ListIssuers",
      "SetIssuers",
      "DeleteIssuers",
    ]
  }
}

resource "azurerm_key_vault_secret" "serverPassword" {
  name         = "serverPassword"
  value        = "Canada123!"
  key_vault_id = azurerm_key_vault.test-keyvault.id
}
*/

resource "azurerm_log_analytics_workspace" "logAnalyticsWS" {
  name                = "test-${substr(sha1("${data.azurerm_client_config.current.subscription_id}${azurerm_resource_group.test-RG.name}"), 0, 8)}-law"
  location            = var.location
  resource_group_name = azurerm_resource_group.test-RG.name
  sku                 = "pergb2018"
}
