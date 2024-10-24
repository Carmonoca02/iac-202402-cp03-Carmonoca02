##RG
resource "azurerm_resource_group" "rg" {
    name     = "rg-staticsite-lb-multicloud-fernanda"
    location = "brazilsouth"
}

##VNET 1
resource "azurerm_virtual_network" "vnet1" {
    name                = "vnet"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    address_space       = ["10.0.0.0/16"]
}

##VNET 2
resource "azurerm_virtual_network" "vnet2" {
    name                = "vnet"
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
