resource "azurerm_resource_group" "waflab" {
  name     = "waflab-resources"
  location = "West Europe"
}

# Create a virtual network
resource "azurerm_virtual_network" "waflab" {
  name                = "waflab-network"
  resource_group_name = azurerm_resource_group.waflab.name
  location            = azurerm_resource_group.waflab.location
  address_space       = ["10.0.0.0/16"]
}

# Create a subnet
resource "azurerm_subnet" "waflab" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.waflab.name
  virtual_network_name = azurerm_virtual_network.waflab.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create a public IP for the network interface
resource "azurerm_public_ip" "waflab_nic" {
  name                = "waflab-nic-pip"
  location            = azurerm_resource_group.waflab.location
  resource_group_name = azurerm_resource_group.waflab.name
  allocation_method   = "Static"
}

# Create a network interface
resource "azurerm_network_interface" "waflab" {
  name                = "waflab-nic"
  location            = azurerm_resource_group.waflab.location
  resource_group_name = azurerm_resource_group.waflab.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.waflab.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.waflab_nic.id
  }
}

# Create a virtual machine
resource "azurerm_linux_virtual_machine" "waflab" {
  name                = "waflab-machine"
  resource_group_name = azurerm_resource_group.waflab.name
  location            = azurerm_resource_group.waflab.location
   size = "Standard_D2s_v3"
  admin_username      = "adminuser"
  network_interface_ids = [azurerm_network_interface.waflab.id]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "20.04.202209200"
   
  }
  
# provisioner "local-exec" {
#   command = "ansible-playbook -i '${azurerm_public_ip.waflab_nic.ip_address},' -u adminuser --private-key ~/.ssh/id_rsa ansible_react_playbook.yml"
# }

}

# Create a public IP for the load balancer
resource "azurerm_public_ip" "waflab_lb" {
  name                = "waflab-lb-pip"
  location            = azurerm_resource_group.waflab.location
  resource_group_name = azurerm_resource_group.waflab.name
  allocation_method   = "Static"
}

# Create a load balancer
resource "azurerm_lb" "waflab" {
  name                = "waflab-lb"
  location            = azurerm_resource_group.waflab.location
  resource_group_name = azurerm_resource_group.waflab.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.waflab_lb.id
  }
}

# Create a load balancer backend address pool
resource "azurerm_lb_backend_address_pool" "waflab" {
  loadbalancer_id = azurerm_lb.waflab.id
  name            = "BackEndAddressPool"
}

resource "azurerm_network_interface_backend_address_pool_association" "waflab" {
  network_interface_id    = azurerm_network_interface.waflab.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_lb_backend_address_pool.waflab.id
}

# Create a load balancer rule
resource "azurerm_lb_rule" "waflab" {
  loadbalancer_id       = azurerm_lb.waflab.id
  name                  = "LBRule"
  protocol              = "Tcp"
  frontend_port         = 80
  backend_port          = 3000
  frontend_ip_configuration_name = azurerm_lb.waflab.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.waflab.id]
  probe_id                       = azurerm_lb_probe.waflab.id
}

# Create a load balancer health probe
resource "azurerm_lb_probe" "waflab" {
  loadbalancer_id           = azurerm_lb.waflab.id
  name                      = "HealthProbe"
  port                      = 3000
  protocol                  = "Tcp"
  interval_in_seconds       = 15
  number_of_probes          = 2
}

output "vm_ssh_command" {
  value = "ssh -i ~/.ssh/id_rsa adminuser@${azurerm_public_ip.waflab_nic.ip_address}"
  description = "SSH command to connect to the VM"
}

output "lb_http_url" {
  value = "http://${azurerm_public_ip.waflab_lb.ip_address}"
  description = "HTTP URL to connect to the load balancer"
}

