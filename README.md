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

```terraform
module "linuxvm" {
  source = "github.com/canada-ca-terraform-modules/terraform-azurerm_linux_virtual_machine?ref=20200506.3"

  name                              = "dockerweb"
  resource_group_name               = "some-RG-Name"
  admin_username                    = "someusername"
  secretPasswordName                = "somekeyvaultsecretname"
  nic_subnetName                    = "some-subnet-name"
  nic_vnetName                      = "some-vnet-name"
  nic_resource_group_name           = "some-vnet-resourcegroup-name"
  vm_size                           = "Standard_D2_v3"
  keyvault = {
    name                = "some-keyvault-name"
    resource_group_name = "some-keyvault-resourcegroup-name"
  }
}
```


## Variables Values

| Name                                    | Type   | Required | Value                                                                                                                                                                                                       |
| --------------------------------------- | ------ | -------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| name                                    | string | yes      | Name of the vm                                                                                                                                                                                              |
| resource_group_name                     | string | yes      | Name of the resourcegroup that will contain the VM resources                                                                                                                                                |
| admin_username                          | string | yes      | Name of the VM admin account                                                                                                                                                                                |
| admin_password                          | string | yes      | Password of the VM admin account                                                                                                                                                                            |
| nic_subnetName                          | string | yes      | Name of the subnet to which the VM NIC will connect to                                                                                                                                                      |
| nic_vnetName                            | string | yes      | Name of the VNET the subnet is part of                                                                                                                                                                      |
| nic_resource_group_name                 | string | yes      | Name of the resourcegroup containing the VNET                                                                                                                                                               |
| vm_size                                 | string | yes      | Specifies the desired size of the Virtual Machine. Eg: Standard_F4                                                                                                                                          |
| location                                | string | no       | Azure location for resources. Default: canadacentral                                                                                                                                                        |
| tags                                    | object | no       | Object containing a tag values - [tags pairs](#tag-object)                                                                                                                                                  |
| data_disk_sizes_gb                      | list   | no       | List of data disk sizes in gigabytes required for the VM. - [data disk](#data-disk-list)                                                                                                                    |
| os_managed_disk_type                    | string | no       | Specifies the type of OS Managed Disk which should be created. Possible values are Standard_LRS or Premium_LRS. Default: Standard_LRS                                                                       |
| data_managed_disk_type                  | string | no       | Specifies the type of Data Managed Disk which should be created. Possible values are Standard_LRS or Premium_LRS. Default: Standard_LRS                                                                     |
| disable_password_authentication         | boot   | no       | Specifies whether password authentication should be disabled. If set to false, an admin_password must be specified. - Default: false                                                                        |
| dnsServers                              | list   | no       | List of DNS servers IP addresses as string to use for this NIC, overrides the VNet-level dns server list - [dns servers](#dns-servers-list)                                                                 |
| nic_enable_ip_forwarding                | bool   | no       | Enables IP Forwarding on the NIC. Default: false                                                                                                                                                            |
| nic_enable_accelerated_networkingg      | bool   | no       | Enables Azure Accelerated Networking using SR-IOV. Only certain VM instance sizes are supported. Default: false                                                                                             |
| nic_ip_configuration                    | object | no       | Defines how a private IP address is assigned. Options are Static or Dynamic. In case of Static also specifiy the desired privat IP address. Default: Dynamic - [ip configuration](#ip-configuration-object) |
| load_balancer_backend_address_pools_ids | List   | no       | List of Load Balancer Backend Address Pool IDs references to which this NIC belongs. Default: [[]]                                                                                                          |
| public_ip                               | bool   | no       | Does the VM require a public IP. true or false. Default: false                                                                                                                                              |
| storage_image_reference                 | object | no       | Specify the storage image used to create the VM. Default is 2016-Datacenter. - [storage image](#storage-image-reference-object)                                                                             |
| plan                                    | object | no       | Specify the plan used to create the VM. Default is null. - [plan](#plan-object)                                                                                                                             |
| storage_os_disk                         | object | no       | Storage OS Disk configuration. Default: ReadWrite from image.                                                                                                                                               |
| ssh_key                                 | string | no       | The Public SSH Key. - Default: none                                                                                                                                                                         |
| custom_data                             | string | no       | some custom ps1 code to execute. Eg: ${file("serverconfig/jumpbox-init.sh")}                                                                                                                                |
| security_rules                          | list   | no       | [Security rules](#securityrules-object) to be applied to the VM nic through an NSG                                                                                                                          |
| encryptDisk                             | object | no       | Configure if VM disks should be encrypted with Bitlocker. Default null - [encryptDisk](#encryptDisk-object)                                                                                                 |
| monitoringAgent                         | object | no       | Configure Azure monitoring on VM. Requires configured log analytics workspace. - [monitoring agent](#monitoring-agent-object)                                                                               |
| dependancyAgent                         | bool   | no       | Installs the dependancy agent for service map support. Default: false                                                                                                                                       |
| shutdownConfig                          | object | no       | Configure desired VM shutdown time - [shutdown config](#shutdown-config-object)                                                                                                                             |
| boot_diagnostic                         | bool   | no       | Should a boot be turned on or not. Default: false                                                                                                                                                           |
| availability_set_id                     | string | no       | Id of the availaiblity set to join. Default is null.                                                                                                                                                        |
| priority                                | string | no       | Specifies what should happen when the Virtual Machine is evicted for price reasons when using a Spot instance. At this time the only supported value is Deallocate. Changing this forces a new resource to be created. |

### tag object

Example tag variable:

```hcl
tags = {
  "tag1name" = "somevalue"
  "tag2name" = "someothervalue"
  .
  .
  .
  "tagXname" = "some other value"
}
```

### data disk list

Example data_disk_size_gb variable. The following example would deploy 3 data disks. One one of 40GB, one of 100GB and a last of 60GB:

```hcl
data_disk_size_gb = [40,100,60]
```

### dns servers list

Example dnsServers variable. The following example would configure 2 dns servers:

```hcl
dnsServers = ["10.20.30.40","10.20.30.41]
```

### ip configuration object

| Name                          | Type | Required | Value                                                                                                                                                           |
| ----------------------------- | ---- | -------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| private_ip_address            | list | yes      | List of Static IP desired for each IP allocation. Set each list items to null if using Dynamic allocation or to an static IP part of the subnet is using Static |
| private_ip_address_allocation | list | yes      | List of IP allocation type for each ip configuration. Set each to either Dynamic or Static                                                                      |
Default:

```hcl
nic_ip_configuration = {
  private_ip_address            = [null]
  private_ip_address_allocation = ["Dynamic"]
}
```

Example variable for a NIC with 2 staticly assigned IP and one dynamic:

```hcl
nic_ip_configuration = {
  private_ip_address            = ["10.20.30.42","10.20.40.43",null]
  private_ip_address_allocation = ["Static","Static","Dynamic"]
}
```

### securityrules object

| Name                       | Type   | Required | Value                                                                                                                                                                                                              |
| -------------------------- | ------ | -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| name                       | string | yes      | The name of the security rule.                                                                                                                                                                                     |
| description                | string | yes      | A description for this rule. Restricted to 140 characters.                                                                                                                                                         |
| access                     | string | yes      | Specifies whether network traffic is allowed or denied. Possible values are Allow and Deny.                                                                                                                        |
| priority                   | string | yes      | Specifies the priority of the rule. The value can be between 100 and 4096. The priority number must be unique for each rule in the collection. The lower the priority number, the higher the priority of the rule. |
| protocol                   | string | yes      | Network protocol this rule applies to. Can be Tcp, Udp or * to match both.                                                                                                                                         |
| direction                  | string | yes      | The direction specifies if rule will be evaluated on incoming or outgoing traffic. Possible values are Inbound and Outbound.                                                                                       |
| source_port_ranges         | string | yes      | List of source ports or port ranges.                                                                                                                                                                               |
| source_address_prefix      | string | yes      | CIDR or source IP range or * to match any IP. Tags such as ‘VirtualNetwork’, ‘AzureLoadBalancer’ and ‘Internet’ can also be used.                                                                                  |
| destination_port_ranges    | string | yes      | Destination Port or Range. Integer or range between 0 and 65535 or * to match any.                                                                                                                                 |
| destination_address_prefix | string | yes      | CIDR or destination IP range or * to match any IP. Tags such as ‘VirtualNetwork’, ‘AzureLoadBalancer’ and ‘Internet’ can also be used.                                                                             |

Example variable:

```hcl
security_rules = [
    {
      name                       = "AllowAllInbound"
      description                = "Allow all in"
      access                     = "Allow"
      priority                   = "100"
      protocol                   = "*"
      direction                  = "Inbound"
      source_port_ranges         = "*"
      source_address_prefix      = "*"
      destination_port_ranges    = "*"
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowAllOutbound"
      description                = "Allow all out"
      access                     = "Allow"
      priority                   = "105"
      protocol                   = "*"
      direction                  = "Outbound"
      source_port_ranges         = "*"
      source_address_prefix      = "*"
      destination_port_ranges    = "*"
      destination_address_prefix = "*"
    }
  ]
```

### storage image reference object

| Name      | Type       | Required           | Value                                                                                              |
| --------- | ---------- | ------------------ | -------------------------------------------------------------------------------------------------- |
| publisher | string     | yes                | The image publisher.                                                                               |
| offer     | string     | yes                | Specifies the offer of the platform image or marketplace image used to create the virtual machine. |
| sku       | string     | yes                | The image SKU.                                                                                     |
| version   | string yes | The image version. |

Example variable:

```hcl
storage_image_reference = {
  publisher = "RedHat"
  offer     = "RHEL"
  sku       = "7.4"
  version   = "latest"
}
```

### plan object

| Name      | Type   | Required | Value               |
| --------- | ------ | -------- | ------------------- |
| name      | string | yes      | The plan nome.      |
| publisher | string | yes      | The publisher name. |
| product   | string | yes      | The product name.   |

Example variable:

```hcl
plan = {
    name      = "fortinet-fortimanager"
    publisher = "fortinet"
    product   = "fortinet-fortimanager"
}
```

### keyvault object

| Name                | Type   | Required | Value                                                    |
| ------------------- | ------ | -------- | -------------------------------------------------------- |
| name                | string | yes      | Name of the keyvault resource                            |
| resource_group_name | string | yes      | Name of the resource group where the keyvault is located |

Example variable:

```hcl
keyvault = {
  name                = "some-keyvault-name"
  resource_group_name = "some-resource-group-name"
}
```

### monitoring agent object

| Name                                        | Type   | Required | Value                                                                |
| ------------------------------------------- | ------ | -------- | -------------------------------------------------------------------- |
| log_analytics_workspace_name                | string | Yes      | Name of the log analytics workspace that the VM will send logs to.   |
| log_analytics_workspace_resource_group_name | string | Yes      | Name of the resource group that contain the log analytics workspace. |

Example variable:

```hcl
  monitoringAgent = {
    workspace_id       = azurerm_log_analytics_workspace.logAnalyticsWS.workspace_id
    primary_shared_key = azurerm_log_analytics_workspace.logAnalyticsWS.primary_shared_key
  }
```

### encryptDisk object

| Name               | Type   | Required | Value                                                           |
| ------------------ | ------ | -------- | --------------------------------------------------------------- |
| KeyVaultResourceId | string | Yes      | ID of the keyvault resource that will store the encryption keys |
| KeyVaultURL        | string | Yes      | URL of the keyvault that will store the encryption keys         |

Example variable:

```hcl
encryptDisks = {
  KeyVaultResourceId = "${azurerm_key_vault.test-keyvault.id}"
  KeyVaultURL        = "${azurerm_key_vault.test-keyvault.vault_uri}"
}
```

### shutdown config object

| Name                           | Type   | Required | Value                                                                                          |
| ------------------------------ | ------ | -------- | ---------------------------------------------------------------------------------------------- |
| autoShutdownStatus             | string | Yes      | Name of the VM                                                                                 |
| autoShutdownTime               | string | Yes      | The time of day the schedule will occur. Eg: 17:00                                             |
| autoShutdownTimeZone           | string | Yes      | Timezone ID. Eg: Eastern Standard Time                                                         |
| autoShutdownNotificationStatus | string | Yes      | If notifications are enabled for this schedule (i.e. Enabled, Disabled). - Enabled or Disabled |

Example variable:

```hcl
shutdownConfig = {
  autoShutdownStatus = "Enabled"
  autoShutdownTime = "17:00"
  autoShutdownTimeZone = "Eastern Standard Time"
  autoShutdownNotificationStatus = "Disabled"
}
```

## History

| Date     | Release    | Change                                                                                       |
| -------- | ---------- | -------------------------------------------------------------------------------------------- |
| 20200506 | 20200506.1 | 1st commit              |
| 20200519 | 20200519.1 | Fix issue with non spot instance |

