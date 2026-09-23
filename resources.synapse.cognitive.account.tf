# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

resource "azurerm_cognitive_account" "cog" {
  count = signum(var.create_cognitive_account ? 1 : 0)

  name                  = local.cog_account_name
  custom_subdomain_name = local.cog_account_name
  location              = local.location
  resource_group_name   = local.resource_group_name
  kind                  = var.kind

  sku_name                      = var.sku
  public_network_access_enabled = false

  dynamic "identity" {
    for_each = toset(var.cmk_user_assigned_identity_id != null ? [1] : [])
    content {
      type         = "UserAssigned"
      identity_ids = [var.cmk_user_assigned_identity_id]
    }
  }

  dynamic "identity" {
    for_each = toset(var.cmk_user_assigned_identity_id == null ? [1] : [])
    content {
      type = "SystemAssigned"
    }
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [customer_managed_key]
  }
}


resource "azurerm_cognitive_account_customer_managed_key" "cog_cmk" {
  count = signum(var.create_cognitive_account && var.cmk_user_assigned_identity_client_id != null ? 1 : 0)

  cognitive_account_id = azurerm_cognitive_account.cog.0.id
  key_vault_key_id     = var.cmk_key_vault_key_id
  identity_client_id   = var.cmk_user_assigned_identity_client_id
}
