resource "random_id" "cluster_name" {
  byte_length = 6
}

resource "azurerm_resource_group" "rg" {
  count    = var.enable_microsoft ? 1 : 0
  name     = "K8sRG1"
  location = var.aks_region
}

## Azure Networking (enable_azurenet = true)

resource "azurerm_virtual_network" "vnet" {
  count =  var.enable_azurenet ? 1 : 0
  name                = "${var.aks_name}-${random_id.cluster_name.hex}-network"
  location            = "${azurerm_resource_group.rg[count.index].location}"
  resource_group_name = "${azurerm_resource_group.rg[count.index].name}"
  address_space       = [var.az_vpc_cidr]
}


resource "azurerm_route_table" "rt" {
  count = var.enable_azurenet ? 1 : 0
  name                = "${var.aks_name}-${random_id.cluster_name.hex}-routetable"
  location            =  azurerm_resource_group.rg[count.index].location
  resource_group_name =  azurerm_resource_group.rg[count.index].name

  route {
    name                   = "default"
    address_prefix         = "10.100.0.0/14"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.10.1.1"
  }
}

resource "azurerm_subnet" "subnet" {
  count = var.enable_azurenet ? 1 : 0
  name                 = "${var.aks_name}-${random_id.cluster_name.hex}-subnet"
  resource_group_name  = "${azurerm_resource_group.rg[count.index].name}"
  address_prefix       = cidrsubnet(var.az_vpc_cidr, 4, 1)
  virtual_network_name = "${azurerm_virtual_network.vnet[count.index].name}"
}

resource "azurerm_subnet_route_table_association" "rtassoc" {
  count = var.enable_azurenet ? 1 : 0
  subnet_id      = "${azurerm_subnet.subnet[count.index].id}"
  route_table_id = "${azurerm_route_table.rt[count.index].id}"
}


## Log Analytics for Container logs (enable_logs = true)

resource "azurerm_log_analytics_workspace" "logworkspace" {
  count = var.enable_logs ? 1 : 0
  name                = "${var.aks_name}-${random_id.cluster_name.hex}-law"
  location            = "${azurerm_resource_group.rg[count.index].location}"
  resource_group_name = "${azurerm_resource_group.rg[count.index].name}"
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_solution" "logsolution" {
  count = var.enable_logs ? 1 : 0
  solution_name         = "ContainerInsights"
  location              = "${azurerm_resource_group.rg[count.index].location}"
  resource_group_name   = "${azurerm_resource_group.rg[count.index].name}"
  workspace_resource_id = "${azurerm_log_analytics_workspace.logworkspace[count.index].id}"
  workspace_name        = "${azurerm_log_analytics_workspace.logworkspace[count.index].name}"

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}


## AKS

resource "azurerm_kubernetes_cluster" "aks" {
  count               = var.enable_microsoft ? 1 : 0
  name                = "${var.aks_name}-${random_id.cluster_name.hex}"
  location            = azurerm_resource_group.rg.0.location
  resource_group_name = azurerm_resource_group.rg.0.name
  dns_prefix          = "${var.aks_name}-${random_id.cluster_name.hex}"

  agent_pool_profile {
    vnet_subnet_id  = var.enable_azurenet ? azurerm_subnet.subnet[count.index].id : 0
    name            = var.aks_pool_name
    count           = var.aks_nodes
    vm_size         = var.aks_node_type
    os_type         = "Linux"
    os_disk_size_gb = var.aks_node_disk_size
  }

  linux_profile {
    admin_username = "ubuntu"

    ssh_key {
      key_data = "${file("${var.ssh_public_key}")}"
    }
  }

  service_principal {
    client_id     = var.az_client_id
    client_secret = var.az_client_secret
  }

  network_profile {
    network_plugin = var.enable_azurenet ? "azure" : "kubenet"
  }

  tags = {
    Project = "k8s",
    ManagedBy = "terraform"
  }
}


## Static Public IP Address to be used e.g. by Nginx Ingress

resource "azurerm_public_ip" "public_ip" {
  count               = var.enable_microsoft ? 1 : 0
  name                         = "k8s-public-ip"
  location                     = azurerm_kubernetes_cluster.aks[count.index].location
  resource_group_name          = azurerm_kubernetes_cluster.aks[count.index].node_resource_group
  allocation_method = "Static"
  domain_name_label            = "${var.aks_name}-${random_id.cluster_name.hex}"
}


## kubeconfig file

resource "local_file" "kubeconfigaks" {
  count    = var.enable_microsoft ? 1 : 0
  content  = azurerm_kubernetes_cluster.aks.0.kube_config_raw
  filename = "${path.module}/kubeconfig_aks"
}