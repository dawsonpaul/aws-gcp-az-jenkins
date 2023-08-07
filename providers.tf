terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  client_id       = "${env.AZURE_CLIENT_ID}"
  client_secret   = "${env.AZURE_CLIENT_SECRET}"
  tenant_id       = "${env.AZURE_TENANT_ID}"
  subscription_id = "${env.AZURE_SUBSCRIPTION_ID}"
}
