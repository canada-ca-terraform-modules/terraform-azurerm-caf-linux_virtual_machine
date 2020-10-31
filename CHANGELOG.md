# Changelog
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
