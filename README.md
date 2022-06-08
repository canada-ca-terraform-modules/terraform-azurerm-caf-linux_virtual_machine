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

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 1.32.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 1.32.0 |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_backup_protected_vm.backup_vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_protected_vm) | resource |
| [azurerm_linux_virtual_machine.VM](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_managed_disk.data_disks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk) | resource |
| [azurerm_network_interface.NIC](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface_application_security_group_association.asg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_application_security_group_association) | resource |
| [azurerm_network_interface_backend_address_pool_association.LB](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_backend_address_pool_association) | resource |
| [azurerm_network_interface_security_group_association.nic-nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_network_security_group.NSG](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_public_ip.VM-EXT-PubIP](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_resource_group_template_deployment.autoshutdown](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_template_deployment) | resource |
| [azurerm_storage_account.boot_diagnostic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_virtual_machine_data_disk_attachment.data_disks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment) | resource |
| [azurerm_virtual_machine_extension.AzureDiskEncryption](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.DAAgentForLinux](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.OmsAgentForLinux](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [random_uuid.SequenceVersion](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | Password of the VM admin account | `string` | `null` | no |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | Name of the VM admin account | `string` | n/a | yes |
| <a name="input_asg"></a> [asg](#input\_asg) | ASG object to join the NIC to | `any` | `null` | no |
| <a name="input_availability_set_id"></a> [availability\_set\_id](#input\_availability\_set\_id) | Sets the id for the availability set to use for the VM | `string` | `null` | no |
| <a name="input_backup"></a> [backup](#input\_backup) | Specifies the id of the backup policy to use. | `bool` | `false` | no |
| <a name="input_backup_policy_id"></a> [backup\_policy\_id](#input\_backup\_policy\_id) | Specifies the id of the backup policy to use. | `string` | `null` | no |
| <a name="input_boot_diagnostic"></a> [boot\_diagnostic](#input\_boot\_diagnostic) | Should a boot be turned on or not | `bool` | `false` | no |
| <a name="input_custom_data"></a> [custom\_data](#input\_custom\_data) | Specifies custom data to supply to the machine. On Linux-based systems, this can be used as a cloud-init script. On other systems, this will be copied as a file on disk. Internally, Terraform will base64 encode this value before sending it to the API. The maximum length of the binary array is 65535 bytes. | `string` | `null` | no |
| <a name="input_data_disks"></a> [data\_disks](#input\_data\_disks) | Map of object of disk sizes in gigabytes and lun number for each desired data disks. See variable.tf file for example | `any` | `{}` | no |
| <a name="input_data_managed_disk_type"></a> [data\_managed\_disk\_type](#input\_data\_managed\_disk\_type) | Specifies the type of Data Managed Disk which should be created. Possible values are Standard\_LRS or Premium\_LRS. | `string` | `"Standard_LRS"` | no |
| <a name="input_dependancyAgent"></a> [dependancyAgent](#input\_dependancyAgent) | Should the VM be include the dependancy agent | `bool` | `false` | no |
| <a name="input_disable_password_authentication"></a> [disable\_password\_authentication](#input\_disable\_password\_authentication) | Specifies whether password authentication should be disabled. If set to false, an admin\_password must be specified. | `bool` | `"false"` | no |
| <a name="input_dnsServers"></a> [dnsServers](#input\_dnsServers) | List of DNS servers IP addresses to use for this NIC, overrides the VNet-level server list. See variable.tf file for example | `list(string)` | `null` | no |
| <a name="input_encryptDisks"></a> [encryptDisks](#input\_encryptDisks) | Should the VM disks be encrypted. See option-30-AzureDiskEncryption.tf file for example | <pre>object({<br>    KeyVaultResourceId = string<br>    KeyVaultURL        = string<br>  })</pre> | `null` | no |
| <a name="input_encryption_at_host_enabled"></a> [encryption\_at\_host\_enabled](#input\_encryption\_at\_host\_enabled) | n/a | `bool` | `false` | no |
| <a name="input_env"></a> [env](#input\_env) | 4 chars defining the environment name prefix for the VM. Example: ScSc | `string` | n/a | yes |
| <a name="input_eviction_policy"></a> [eviction\_policy](#input\_eviction\_policy) | Specifies what should happen when the Virtual Machine is evicted for price reasons when using a Spot instance. At this time the only supported value is Deallocate. Changing this forces a new resource to be created. | `string` | `"Deallocate"` | no |
| <a name="input_license_type"></a> [license\_type](#input\_license\_type) | (Optional) Specifies the BYOL Type for this Virtual Machine. Possible values are RHEL\_BYOS and SLES\_BYOS. | `string` | `null` | no |
| <a name="input_load_balancer_backend_address_pools_ids"></a> [load\_balancer\_backend\_address\_pools\_ids](#input\_load\_balancer\_backend\_address\_pools\_ids) | List of Load Balancer Backend Address Pool IDs references to which this NIC belongs | `list(string)` | `[]` | no |
| <a name="input_monitoringAgent"></a> [monitoringAgent](#input\_monitoringAgent) | Should the VM be monitored. If yes provide the appropriate object as described. See option-40-OmsAgentForLinux.tf file for example | <pre>object({<br>    workspace_id       = string<br>    primary_shared_key = string<br>  })</pre> | `null` | no |
| <a name="input_nic_depends_on"></a> [nic\_depends\_on](#input\_nic\_depends\_on) | List of resources that the VM NIC depend on | `any` | `null` | no |
| <a name="input_nic_enable_accelerated_networking"></a> [nic\_enable\_accelerated\_networking](#input\_nic\_enable\_accelerated\_networking) | Enables Azure Accelerated Networking using SR-IOV. Only certain VM instance sizes are supported. | `bool` | `false` | no |
| <a name="input_nic_enable_ip_forwarding"></a> [nic\_enable\_ip\_forwarding](#input\_nic\_enable\_ip\_forwarding) | Enables IP Forwarding on the NIC. | `bool` | `false` | no |
| <a name="input_nic_ip_configuration"></a> [nic\_ip\_configuration](#input\_nic\_ip\_configuration) | Defines how a private IP address is assigned. Options are Static or Dynamic. In case of Static also specifiy the desired privat IP address. See variable.tf file for example | <pre>object({<br>    private_ip_address            = list(string)<br>    private_ip_address_allocation = list(string)<br>  })</pre> | <pre>{<br>  "private_ip_address": [<br>    null<br>  ],<br>  "private_ip_address_allocation": [<br>    "Dynamic"<br>  ]<br>}</pre> | no |
| <a name="input_os_managed_disk_type"></a> [os\_managed\_disk\_type](#input\_os\_managed\_disk\_type) | Specifies the type of OS Managed Disk which should be created. Possible values are Standard\_LRS or Premium\_LRS. | `string` | `"Standard_LRS"` | no |
| <a name="input_plan"></a> [plan](#input\_plan) | An optional plan block | <pre>object({<br>    name      = string<br>    product   = string<br>    publisher = string<br>  })</pre> | `null` | no |
| <a name="input_postfix"></a> [postfix](#input\_postfix) | (Optional) Desired postfix value for the name. Max 3 chars. | `string` | `""` | no |
| <a name="input_priority"></a> [priority](#input\_priority) | Specifies the priority of this Virtual Machine. Possible values are Regular and Spot. Defaults to Regular. Changing this forces a new resource to be created. | `string` | `"Regular"` | no |
| <a name="input_provision_vm_agent"></a> [provision\_vm\_agent](#input\_provision\_vm\_agent) | Should an Azure VM Agent be provisionned on the VM | `bool` | `true` | no |
| <a name="input_public_ip"></a> [public\_ip](#input\_public\_ip) | Should the VM be assigned public IP(s). True or false. | `bool` | `false` | no |
| <a name="input_recovery_vault"></a> [recovery\_vault](#input\_recovery\_vault) | The Recovery Services Vault object to use. Changing this forces a new resource to be created. | `any` | `null` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | Resourcegroup object that will contain the VM resources | `any` | n/a | yes |
| <a name="input_security_rules"></a> [security\_rules](#input\_security\_rules) | Security rules to apply to the VM NIC | `list(map(string))` | <pre>[<br>  {<br>    "access": "Allow",<br>    "description": "Allow all in",<br>    "destination_address_prefix": "*",<br>    "destination_port_ranges": "*",<br>    "direction": "Inbound",<br>    "name": "AllowAllInbound",<br>    "priority": "100",<br>    "protocol": "*",<br>    "source_address_prefix": "*",<br>    "source_port_ranges": "*"<br>  },<br>  {<br>    "access": "Allow",<br>    "description": "Allow all out",<br>    "destination_address_prefix": "*",<br>    "destination_port_ranges": "*",<br>    "direction": "Outbound",<br>    "name": "AllowAllOutbound",<br>    "priority": "105",<br>    "protocol": "*",<br>    "source_address_prefix": "*",<br>    "source_port_ranges": "*"<br>  }<br>]</pre> | no |
| <a name="input_serverType"></a> [serverType](#input\_serverType) | 3 chars server type code for the VM. | `string` | `"SRV"` | no |
| <a name="input_shutdownConfig"></a> [shutdownConfig](#input\_shutdownConfig) | Should the VM shutdown at the time specified. See option-30-autoshutdown.tf file for example | <pre>object({<br>    autoShutdownStatus             = string<br>    autoShutdownTime               = string<br>    autoShutdownTimeZone           = string<br>    autoShutdownNotificationStatus = string<br>  })</pre> | `null` | no |
| <a name="input_source_image_id"></a> [source\_image\_id](#input\_source\_image\_id) | (Optional) The ID of the Image which this Virtual Machine should be created from. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_ssh_key"></a> [ssh\_key](#input\_ssh\_key) | The Public SSH Key. | `string` | `null` | no |
| <a name="input_storage_image_reference"></a> [storage\_image\_reference](#input\_storage\_image\_reference) | (Optional) This block provisions the Virtual Machine from one of two sources: an Azure Platform Image (e.g. Ubuntu/Windows Server) or a Custom Image. Refer to https://www.terraform.io/docs/providers/azurerm/r/virtual_machine.html for more details. | <pre>object({<br>    publisher = string<br>    offer     = string<br>    sku       = string<br>    version   = string<br>  })</pre> | <pre>{<br>  "offer": "RHEL",<br>  "publisher": "RedHat",<br>  "sku": "7.4",<br>  "version": "latest"<br>}</pre> | no |
| <a name="input_storage_os_disk"></a> [storage\_os\_disk](#input\_storage\_os\_disk) | This block describe the parameters for the OS disk. Refer to https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine#os_disk for more details. | <pre>object({<br>    caching       = string<br>    create_option = string<br>    disk_size_gb  = number<br>  })</pre> | <pre>{<br>  "caching": "ReadWrite",<br>  "create_option": "FromImage",<br>  "disk_size_gb": null<br>}</pre> | no |
| <a name="input_subnet"></a> [subnet](#input\_subnet) | subnet object to which the VM NIC will connect to | `any` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags that will be associated to VM resources | `map(string)` | <pre>{<br>  "exampleTag1": "SomeValue2"<br>}</pre> | no |
| <a name="input_ultra_ssd_enabled"></a> [ultra\_ssd\_enabled](#input\_ultra\_ssd\_enabled) | Should the capacity to enable Data Disks of the UltraSSD\_LRS storage account type be supported on this Virtual Machine? | `bool` | `false` | no |
| <a name="input_use_nic_nsg"></a> [use\_nic\_nsg](#input\_use\_nic\_nsg) | Should a NIC NSG be used | `bool` | `true` | no |
| <a name="input_userDefinedString"></a> [userDefinedString](#input\_userDefinedString) | User defined portion of the server name. Up to 8 chars minus the postfix lenght | `string` | n/a | yes |
| <a name="input_vm_depends_on"></a> [vm\_depends\_on](#input\_vm\_depends\_on) | List of resources that the VM depend on | `any` | `null` | no |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | Specifies the size of the Virtual Machine. Eg: Standard\_F4 | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | The Zone in which this Virtual Machine should be created. Changing this forces a new resource to be created. | `any` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The id of the VM |
| <a name="output_name"></a> [name](#output\_name) | The name of the VM |
| <a name="output_nic"></a> [nic](#output\_nic) | The VM nic object |
| <a name="output_pip"></a> [pip](#output\_pip) | The VM public ip if defined |
| <a name="output_vm"></a> [vm](#output\_vm) | The VM object |
