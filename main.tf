# Terraform (azurerm) — Azure Architect v1.0
# Generated: 2026-06-22T17:13:34.026Z

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
resource "azurerm_virtual_network" "vnet1" {
  name                = "vnet1"
  resource_group_name = azurerm_resource_group.test_rg.name
  location            = var.location
  address_space       = ["10.0.0.0/16"]
}

# ⬡ Subnet [vnet: vnet1]
resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.test_rg.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.0.1.0/24"]

  depends_on = [azurerm_virtual_network.vnet1]
}

# 🔒 NSG for vm1 (inbound: 22, 80, 443, 9000, 8080, 8000, 8081, 4000 | outbound: *)
resource "azurerm_network_security_group" "vm1_nsg" {
  name                = "vm1-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.test_rg.name

  security_rule {
    name                       = "inbound-allow-22"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "inbound-allow-80"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "inbound-allow-443"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "inbound-allow-9000"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "9000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "inbound-allow-8080"
    priority                   = 140
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "inbound-allow-8000"
    priority                   = 150
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "inbound-allow-8081"
    priority                   = 160
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8081"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "inbound-allow-4000"
    priority                   = 170
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "4000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "outbound-allow-all"
    priority                   = 200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  depends_on = [azurerm_resource_group.test_rg]

  tags = {
    managed_by = "azure-architect"
  }
}

# 🌐 Public IP for vm1 (public subnet)
resource "azurerm_public_ip" "vm1_pip" {
  name                = "vm1-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.test_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  depends_on = [azurerm_resource_group.test_rg]

  tags = {
    managed_by = "azure-architect"
  }
}

# 🔌 Network Interface for vm1 [PUBLIC]
resource "azurerm_network_interface" "vm1_nic" {
  name                = "vm1-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.test_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm1_pip.id
  }

  depends_on = [azurerm_public_ip.vm1_pip, azurerm_subnet.subnet1]
}

resource "azurerm_network_interface_security_group_association" "vm1_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.vm1_nic.id
  network_security_group_id = azurerm_network_security_group.vm1_nsg.id

  depends_on = [azurerm_network_interface.vm1_nic, azurerm_network_security_group.vm1_nsg]
}

# 💻 Virtual Machine [subnet: subnet1] [vnet: vnet1] [rg: test-rg]
resource "azurerm_linux_virtual_machine" "vm1" {
  resource_group_name = azurerm_resource_group.test_rg.name
  location            = var.location
  name           = "vm1"
  size           = "Standard_D2s_v3"
  admin_username = "azureuser"

  network_interface_ids = [
    azurerm_network_interface.vm1_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("./crud-key.pub")
  }

  depends_on = [azurerm_network_interface.vm1_nic]

  tags = {
    managed_by = "azure-architect"
  }
}

