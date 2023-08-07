terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

variable "AZURE_CLIENT_ID" {}
variable "AZURE_CLIENT_SECRET" {}
variable "AZURE_TENANT_ID" {}
variable "AZURE_SUBSCRIPTION_ID" {}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  client_id       = "${env.AZURE_CLIENT_ID}"
  client_secret   = "${env.AZURE_CLIENT_SECRET}"
  tenant_id       = "${env.AZURE_TENANT_ID}"
  subscription_id = "${env.AZURE_SUBSCRIPTION_ID}"
}
