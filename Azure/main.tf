resource "azurerm_resource_group" "waflab" {
  name     = "waflab-resources"
  location = "West Europe"
}

# Create a virtual network --
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
  name                = "waflab-juiceshop-VM"
  resource_group_name = azurerm_resource_group.waflab.name
  location            = azurerm_resource_group.waflab.location
   size = "Standard_D2s_v3"
  admin_username      = "adminuser"
  network_interface_ids = [azurerm_network_interface.waflab.id]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("/var/lib/jenkins/workspace/id_rsa.pub")
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
}


# Application Gateway Subnet
resource "azurerm_subnet" "waflab_appgw" {
  name                 = "appgw"
  resource_group_name  = azurerm_resource_group.waflab.name
  virtual_network_name = azurerm_virtual_network.waflab.name
  address_prefixes     = ["10.0.3.0/24"]
}

# Application Gateway Public IP
resource "azurerm_public_ip" "waflab_appgw" {
  name                = "waflab-appgw-pip"
  location            = azurerm_resource_group.waflab.location
  resource_group_name = azurerm_resource_group.waflab.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Application Gateway with WAF policy
resource "azurerm_application_gateway" "waflab" {
  name                = "waflab-appgw"
  location            = azurerm_resource_group.waflab.location
  resource_group_name = azurerm_resource_group.waflab.name
  firewall_policy_id = azurerm_web_application_firewall_policy.waflab_policy.id


  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gateway-ip-configuration"
    subnet_id = azurerm_subnet.waflab_appgw.id
  }

  frontend_port {
    name = "frontend-port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontend-ip-configuration"
    public_ip_address_id = azurerm_public_ip.waflab_appgw.id
  }

  backend_address_pool {
    name = "backend-address-pool"
    fqdns = [
      azurerm_public_ip.waflab_nic.ip_address
    ]
  }

  backend_http_settings {
    name                  = "backend-http-settings"
    cookie_based_affinity = "Disabled"
    path                  = "/"
    port                  = 3000
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "frontend-ip-configuration"
    frontend_port_name             = "frontend-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "request-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-address-pool"
    backend_http_settings_name = "backend-http-settings"
  }

  # waf_configuration {
  #   enabled                  = true
  #   firewall_mode            = "Prevention"
  #   rule_set_type            = "OWASP"
  #   rule_set_version         = "3.2"
  #   request_body_check       = true
  #   max_request_body_size_kb = 128
  # }
}


output "vm_ssh_command" {
  value = "ssh -i ~/.ssh/id_rsa adminuser@${azurerm_public_ip.waflab_nic.ip_address}"
  description = "SSH command to connect to the VM"
}

output "waflab_appgw_url" {
  value       = "http://${azurerm_public_ip.waflab_appgw.ip_address}"
  description = "URL to connect to the Application Gateway"
}


output "waflab_vm_ip_address" {
  value = azurerm_public_ip.waflab_nic.ip_address
  description = "Public IP address of the VM"
}

