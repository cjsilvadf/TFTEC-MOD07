data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}

resource "azurerm_resource_group" "rg_sto_lab07" {
  name     = "${lower(var.resource_group_name)}-${lower(var.ambiente)}"
  location = local.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "ResVnet" {
  name                = var.vnet_name_lab07
  location            = azurerm_resource_group.rg_sto_lab07.location
  resource_group_name = azurerm_resource_group.rg_sto_lab07.name
  address_space       = var.address_vnet
  tags                = merge(var.tags, { treinamento = "terraform" }, )
}

resource "azurerm_subnet" "ResSubnet" {

  name                 = var.vnet_name_lab07
  resource_group_name  = azurerm_resource_group.rg_sto_lab07.name
  virtual_network_name = azurerm_virtual_network.ResVnet.name
  address_prefixes     = var.address_vnet
}
#

resource "azurerm_public_ip" "pipipvm-win" {
  name                = "pipvm-win"
  location            = azurerm_resource_group.rg_sto_lab07.location
  resource_group_name = azurerm_resource_group.rg_sto_lab07.name
  allocation_method   = "Static"
  tags                = merge(var.tags, { treinamento = "terraform" }, )
}


resource "azurerm_network_interface" "nic-vm-win" {

  name                = "Fs-lab07"
  location            = azurerm_resource_group.rg_sto_lab07.location
  resource_group_name = azurerm_resource_group.rg_sto_lab07.name

  ip_configuration {
    name                          = "nic-ipconfig"
    subnet_id                     = azurerm_subnet.ResSubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pipipvm-win.id
  }
}

resource "azurerm_windows_virtual_machine" "ResVMWindows" {

  name                  = var.vm_name
  location              = azurerm_resource_group.rg_sto_lab07.location
  resource_group_name   = azurerm_resource_group.rg_sto_lab07.name
  admin_username        = var.admin_login
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.nic-vm-win.id]
  size                  = var.vmsize_web

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  tags = merge(var.tags, { treinamento = "terraform" }, )

}

resource "azurerm_managed_disk" "disk" {
  name                 = "${var.vm_name}-disk1"
  location             = azurerm_resource_group.rg_sto_lab07.location
  resource_group_name  = azurerm_resource_group.rg_sto_lab07.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 10
}

resource "azurerm_virtual_machine_data_disk_attachment" "example" {
  managed_disk_id    = azurerm_managed_disk.disk.id
  virtual_machine_id = azurerm_windows_virtual_machine.ResVMWindows.id
  lun                = "10"
  caching            = "ReadWrite"
}
