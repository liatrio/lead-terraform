provider "azurerm" {
  version                    = "=2.20.0"
  skip_provider_registration = true
  features {}
}

provider "random" {
  version = "=2.3.0"
}

data "azurerm_resource_group" "leadrg" {
  name = var.resource_group
}

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.leadrg.location
  resource_group_name = var.resource_group
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = data.azurerm_resource_group.leadrg.location
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "leadconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "azurerm_virtual_machine" "main" {
  name                  = "${var.prefix}-vm"
  location              = data.azurerm_resource_group.leadrg.location
  resource_group_name   = var.resource_group
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_DS1_v2"

  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "leadosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "lead"
    admin_username = "leadadmin"
    admin_password = random_password.password.result
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = var.environment
  }
}