mock_provider "azurerm" {
  mock_data "azurerm_resource_group" {
    defaults = {
      id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-existing"
      name     = "rg-existing"
      location = "eastus"
    }
  }

  mock_resource "azurerm_cognitive_account" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-existing/providers/Microsoft.CognitiveServices/accounts/cog"
    }
  }
}

mock_provider "popsrox" {
  mock_data "popsrox_resource_name" {
    defaults = {
      result = "generated-cognitive-account"
    }
  }
}

mock_provider "azapi" {}
mock_provider "random" {}

variables {
  location                     = "eastus"
  environment                  = "public"
  deploy_environment           = "dev"
  workload_name                = "synapse"
  org_name                     = "anoa"
  existing_resource_group_name = "rg-existing"
}

run "generated_name_empty_custom_name_and_disabled_counts" {
  command = plan

  override_module {
    target = module.mod_azregions

    outputs = {
      location_cli   = "eastus"
      location_short = "eus"
    }
  }

  variables {
    cog_account_custom_name  = ""
    create_cognitive_account = false
    kind                     = "CognitiveServices"
    enable_resource_locks    = false
    default_tags_enabled     = false
    tags                     = { costCenter = "1000" }
    add_tags                 = { owner = "platform" }
  }

  assert {
    condition     = local.cog_account_name == "generated-cognitive-account"
    error_message = "An empty cognitive account custom name must fall through to the generated name."
  }

  assert {
    condition     = length(azurerm_cognitive_account.cog) == 0
    error_message = "create_cognitive_account=false must not plan a cognitive account."
  }

  assert {
    condition     = length(azurerm_management_lock.resource_group_level_lock) == 0
    error_message = "enable_resource_locks=false must not plan a management lock."
  }

  assert {
    condition     = local.tags == tomap({ costCenter = "1000", owner = "platform" })
    error_message = "When default tags are disabled, caller supplied tag maps must still merge."
  }
}

run "custom_name_tags_location_and_enabled_counts" {
  command = plan

  override_module {
    target = module.mod_azregions

    outputs = {
      location_cli   = "eastus"
      location_short = "eus"
    }
  }

  variables {
    cog_account_custom_name  = "custom-cog-name"
    create_cognitive_account = true
    kind                     = "CognitiveServices"
    enable_resource_locks    = true
    tags                     = { workload = "caller-workload", costCenter = "1000" }
    add_tags                 = { owner = "platform" }
  }

  assert {
    condition     = azurerm_cognitive_account.cog[0].name == "custom-cog-name"
    error_message = "The cognitive account custom name must take precedence over the generated name."
  }

  assert {
    condition     = azurerm_cognitive_account.cog[0].location == var.location
    error_message = "The cognitive account location must pass through the resolved resource group location."
  }

  assert {
    condition     = length(azurerm_cognitive_account.cog) == 1
    error_message = "create_cognitive_account=true must plan one cognitive account."
  }

  assert {
    condition     = length(azurerm_management_lock.resource_group_level_lock) == 1
    error_message = "enable_resource_locks=true must plan one management lock."
  }

  assert {
    condition     = azurerm_management_lock.resource_group_level_lock[0].scope == local.resource_group_id
    error_message = "Management locks must target the resolved resource group ID."
  }

  assert {
    condition = azurerm_cognitive_account.cog[0].tags == tomap({
      deployedBy = "AzureNoOpsTF [default]"
      env        = "public"
      workload   = "caller-workload"
      costCenter = "1000"
      owner      = "platform"
    })
    error_message = "Cognitive account tags must merge default, tags, and add_tags values with caller values taking precedence."
  }
}

run "created_resource_group_location_and_lock_scope" {
  command = plan

  override_module {
    target = module.mod_azregions

    outputs = {
      location_cli   = "eastus"
      location_short = "eus"
    }
  }

  override_module {
    target = module.mod_scaffold_rg

    outputs = {
      resource_group_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-created"
      resource_group_name     = "rg-created"
      resource_group_location = "eastus"
    }
  }

  variables {
    create_resource_group      = true
    custom_resource_group_name = "rg-created"
    create_cognitive_account   = true
    cog_account_custom_name    = "custom-cog-name"
    kind                       = "CognitiveServices"
    enable_resource_locks      = true
  }

  assert {
    condition     = local.resource_group_name == "rg-created"
    error_message = "A created resource group's name must be used when create_resource_group=true."
  }

  assert {
    condition     = local.location == var.location
    error_message = "The configured location must pass through created resource group scaffolding."
  }

  assert {
    condition     = azurerm_management_lock.resource_group_level_lock[0].scope == "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-created"
    error_message = "Management locks must target the created resource group ID when the module creates the resource group."
  }
}
