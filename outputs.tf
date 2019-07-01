output "kubeconfig_path_aks" {
  value = "${local_file.kubeconfigaks.0.filename}"
}

output "public_ip_address" {
  value = azurerm_public_ip.public_ip.*.ip_address
}

output "public_ip_fqdn" {
  value = azurerm_public_ip.public_ip.*.fqdn
}