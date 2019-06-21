# Terraform module for Azure Bastion service

This is a free to use (no guarantees given) terraform module that can be used to deploy the Azure Bastion service into an existing Azure virtual network.

For more information about this service, read the official [Microsoft documentation on Azure Bastion](https://azure.microsoft.com/en-us/services/azure-bastion/).

## Requirements

* terraform 0.12.n
* tested with terraform AzureRM provider `1.29.0`
* Azure virtual network
* Azure Resource Group

> Deploying this module will incur cost in your subscription!

## Deploy

The module can be called from any terraform script like below.
As there is currently no Azure Bastion terraform resource we are using an inline Azure Resource Manager deployment to deploy the Bastion resource.

```hcl
provider "azurerm" {
  environment     = "public"
  subscription_id = <pass in your Azure subscription Id>
  version         = "1.29.0"
}

variable "ARM_VNETADDRESSSPACE" {
  type        = "string"
  description = "CIDR Range for vnet"
  default     = "10.0.0.0/8"
}

resource "azurerm_resource_group" "resourcegroup" {
  name     = join("-", ["sharedservices", "australiaeast", "prod", "rg"])
  location = "australiaeast"
}

resource "azurerm_virtual_network" "sharedservicesvnet" {
  name                = join("-", ["xir", "australiaeast", "vnet"])
  location            = "australiaeast"
  resource_group_name = azurerm_resource_group.resourcegroup.name
  address_space       = [var.ARM_VNETADDRESSSPACE]
  tags                = local.common_tags
}

module "azurebastion" {
  source = "../azurebastion"
  ARM_LOCATION             = "australiaeast"
  ARM_RESOURCEGROUP        = azurerm_resource_group.resourcegroup.name
  ARM_ENVIRONMENT_NAME     = "prod"
  CUSTOMER_PREFIX          = "xir"
  CUSTOMER_COSTCENTRE      = "1234"
  CUSTOMER_APPLICATION     = "azurebastion"
  BASTIONSUBNETCIDR        = cidrsubnet(var.ARM_VNETADDRESSSPACE, 8, 4)
  LAWORKSPACEID            = <input Log Analytics Workspace ID>
  VNETNAME                 = azurerm_virtual_network.sharedservicesvnet.name
}
```

Always interested in feedback on this.