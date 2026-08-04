config {
  call_module_type = "local"
  force            = false
}

# ESLZ/linux_virtual_machine.tf is copied verbatim into an L2 blueprint that
# already declares its own root `terraform {}` block - adding one here would
# collide with it on copy-paste. These two rules are disabled for this
# directory only; the module root's own .tflint.hcl still enforces both.
rule "terraform_required_version" {
  enabled = false
}

rule "terraform_required_providers" {
  enabled = false
}

rule "terraform_module_pinned_source" {
  enabled = true
}
