terraform {
  backend "azurerm" {
    resource_group_name   = "ecommerce-rg"
    storage_account_name  = "<replace-with-tfstate1-storage-account-name>"
    container_name        = "tfstate"
    key                   = "terraform.tfstate"
  }
}