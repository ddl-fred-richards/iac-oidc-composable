terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws        = { source = "hashicorp/aws", version = ">= 5.0" }
    azurerm    = { source = "hashicorp/azurerm", version = ">= 4.0" }
    auth0      = { source = "auth0/auth0", version = ">= 1.40.0" }
    github     = { source = "integrations/github", version = ">= 6.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = ">= 2.25" }
    platform   = { source = "jfrog/platform", version = ">= 2.2.11" }
    tls        = { source = "hashicorp/tls", version = ">= 4.0" }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "azurerm" {
  features {}
}

provider "auth0" {}
provider "github" {}
provider "kubernetes" {}
provider "platform" {}
