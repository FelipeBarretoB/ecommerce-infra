# Resource Group and Storage for Cluster 1
resource "azurerm_resource_group" "rg1" {
  name     = "ecommerce-rg"
  location = "East US"
}

resource "azurerm_storage_account" "tfstate1" {
  name                     = "ecommercetfstate1bl0fci"
  resource_group_name      = azurerm_resource_group.rg1.name
  location                 = azurerm_resource_group.rg1.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "tfstate1" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.tfstate1.id
  container_access_type = "private"
}

resource "azurerm_kubernetes_cluster" "aks1" {
  name                = "ecommerce-cluster"
  location            = azurerm_resource_group.rg1.location
  resource_group_name = azurerm_resource_group.rg1.name
  dns_prefix          = "ecommerceaks1"

  default_node_pool {
    name       = "tempnodepool"
    node_count = 1
    vm_size    = "Standard_E4s_v3"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "d2pool1" {
  name                  = "d2pool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks1.id
  vm_size               = "Standard_D2s_v3"
  node_count            = 1
}

# Resource Group and Storage for Cluster 2
resource "azurerm_resource_group" "rg2" {
  name     = "ecommerce-rg-2"
  location = "West Europe"
}


resource "azurerm_kubernetes_cluster" "aks2" {
  name                = "ecommerce-aks"
  location            = azurerm_resource_group.rg2.location
  resource_group_name = azurerm_resource_group.rg2.name
  dns_prefix          = "ecommerceaks2"

  default_node_pool {
    name       = "tempnodepool"
    node_count = 1
    vm_size    = "Standard_D2s_v3"
  }

  identity {
    type = "SystemAssigned"
  }
}

output "kube_config_aks1" {
  value     = azurerm_kubernetes_cluster.aks1.kube_config_raw
  sensitive = true
}

output "kube_config_aks2" {
  value     = azurerm_kubernetes_cluster.aks2.kube_config_raw
  sensitive = true
}

output "azurerm_storage_account_tfstate1_name" {
  value = azurerm_storage_account.tfstate1.name
}