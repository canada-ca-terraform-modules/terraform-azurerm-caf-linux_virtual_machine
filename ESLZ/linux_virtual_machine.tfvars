# ESLZ/linux_virtual_machine.tfvars
# Example tfvars for the ESLZ/linux_virtual_machine.tf module block.
# Rules: existing entries unchanged; new args go below, commented out with explanation.

linux_virtual_machines = {
  # --- EXISTING ENTRY (minimal, backward compatible) ---
  SRV-SASPR1 = {
    env                = "Prod"
    userDefinedString  = "sasapp1"
    resource_group_key = "Project"
    subnet_key         = "app"
    admin_username     = "adminuser"
    vm_size            = "Standard_D2s_v5"
    ssh_key            = "ssh-rsa AAAA..."
  }

  # --- NEW ARGUMENT EXAMPLES (commented out) ---
  # SRV-SASPR2 = {
  #   env                 = "Prod"
  #   userDefinedString   = "sasapp2"
  #   resource_group_key  = "Project"
  #   subnet_key          = "app"
  #   admin_username      = "adminuser"
  #   vm_size             = "Standard_D2s_v5"
  #   ssh_key             = "ssh-rsa AAAA..."
  #
  #   # New: system-assigned managed identity
  #   identity = {
  #     type = "SystemAssigned"
  #   }
  #
  #   # New: Trusted Launch (secure boot + vTPM)
  #   secure_boot_enabled = true
  #   vtpm_enabled        = true
  #
  #   # New: cloud-init user data (base64-encoded)
  #   user_data = "IyEvYmluL3NoCmVjaG8gaGVsbG8="
  #
  #   # New: pin availability zones for the public IP
  #   public_ip       = true
  #   public_ip_zones = ["1", "2"]
  #
  #   # Pattern 12: pin an already-deployed resource name that diverges
  #   # from the module's naming formula (avoids destroy/recreate)
  #   vm_name  = "existing-prod-vm"
  #   nic_name = "existing-prod-nic"
  #
  #   data_disks = {
  #     "data1" = { disk_size_gb = 50, lun = 0 }
  #     "data2" = { disk_size_gb = 100, lun = 1, name = "existing-prod-datadisk2" }
  #   }
  # }
}
