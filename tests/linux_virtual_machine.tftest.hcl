# tests/linux_virtual_machine.tftest.hcl
# Functional plan-only tests using mock_provider — no Azure credentials needed.

mock_provider "azurerm" {}
mock_provider "random" {}

variables {
  env               = "Dev"
  userDefinedString = "test"
  admin_username    = "adminuser"
  vm_size           = "Standard_D2s_v5"
  resource_group = {
    name     = "rg-test"
    location = "canadacentral"
    id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test"
  }
  subnet = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/subnet-test"
  }
  ssh_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1sAiP3+GKrjCkHUL/jTIcm5CO/DMZTFxOL7whIfDYSVEMrT930kJOCW1WfK5bQaF8I9JtenmExWcfyMiDKn8yLiBb23Xu9QPaenUUB98i+CTUCKiZK3fvpVMj1nIsXMCqz6YsJrZv13++06htJ5slVw1nbjXyKSuHREcAT26YDiM2SNx9B9mAEpep+GFTHt9YO+qV3Cjhmx0izomrp2vjBROp3CABWz4tG/kWomNe3pgV8iE14z1Fcqn8tjCMN9QY50BiAreOCYW1NVLdOiadRcBEtynmdptAjZtnbOpQKZKL3ypxNkGm2nWZL8Lt7/Cm7KG/bE9DWs14IM0fUWiN test"
}

run "naming_convention" {
  command = plan

  assert {
    condition     = azurerm_linux_virtual_machine.VM.name == "DevSRV-test"
    error_message = "Name must follow {env4}{serverType3}-{userDefinedString}{postfix} convention"
  }
}

run "default_values" {
  command = plan

  assert {
    condition     = azurerm_linux_virtual_machine.VM.size == "Standard_D2s_v5"
    error_message = "Plan must succeed with minimal required inputs"
  }
  assert {
    condition     = azurerm_linux_virtual_machine.VM.disable_password_authentication == false
    error_message = "disable_password_authentication default must be false"
  }
  assert {
    condition     = length(azurerm_network_security_group.NSG) == 0
    error_message = "NSG must not be created when use_nic_nsg is false (default)"
  }
}

run "custom_resource_names" {
  command = plan
  variables {
    vm_name                              = "existing-prod-vm"
    nic_name                             = "existing-prod-nic"
    nsg_name                             = "existing-prod-nsg"
    os_disk_name                         = "existing-prod-osdisk"
    boot_diagnostic_storage_account_name = "existingprodsa"
    use_nic_nsg                          = true
    boot_diagnostic                      = true
  }

  assert {
    condition     = azurerm_linux_virtual_machine.VM.name == "existing-prod-vm"
    error_message = "vm_name override not applied"
  }
  assert {
    condition     = azurerm_network_interface.NIC.name == "existing-prod-nic"
    error_message = "nic_name override not applied"
  }
  assert {
    condition     = azurerm_network_security_group.NSG[0].name == "existing-prod-nsg"
    error_message = "nsg_name override not applied"
  }
  assert {
    condition     = azurerm_linux_virtual_machine.VM.os_disk[0].name == "existing-prod-osdisk"
    error_message = "os_disk_name override not applied"
  }
  assert {
    condition     = azurerm_storage_account.boot_diagnostic[0].name == "existingprodsa"
    error_message = "boot_diagnostic_storage_account_name override not applied"
  }
}

run "identity_system_assigned" {
  command = plan
  variables {
    identity = {
      type = "SystemAssigned"
    }
  }

  assert {
    condition     = azurerm_linux_virtual_machine.VM.identity[0].type == "SystemAssigned"
    error_message = "identity block must be set when var.identity is provided"
  }
}

run "identity_user_assigned" {
  command = plan
  variables {
    identity = {
      type         = "UserAssigned"
      identity_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uami-test"]
    }
  }

  assert {
    condition     = azurerm_linux_virtual_machine.VM.identity[0].type == "UserAssigned"
    error_message = "identity.type must be UserAssigned"
  }
  assert {
    condition     = length(azurerm_linux_virtual_machine.VM.identity[0].identity_ids) == 1
    error_message = "identity.identity_ids must be passed through"
  }
}

run "no_identity" {
  command = plan

  assert {
    condition     = length(azurerm_linux_virtual_machine.VM.identity) == 0
    error_message = "identity block must not be emitted when var.identity is null (default)"
  }
}

run "trusted_launch" {
  command = plan
  variables {
    secure_boot_enabled = true
    vtpm_enabled        = true
  }

  assert {
    condition     = azurerm_linux_virtual_machine.VM.secure_boot_enabled == true
    error_message = "secure_boot_enabled must be passed through"
  }
  assert {
    condition     = azurerm_linux_virtual_machine.VM.vtpm_enabled == true
    error_message = "vtpm_enabled must be passed through"
  }
}

run "user_data" {
  command = plan
  variables {
    user_data = "IyEvYmluL3NoCmVjaG8gaGVsbG8="
  }

  assert {
    condition     = azurerm_linux_virtual_machine.VM.user_data == "IyEvYmluL3NoCmVjaG8gaGVsbG8="
    error_message = "user_data must be passed through"
  }
}

run "public_ip_with_zones" {
  command = plan
  variables {
    public_ip       = true
    public_ip_zones = ["1", "2"]
  }

  assert {
    condition     = length(azurerm_public_ip.VM-EXT-PubIP) == 1
    error_message = "Public IP must be created when public_ip is true"
  }
  assert {
    condition     = length(azurerm_public_ip.VM-EXT-PubIP[0].zones) == 2
    error_message = "public_ip_zones must be passed through"
  }
}

run "public_ip_no_zones" {
  command = plan
  variables {
    public_ip = true
  }

  assert {
    condition     = azurerm_public_ip.VM-EXT-PubIP[0].zones == null
    error_message = "public_ip_zones must default to null (no zone pinning)"
  }
}

run "use_nic_nsg" {
  command = plan
  variables {
    use_nic_nsg = true
  }

  assert {
    condition     = length(azurerm_network_security_group.NSG) == 1
    error_message = "NSG must be created when use_nic_nsg is true"
  }
  assert {
    condition     = length(azurerm_network_interface_security_group_association.nic-nsg) == 1
    error_message = "NIC-NSG association must be created when use_nic_nsg is true"
  }
}

run "data_disks_default_and_override_name" {
  command = plan
  variables {
    data_disks = {
      "data1" = {
        disk_size_gb = 50
        lun          = 0
      },
      "data2" = {
        disk_size_gb = 100
        lun          = 1
        name         = "existing-prod-datadisk2"
      }
    }
  }

  assert {
    condition     = azurerm_managed_disk.data_disks["data1"].name == "DevSRV-test-datadisk1"
    error_message = "Data disk name must default to <vm-name>-datadisk<lun+1>"
  }
  assert {
    condition     = azurerm_managed_disk.data_disks["data2"].name == "existing-prod-datadisk2"
    error_message = "Data disk name override not applied"
  }
}

run "backup_enabled" {
  command = plan
  variables {
    backup           = true
    backup_policy_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.RecoveryServices/vaults/vault-test/backupPolicies/policy-test"
    recovery_vault = {
      name                = "vault-test"
      resource_group_name = "rg-test"
    }
  }

  assert {
    condition     = length(azurerm_backup_protected_vm.backup_vm) == 1
    error_message = "Backup protected VM must be created when backup is true"
  }
}

run "spot_priority" {
  command = plan
  variables {
    priority        = "Spot"
    eviction_policy = "Deallocate"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.VM.priority == "Spot"
    error_message = "priority must be Spot"
  }
  assert {
    condition     = azurerm_linux_virtual_machine.VM.eviction_policy == "Deallocate"
    error_message = "eviction_policy must apply when priority is Spot"
  }
}

run "boot_diagnostic_enabled" {
  command = plan
  variables {
    boot_diagnostic = true
  }

  assert {
    condition     = length(azurerm_storage_account.boot_diagnostic) == 1
    error_message = "Boot diagnostic storage account must be created when boot_diagnostic is true"
  }
}

run "ultra_ssd_enabled" {
  command = plan
  variables {
    ultra_ssd_enabled = true
  }

  assert {
    condition     = azurerm_linux_virtual_machine.VM.additional_capabilities[0].ultra_ssd_enabled == true
    error_message = "additional_capabilities.ultra_ssd_enabled must be true"
  }
}

run "patch_settings" {
  command = plan
  variables {
    provision_vm_agent    = true
    patch_mode            = "AutomaticByPlatform"
    patch_assessment_mode = "AutomaticByPlatform"
  }

  assert {
    condition     = azurerm_linux_virtual_machine.VM.patch_mode == "AutomaticByPlatform"
    error_message = "patch_mode must be passed through"
  }
  assert {
    condition     = azurerm_linux_virtual_machine.VM.patch_assessment_mode == "AutomaticByPlatform"
    error_message = "patch_assessment_mode must be passed through"
  }
}

run "monitoring_agent_extension" {
  command = plan
  variables {
    monitoringAgent = {
      workspace_id       = "00000000-0000-0000-0000-000000000000"
      primary_shared_key = "dGVzdC1rZXk="
    }
  }

  assert {
    condition     = length(azurerm_virtual_machine_extension.OmsAgentForLinux) == 1
    error_message = "OmsAgentForLinux extension must be created when monitoringAgent is set"
  }
}

run "dependancy_agent_extension" {
  command = plan
  variables {
    dependancyAgent = true
  }

  assert {
    condition     = length(azurerm_virtual_machine_extension.DAAgentForLinux) == 1
    error_message = "DAAgentForLinux extension must be created when dependancyAgent is true"
  }
}

run "autoshutdown_config" {
  command = plan
  variables {
    shutdownConfig = {
      autoShutdownStatus             = "Enabled"
      autoShutdownTime               = "17:00"
      autoShutdownTimeZone           = "Eastern Standard Time"
      autoShutdownNotificationStatus = "Disabled"
    }
  }

  assert {
    condition     = length(azurerm_resource_group_template_deployment.autoshutdown) == 1
    error_message = "autoshutdown deployment must be created when shutdownConfig is set"
  }
}

run "disk_encryption" {
  command = plan
  variables {
    encryptDisks = {
      KeyVaultResourceId = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.KeyVault/vaults/kv-test"
      KeyVaultURL        = "https://kv-test.vault.azure.net/"
    }
  }

  assert {
    condition     = length(azurerm_virtual_machine_extension.AzureDiskEncryption) == 1
    error_message = "AzureDiskEncryption extension must be created when encryptDisks is set"
  }
}
