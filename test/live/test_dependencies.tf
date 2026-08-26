# test_dependencies.tf
# Self-contained dependency resources, owned entirely by this harness.
#
# Deliberately NOT reusing any shared/production resource group, vnet, or
# subnet: writing into a shared L1-managed "Network" RG usually requires
# elevated, L1-scoped permissions. A dedicated throwaway RG + vnet + subnet
# here needs only Contributor on the sandbox subscription and can never
# collide with or affect any production resource.

resource "azurerm_resource_group" "live_test" {
  # PR-number suffix keeps two concurrently open PRs against this module from
  # colliding on the same sandbox resources.
  name     = "${var.env}-caf-linux-vm-live-test-${var.pr_number}-rg"
  location = var.location

  # pr-number tag (ticket 13): lets the nightly orphan sweeper find this RG
  # by tag and match it back to a PR, independent of naming convention.
  tags = {
    "pr-number" = var.pr_number
  }
}

resource "azurerm_virtual_network" "live_test" {
  name                = "${var.env}-caf-linux-vm-live-test-${var.pr_number}-vnet"
  address_space       = ["10.254.0.0/16"] # arbitrary, unpeered - collision-safe by construction
  location            = azurerm_resource_group.live_test.location
  resource_group_name = azurerm_resource_group.live_test.name
}

resource "azurerm_subnet" "live_test" {
  name                 = "${var.env}-caf-linux-vm-live-test-${var.pr_number}-snet"
  resource_group_name  = azurerm_resource_group.live_test.name
  virtual_network_name = azurerm_virtual_network.live_test.name
  address_prefixes     = ["10.254.0.0/24"]
}

locals {
  # terraform-azurerm-caf-linux_virtual_machine takes resource_group/subnet
  # as direct OBJECTS, not map+key lookups - so single locals here, not maps.
  resource_group = {
    id       = azurerm_resource_group.live_test.id
    name     = azurerm_resource_group.live_test.name
    location = azurerm_resource_group.live_test.location
  }
  subnet = {
    id = azurerm_subnet.live_test.id
  }
}
