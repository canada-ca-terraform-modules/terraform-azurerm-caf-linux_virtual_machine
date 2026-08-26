terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 5.0"
    }
  }

  # Empty on purpose: the state file path is supplied at `terraform init`
  # time via `-backend-config="path=..."` (partial configuration), so the
  # target-branch checkout and the PR-branch checkout can point at the same
  # external state file without either owning its own local state.
  backend "local" {}
}

provider "azurerm" {
  storage_use_azuread             = true
  resource_provider_registrations = "legacy"
  features {}
}

module "linux_virtual_machine" {
  # PR code and baseline code are two on-disk checkouts of this same repo,
  # not two resolved git refs - no pinned ?ref, no version toggle here.
  source = "../../"

  env                             = var.env
  userDefinedString               = try(var.linux_virtual_machine.userDefinedString, "livetest")
  resource_group                  = local.resource_group # from test_dependencies.tf
  subnet                          = local.subnet         # from test_dependencies.tf
  admin_username                  = var.linux_virtual_machine.admin_username
  admin_password                  = try(var.linux_virtual_machine.admin_password, null)
  disable_password_authentication = try(var.linux_virtual_machine.disable_password_authentication, false)
  vm_size                         = var.linux_virtual_machine.vm_size
  storage_image_reference         = try(var.linux_virtual_machine.storage_image_reference, null)
  tags                            = var.tags
}
