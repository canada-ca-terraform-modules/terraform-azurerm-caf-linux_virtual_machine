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
  source = "github.com/canada-ca-terraform-modules/terraform-azurerm_linux_virtual_machine?ref=20200612.1"

  name                              = "dockerweb"
  resource_group                    = "some-RG"
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

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| azurerm | n/a |
| random | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| admin\_username | Name of the VM admin account | `any` | n/a | yes |
| env | 4 chars env name | `string` | n/a | yes |
| resource\_group | Resourcegroup object that will contain the VM resources | `any` | n/a | yes |
| subnet | subnet object to which the VM NIC will connect to | `any` | n/a | yes |
| userDefinedString | User defined portion of the server name. Up to 8 chars minus the postfix lenght | `string` | n/a | yes |
| vm\_size | Specifies the size of the Virtual Machine. Eg: Standard\_F4 | `any` | n/a | yes |
| admin\_password | Password of the VM admin account | `any` | `null` | no |
| asg | ASG resource to join the NIC to | `any` | `null` | no |
| availability\_set\_id | Sets the id for the availability set to use for the VM | `any` | `null` | no |
| boot\_diagnostic | n/a | `bool` | `false` | no |
| custom\_data | Specifies custom data to supply to the machine. On Linux-based systems, this can be used as a cloud-init script. On other systems, this will be copied as a file on disk. Internally, Terraform will base64 encode this value before sending it to the API. The maximum length of the binary array is 65535 bytes. | `any` | `null` | no |
| data\_disk\_sizes\_gb | List of data disk sizes in gigabytes required for the VM. EG.: If 3 data disks are required then data\_disk\_size\_gb might look like [40,100,60] for disk 1 of 40 GB, disk 2 of 100 GB and disk 3 of 60 GB | `list` | `[]` | no |
| data\_disks | List of data disk sizes in gigabytes required for the VM. EG.: If 3 data disks are required then data\_disk\_size\_gb might look like [40,100,60] for disk 1 of 40 GB, disk 2 of 100 GB and disk 3 of 60 GB | `map` | `{}` | no |
| data\_managed\_disk\_type | n/a | `string` | `"Standard_LRS"` | no |
| dependancyAgent | Should the VM be include the dependancy agent | `bool` | `false` | no |
| disable\_password\_authentication | description | `string` | `"false"` | no |
| dnsServers | List of DNS servers IP addresses to use for this NIC, overrides the VNet-level server list | `any` | `null` | no |
| encryptDisks | Should the VM disks be encrypted | <pre>object({<br>    KeyVaultResourceId = string<br>    KeyVaultURL        = string<br>  })</pre> | `null` | no |
| eviction\_policy | Specifies what should happen when the Virtual Machine is evicted for price reasons when using a Spot instance. At this time the only supported value is Deallocate. Changing this forces a new resource to be created. | `string` | `"Deallocate"` | no |
| license\_type | BYOL license type for those with Azure Hybrid Benefit | `any` | `null` | no |
| load\_balancer\_backend\_address\_pools\_ids | List of Load Balancer Backend Address Pool IDs references to which this NIC belongs | `list` | `[]` | no |
| monitoringAgent | Should the VM be monitored. If yes provide the appropriate object as described. | <pre>object({<br>    log_analytics_workspace_name                = string<br>    log_analytics_workspace_resource_group_name = string<br>  })</pre> | `null` | no |
| nic\_depends\_on | n/a | `any` | `null` | no |
| nic\_enable\_accelerated\_networking | Enables Azure Accelerated Networking using SR-IOV. Only certain VM instance sizes are supported. | `bool` | `false` | no |
| nic\_enable\_ip\_forwarding | Enables IP Forwarding on the NIC. | `bool` | `false` | no |
| nic\_ip\_configuration | Defines how a private IP address is assigned. Options are Static or Dynamic. In case of Static also specifiy the desired privat IP address | `map` | <pre>{<br>  "private_ip_address": [<br>    null<br>  ],<br>  "private_ip_address_allocation": [<br>    "Dynamic"<br>  ]<br>}</pre> | no |
| os\_managed\_disk\_type | n/a | `string` | `"Standard_LRS"` | no |
| plan | An optional plan block | `any` | `null` | no |
| postfix | (Optional) Desired postfix value for the name. Max 3 chars. | `string` | `""` | no |
| priority | Specifies the priority of this Virtual Machine. Possible values are Regular and Spot. Defaults to Regular. Changing this forces a new resource to be created. | `string` | `"Regular"` | no |
| provision\_vm\_agent | n/a | `bool` | `true` | no |
| public\_ip | Should the VM be assigned public IP(s). True or false. | `bool` | `false` | no |
| security\_rules | n/a | `list(map(string))` | <pre>[<br>  {<br>    "access": "Allow",<br>    "description": "Allow all in",<br>    "destination_address_prefix": "*",<br>    "destination_port_ranges": "*",<br>    "direction": "Inbound",<br>    "name": "AllowAllInbound",<br>    "priority": "100",<br>    "protocol": "*",<br>    "source_address_prefix": "*",<br>    "source_port_ranges": "*"<br>  },<br>  {<br>    "access": "Allow",<br>    "description": "Allow all out",<br>    "destination_address_prefix": "*",<br>    "destination_port_ranges": "*",<br>    "direction": "Outbound",<br>    "name": "AllowAllOutbound",<br>    "priority": "105",<br>    "protocol": "*",<br>    "source_address_prefix": "*",<br>    "source_port_ranges": "*"<br>  }<br>]</pre> | no |
| serverType | 3 chars server type | `string` | `"SRV"` | no |
| shutdownConfig | Should the VM shutdown at the time specified. | <pre>object({<br>    autoShutdownStatus             = string<br>    autoShutdownTime               = string<br>    autoShutdownTimeZone           = string<br>    autoShutdownNotificationStatus = string<br>  })</pre> | `null` | no |
| ssh\_key | description | `any` | `null` | no |
| storage\_image\_reference | This block provisions the Virtual Machine from one of two sources: an Azure Platform Image (e.g. Ubuntu/Windows Server) or a Custom Image. Refer to https://www.terraform.io/docs/providers/azurerm/r/virtual_machine.html for more details. | `map` | <pre>{<br>  "offer": "RHEL",<br>  "publisher": "RedHat",<br>  "sku": "7.4",<br>  "version": "latest"<br>}</pre> | no |
| storage\_os\_disk | This block describe the parameters for the OS disk. Refer to https://www.terraform.io/docs/providers/azurerm/r/virtual_machine.html for more details. | `map` | <pre>{<br>  "caching": "ReadWrite",<br>  "create_option": "FromImage",<br>  "disk_size_gb": null,<br>  "os_type": null<br>}</pre> | no |
| tags | Tags that will be associated to VM resources | `map` | <pre>{<br>  "exampleTag1": "SomeValue2"<br>}</pre> | no |
| use\_nic\_nsg | n/a | `bool` | `true` | no |
| vm\_depends\_on | n/a | `any` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The id of the VM |
| name | The name of the VM |
| nic | The VM nic object |
| pip | The VM public ip if defined |
| vm | The VM object |

