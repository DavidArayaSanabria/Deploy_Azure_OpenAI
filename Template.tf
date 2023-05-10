provider "azurerm" {
  subscription_id = ""
  tenant_id       = ""
  client_id       = ""
  client_secret   = ""
  features {}

}

// Local Variables


locals {
  rg_name     = ""
  rg_location = "" // only available on East Us, South Central Us and West Europe as of now May-2023

  azurerm_virtual_network_hub = {
    name          = ""
    address_space = ""
    dns_servers   = "" //Optional 
  }

  gateway_subnet = {
    name           = "GatewaySubnet"
    address_prefix = "" 
  }

  azurerm_public_ip = {
    name              = ""
    allocation_method = ""
  }

  azurerm_virtual_network_gateway = {
    name          = ""
    type          = "Vpn"
    vpn_type      = "RouteBased"
    active_active = false
    enable_bgp    = false
    sku           = ""
  }

  ip_configuration = {
    name                          = ""
    private_ip_address_allocation = "Dynamic"
  }

  azurerm_virtual_network_spoke = {
    name          = ""
    address_space = ""
  }

  openai_subnet = {
    name           = ""
    address_prefix = ""
  }

  azurerm_virtual_network_peering_hubtospoke = {
    name = ""
  }

  azurerm_virtual_network_peering_spoketohub = {
    name = ""
  }

  azurerm_cognitive_account = {
    name                  = ""
    kind                  = "OpenAI"
    sku_name              = "S0"
    custom_subdomain_name = ""
  }
}



//Azure Objects

resource "azurerm_resource_group" "openai" {
  name     = local.rg_name
  location = local.rg_location
  tags = {
    POC = "OpenAI"
  }
}

resource "azurerm_virtual_network" "hub" {
  name                = local.azurerm_virtual_network_hub.name
  location            = local.rg_location
  resource_group_name = local.rg_name
  address_space       = [local.azurerm_virtual_network_hub.address_space]
  tags = {
    POC = "OpenAI"
  }
  depends_on = [
    azurerm_resource_group.openai
  ]
}

output "hub-vnet" {
  value = azurerm_virtual_network.hub.id
}


resource "azurerm_subnet" "gateway_subnet" {
  name                 = local.gateway_subnet.name
  resource_group_name  = local.rg_name
  virtual_network_name = local.azurerm_virtual_network_hub.name
  address_prefixes     = [local.gateway_subnet.address_prefix]
  depends_on = [
    azurerm_virtual_network.hub
  ]
}

output "gw-subnet" {
  value = azurerm_subnet.gateway_subnet.id
}

resource "azurerm_public_ip" "openai" {
  name                = local.azurerm_public_ip.name
  location            = local.rg_location
  resource_group_name = local.rg_name
  allocation_method   = local.azurerm_public_ip.allocation_method
  tags = {
    POC = "OpenAI"
  }
  depends_on = [
    azurerm_virtual_network.hub
  ]
}
output "pip-id" {
  value = azurerm_public_ip.openai.id
}


resource "azurerm_virtual_network_gateway" "openai" {
  name                = local.azurerm_virtual_network_gateway.name
  location            = local.rg_location
  resource_group_name = local.rg_name
  type                = local.azurerm_virtual_network_gateway.type
  vpn_type            = local.azurerm_virtual_network_gateway.vpn_type
  active_active       = local.azurerm_virtual_network_gateway.active_active
  enable_bgp          = local.azurerm_virtual_network_gateway.enable_bgp
  sku                 = local.azurerm_virtual_network_gateway.sku
  tags = {
    POC = "OpenAI"
  }
  depends_on = [
    azurerm_virtual_network.hub
  ]

  ip_configuration {
    name                          = local.ip_configuration.name
    public_ip_address_id          = azurerm_public_ip.openai.id
    private_ip_address_allocation = local.ip_configuration.private_ip_address_allocation
    subnet_id                     = azurerm_subnet.gateway_subnet.id
  }
}

resource "azurerm_virtual_network" "spoke" {
  name                = local.azurerm_virtual_network_spoke.name
  location            = local.rg_location
  resource_group_name = local.rg_name
  address_space       = [local.azurerm_virtual_network_spoke.address_space]
  tags = {
    POC = "OpenAI"
  }
}
output "spoke-vnet" {
  value = azurerm_virtual_network.spoke.id
}

resource "azurerm_subnet" "openai_subnet" {
  name                 = local.openai_subnet.name
  resource_group_name  = local.rg_name
  virtual_network_name = local.azurerm_virtual_network_spoke.name
  address_prefixes     = [local.openai_subnet.address_prefix]
  service_endpoints = [ "Microsoft.CognitiveServices" ]
  depends_on = [
    azurerm_virtual_network.spoke
  ]
}

output "openai-subnet" {
  value = azurerm_subnet.openai_subnet.id
}


resource "azurerm_virtual_network_peering" "hub2spoke" {
  name                      = local.azurerm_virtual_network_peering_hubtospoke.name
  resource_group_name       = local.rg_name
  virtual_network_name      = local.azurerm_virtual_network_hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke.id
}

resource "azurerm_virtual_network_peering" "spoke2hub" {
  name                      = local.azurerm_virtual_network_peering_spoketohub.name
  resource_group_name       = local.rg_name
  virtual_network_name      = local.azurerm_virtual_network_spoke.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
}

resource "azurerm_cognitive_account" "openai" {
  name                = local.azurerm_cognitive_account.name
  location            = local.rg_location
  resource_group_name = local.rg_name
  kind                = local.azurerm_cognitive_account.kind
  sku_name            = local.azurerm_cognitive_account.sku_name
  depends_on = [
    azurerm_resource_group.openai
  ]
  tags = {
    POC = "OpenAI"
  }
  custom_subdomain_name         = local.azurerm_cognitive_account.custom_subdomain_name
  public_network_access_enabled = "true" 
  network_acls {
    default_action = "Deny"
    ip_rules = [local.azurerm_virtual_network_hub.address_space]

   virtual_network_rules {
    subnet_id = azurerm_subnet.openai_subnet.id
   ignore_missing_vnet_service_endpoint = "false"  
   }

  }
}
