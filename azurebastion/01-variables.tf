variable "ARM_RESOURCEGROUP" {
  description = "Resource Group name the resources should be deployed into."
  type        = "string"
}

variable "ARM_LOCATION" {
  description = "Which Azure region are we supposed to use?"
  type        = "string"
}

variable "ARM_ENVIRONMENT_NAME" {
  type        = "string"
  description = "Name of environment to deploy"
}

variable "CUSTOMER_PREFIX" {
  type        = "string"
  description = "Three character customer prefix"
}

variable "CUSTOMER_COSTCENTRE" {
  type        = "string"
  description = "Customer specific cost centre"
}

variable "CUSTOMER_APPLICATION" {
  type        = "string"
  description = "Customer application name"
}

variable "BASTIONSUBNETCIDR" {
  type        = "string"
  description = "CIDR Range for bastion subnet"
}

variable "VNETNAME" {
  type        = "string"
  description = "vnetname the Firewall shall be created in"
}

variable "LAWORKSPACEID" {
  type        = "string"
  description = "Workspace ID of Log Analytics"
}