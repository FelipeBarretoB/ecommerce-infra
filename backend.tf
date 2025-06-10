terraform {
  backend "azurerm" {
    resource_group_name   = "ecommerce-rg"
    storage_account_name  = "ecommercetfstate1bl0fci"
    container_name        = "tfstate"
    key                   = "terraform.tfstate"
  }
}