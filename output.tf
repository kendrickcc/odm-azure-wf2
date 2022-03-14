#-------------------------------
# Outputs
#-------------------------------
output "ODM_public_ip_port_8001" {
  value = azurerm_linux_virtual_machine.nodeodm.*.public_ip_addresses
}
output "NodeODM_private_ip_addresses_port_3000" {
  value = azurerm_linux_virtual_machine.nodeodm.*.private_ip_addresses
}
