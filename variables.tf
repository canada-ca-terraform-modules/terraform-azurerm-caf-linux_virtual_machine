variable "tags" {
  description = "Tags that will be associated to VM resources"
  type        = map(string)
  default = {
    "exampleTag1" = "SomeValue1"
    "exampleTag2" = "SomeValue2"
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

variable "computer_name" {
  description = "(Optional) VM OS Hostname"
  type        = string
  default     = null
}

variable "data_disks" {
  description = "Map of object of disk sizes in gigabytes and lun number for each desired data disks. See variable.tf file for example"
  type        = any
  default     = {}
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
  description = "(Optional) Should all of the disks (including the temp disk) attached to this Virtual Machine be encrypted by enabling Encryption at Host?"
  type        = bool
  default     = false
}

variable "ip_forwarding_enabled" {
  description = "Enables IP Forwarding on the NIC."
  type        = bool
  default     = false
}

variable "accelerated_networking_enabled" {
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
  # WARNING: the default value below is permissive (allow all inbound + all
  # outbound, all ports/protocols). It only takes effect when use_nic_nsg =
  # true and no explicit security_rules are supplied. Override this variable
  # with least-privilege rules for any production/GC workload NSG. See
  # README.md "Security" section.
  description = "Security rules to apply to the VM NIC. WARNING: default is permissive (allow all in/out) - override for production use when use_nic_nsg = true."
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
  default     = false
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
  description = "(Optional) This block provisions the Virtual Machine from one of two sources: an Azure Platform Image (e.g. Ubuntu/Windows Server) or a Custom Image. Refer to https://www.terraform.io/docs/providers/azurerm/r/virtual_machine.html for more details."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  # Default is a currently-supported RHEL SKU (9-lvm). The previous default
  # (RHEL 7.4) reached end-of-support in 2024 - callers relying on the
  # default no longer got a patchable image. Safe to change: this argument
  # is in azurerm_linux_virtual_machine.VM's lifecycle.ignore_changes list
  # in main.tf, so it does not force replacement of already-deployed VMs.
  default = {
    publisher = "RedHat",
    offer     = "RHEL",
    sku       = "9-lvm",
    version   = "latest"
  }
}

variable "source_image_id" {
  description = "(Optional) The ID of the Image which this Virtual Machine should be created from. Changing this forces a new resource to be created."
  type        = string
  default     = null
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
  default     = false
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

# Backup related vars
variable "backup" {
  description = "Specifies the id of the backup policy to use."
  type        = bool
  default     = false
}

variable "backup_policy_id" {
  description = "Specifies the id of the backup policy to use."
  type        = string
  default     = null
}

variable "recovery_vault" {
  description = "The Recovery Services Vault object to use. Changing this forces a new resource to be created."
  type        = any
  default     = null
}

variable "patch_mode" {
  description = "(Optional) Specifies the mode of in-guest patching to this Linux Virtual Machine. Possible values are AutomaticByPlatform and ImageDefault. Defaults to ImageDefault"
  type        = string
  default     = null
}

variable "patch_assessment_mode" {
  description = "(Optional) Specifies the mode of in-guest patching to this Linux Virtual Machine. Possible values are AutomaticByPlatform and ImageDefault. Defaults to ImageDefault."
  type        = string
  default     = null
}

variable "identity" {
  description = "(Optional) An identity block. Object with 'type' (SystemAssigned, UserAssigned or 'SystemAssigned, UserAssigned') and optional 'identity_ids' (list of User Assigned Managed Identity IDs). See variable.tf file for example"
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default = null
  /*
    Example:

    identity = {
      type         = "UserAssigned"
      identity_ids = ["/subscriptions/.../resourceGroups/.../providers/Microsoft.ManagedIdentity/userAssignedIdentities/example"]
    }
  */
}

variable "secure_boot_enabled" {
  description = "(Optional) Specifies whether secure boot should be enabled on the virtual machine. Changing this forces a new resource to be created."
  type        = bool
  default     = null
}

variable "vtpm_enabled" {
  description = "(Optional) Specifies whether vTPM should be enabled on the virtual machine. Changing this forces a new resource to be created."
  type        = bool
  default     = null
}

variable "user_data" {
  description = "(Optional) The Base64-Encoded User Data which should be used for this Virtual Machine."
  type        = string
  default     = null
}

variable "public_ip_zones" {
  description = "(Optional) A collection containing the availability zone(s) to allocate the Public IP(s) in. Changing this forces a new resource to be created."
  type        = list(string)
  default     = null
}

# --- Pattern 12: optional overrides for auto-generated resource names ---
# These allow callers whose already-deployed resource names diverge from the
# module's naming formula to pin the real name without forcing destroy/recreate.

variable "vm_name" {
  description = "(Optional) Override the auto-generated VM name. Defaults to the {env}{serverType}-{userDefinedString}{postfix} naming convention."
  type        = string
  default     = null
}

variable "nic_name" {
  description = "(Optional) Override the auto-generated NIC name. Defaults to '<vm-name>-nic1'."
  type        = string
  default     = null
}

variable "nsg_name" {
  description = "(Optional) Override the auto-generated NSG name. Defaults to '<vm-name>-nsg'."
  type        = string
  default     = null
}

variable "os_disk_name" {
  description = "(Optional) Override the auto-generated OS disk name. Defaults to '<vm-name>-osdisk1'."
  type        = string
  default     = null
}

variable "boot_diagnostic_storage_account_name" {
  description = "(Optional) Override the auto-generated boot diagnostic storage account name."
  type        = string
  default     = null
}
