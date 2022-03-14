#-------------------------------
# Terraform provider and backend
#-------------------------------
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.95.0"
    }
  }
  #/* disabling the backend, remove the leading "#"
  backend "azurerm" {
    resource_group_name = "odm-rsg"
    #storage_account_name = Stored as a GitHub secret 
    container_name = "tfstates"
    key            = "terraform.tfstate"
  } # */
}
provider "azurerm" {
  features {}
}
#-------------------------------
# Define tags, edit in variables
#------------------------------
locals {
  common_tags = {
    environment = "${var.repo_name}"
    project     = "${var.project}"
    Owner       = "${var.repo_owner}"
  }
  /*
  extra_tags  = {
    network = "${var.network1_name}"
    support = "${var.network_support_name}"
  }*/
}