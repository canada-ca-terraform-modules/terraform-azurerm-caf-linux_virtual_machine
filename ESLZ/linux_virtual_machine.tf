# ESLZ/linux_virtual_machine.tf
# Declares the variables consumed by the module block so L2 callers can wire
# their own var.* values in, and the module block itself. Copy this file into
# an ESLZ L2 blueprint and populate linux_virtual_machines.tfvars.
#
# Provider requirement for this module: azurerm ~> 5.0, required_version >= 1.9
# (see providers.tf in the module root). Do NOT add a `terraform {}` block to
# this file - it is copied verbatim into an L2 blueprint that already declares
# its own root `terraform {}` block, and a second one here would collide with
# it (duplicate required_providers/required_version block error).

variable "linux_virtual_machines" {
  description = "Map of Linux VM configuration objects. See ESLZ/linux_virtual_machine.tfvars for examples of every supported key."
  type        = any
  default     = {}
}

variable "resource_groups" {
  description = "Map of resource group objects (key referenced by each VM's resource_group_key)"
  type        = any
  default     = {}
}

variable "subnets" {
  description = "Map of subnet objects (key referenced by each VM's subnet_key)"
  type        = any
  default     = {}
}

variable "recovery_vaults" {
  description = "Map of Recovery Services Vault objects (optional, only needed when backup = true)"
  type        = any
  default     = {}
}

variable "application_security_groups" {
  description = "Map of Application Security Group objects (optional)"
  type        = any
  default     = {}
}

variable "tags" {
  description = "Tags to apply to all VM resources created by this module block"
  type        = map(string)
  default     = {}
}

module "linux_virtual_machine" {
  source   = "github.com/canada-ca-terraform-modules/terraform-azurerm-caf-linux_virtual_machine?ref=v3.1.0"
  for_each = var.linux_virtual_machines

  # Naming
  env               = each.value.env
  serverType        = try(each.value.serverType, "SRV")
  userDefinedString = each.value.userDefinedString
  postfix           = try(each.value.postfix, "")
  computer_name     = try(each.value.computer_name, null)

  # Placement
  resource_group = var.resource_groups[each.value.resource_group_key]
  subnet         = var.subnets[each.value.subnet_key]

  # Identity / auth
  admin_username                  = each.value.admin_username
  admin_password                  = try(each.value.admin_password, null)
  ssh_key                         = try(each.value.ssh_key, null)
  disable_password_authentication = try(each.value.disable_password_authentication, false)
  identity                        = try(each.value.identity, null)

  # Compute / image
  vm_size                 = each.value.vm_size
  storage_image_reference = try(each.value.storage_image_reference, null)
  source_image_id         = try(each.value.source_image_id, null)
  plan                    = try(each.value.plan, null)
  zone                    = try(each.value.zone, null)
  availability_set_id     = try(each.value.availability_set_id, null)
  priority                = try(each.value.priority, "Regular")
  eviction_policy         = try(each.value.eviction_policy, "Deallocate")
  license_type            = try(each.value.license_type, null)
  provision_vm_agent      = try(each.value.provision_vm_agent, true)
  custom_data             = try(each.value.custom_data, null)
  user_data               = try(each.value.user_data, null)

  # Trusted Launch / host encryption
  secure_boot_enabled        = try(each.value.secure_boot_enabled, null)
  vtpm_enabled               = try(each.value.vtpm_enabled, null)
  encryption_at_host_enabled = try(each.value.encryption_at_host_enabled, false)
  ultra_ssd_enabled          = try(each.value.ultra_ssd_enabled, false)

  # Patching
  patch_mode            = try(each.value.patch_mode, null)
  patch_assessment_mode = try(each.value.patch_assessment_mode, null)

  # Disks
  storage_os_disk        = try(each.value.storage_os_disk, null)
  os_managed_disk_type   = try(each.value.os_managed_disk_type, "Standard_LRS")
  data_managed_disk_type = try(each.value.data_managed_disk_type, "Standard_LRS")
  data_disks             = try(each.value.data_disks, {})

  # Networking
  nic_ip_configuration                    = try(each.value.nic_ip_configuration, null)
  dnsServers                              = try(each.value.dnsServers, null)
  ip_forwarding_enabled                   = try(each.value.ip_forwarding_enabled, false)
  accelerated_networking_enabled          = try(each.value.accelerated_networking_enabled, false)
  load_balancer_backend_address_pools_ids = try(each.value.load_balancer_backend_address_pools_ids, [])
  security_rules                          = try(each.value.security_rules, null)
  use_nic_nsg                             = try(each.value.use_nic_nsg, false)
  asg                                     = try(var.application_security_groups[each.value.asg_key], null)
  public_ip                               = try(each.value.public_ip, false)
  public_ip_zones                         = try(each.value.public_ip_zones, null)

  # Boot diagnostics
  boot_diagnostic                      = try(each.value.boot_diagnostic, false)
  boot_diagnostic_storage_account_name = try(each.value.boot_diagnostic_storage_account_name, null)

  # Backup
  backup           = try(each.value.backup, false)
  backup_policy_id = try(each.value.backup_policy_id, null)
  recovery_vault   = try(var.recovery_vaults[each.value.recovery_vault_key], null)

  # Pattern 12: optional overrides for already-deployed resource names
  vm_name      = try(each.value.vm_name, null)
  nic_name     = try(each.value.nic_name, null)
  nsg_name     = try(each.value.nsg_name, null)
  os_disk_name = try(each.value.os_disk_name, null)

  # Tags
  tags = merge(var.tags, try(each.value.tags, {}))

  # Monitoring / extensions
  monitoringAgent = try(each.value.monitoringAgent, null)
  dependancyAgent = try(each.value.dependancyAgent, false)
  encryptDisks    = try(each.value.encryptDisks, null)
  shutdownConfig  = try(each.value.shutdownConfig, null)

  # Module-level dependency injection (for cross-module sequencing)
  vm_depends_on  = try(each.value.vm_depends_on, null)
  nic_depends_on = try(each.value.nic_depends_on, null)
}
