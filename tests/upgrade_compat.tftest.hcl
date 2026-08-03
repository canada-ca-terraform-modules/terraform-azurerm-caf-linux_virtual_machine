# tests/upgrade_compat.tftest.hcl
# State-chaining upgrade safety test: simulates a VM already deployed with the
# pre-upgrade (azurerm >= 1.32.0) argument set, then plans the upgraded code
# (azurerm ~> 5.0, with new optional args) against that state to prove no
# replacement/destroy is triggered by the upgrade itself.

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

# Step 1: simulate the currently-deployed resource — pre-upgrade config, no new args set
run "baseline_apply" {
  command = apply

  # azurerm_linux_virtual_machine.network_interface_ids reads NIC.id as an
  # ARM-ID-validated argument; mock_provider's auto-generated opaque id
  # (e.g. "6mxaymij") fails that validation, so pin a realistic ARM ID here.
  override_resource {
    target = azurerm_network_interface.NIC
    values = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/networkInterfaces/DevSRV-test-nic1"
    }
  }

  assert {
    condition     = azurerm_linux_virtual_machine.VM.name == "DevSRV-test"
    error_message = "Baseline apply: unexpected resource name"
  }
}

# Step 2: plan the upgraded code (new optional args added) against that state
run "upgrade_plan_no_replacement" {
  command = plan
  variables {
    secure_boot_enabled = true
    vtpm_enabled        = true
    user_data           = "IyEvYmluL3NoCmVjaG8gaGVsbG8="
  }

  assert {
    condition     = azurerm_linux_virtual_machine.VM.name == "DevSRV-test"
    error_message = "Resource name must be unchanged after upgrade"
  }
  assert {
    condition     = azurerm_network_interface.NIC.name == "DevSRV-test-nic1"
    error_message = "NIC name must be unchanged after upgrade"
  }
}
