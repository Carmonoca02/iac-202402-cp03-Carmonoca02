##RG
resource "azurerm_resource_group" "rg" {
    name     = "rg-recursosazurecp3"
    location = "brazilsouth"
}

##VNET 1
resource "azurerm_virtual_network" "vnet1" {
    name                = "vnet1"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    address_space       = ["10.0.0.0/16"]
}

##VNET 2
resource "azurerm_virtual_network" "vnet2" {
    name                = "vnet2"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    address_space       = ["20.0.0.0/16"]
}


##VPC PEERING

resource "azurerm_virtual_network_peering" "vpcpeering" {
  name                      = "peer10to20" 
resource_group_name = azurerm_resource_group.rg.name 
virtual_network_name = azurerm_virtual_network.vnet1.name  
remote_virtual_network_id = azurerm_virtual_network.vnet2.id  
}


resource "azurerm_subnet" "subnet1a" {
    name                 = "subnet1a"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet1.name
    address_prefixes     = ["10.0.5.0/24"]
}

resource "azurerm_subnet" "subnet2a" {
    name                 = "subnet2a"
    resource_group_name  = azurerm_resource_group.rg.name
    virtual_network_name = azurerm_virtual_network.vnet2.name
    address_prefixes     = ["20.0.6.0/24"]
}

resource "azurerm_network_security_group" "nsgvm" {
    name                = "nsgvm"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    security_rule {
        name                       = "HTTP"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
    security_rule {
        name                       = "FTP"
        priority                   = 1011
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }
}

resource "azurerm_subnet_network_security_group_association" "nsgsubnet1a" {
    subnet_id                 = azurerm_subnet.subnet1a.id
    network_security_group_id = azurerm_network_security_group.nsgvm.id
}

resource "azurerm_subnet_network_security_group_association" "nsgsubnet2a" {
    subnet_id                 = azurerm_subnet.subnet2a.id
    network_security_group_id = azurerm_network_security_group.nsgvm.id
}

resource "azurerm_network_interface" "vm01" {
    name                = "vm01"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    ip_configuration {
        name                          = "vm01"
        subnet_id                     = azurerm_subnet.subnet1a.id
        private_ip_address_allocation = "Dynamic"
    }
}

resource "azurerm_network_interface" "vm02" {
    name                = "vm02"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    ip_configuration {
        name                          = "vm02"
        subnet_id                     = azurerm_subnet.subnet2a.id
        private_ip_address_allocation = "Dynamic"
    }
}


resource "azurerm_availability_set" "asvm" {
    name                = "asvm"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_virtual_machine" "vm01" {
    name                             = "vm01"
    location                         = azurerm_resource_group.rg.location
    resource_group_name              = azurerm_resource_group.rg.name
    network_interface_ids            = [azurerm_network_interface.vm01.id]
    availability_set_id              = azurerm_availability_set.asvm.id
    vm_size                          = "Standard_DS1_v2"
    delete_os_disk_on_termination    = true
    delete_data_disks_on_termination = true
    storage_image_reference {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts"
        version   = "latest"
    }
    storage_os_disk {
        name              = "vm01"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }
    os_profile {
        computer_name  = "vm01"
        admin_username = "vmuser"
        admin_password = "Password1234!"
        custom_data    = <<CUSTOM_DATA
#!/bin/bash
sudo apt update
sudo apt install apache2 -y
echo "staticsite-lb-multi-cloud - Azure - instance01" > /var/www/html/index.html
CUSTOM_DATA
    }
    os_profile_linux_config {
        disable_password_authentication = false
    }
}

resource "azurerm_virtual_machine" "vm02" {
    name                             = "vm02"
    location                         = azurerm_resource_group.rg.location
    resource_group_name              = azurerm_resource_group.rg.name
    network_interface_ids            = [azurerm_network_interface.vm02.id]
    availability_set_id              = azurerm_availability_set.asvm.id
    vm_size                          = "Standard_DS1_v2"
    delete_os_disk_on_termination    = true
    delete_data_disks_on_termination = true
    storage_image_reference {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts"
        version   = "latest"
    }
    storage_os_disk {
        name              = "vm02"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"
    }
    os_profile {
        computer_name  = "vm02"
        admin_username = "vmuser"
        admin_password = "Password1234!"
        custom_data    = <<CUSTOM_DATA
#!/bin/bash
sudo apt update
sudo apt install apache2 -y
echo "staticsite-lb-multi-cloud - Azure - instance02" > /var/www/html/index.html
CUSTOM_DATA
    }
    os_profile_linux_config {
        disable_password_authentication = false
    }
}