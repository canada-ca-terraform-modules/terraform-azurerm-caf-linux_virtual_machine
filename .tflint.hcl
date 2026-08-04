config {
  call_module_type = "local"
  force            = false
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_module_pinned_source" {
  enabled = true
}

rule "terraform_naming_convention" {
  enabled = false # legacy CAF module uses hyphenated locals / camelCase public vars; renaming is a breaking change out of scope for a provider upgrade
}
