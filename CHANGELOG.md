# Changelog

All notable changes to this module are documented in this file, in the
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format.

## [3.1.0] - 2026-08-03

### Added

- `azurerm` provider requirement pinned to `~> 5.0` in new `providers.tf` (previously unpinned).
- `identity` variable — optional `SystemAssigned`/`UserAssigned`/mixed managed identity block on the VM.
- `secure_boot_enabled` / `vtpm_enabled` variables — Trusted Launch support.
- `user_data` variable — cloud-init-style user data (distinct from `custom_data`).
- `public_ip_zones` variable — pin availability zone(s) for the public IP.
- Pattern 12 name overrides: `vm_name`, `nic_name`, `nsg_name`, `os_disk_name`,
  `boot_diagnostic_storage_account_name`, and a `name` key on each `data_disks` entry —
  let callers pin already-deployed resource names that diverge from the module's
  naming formula without forcing a destroy/recreate.
- `ESLZ/linux_virtual_machine.tf` and `ESLZ/linux_virtual_machine.tfvars` — module block and
  example tfvars for L2 blueprint callers.
- `tests/linux_virtual_machine.tftest.hcl` and `tests/upgrade_compat.tftest.hcl` — mock-provider
  test coverage for every variable and an upgrade-safety state-chaining test.
- `.tflint.hcl`, `.gitattributes`, `.github/workflows/terraform-ci.yml`,
  `.github/workflows/release.yml`.

### Changed

- `.gitignore` replaced with the standard module template.
- `outputs.tf`: `vm`, `pip`, and `nic` outputs marked `sensitive = true` (they expose full
  resource objects).

### Fixed

- `variables.tf`: `tags` default no longer duplicates the `exampleTag1` key.
- `variables.tf`: `disable_password_authentication` default corrected from the string
  `"false"` to the boolean `false`.
- `variables.tf`: `encryption_at_host_enabled` was missing a `type` argument.

### Known blockers

- `ESLZ/linux_virtual_machine.tf` pins `?ref=v3.1.0`, which does not exist as a published
  tag until this change is merged and released — `terraform init` against the ESLZ example
  will fail until then. This is expected; the release workflow tags the next version on merge.

## v1.1.4 (ep 2020)

FEATURES:

IMPROVEMENTS:

* Add new data_disk variable support. WARNING! This update is a significant change and will require new datadisk to be deployed. DO NOT APPLY this new version on top of an already deployed VM or it will destroy existing datadisks.

Data disks now need to be provided as:

```json
data_disks = {
      "data1" = {
        disk_size_gb = 300
        lun          = 0
      },
      "data2" = {
        disk_size_gb = 300
        lun          = 1
      }
    }
```

Sorry for the change but this will be better down the road.

* Lifecycle to prevent disk replacements after restore from recovery vault.

BUGS:

* Fix deprecated variable calls in autoshutdown

## v1.1.1 (ep 2020)

FEATURES:

* Add lifecycle identity exclusion to prevent vm update when azure change the identity config on vms.

IMPROVEMENTS:

BUGS:

## v1.1.0 (Aug 2020)

FEATURES:

* Remove support for deploy as it is no lonfer needed under terraform 0.13.x

IMPROVEMENTS:

BUGS:

## v1.0.2 (June 2020)

FEATURES:

* Add support for LB, ASG and NSG

IMPROVEMENTS:

BUGS:

## v1.0.0 (June 2020)

FEATURES:

* 1st release

IMPROVEMENTS:

* Add virtual machine name validation/creation

BUGS:
