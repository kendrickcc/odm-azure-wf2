variable "repo_name" {
  default = "odm-azure-wf2"
}
variable "repo_owner" {
  default = "kendrickcc"
}
variable "project" {
  default = "test build"
}
variable "pub_key" {
  default = "id_rsa_webodm"
}
variable "pub_key_data" {
  description = "The contents of the public key are stored in GitHub as a secret"
}
variable "fuse_accountname" {
  description = "Stored as a GitHub secret"
}
variable "fuse_accountkey" {
  description = "Stored as a GitHub secret"
}
variable "container" {
  default = "hwyuu"
}
variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  default     = "odmv6"
}
variable "location" {
  default = "centralus"
}
variable "nodeodm_servers" {
  description = "Number of nodeODM servers"
  default     = 1
}
variable "vnet_cidr" {
  default = "192.168.0.0/16"
}
variable "subnet_cidr" {
  default = "192.168.100.0/24"
}
variable "vmSize" {
  #default = "Standard_E4as_v5"  #  2 CPU  16 GiB $0.128/hour
  default = "Standard_E8as_v5" #  8 CPU  32 GiB $0.255/hour
  #default = "Standard_E16as_v5" # 16 CPU  64 GiB $0.511/hour 
  #default = "Standard_E20as_v5" # 20 CPU 128 GiB $1.022/hour
}
variable "adminUser" {
  default = "ubuntu"
}
variable "storageAccountType" {
  default = "Premium_LRS"
}
variable "diskSizeGB" {
  default = "100"
}
# Edit to one of the values for standard_os
variable "simple_os" {
  default = "focal"
}
# Definition of the standard OS with "SimpleName" = "publisher,offer,sku"
# To get a list of images for your location run
#    az vm image list --all --publisher Canonical --location centralus --output [table, tsv, json]
variable "standard_os" {
  default = {
    "bionic" = "Canonical,UbuntuServer,18_04-lts-gen2"
    "focal"  = "Canonical,0001-com-ubuntu-server-focal,20_04-lts-gen2"
  }
}