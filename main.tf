# Terraform (azurerm) — Azure Architect v1.0
# Generated: 2026-06-14T21:14:26.395Z

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }

  # Remote backend — state stored in Azure Blob Storage with automatic locking
  # Note: ensure storage account enforces min_tls_version = "TLS1_2"
  # TLS 1.0 and 1.1 were retired by Azure on 2026-02-03
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstateazarch001"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
    use_oidc             = true
  }
}

provider "azurerm" {
  features {}
}

variable "location" {
  default = "westeurope"
}

# 📦 Resource Group
resource "azurerm_resource_group" "test_rg" {
  name     = "test-rg"
  location = var.location
}

# 🌐 Virtual Network [rg: test-rg]
resource "azurerm_virtual_network" "test_vnet" {
  name                = "test-vnet"
  resource_group_name = azurerm_resource_group.test_rg.name
  location            = var.location
  address_space       = ["10.0.0.0/16"]
}

