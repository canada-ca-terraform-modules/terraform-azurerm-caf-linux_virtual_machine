/*
List of option related variables:

custom_data = "some custom shell code to execute. Eg: ${file("serverconfig/jumpbox-init.sh")}"

monitoringAgent = {
  log_analytics_workspace_name = "somename"
  log_analytics_workspace_resource_group_name = "someRGName"
}

shutdownConfig = {
  autoShutdownStatus = "Enabled"
  autoShutdownTime = "17:00"
  autoShutdownTimeZone = "Eastern Standard Time"
  autoShutdownNotificationStatus = "Disabled"
}

Those can be set optionally if you want to deploy with optional features
*/

variable "tags" {
  description = "Tags that will be associated to VM resources"
  default = {
    "exampleTag1" = "SomeValue1"
    "exampleTag1" = "SomeValue2"
  }
}

variable "env" {
  description = "4 chars env name"
  type        = string
}

variable "serverType" {
  description = "3 chars server type"
  type        = string
  default     = "SRV"
}

variable "userDefinedString" {
  description = "User defined portion of the server name. Up to 8 chars minus the postfix lenght"
  type        = string
}

variable "postfix" {
  description = "(Optional) Desired postfix value for the name. Max 3 chars."
  type        = string
  default     = ""
}

variable "data_disk_sizes_gb" {
  description = "List of data disk sizes in gigabytes required for the VM. EG.: If 3 data disks are required then data_disk_size_gb might look like [40,100,60] for disk 1 of 40 GB, disk 2 of 100 GB and disk 3 of 60 GB"
  default     = []
}

variable "data_disks" {
  description = "List of data disk sizes in gigabytes required for the VM. EG.: If 3 data disks are required then data_disk_size_gb might look like [40,100,60] for disk 1 of 40 GB, disk 2 of 100 GB and disk 3 of 60 GB"
  default     = {}
}

variable "subnet" {
  description = "subnet object to which the VM NIC will connect to"
}

variable "dnsServers" {
  description = "List of DNS servers IP addresses to use for this NIC, overrides the VNet-level server list"
  default     = null
}
variable "nic_enable_ip_forwarding" {
  description = "Enables IP Forwarding on the NIC."
  default     = false
}
variable "nic_enable_accelerated_networking" {
  description = "Enables Azure Accelerated Networking using SR-IOV. Only certain VM instance sizes are supported."
  default     = false
}
variable "nic_ip_configuration" {
  description = "Defines how a private IP address is assigned. Options are Static or Dynamic. In case of Static also specifiy the desired privat IP address"
  default = {
    private_ip_address            = [null]
    private_ip_address_allocation = ["Dynamic"]
  }
}

variable "load_balancer_backend_address_pools_ids" {
  description = "List of Load Balancer Backend Address Pool IDs references to which this NIC belongs"
  default     = []
}

variable "security_rules" {
  type = list(map(string))
  default = [
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
}

variable "asg" {
  description = "ASG resource to join the NIC to"
  default     = null
}

variable "public_ip" {
  description = "Should the VM be assigned public IP(s). True or false."
  default     = false
}

variable "resource_group" {
  description = "Resourcegroup object that will contain the VM resources"
}

variable "admin_username" {
  description = "Name of the VM admin account"
}

variable "admin_password" {
  description = "Password of the VM admin account"
  default     = null
}

variable "os_managed_disk_type" {
  default = "Standard_LRS"
}

variable "data_managed_disk_type" {
  default = "Standard_LRS"
}

variable "ssh_key" {
  description = "description"
  default     = null
}

variable "disable_password_authentication" {
  description = "description"
  default     = "false"
}

variable "custom_data" {
  description = "Specifies custom data to supply to the machine. On Linux-based systems, this can be used as a cloud-init script. On other systems, this will be copied as a file on disk. Internally, Terraform will base64 encode this value before sending it to the API. The maximum length of the binary array is 65535 bytes."
  default     = null
}

variable "vm_size" {
  description = "Specifies the size of the Virtual Machine. Eg: Standard_F4"
}

variable "storage_image_reference" {
  description = "This block provisions the Virtual Machine from one of two sources: an Azure Platform Image (e.g. Ubuntu/Windows Server) or a Custom Image. Refer to https://www.terraform.io/docs/providers/azurerm/r/virtual_machine.html for more details."
  default = {
    publisher = "RedHat",
    offer     = "RHEL",
    sku       = "7.4",
    version   = "latest"
  }
}

variable "plan" {
  description = "An optional plan block"
  default     = null
}

variable "storage_os_disk" {
  description = "This block describe the parameters for the OS disk. Refer to https://www.terraform.io/docs/providers/azurerm/r/virtual_machine.html for more details."
  default = {
    caching       = "ReadWrite"
    create_option = "FromImage"
    os_type       = null
    disk_size_gb  = null
  }
}

variable "license_type" {
  description = "BYOL license type for those with Azure Hybrid Benefit"
  default     = null
}

variable "provision_vm_agent" {
  type    = bool
  default = true
}

variable "boot_diagnostic" {
  default = false
}

variable "availability_set_id" {
  description = "Sets the id for the availability set to use for the VM"
  default     = null
}

variable "use_nic_nsg" {
  default = true
}

variable "priority" {
  description = "Specifies the priority of this Virtual Machine. Possible values are Regular and Spot. Defaults to Regular. Changing this forces a new resource to be created."
  default     = "Regular"
}

variable "eviction_policy" {
  description = "Specifies what should happen when the Virtual Machine is evicted for price reasons when using a Spot instance. At this time the only supported value is Deallocate. Changing this forces a new resource to be created."
  default     = "Deallocate"
}