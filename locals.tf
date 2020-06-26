# This local is used to create a simple array with a single plan object if a plan is specified as an optional variable

locals {
  module_tag = {
    "module" = basename(abspath(path.module))
  }
  tags                        = merge(var.tags, local.module_tag)
  linux_virtual_machine_regex = "/[//\"'\\[\\]:|<>+=;,?*@&]/" # Can't include those characters in linus_virtual_machine name: \/"'[]:|<>+=;,?*@&
  env_4                       = substr(var.env, 0, 4)
  serverType_3                = substr(var.serverType, 0, 3)
  postfix_3                   = substr(var.postfix, 0, 3)
  userDefinedString_56        = substr(var.userDefinedString, 0, 56 - length(local.postfix_3))
  vm-name                     = replace("${local.env_4}${local.serverType_3}-${local.userDefinedString_56}${local.postfix_3}", local.linux_virtual_machine_regex, "")
  plan                        = var.plan == null ? [] : [var.plan]
  ssh_key                     = var.ssh_key == null ? [] : [var.ssh_key]
  boot_diagnostic             = var.boot_diagnostic ? ["1"] : []
  unique                      = substr(sha1(var.resource_group.id), 0, 8)
  fixname                     = replace(local.vm-name, "-", "")
  fixname2                    = replace(local.fixname, "_", "")
  fixname3                    = substr("${local.fixname2}diag", 0, 16)
  storageName                 = lower("${local.fixname3}${local.unique}")
  eviction_policy             = var.priority == "Regular" ? null : var.eviction_policy
}
