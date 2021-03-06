terraform {
  required_version = ">= 0.11"

  backend "azurerm" {}
}

# Set the Provider as AZURE and Configures it
provider "azurerm" {}

# Create a resource group if it is not there yet
resource "azurerm_resource_group" "company_resource_group" {
  name     = "companydemocreate"
  location = "Central US"

  tags {
    environment = "company Demo"
  }
}

# Create the virtual network
resource "azurerm_virtual_network" "company_virtual_network" {
  name                = "companydemo"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.company_resource_group.location}"
  resource_group_name = "${azurerm_resource_group.company_resource_group.name}"

  tags {
    environment = "company Demo"
  }
}

# Create the subnet
resource "azurerm_subnet" "company_demo_subnet" {
  name                 = "companydemo"
  resource_group_name  = "${azurerm_resource_group.company_resource_group.name}"
  virtual_network_name = "${azurerm_virtual_network.company_virtual_network.name}"
  address_prefix       = "10.0.1.0/24"
}

# Create the public IPs
resource "azurerm_public_ip" "company_demo_public_ip" {
  name                         = "companypublicip"
  location                     = "${azurerm_resource_group.company_resource_group.location}"
  resource_group_name          = "${azurerm_resource_group.company_resource_group.name}"
  public_ip_address_allocation = "static"
  domain_name_label            = "companydemoiac"

  tags {
    environment = "company Demo"
  }
}

# Create The Network Security Group and a simple rule
resource "azurerm_network_security_group" "company_demo_security_group" {
  name                = "companysecuritygroups"
  location            = "${azurerm_resource_group.company_resource_group.location}"
  resource_group_name = "${azurerm_resource_group.company_resource_group.name}"

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags {
    environment = "company Demo"
  }
}

resource "azurerm_lb" "vmss_lb" {
  name                = "vmss-lb"
  location            = "${azurerm_resource_group.company_resource_group.location}"
  resource_group_name = "${azurerm_resource_group.company_resource_group.name}"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = "${azurerm_public_ip.company_demo_public_ip.id}"
  }

  tags {
    environment = "company Terraform Demo"
  }
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
  resource_group_name = "${azurerm_resource_group.company_resource_group.name}"
  loadbalancer_id     = "${azurerm_lb.vmss_lb.id}"
  name                = "BackEndAddressPool"
}

resource "azurerm_lb_probe" "vmss_probe" {
  resource_group_name = "${azurerm_resource_group.company_resource_group.name}"
  loadbalancer_id     = "${azurerm_lb.vmss_lb.id}"
  name                = "ssh-running-probe"
  port                = "8080"
}

resource "azurerm_lb_rule" "lbnatrule" {
  resource_group_name            = "${azurerm_resource_group.company_resource_group.name}"
  loadbalancer_id                = "${azurerm_lb.vmss_lb.id}"
  name                           = "http"
  protocol                       = "Tcp"
  frontend_port                  = "80"
  backend_port                   = "8080"
  backend_address_pool_id        = "${azurerm_lb_backend_address_pool.bpepool.id}"
  frontend_ip_configuration_name = "PublicIPAddress"
  probe_id                       = "${azurerm_lb_probe.vmss_probe.id}"
}

# Generate a random name for the unique storage account
resource "random_id" "randomId" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = "${azurerm_resource_group.company_resource_group.name}"
  }

  byte_length = 8
}

# Create a storage account for boot diagnostics
resource "azurerm_storage_account" "company_demo_storage_account" {
  name                     = "diag${random_id.randomId.hex}"
  resource_group_name      = "${azurerm_resource_group.company_resource_group.name}"
  location                 = "${azurerm_resource_group.company_resource_group.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags {
    environment = "company Terraform Demo"
  }
}

# Tells it to use the Packer built image 
data "azurerm_image" "image" {
  name                = "${var.manageddiskname}"
  resource_group_name = "${var.manageddiskname-rg}"
}

# Create the virtual machine scale set
resource "azurerm_virtual_machine_scale_set" "vmss" {
  name                = "vmscaleset"
  location            = "${azurerm_resource_group.company_resource_group.location}"
  resource_group_name = "${azurerm_resource_group.company_resource_group.name}"
  upgrade_policy_mode = "Automatic"

  sku {
    name     = "Standard_DS1_v2"
    tier     = "Standard"
    capacity = 2
  }

  storage_profile_image_reference {
    id = "${data.azurerm_image.image.id}"
  }

  storage_profile_os_disk {
    name              = ""
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name_prefix = "companyvm"
    admin_username       = "ubuntu"
    admin_password       = "klb15cj1"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/ubuntu/.ssh/authorized_keys"
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEA7SMcumgTAnBm7mFWymUtRz9wv6fx64+OB604qOtBQRyJp8j/nGwGjCSVYYLLIHa+g3x5NXDFxiUcG/EE2KnrB/z3F/nQJr6hCCFHcJ8wBj4YCH99SqS9j3dFN63f0VqH8MY4sNeinzAhIQ92t40wZVkAWrg2S91im8f0/R7c/uHm2k+gs1kceZFVYvcIPjh/y7pjqiOXDURwWE7YHjxjU9O/lADpHTPZR/3wLlDZOGw7ZhRsUUPxXzWZHqszac+xZI0uHrolLoSWS/Af+oYKmqx3fHJ3x20ArjRy1RfkxNDU9+iQMgb69ljoC3Qqtzzdb6i+YkKAgrlIUm9o7wpDdw== rsa-key-20181115"
    }
  }

  network_profile {
    name    = "terraformnetworkprofile"
    primary = true

    ip_configuration {
      name                                   = "IPConfiguration"
	  subnet_id                              = "${azurerm_subnet.company_demo_subnet.id}"
	  primary                                = true
      load_balancer_backend_address_pool_ids = ["${azurerm_lb_backend_address_pool.bpepool.id}"]
    }
  }

  tags {
    environment = "company Terraform Demo"
  }
}

output "vm_ip" {
  value = "${azurerm_public_ip.company_demo_public_ip.ip_address}"
}

output "vm_dns" {
  value = "http://${azurerm_public_ip.company_demo_public_ip.domain_name_label}.azurewebsites.net"
}
