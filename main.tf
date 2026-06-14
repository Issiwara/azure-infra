# main.tf — Azure Architect v1.0
# State: stored in Azure Blob Storage with automatic locking

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }

  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstateazarch001"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

variable "location" {
  default = "westeurope"
}

# Add your resources below — or export from Azure Architect and paste here

resource "azurerm_resource_group" "test_rg" {
  name     = "test-rg"
  location = var.location

  tags = {
    managed_by  = "azure-architect"
    environment = "test"
  }
}

resource "azurerm_virtual_network" "test_vnet" {
  name                = "test-vnet"
  resource_group_name = azurerm_resource_group.test_rg.name
  location            = var.location
  address_space       = ["10.0.0.0/16"]

  depends_on = [azurerm_resource_group.test_rg]

  tags = {
    managed_by  = "azure-architect"
    environment = "test"
  }
}
