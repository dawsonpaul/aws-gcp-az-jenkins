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
  subscription_id = "22963932-27fd-475c-98b0-a83f58d4f46d"
  tenant_id       = "3a9fdbd6-1297-4b8f-8d27-4b331969880e"
}
