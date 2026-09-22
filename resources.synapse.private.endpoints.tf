# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

# Remove this file is you are not using the private endpoints. 
# Remove the comments to enable the private endpoints.

#---------------------------------------------------------
# Private Link for <<name of resource>> - Default is "false" 
#---------------------------------------------------------
/* data "azurerm_virtual_network" "vnet" {
  count               = var.enable_private_endpoint && var.virtual_network_name != null ? 1 : 0
  name                = var.virtual_network_name
  resource_group_name = local.resource_group_name
}

resource "azurerm_private_endpoint" "pep" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = format("%s-private-endpoint", var.workload_name)
  location            = var.location
  resource_group_name = local.resource_group_name
  subnet_id           = var.existing_subnet_id
  tags                = merge({ "Name" = format("%s-private-endpoint", var.workload_name) }, var.add_tags, )

  private_service_connection {
    name                           = "privatelink-primary"
    is_manual_connection           = false
    private_connection_resource_id = <<id of resource>>
    subresource_names              = [""]
  }
}

#------------------------------------------------------------------
# DNS zone & records for SQL Private endpoints - Default is "false" 
#------------------------------------------------------------------
data "azurerm_private_endpoint_connection" "pip" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = azurerm_private_endpoint.pep.0.name
  resource_group_name = local.resource_group_name
  depends_on          = [azurerm_mssql_server.sql]
}

resource "azurerm_private_dns_zone" "dns_zone" {
  count               = var.existing_private_dns_zone == null && var.enable_private_endpoint ? 1 : 0
  name                = var.environment == "public" ? "privatelink.<>.windows.net" : "privatelink.<>.usgovcloudapi.net"
  resource_group_name = local.resource_group_name
  tags                = merge({ "Name" = format("%s", "Azure-Private-DNS-Zone") }, var.add_tags, )
}

resource "azurerm_private_dns_zone_virtual_network_link" "vnet_link" {
  count                 = var.existing_private_dns_zone == null && var.enable_private_endpoint ? 1 : 0
  name                  = "vnet-private-zone-link"
  private_dns_zone_id   = azurerm_private_dns_zone.dns_zone.0.id
  virtual_network_id    = var.existing_vnet_id
  registration_enabled  = true
  tags                  = merge({ "Name" = format("%s", "vnet-private-zone-link") }, var.add_tags, )
}

resource "azurerm_private_dns_a_record" "a_rec" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = <<name of resource>>
  private_dns_zone_id = azurerm_private_dns_zone.dns_zone.0.id
  ttl                 = 300
  records             = [data.azurerm_private_endpoint_connection.pip.0.private_service_connection.0.private_ip_address]
}
 */