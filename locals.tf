# This local is used to create a simple array with a single plan object if a plan is specified as an optional variable

locals {
  module_tag = {
    "module" = basename(abspath(path.module))
  }
  tags                    = merge(var.tags, local.module_tag)
  plan                    = var.plan == null ? [] : [var.plan]
  storage_image_reference = var.storage_image_reference == null ? [] : var.storage_image_reference
  ssh_key                 = var.ssh_key == null ? [] : [var.ssh_key]
  boot_diagnostic         = var.boot_diagnostic ? ["1"] : []
  unique                  = substr(sha1(var.resource_group.id), 0, 8)
  fixname                 = replace(local.vm-name, "-", "")
  fixname2                = replace(local.fixname, "_", "")
  fixname3                = substr("${local.fixname2}diag", 0, 16)
  storageName             = lower("${local.fixname3}${local.unique}")
  eviction_policy         = var.priority == "Regular" ? null : var.eviction_policy
}
