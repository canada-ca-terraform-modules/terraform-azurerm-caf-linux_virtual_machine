data "azurerm_subnet" "subnet" {
  name                 = var.nic_subnetName
  virtual_network_name = var.nic_vnetName
  resource_group_name  = var.nic_resource_group_name
}

data "azurerm_resource_group" "resourceGroup" {
  depends_on = [var.resource_group_name]
  name       = var.resource_group_name
}
