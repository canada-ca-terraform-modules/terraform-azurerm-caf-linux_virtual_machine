terraform {
  required_version = ">= 0.12"
  required_providers {
    azurerm = ">= 1.32.0"
  }
}

resource "azurerm_network_security_group" "NSG" {
  count               = var.use_nic_nsg ? 1 : 0
  name                = "${local.vm-name}-nsg"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  dynamic "security_rule" {
    for_each = [for s in var.security_rules : {
      name                       = s.name
      priority                   = s.priority
      direction                  = s.direction
      access                     = s.access
      protocol                   = s.protocol
      source_port_ranges         = split(",", replace(s.source_port_ranges, "*", "0-65535"))
      destination_port_ranges    = split(",", replace(s.destination_port_ranges, "*", "0-65535"))
      source_address_prefix      = s.source_address_prefix
      destination_address_prefix = s.destination_address_prefix
      description                = s.description
    }]
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_ranges         = security_rule.value.source_port_ranges
      destination_port_ranges    = security_rule.value.destination_port_ranges
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
      description                = security_rule.value.description
    }
  }
  tags = local.tags
}

resource "azurerm_storage_account" "boot_diagnostic" {
  count                    = var.boot_diagnostic ? 1 : 0
  name                     = local.storageName
  resource_group_name      = var.resource_group.name
  location                 = var.resource_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# If public_ip is true then create resource. If not then do not create any
resource "azurerm_public_ip" "VM-EXT-PubIP" {
  count               = var.public_ip ? length(var.nic_ip_configuration.private_ip_address_allocation) : 0
  name                = "${local.vm-name}-pip${count.index + 1}"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  sku                 = "Standard"
  allocation_method   = "Static"
  tags                = local.tags
}

resource "azurerm_network_interface" "NIC" {
  name                          = "${local.vm-name}-nic1"
  depends_on                    = [var.nic_depends_on]
  location                      = var.resource_group.location
  resource_group_name           = var.resource_group.name
  ip_forwarding_enabled          = var.ip_forwarding_enabled
  accelerated_networking_enabled = var.accelerated_networking_enabled
  dns_servers                   = var.dnsServers
  dynamic "ip_configuration" {
    for_each = var.nic_ip_configuration.private_ip_address_allocation
    content {
      name                          = "ipconfig${ip_configuration.key + 1}"
      subnet_id                     = var.subnet.id
      private_ip_address            = var.nic_ip_configuration.private_ip_address[ip_configuration.key]
      private_ip_address_allocation = var.nic_ip_configuration.private_ip_address_allocation[ip_configuration.key]
      public_ip_address_id          = var.public_ip ? azurerm_public_ip.VM-EXT-PubIP[ip_configuration.key].id : null
      primary                       = ip_configuration.key == 0 ? true : false
    }
  }
  tags = local.tags
}

resource "azurerm_network_interface_backend_address_pool_association" "LB" {
  for_each = toset(var.load_balancer_backend_address_pools_ids)

  network_interface_id    = azurerm_network_interface.NIC.id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = each.key
}

resource "azurerm_network_interface_application_security_group_association" "asg" {
  count                         = var.asg != null ? 1 : 0
  network_interface_id          = azurerm_network_interface.NIC.id
  application_security_group_id = var.asg.id
}

resource "azurerm_network_interface_security_group_association" "nic-nsg" {
  count                     = var.use_nic_nsg ? 1 : 0
  network_interface_id      = azurerm_network_interface.NIC.id
  network_security_group_id = azurerm_network_security_group.NSG[0].id
}

moved {
  from = azurerm_network_interface_security_group_association.nic-nsg
  to   = azurerm_network_interface_security_group_association.nic-nsg[0]
}

resource "azurerm_linux_virtual_machine" "VM" {
  name                            = local.vm-name
  depends_on                      = [var.vm_depends_on]
  location                        = var.resource_group.location
  resource_group_name             = var.resource_group.name
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = var.disable_password_authentication
  computer_name                   = var.computer_name
  custom_data                     = var.custom_data
  size                            = var.vm_size
  priority                        = var.priority
  eviction_policy                 = local.eviction_policy
  network_interface_ids           = [azurerm_network_interface.NIC.id]
  availability_set_id             = var.availability_set_id
  encryption_at_host_enabled      = var.encryption_at_host_enabled
  license_type                    = var.license_type
  patch_mode                      = var.patch_mode
  patch_assessment_mode           = var.patch_assessment_mode
  dynamic "admin_ssh_key" {
    for_each = local.ssh_key
    content {
      public_key = local.ssh_key[0]
      username   = var.admin_username
    }
  }
  source_image_id = var.source_image_id
  dynamic "source_image_reference" {
    for_each = var.source_image_id == null ? ["1"] : [] # If there is a source image id provided then don't use source_image_reference
    content {
      publisher = var.storage_image_reference.publisher
      offer     = var.storage_image_reference.offer
      sku       = var.storage_image_reference.sku
      version   = var.storage_image_reference.version
    }
  }
  dynamic "plan" {
    for_each = local.plan
    content {
      name      = local.plan[0].name
      product   = local.plan[0].product
      publisher = local.plan[0].publisher
    }
  }
  provision_vm_agent = var.provision_vm_agent
  os_disk {
    name                 = "${local.vm-name}-osdisk1"
    caching              = var.storage_os_disk.caching
    storage_account_type = var.os_managed_disk_type
    disk_size_gb         = var.storage_os_disk.disk_size_gb
  }
  zone = var.zone
  dynamic "additional_capabilities" {
    for_each = var.ultra_ssd_enabled ? ["1"] : []
    content {
      ultra_ssd_enabled = true
    }
  }
  dynamic "boot_diagnostics" {
    for_each = local.boot_diagnostic
    content {
      storage_account_uri = azurerm_storage_account.boot_diagnostic[0].primary_blob_endpoint
    }
  }
  tags = merge(local.tags,[var.computer_name != null ? {"OsHostname" = var.computer_name}: null]...)
  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      admin_username,
      admin_password,
      identity,
      license_type,
      os_disk, # Prevent restored OS disks from causinf terraform to attempt to re-create the original os disk name and break the restores OS
      custom_data,
      additional_capabilities,
      gallery_application
    ]
  }
}

resource "azurerm_managed_disk" "data_disks" {
  for_each = var.data_disks

  name                 = "${local.vm-name}-datadisk${each.value.lun + 1}"
  location             = var.resource_group.location
  resource_group_name  = var.resource_group.name
  storage_account_type = lookup(each.value, "storage_account_type", var.data_managed_disk_type)
  create_option        = lookup(each.value, "create_option", "Empty")
  disk_size_gb         = each.value.disk_size_gb
  disk_iops_read_write = lookup(each.value, "disk_iops_read_write", null)
  disk_mbps_read_write = lookup(each.value, "disk_mbps_read_write", null)
  zone                 = lookup(each.value, "zone", null)
  lifecycle {
    ignore_changes = [
      name,               # Prevent restored data disks from causing terraform to attempt to re-create the original os disk name and break the restores OS
      create_option,      # Prevent restored data disks from causing terraform to attempt to re-create the original os disk name and break the restores OS
      source_resource_id, # Prevent restored data disks from causing terraform to attempt to re-create the original os disk name and break the restores OS
      tags,               # Prevent restored data disks from causing terraform to attempt to re-create the original os disk name and break the restores OS
      zone,               # Prevent restored data disks from causing terraform to attempt to re-create the original os disk name and break the restores OS
      
    ]
  }
}

resource "azurerm_virtual_machine_data_disk_attachment" "data_disks" {
  #count = length(var.data_disk_sizes_gb)
  for_each = var.data_disks

  managed_disk_id    = azurerm_managed_disk.data_disks[each.key].id
  virtual_machine_id = azurerm_linux_virtual_machine.VM.id
  lun                = each.value.lun
  caching            = lookup(each.value, "caching", "ReadWrite")
  lifecycle {
    ignore_changes = [
      managed_disk_id, # Prevent restored data disks from causing terraform to attempt to re-create the original os disk name and break the restores OS
      virtual_machine_id, # Prevent restored data disks from causing terraform to attempt to re-create the original os disk name and break the restores OS
    ]
  }
}

resource "azurerm_backup_protected_vm" "backup_vm" {
  count               = var.backup ? 1 : 0
  resource_group_name = var.recovery_vault.resource_group_name
  recovery_vault_name = var.recovery_vault.name
  source_vm_id        = azurerm_linux_virtual_machine.VM.id
  backup_policy_id    = var.backup_policy_id
  lifecycle {
    # Required otherwise it want to replace the resource
    ignore_changes = [
      source_vm_id,
    ]
  }
}
