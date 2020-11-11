# Terraform Basic Linux Virtual Machine

## Introduction

This module deploys a simple [virtual machine resource](https://docs.microsoft.com/en-us/azure/templates/microsoft.compute/2019-03-01/virtualmachines) with an NSG, 1 NIC and a simple OS Disk.

## Security Controls

The following security controls can be met through configuration of this template:

* AC-1, AC-10, AC-11, AC-11(1), AC-12, AC-14, AC-16, AC-17, AC-18, AC-18(4), AC-2 , AC-2(5), AC-20(1) , AC-20(3), AC-20(4), AC-24(1), AC-24(11), AC-3, AC-3 , AC-3(1), AC-3(3), AC-3(9), AC-4, AC-4(14), AC-6, AC-6, AC-6(1), AC-6(10), AC-6(11), AC-7, AC-8, AC-8, AC-9, AC-9(1), AI-16, AU-2, AU-3, AU-3(1), AU-3(2), AU-4, AU-5, AU-5(3), AU-8(1), AU-9, CM-10, CM-11(2), CM-2(2), CM-2(4), CM-3, CM-3(1), CM-3(6), CM-5(1), CM-6, CM-6, CM-7, CM-7, IA-1, IA-2, IA-3, IA-4(1), IA-4(4), IA-5, IA-5, IA-5(1), IA-5(13), IA-5(1c), IA-5(6), IA-5(7), IA-9, SC-10, SC-13, SC-15, SC-18(4), SC-2, SC-2, SC-23, SC-28, SC-30(5), SC-5, SC-7, SC-7(10), SC-7(16), SC-7(8), SC-8, SC-8(1), SC-8(4), SI-14, SI-2(1), SI-3

## Dependancies

Hard:

* Resource Groups
* Keyvault
* VNET-Subnet

Optional (depending on options configured):

* log analytics workspace

## Usage

```hcl
module "SRV-SASPR1" {
  count               = var.vmConfigs.SRV-SASPR1.deploy ? 1 : 0
  source              = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-linux_virtual_machine?ref=v1.1.5"
  env                 = var.env
  serverType          = var.vmConfigs.SRV-SASPR1.serverType
  userDefinedString   = var.vmConfigs.SRV-SASPR1.userDefinedString
  postfix             = var.vmConfigs.SRV-SASPR1.postfix
  resource_group      = local.resource_groups_L2.Project
  availability_set_id = azurerm_availability_set.SRV-SASPR-as.id
  subnet              = local.subnets[var.vmConfigs.SRV-SASPR1.subnet]
  nic_ip_configuration = {
    private_ip_address            = [cidrhost(local.subnets[var.vmConfigs.SRV-SASPR1.subnet].address_prefix, var.vmConfigs.SRV-SASPR1.IP)]
    private_ip_address_allocation = ["Static"]
  }
  storage_image_reference = {
    publisher = "RedHat",
    offer     = "RHEL",
    sku       = "7-LVM",
    version   = "7.7.2020031212"
  }
  encryptDisks = {
    KeyVaultResourceId = local.Project-kv.id
    KeyVaultURL        = local.Project-kv.vault_uri
  }
  os_managed_disk_type   = lookup(var.vmConfigs.SRV-SASPR1, "os_managed_disk_type", "StandardSSD_LRS")
  data_managed_disk_type = lookup(var.vmConfigs.SRV-SASPR1, "data_managed_disk_type", "StandardSSD_LRS")
  data_disks             = lookup(var.vmConfigs.SRV-SASPR1, "data_disks", {})
  priority               = lookup(var.vmConfigs.SRV-SASPR1, "priority", "Regular")
  admin_username         = var.vmConfigs.SRV-SASPR1.admin_username
  admin_password         = var.vmConfigs.SRV-SASPR1.admin_password
  vm_size                = var.vmConfigs.SRV-SASPR1.vm_size
  asg                    = azurerm_application_security_group.AD-Clients
  tags                   = var.tags
}
```