#Create .tfvars file. Set password and subnetId in *.tfvars file

resource "azurerm_resource_group" "rg" {
  name     = var.resourceGroupName
  location = var.location
}

resource "azurerm_network_interface" "vm_private_nic" {
  count = var.numAvailabilityZones
  name                = "${var.serverName}-${count.index+1}-private-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  enable_accelerated_networking = true

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnetId
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.vm_public_nic.*.id, count.index+1)
  }
}

resource "azurerm_public_ip" "vm_public_nic" {
  count = var.numAvailabilityZones
  name                = "${var.serverName}-${count.index+1}-public-nic"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku = "Standard"
  availability_zone = "${count.index+1}"

}

resource "azurerm_network_security_group" "nic_nsg" {
  count = var.numAvailabilityZones
    name                = "${var.serverName}-${count.index+1}-nsg"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "Terraform Demo"
    }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg_association" {
  count = var.numAvailabilityZones
    network_interface_id      = element(azurerm_network_interface.vm_private_nic.*.id, count.index+1)
    network_security_group_id = element(azurerm_network_security_group.nic_nsg.*.id, count.index+1)
}

resource "azurerm_linux_virtual_machine" "vm" {
  count = var.numAvailabilityZones
  name                            = "${var.serverName}-${count.index+1}"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  zone                            = "${count.index+1}"
  size                            = var.vmSKU
  admin_username                  = var.adminUsername
  admin_password                  = var.adminPassword
  disable_password_authentication = false
  network_interface_ids = [element(concat(azurerm_network_interface.vm_private_nic.*.id), count.index+1)]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "RedHat"
    offer     = "RHEL"
    sku       = "8-LVM"
    version   = "8.3.2020111909"
  }
}
