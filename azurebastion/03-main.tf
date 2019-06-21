resource "azurerm_subnet" "subnet-bastion" {
  name                 = "AzureBastionSubnet"
  virtual_network_name = var.VNETNAME
  resource_group_name  = var.ARM_RESOURCEGROUP
  address_prefix       = var.BASTIONSUBNETCIDR
}

resource "azurerm_public_ip" "bastionpip" {
  name                = join("-", ["pip-bastion", var.ARM_LOCATION])
  location            = var.ARM_LOCATION
  resource_group_name = var.ARM_RESOURCEGROUP
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.common_tags
}

resource "azurerm_template_deployment" "bastion" {
  name                = join("", [var.CUSTOMER_PREFIX, "-bastion"])
  deployment_mode     = "Incremental"
  resource_group_name = var.ARM_RESOURCEGROUP
  template_body       = <<DEPLOY
{
  "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "bastionHostName": {
      "type": "string",
      "metadata": {
        "description": "Bastion Name"
      }
    },
    "location": {
      "type": "string",
      "metadata": {
        "description": "Location for all resources."
      }
    },
    "bastionServicesVnetName": {
      "type": "string",
      "metadata": {
        "description": "Virtual Network Name"
      }
    },
    "bastionServicesSubnetName": {
      "type": "string",
      "metadata": {
        "description": "Subnet Name"
      }
    },
    "publicIpAddressName": {
      "type": "string"
    },
    "COSTCENTRE": {
      "type": "string",
      "defaultValue": ""
    },
    "APPLICATION": {
      "type": "string",
      "defaultValue": ""
    },
    "ENVIRONMENT": {
      "type": "string",
      "defaultValue": ""
    },
  },
  "variables": {
    "subnetRefId": "[resourceId('Microsoft.Network/virtualNetworks/subnets', parameters('bastionServicesVnetName'), parameters('bastionServicesSubnetName'))]"
  },
  "resources": [
        {
          "apiVersion": "2018-10-01",
          "type": "Microsoft.Network/bastionHosts",
          "name": "[parameters('bastionHostName')]",
          "location": "[parameters('location')]",
          "properties": {
              "ipConfigurations": [
                  {
                      "name": "IpConf",
                      "properties": {
                          "subnet": {
                              "id": "[variables('subnetRefId')]"
                          },
                          "publicIPAddress": {
                              "id": "[resourceId('Microsoft.Network/publicIpAddresses', parameters('publicIpAddressName'))]"
                          }
                      }
                  }
              ]
          },
          "tags": {}
        }
  ],
  "outputs": {}
}
DEPLOY

  parameters = {
    "bastionHostName" = join("", [var.CUSTOMER_PREFIX, var.ARM_LOCATION, "bastion"])
    "publicIpAddressName" = azurerm_public_ip.bastionpip.name
    "location" = var.ARM_LOCATION
    "bastionServicesVnetName" = var.VNETNAME
    "bastionServicesSubnetName" = azurerm_subnet.subnet-bastion.name
    "COSTCENTRE" = local.common_tags.COSTCENTRE
    "APPLICATION" = local.common_tags.APPLICATION
    "ENVIRONMENT" = local.common_tags.ENVIRONMENT
  }
}

###############################################################################
# Diagnostics resources
###############################################################################

resource "azurerm_monitor_diagnostic_setting" "bastionpip-diagnostics" {
  name                       = "pipbastiondiagnostics"
  target_resource_id         = azurerm_public_ip.bastionpip.id
  log_analytics_workspace_id = var.LAWORKSPACEID

  log {
    category = "DDoSProtectionNotifications"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 90
    }
  }
  log {
    category = "DDoSMitigationFlowLogs"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 90
    }
  }
  log {
    category = "DDoSMitigationReports"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 90
    }
  }
  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = true
      days    = 90
    }
  }
}