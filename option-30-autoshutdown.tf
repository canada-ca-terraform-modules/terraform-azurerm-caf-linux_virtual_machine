/*
Example:

shutdownConfig = {
  autoShutdownStatus             = "Enabled"
  autoShutdownTime               = "17:00"
  autoShutdownTimeZone           = "Eastern Standard Time"
  autoShutdownNotificationStatus = "Disabled"
}

*/

variable "shutdownConfig" {
  description = "Should the VM shutdown at the time specified. See option-30-autoshutdown.tf file for example"
  type = object({
    autoShutdownStatus             = string
    autoShutdownTime               = string
    autoShutdownTimeZone           = string
    autoShutdownNotificationStatus = string
  })
  default = null
}

resource "azurerm_template_deployment" "autoshutdown" {
  count               = var.shutdownConfig != null ? 1 : 0
  name                = "autoshutdown"
  resource_group_name = var.resource_group.name
  depends_on          = [azurerm_linux_virtual_machine.VM]
  template_body       = <<DEPLOY
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "computerName": {
      "type": "string"
    },
    "autoShutdownStatus": {
      "type": "string",
      "defaultValue": "Enabled"
    },
    "autoShutdownTime": {
      "type": "string",
      "defaultValue": "17:00"
    },
    "autoShutdownTimeZone": {
      "type": "string",
      "defaultValue": "Eastern Standard Time"
    },
    "autoShutdownNotificationStatus": {
      "type": "string",
      "defaultValue": "Disabled"
    }
  },
  "variables": {
  },
  "resources": [
    {
            "name": "[concat('shutdown-computevm-', parameters('computerName'))]",
            "type": "Microsoft.DevTestLab/schedules",
            "apiVersion": "2017-04-26-preview",
            "location": "[resourceGroup().location]",
            "properties": {
                "status": "[parameters('autoShutdownStatus')]",
                "taskType": "ComputeVmShutdownTask",
                "dailyRecurrence": {
                    "time": "[parameters('autoShutdownTime')]"
                },
                "timeZoneId": "[parameters('autoShutdownTimeZone')]",
                "targetResourceId": "[resourceId('Microsoft.Compute/virtualMachines', parameters('computerName'))]",
                "notificationSettings": {
                    "status": "[parameters('autoShutdownNotificationStatus')]",
                    "timeInMinutes": "30"
                }
            }
    }
  ]
}
DEPLOY

  # these key-value pairs are passed into the ARM Template's `parameters` block
  parameters = {
    "computerName"                   = azurerm_linux_virtual_machine.VM.name
    "autoShutdownStatus"             = var.shutdownConfig.autoShutdownStatus
    "autoShutdownTime"               = var.shutdownConfig.autoShutdownTime
    "autoShutdownTimeZone"           = var.shutdownConfig.autoShutdownTimeZone
    "autoShutdownNotificationStatus" = var.shutdownConfig.autoShutdownNotificationStatus
  }

  deployment_mode = "Incremental"
}
