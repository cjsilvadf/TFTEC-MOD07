#Randon - utilizado para gerar uma string aleatória.
#length - tamanho
#special = false - sem caracter especial
#upper = false - sem caixa alta
#number = true - pode conter números
resource "random_string" "random" {
  length  = 3
  special = false
  upper   = false
}
resource "azurerm_storage_account" "storageCJS22" {
  # (resource arguments)  
  name                = "${var.storage_account_name}${random_string.random.result}${lower(var.ambiente)}"
  location              = azurerm_resource_group.rg_sto_lab07.location
  resource_group_name   = azurerm_resource_group.rg_sto_lab07.name
  account_tier        = "Standard"
  access_tier         = "Hot"
  //account_replication_type = "GRS"
  account_replication_type = "RAGRS"

  blob_properties {
    change_feed_enabled           = true
    versioning_enabled            = true
    last_access_time_enabled      = true
    change_feed_retention_in_days = 7

    //change_feed_retention_in_days = "1"

    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }

  tags = {
    environment = "staging"
  }

}
#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container
resource "azurerm_storage_container" "container" {
  name                 = "blobazcjs22"
  storage_account_name = azurerm_storage_account.storageCJS22.name
  //container_access_type = "container" 
  //permissão em nível de container e de blob, podendo acessa a raíz do container.
  //container_access_type = "blob"  permissão no nível do arquivo.
  container_access_type = "private"
  // Default to private 
  depends_on = [azurerm_storage_account.storageCJS22
  ]
}

#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_blob
resource "azurerm_storage_blob" "blob" {
  name                   = "ResVNGW.zip"
  storage_account_name   = azurerm_storage_account.storageCJS22.name
  storage_container_name = azurerm_storage_container.container.name
  type                   = "Block"
  content_type           = "application/x-zip-compressed"
  source                 = "ResVNGW.zip"
}
#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_management_policy

resource "azurerm_storage_management_policy" "policy" {
  storage_account_id = azurerm_storage_account.storageCJS22.id
  rule {
    name    = "Rule-01-BlobTest"
    enabled = true
    filters {
      //  prefix_match = ["container2/prefix1", "container2/prefix2"]
      blob_types = ["blockBlob"]
    }
    actions {
      base_blob {
        tier_to_cool_after_days_since_modification_greater_than    = 60
        tier_to_archive_after_days_since_modification_greater_than = 180
      }
    }
  }
}
#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_share
resource "azurerm_storage_share" "stoshare" {
  name                 = var.storage_share_name
  storage_account_name = azurerm_storage_account.storageCJS22.name
  quota                = var.storage_share_quota
  access_tier          = "Hot"
}
#Hot
#Cool
#TransactionOptimized
#Premium

resource "azurerm_storage_sync" "storage_sync" {
  name                = var.storage_sync_name
  location              = azurerm_resource_group.rg_sto_lab07.location
  resource_group_name   = azurerm_resource_group.rg_sto_lab07.name

  tags = {
    Modulo = "MOD07"
  }
}

resource "azurerm_storage_sync_group" "storage_sync_group" {
  name            = var.storage_sync_group
  storage_sync_id = azurerm_storage_sync.storage_sync.id
}

resource "azurerm_storage_sync_cloud_endpoint" "storage_sync_cloud_endpoint" {
  name                  = var.storage_sync_cloud_endpoint_name
  storage_sync_group_id = azurerm_storage_sync_group.storage_sync_group.id
  file_share_name       = azurerm_storage_share.stoshare.name
  storage_account_id    = azurerm_storage_account.storageCJS22.id
}




