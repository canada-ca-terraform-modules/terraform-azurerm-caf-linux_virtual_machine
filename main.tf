resource azurerm_network_security_group NSG {
  name                = "${var.name}-nsg"
  count               = var.use_nic_nsg ? 1 : 0
  location            = var.location
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
  tags = var.tags
}

resource "azurerm_storage_account" "boot_diagnostic" {
  count                    = var.boot_diagnostic ? 1 : 0
  name                     = local.storageName
  resource_group_name      = var.resource_group.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# If public_ip is true then create resource. If not then do not create any
resource azurerm_public_ip VM-EXT-PubIP {
  count               = var.public_ip ? length(var.nic_ip_configuration.private_ip_address_allocation) : 0
  name                = "${var.name}-pip${count.index + 1}"
  location            = var.location
  resource_group_name = var.resource_group.name
  sku                 = "Standard"
  allocation_method   = "Static"
  tags                = var.tags
}

resource azurerm_network_interface NIC {
  name                          = "${var.name}-nic1"
  depends_on                    = [var.nic_depends_on]
  location                      = var.location
  resource_group_name           = var.resource_group.name
  enable_ip_forwarding          = var.nic_enable_ip_forwarding
  enable_accelerated_networking = var.nic_enable_accelerated_networking
  #network_security_group_id     = var.use_nic_nsg ? azurerm_network_security_group.NSG[0].id : null
  dns_servers = var.dnsServers
  dynamic "ip_configuration" {
    for_each = var.nic_ip_configuration.private_ip_address_allocation
    content {
      name                          = "ipconfig${ip_configuration.key + 1}"
      subnet_id                     = data.azurerm_subnet.subnet.id
      private_ip_address            = var.nic_ip_configuration.private_ip_address[ip_configuration.key]
      private_ip_address_allocation = var.nic_ip_configuration.private_ip_address_allocation[ip_configuration.key]
      public_ip_address_id          = var.public_ip ? azurerm_public_ip.VM-EXT-PubIP[ip_configuration.key].id : ""
      primary                       = ip_configuration.key == 0 ? true : false
      #load_balancer_backend_address_pools_ids = var.load_balancer_backend_address_pools_ids[ip_configuration.key]
    }
  }
  tags = var.tags
}
/*
resource azurerm_virtual_machine VM {
  name                             = var.name
  depends_on                       = [var.vm_depends_on]
  location                         = var.location
  resource_group_name              = var.resource_group.name
  vm_size                          = var.vm_size
  network_interface_ids            = [azurerm_network_interface.NIC.id]
  primary_network_interface_id     = azurerm_network_interface.NIC.id
  delete_data_disks_on_termination = "true"
  delete_os_disk_on_termination    = "true"
  license_type                     = var.license_type == null ? null : var.license_type
  availability_set_id              = var.availability_set_id
  os_profile {
    computer_name  = var.name
    admin_username = var.admin_username
    admin_password = var.admin_password
    custom_data    = var.custom_data
  }
  storage_image_reference {
    publisher = var.storage_image_reference.publisher
    offer     = var.storage_image_reference.offer
    sku       = var.storage_image_reference.sku
    version   = var.storage_image_reference.version
  }
  dynamic "plan" {
    for_each = local.plan
    content {
      name      = local.plan[0].name
      product   = local.plan[0].product
      publisher = local.plan[0].publisher
    }
  }
  os_profile_linux_config {
    disable_password_authentication = var.disable_password_authentication
    dynamic "ssh_keys" {
      for_each = local.ssh_key
      content {
        key_data = local.ssh_key[0]
        path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      }
    }
  }
  storage_os_disk {
    name              = "${var.name}-osdisk1"
    caching           = var.storage_os_disk.caching
    create_option     = var.storage_os_disk.create_option
    os_type           = var.storage_os_disk.os_type
    disk_size_gb      = var.storage_os_disk.disk_size_gb
    managed_disk_type = var.os_managed_disk_type
  }
  dynamic "storage_data_disk" {
    for_each = var.data_disk_sizes_gb
    content {
      name              = "${var.name}-datadisk${storage_data_disk.key + 1}"
      create_option     = "Empty"
      lun               = storage_data_disk.key
      disk_size_gb      = storage_data_disk.value
      caching           = "ReadWrite"
      managed_disk_type = var.data_managed_disk_type
    }
  }
  dynamic "boot_diagnostics" {
    for_each = local.boot_diagnostic
    content {
      enabled     = true
      storage_uri = azurerm_storage_account.boot_diagnostic[0].primary_blob_endpoint
    }
  }
  tags = var.tags
}
*/

resource azurerm_linux_virtual_machine VM {
  name                            = var.name
  depends_on                      = [var.vm_depends_on]
  location                        = var.location
  resource_group_name             = var.resource_group.name
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = var.disable_password_authentication
  computer_name                   = var.name
  custom_data                     = var.custom_data
  size                            = var.vm_size
  priority                        = var.priority
  eviction_policy                 = local.eviction_policy
  network_interface_ids           = [azurerm_network_interface.NIC.id]
  availability_set_id             = var.availability_set_id
  dynamic "admin_ssh_key" {
    for_each = local.ssh_key
    content {
      public_key = local.ssh_key[0]
      username   = var.admin_username
    }
  }
  source_image_reference {
    publisher = var.storage_image_reference.publisher
    offer     = var.storage_image_reference.offer
    sku       = var.storage_image_reference.sku
    version   = var.storage_image_reference.version
  }
  dynamic "plan" {
    for_each = local.plan
    content {
      name      = local.plan[0].name
      product   = local.plan[0].product
      publisher = local.plan[0].publisher
    }
  }
  provision_vm_agent = true
  os_disk {
    name                 = "${var.name}-osdisk1"
    caching              = var.storage_os_disk.caching
    storage_account_type = var.os_managed_disk_type
    disk_size_gb         = var.storage_os_disk.disk_size_gb
  }
  dynamic "boot_diagnostics" {
    for_each = local.boot_diagnostic
    content {
      storage_account_uri = azurerm_storage_account.boot_diagnostic[0].primary_blob_endpoint
    }
  }
  tags = var.tags
}

resource azurerm_managed_disk data_disks {
  count = length(var.data_disk_sizes_gb)

  name                 = "${var.name}-datadisk${count.index + 1}"
  location             = var.location
  resource_group_name  = var.resource_group.name
  storage_account_type = var.data_managed_disk_type
  create_option        = "Empty"
  disk_size_gb         = var.data_disk_sizes_gb[count.index]
}

resource azurerm_virtual_machine_data_disk_attachment data_disks {
  count = length(var.data_disk_sizes_gb)

  managed_disk_id    = azurerm_managed_disk.data_disks[count.index].id
  virtual_machine_id = azurerm_linux_virtual_machine.VM.id
  lun                = count.index
  caching            = "ReadWrite"
}
