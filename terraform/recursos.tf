
################### 
#  Resource group #
################### 

resource "azurerm_resource_group" "rg" {
  name     = "casoPractico2"
  location = var.location
}

############# 
#  Networks #
#############

# Create a virtual network
# General network
resource "azurerm_virtual_network" "serviceNet" {
  name                = "serviceNet1"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.serviceNet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# resource "azurerm_virtual_network" "internalNet" {
#   name                = "internalNet1"
#   address_space       = ["192.168.0.0/16"]
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
# }

# resource "azurerm_subnet" "internalSubnet" {
#   name                 = "internalSubnet1"
#   resource_group_name  = azurerm_resource_group.rg.name
#   virtual_network_name = azurerm_virtual_network.internalNet.name
#   address_prefixes     = ["192.168.0.0/24"]
# }

resource "azurerm_network_security_group" "mynetwork" {
  name                = "casoPractico2NSG"
  location            = "uksouth"
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "ports_CASO2"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["22", "6443", "2379", "2380", "10250", "10251", "10252", "10253", "10255"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "caso2"
  }
}

resource "azurerm_application_security_group" "caso2asg" {
  name                = "caso2ASG"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_interface" "masternic" {
  name                = "masterNIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.30"
    public_ip_address_id          = azurerm_public_ip.masterPublicIp.id
  }
}

resource "azurerm_network_interface_application_security_group_association" "aniasga" {
  network_interface_id          = azurerm_network_interface.masternic.id
  application_security_group_id = azurerm_application_security_group.caso2asg.id
}

resource "azurerm_network_interface" "nodenic" {
  name                = "nodeNic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.40"
    public_ip_address_id          = azurerm_public_ip.nodePublicIp.id
  }
}

resource "azurerm_network_interface" "nfsnic" {
  name                = "nfsNic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.1.20"
    public_ip_address_id          = azurerm_public_ip.nfsPublicIp.id
  }
}

# Ips publicas para cada maquina
resource "azurerm_public_ip" "masterPublicIp" {
  name                = "masterPublicIp1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Basic"

  tags = {
    environment = "TestCasoPractico2"
  }
}

resource "azurerm_public_ip" "nodePublicIp" {
  name                = "nodePublicIp1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Basic"

  tags = {
    environment = "TestCasoPractico2"
  }
}

resource "azurerm_public_ip" "nfsPublicIp" {
  name                = "nfsPublicIp1"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Basic"

  tags = {
    environment = "TestCasoPractico2"
  }
}

#################### 
# Virtual Machines #
####################

#KubernetesMaster


resource "azurerm_linux_virtual_machine" "kubernetesMaster" {
  name                            = "kubeMaster"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = "Standard_B2s"
  admin_username                  = "adminuser"
  admin_password                  = "P@assword01"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.masternic.id,
  ]

  admin_ssh_key {
    username   = var.ssh_user
    public_key = var.public_key
  }

  os_disk {
    name                 = "MasterDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  plan {
    name      = "centos-8-stream-free"
    product   = "centos-8-stream-free"
    publisher = "cognosys"
  }

  source_image_reference {
    publisher = "cognosys"
    offer     = "centos-8-stream-free"
    sku       = "centos-8-stream-free"
    version   = "22.03.28"
  }
}

resource "azurerm_linux_virtual_machine" "kubernetesNode1" {
  name                            = "kubeNode1"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = "Standard_F2s_v2"
  admin_username                  = "adminuser"
  admin_password                  = "P@assword01"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nodenic.id,
  ]

  admin_ssh_key {
    username   = var.ssh_user
    public_key = var.public_key
  }

  os_disk {
    name                 = "Node1Disk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  plan {
    name      = "centos-8-stream-free"
    product   = "centos-8-stream-free"
    publisher = "cognosys"
  }

  source_image_reference {
    publisher = "cognosys"
    offer     = "centos-8-stream-free"
    sku       = "centos-8-stream-free"
    version   = "22.03.28"
  }
}

resource "azurerm_linux_virtual_machine" "nfsServer" {
  name                            = "nfsServer"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = "Standard_F2s_v2"
  admin_username                  = "adminuser"
  admin_password                  = "P@assword01"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nfsnic.id,
  ]

  admin_ssh_key {
    username   = var.ssh_user
    public_key = var.public_key
  }

  os_disk {
    name                 = "NFSDisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  plan {
    name      = "centos-8-stream-free"
    product   = "centos-8-stream-free"
    publisher = "cognosys"
  }

  source_image_reference {
    publisher = "cognosys"
    offer     = "centos-8-stream-free"
    sku       = "centos-8-stream-free"
    version   = "22.03.28"
  }
}