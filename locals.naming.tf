# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

locals {
  # Naming locals/constants
  name_prefix = lower(var.name_prefix)
  name_suffix = lower(var.name_suffix)

  resource_group_name = element(coalescelist(data.azurerm_resource_group.rg.*.name, module.mod_scaffold_rg.*.resource_group_name, [""]), 0)
  resource_group_id   = element(coalescelist(data.azurerm_resource_group.rg.*.id, module.mod_scaffold_rg.*.resource_group_id, [""]), 0)
  location            = element(coalescelist(data.azurerm_resource_group.rg.*.location, module.mod_scaffold_rg.*.resource_group_location, [""]), 0)
  cog_account_name    = coalesce(var.cog_account_custom_name, data.popsrox_resource_name.cognitive_account.result)
}
