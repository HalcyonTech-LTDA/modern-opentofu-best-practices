# Azure Blob Storage Backend with Native Distributed Blob Lease Locking

terraform {
  backend "azurerm" {
    resource_group_name  = "rg-platform-governance"
    storage_account_name = "stplatformopentofustate"
    container_name       = "tfstates"
    key                  = "core-infra/prod.tfstate"
    use_oidc             = true
    use_azuread_auth     = true
  }
}
