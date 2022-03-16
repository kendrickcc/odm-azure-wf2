#-------------------------------
# Get cloud-init template file
#-------------------------------
data "template_file" "cloud-init" {
  template = file("cloud-init.tpl")
  vars = {
    ssh_key = var.pub_key_data
    fuse_accountname = var.fuse_accountname
    fuse_accountkey = var.fuse_accountkey
    container = var.container
    rclone_azblob_account = var.rclone_azblob_account
    rclone_azblob_key = var.rclone_azblob_key
    rclone_gdrive_client_id = var.rclone_gdrive_client_id
    rclone_gdrive_client_secret = var.rclone_gdrive_client_secret
  }
}
#-------------------------------
# Create resource group
#-------------------------------
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rsg"
  location = var.location
  tags     = merge(local.common_tags)
}
#-------------------------------
# Networking
#-------------------------------
resource "azurerm_public_ip" "odm" {
  name                = "${var.prefix}-webodm${count.index}-pip"
  count               = var.nodeodm_servers
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"
  sku                 = "Basic"
  tags                = merge(local.common_tags)
}
resource "azurerm_virtual_network" "rg" {
  name                = "${var.prefix}-network"
  address_space       = [var.vnet_cidr]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tags                = merge(local.common_tags)
}
resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.rg.name
  address_prefixes     = [var.subnet_cidr]
}
resource "azurerm_network_interface" "nodeodm" {
  name                = "${var.prefix}-nodeodm${count.index}-nic"
  count               = var.nodeodm_servers
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.odm[count.index].id
  }
  tags = merge(local.common_tags)
}
#-------------------------------
# Network security group
#-------------------------------
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-nsg"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  tags                = merge(local.common_tags)
  #/* when needed to connect to VM, add a leading "#"
  security_rule {
    name                       = "SSH"
    priority                   = 300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
  } # */
  security_rule {
    name                       = "AllowClusterODMInBound"
    priority                   = 401
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8001"
    source_address_prefix      = "0.0.0.0/0"
    destination_address_prefix = "*"
  }
}
resource "azurerm_subnet_network_security_group_association" "sec_group" {
  subnet_id                 = azurerm_subnet.internal.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
#-------------------------------
# Create virtual machines
#-------------------------------
resource "azurerm_linux_virtual_machine" "nodeodm" {
  name                = "${var.prefix}-nodeodm${count.index}-vm"
  count               = var.nodeodm_servers
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vmSize
  admin_username      = var.adminUser
  network_interface_ids = [
    azurerm_network_interface.nodeodm[count.index].id,
  ]
  computer_name                   = "${var.prefix}-nodeodm${count.index}-vm"
  disable_password_authentication = true
  custom_data                     = base64encode(data.template_file.cloud-init.rendered)
  source_image_reference {
    publisher = element(split(",", lookup(var.standard_os, var.simple_os, "")), 0)
    offer     = element(split(",", lookup(var.standard_os, var.simple_os, "")), 1)
    sku       = element(split(",", lookup(var.standard_os, var.simple_os, "")), 2)
    version   = "latest"
  }
  os_disk {
    storage_account_type = var.storageAccountType
    caching              = "ReadWrite"
    disk_size_gb         = var.diskSizeGB
  }
  admin_ssh_key {
    username   = var.adminUser
    public_key = var.pub_key_data
  }
  tags = merge(local.common_tags)
}