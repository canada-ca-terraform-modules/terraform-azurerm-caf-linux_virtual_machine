variable "tags" {
  description = "Tags that will be associated to VM resources"
  type        = map(string)
  default = {
    "exampleTag1" = "SomeValue1"
    "exampleTag1" = "SomeValue2"
  }
}

variable "env" {
  description = "4 chars defining the environment name prefix for the VM. Example: ScSc"
  type        = string
}

variable "serverType" {
  description = "3 chars server type code for the VM."
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

variable "data_disks" {
  description = "Map of object of disk sizes in gigabytes and lun number for each desired data disks. See variable.tf file for example"
  type = any
  default = {}
  /*
    Example: 

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
  */
}

variable "subnet" {
  description = "subnet object to which the VM NIC will connect to"
  type        = any
}

variable "dnsServers" {
  description = "List of DNS servers IP addresses to use for this NIC, overrides the VNet-level server list. See variable.tf file for example"
  type        = list(string)
  default     = null
  /*
    Example: 

    dnsServers = ["168.63.129.16", "8.8.8.8"]
  */
}

variable "encryption_at_host_enabled" {
  default = false
}

variable "nic_enable_ip_forwarding" {
  description = "Enables IP Forwarding on the NIC."
  type        = bool
  default     = false
}

variable "nic_enable_accelerated_networking" {
  description = "Enables Azure Accelerated Networking using SR-IOV. Only certain VM instance sizes are supported."
  type        = bool
  default     = false
}

variable "nic_ip_configuration" {
  description = "Defines how a private IP address is assigned. Options are Static or Dynamic. In case of Static also specifiy the desired privat IP address. See variable.tf file for example"
  type = object({
    private_ip_address            = list(string)
    private_ip_address_allocation = list(string)
  })
  default = {
    private_ip_address            = [null]
    private_ip_address_allocation = ["Dynamic"]
  }
  /*
    Example variable for a NIC with 2 staticly assigned IP and one dynamic:

    ```hcl
    nic_ip_configuration = {
      private_ip_address            = ["10.20.30.42","10.20.40.43",null]
      private_ip_address_allocation = ["Static","Static","Dynamic"]
    }
    ```
  */
}

variable "load_balancer_backend_address_pools_ids" {
  description = "List of Load Balancer Backend Address Pool IDs references to which this NIC belongs"
  type        = list(string)
  default     = []
}

variable "security_rules" {
  description = "Security rules to apply to the VM NIC"
  type        = list(map(string))
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
  description = "ASG object to join the NIC to"
  type        = any
  default     = null
}

variable "public_ip" {
  description = "Should the VM be assigned public IP(s). True or false."
  type        = bool
  default     = false
}

variable "resource_group" {
  description = "Resourcegroup object that will contain the VM resources"
  type        = any
}

variable "admin_username" {
  description = "Name of the VM admin account"
  type        = string
}

variable "admin_password" {
  description = "Password of the VM admin account"
  type        = string
  default     = null
}

variable "os_managed_disk_type" {
  description = "Specifies the type of OS Managed Disk which should be created. Possible values are Standard_LRS or Premium_LRS."
  type        = string
  default     = "Standard_LRS"
}

variable "data_managed_disk_type" {
  description = "Specifies the type of Data Managed Disk which should be created. Possible values are Standard_LRS or Premium_LRS."
  type        = string
  default     = "Standard_LRS"
}

variable "ssh_key" {
  description = "The Public SSH Key."
  type        = string
  default     = null
}

variable "disable_password_authentication" {
  description = "Specifies whether password authentication should be disabled. If set to false, an admin_password must be specified."
  type        = bool
  default     = "false"
}

variable "custom_data" {
  description = "Specifies custom data to supply to the machine. On Linux-based systems, this can be used as a cloud-init script. On other systems, this will be copied as a file on disk. Internally, Terraform will base64 encode this value before sending it to the API. The maximum length of the binary array is 65535 bytes."
  type        = string
  default     = null
}

variable "vm_size" {
  description = "Specifies the size of the Virtual Machine. Eg: Standard_F4"
  type        = string
}

variable "storage_image_reference" {
  description = "This block provisions the Virtual Machine from one of two sources: an Azure Platform Image (e.g. Ubuntu/Windows Server) or a Custom Image. Refer to https://www.terraform.io/docs/providers/azurerm/r/virtual_machine.html for more details."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "RedHat",
    offer     = "RHEL",
    sku       = "7.4",
    version   = "latest"
  }
}

variable "plan" {
  description = "An optional plan block"
  type = object({
    name      = string
    product   = string
    publisher = string
  })
  default = null
}

variable "storage_os_disk" {
  description = "This block describe the parameters for the OS disk. Refer to https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine#os_disk for more details."
  type = object({
    caching       = string
    create_option = string
    disk_size_gb  = number
  })
  default = {
    caching       = "ReadWrite"
    create_option = "FromImage"
    disk_size_gb  = null
  }
}

variable "provision_vm_agent" {
  description = "Should an Azure VM Agent be provisionned on the VM"
  type        = bool
  default     = true
}

variable "boot_diagnostic" {
  description = "Should a boot be turned on or not"
  type        = bool
  default     = false
}

variable "ultra_ssd_enabled" {
  description = "Should the capacity to enable Data Disks of the UltraSSD_LRS storage account type be supported on this Virtual Machine?"
  type        = bool
  default     = false
}

variable "zone" {
  description = "The Zone in which this Virtual Machine should be created. Changing this forces a new resource to be created."
  type        = any
  default     = null
}

variable "availability_set_id" {
  description = "Sets the id for the availability set to use for the VM"
  type        = string
  default     = null
}

variable "use_nic_nsg" {
  description = "Should a NIC NSG be used"
  type        = bool
  default     = true
}

variable "priority" {
  description = "Specifies the priority of this Virtual Machine. Possible values are Regular and Spot. Defaults to Regular. Changing this forces a new resource to be created."
  type        = string
  default     = "Regular"
}

variable "eviction_policy" {
  description = "Specifies what should happen when the Virtual Machine is evicted for price reasons when using a Spot instance. At this time the only supported value is Deallocate. Changing this forces a new resource to be created."
  type        = string
  default     = "Deallocate"
}

variable "license_type" {
  description = " (Optional) Specifies the BYOL Type for this Virtual Machine. Possible values are RHEL_BYOS and SLES_BYOS."
  type        = string
  default     = null
}