data "azurerm_subnet" "subnet" {
  name                 = var.nic_subnetName
  virtual_network_name = var.nic_vnetName
  resource_group_name  = var.nic_resource_group_name
}
