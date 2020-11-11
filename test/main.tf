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

module "test_basiclinuxvm" {
  source                          = "../."
  vm_depends_on                   = [azurerm_log_analytics_workspace.logAnalyticsWS.name]
  env                             = "ScSc"
  serverType                      = "SRV"
  userDefinedString               = "test-basiclinuxvm"
  resource_group                  = azurerm_resource_group.test-RG
  subnet                          = azurerm_subnet.subnet1
  admin_username                  = "azureadmin"
  admin_password                  = "Canada123!"
  disable_password_authentication = true
  dnsServers                      = ["168.63.129.16"]
  vm_size                         = "Standard_D2s_v3"
  data_disks = {
    "data1" = {
      disk_size_gb = 50
      lun          = 0
    },
    "data2" = {
      disk_size_gb = 50
      lun          = 1
    }
  }
  priority = "Spot"
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
  public_ip = false
  ssh_key   = file("ssh/rsa_id.pub")
}
