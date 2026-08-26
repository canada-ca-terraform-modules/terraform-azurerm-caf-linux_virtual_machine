# config/linux_virtual_machine.tfvars
# Minimal, valid fixture exercising the module's common path.
#
# admin_password is a literal, obviously-fake placeholder - never a real
# secret. disable_password_authentication = false is required alongside it
# since no ssh_key is supplied here.
#
# vm_size uses the Dav6 family: the sandbox subscription's default Dsv5/
# Dasv5 family quota hits a hard Azure capacity restriction (SkuNotAvailable)
# in canadacentral - Dav6 has dedicated quota provisioned for live-test use.
#
# storage_image_reference is set explicitly (not left to the module default)
# to a currently-available marketplace image.
linux_virtual_machine = {
  userDefinedString               = "livetest"
  admin_username                  = "azureadmin"
  admin_password                  = "CHANGE-ME-P@ssw0rd1234!" # placeholder only - throwaway live-test VM, destroyed after use
  disable_password_authentication = false
  vm_size                         = "Standard_D2as_v6"

  storage_image_reference = {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}
