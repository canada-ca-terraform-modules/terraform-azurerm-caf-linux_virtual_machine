locals {
  linux_virtual_machine_regex = "/[//\"'\\[\\]:|<>+=;,?*@&]/" # Can't include those characters in linus_virtual_machine name: \/"'[]:|<>+=;,?*@&
  env_4                       = substr(var.env, 0, 4)
  serverType_3                = substr(var.serverType, 0, 3)
  postfix_3                   = substr(var.postfix, 0, 3)
  userDefinedString_56        = substr(var.userDefinedString, 0, 56 - length(local.postfix_3))
  vm-name                     = replace("${local.env_4}${local.serverType_3}-${local.userDefinedString_56}${local.postfix_3}", local.linux_virtual_machine_regex, "")
}