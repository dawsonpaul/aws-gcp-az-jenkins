terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

# Configure the Microsoft Azure Providerc -
provider "azurerm" {
  features {}
  client_id       = var.AZURE_CLIENT_ID
  client_secret   = var.AZURE_CLIENT_SECRET
  tenant_id       = var.AZURE_TENANT_ID
  subscription_id = var.AZURE_SUBSCRIPTION_ID
}

variable "AZURE_CLIENT_ID" {
  default = ""
}

variable "AZURE_CLIENT_SECRET" {
  default = ""
}

variable "AZURE_TENANT_ID" {
  default = ""
}

variable "AZURE_SUBSCRIPTION_ID" {
  default = ""
}