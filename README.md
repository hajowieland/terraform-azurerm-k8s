# Terraform Kubernetes on Microsoft Azure

This repository contains the Terraform module for creating a simple but ready-to-use Kubernetes Cluster on Microsoft Azure Kubernetes Service (AKS).

It uses the latest Kubernetes version available in the Azure location and creates a kubeconfig file at completion.

#### Link to my comprehensive blog post (beginner friendly):
[https://napo.io/posts/terraform-kubernetes-multi-cloud-ack-aks-dok-eks-gke-oke/#microsoft-azure](https://napo.io/posts/terraform-kubernetes-multi-cloud-ack-aks-dok-eks-gke-oke/#microsoft-azure)


<p align="center">
<img alt="Azure Logo" src="https://upload.wikimedia.org/wikipedia/commons/thumb/a/a8/Microsoft_Azure_Logo.svg/320px-Microsoft_Azure_Logo.svg.png">
</p>


- [Terraform Kubernetes on Microsoft Azure](#Terraform-Kubernetes-on-Microsoft-Azure)
- [Requirements](#Requirements)
- [Features](#Features)
- [Notes](#Notes)
- [Defaults](#Defaults)
- [Runtime](#Runtime)
- [Terraform Inputs](#Terraform-Inputs)
- [Outputs](#Outputs)


# Requirements

You need a [Microsoft Azure](https://azure.microsoft.com/en-in/free/) account with a subscription (for example a [Pay-As-You-Go](https://azure.microsoft.com/en-in/offers/ms-azr-0003p/) subscription).


# Features

* Always uses latest Kubernetes version available at Azure location
* **kubeconfig** file generation
* Creates public IP address (e.g. for nginx-ingress)
* _OPTIONAL:_ Container Logs via [Log Analytics](https://docs.microsoft.com/en-us/azure/azure-monitor/insights/containers) ContainerInsights


# Notes

* `export KUBECONFIG=./kubeconfig_aks` in repo root dir to use the generated kubeconfig file
* The `enable_microsoft` variable is used in the [hajowieland/terraform-kubernetes-multi-cloud](https://github.com/hajowieland/terraform-kubernetes-multi-cloud) module


# Defaults

See tables at the end for a comprehensive list of inputs and outputs.


* Default region: **West Europe** _(Netherlands)_
* Default node type: **Standard_D1_v2** _(1x vCPU, 3.75GB memory)_
* Default node pool size: **2**


# Runtime

`terraform apply`:

~5-7min

```
2.56s user
0.89s system
7:16.37 total
```

```
2.38s user
0.75s system
5:15.77 total
```

7.11s user
2.30s system
6:44.52 total


# Terraform Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| enable_microsoft | Enable / Disable Microsoft Azure k8s | bool | true | yes |
| random_cluster_suffix | Random 6 byte hex suffix for cluster name | string |  | yes |
| ssh_public_key | Path to your SSH public key | string | ~/.ssh/id_rsa.pub | yes |
| az_client_id | Azure Service Principal appId | string |  | yes |
| az_client_secret | Azure Service Principal password | string |  | yes |
| az_tenant_id | Azure Service Principal tenant | string |  | yes |
| aks_region | AKS region | string | West Europe | yes |
| enable_logs | Enable azure log analtics for container logs | bool | false | yes |
| aks_name | AKS cluster name | string | k8s | yes |
| aks_nodes | AKS Kubernetes worker nodes | number | 2 | yes |
| aks_node_type | AKS node pool instance type | string | Standard_D1_v2 | yes |
| aks_pool_name | AKS agent node pool name | string | k8snodepool | yes |
| aks_node_disk_size | AKS node instance disk size in GB | number | 30 | yes |



# Outputs

| Name | Description |
|------|-------------|
| kubeconfig_path_aks | Kubernetes kubeconfig file |
| latest_k8s_version | Latest Kubernetes Version available in Azure location |
| public_ip_address | Public IP address |
| public_ip_fqdn | Public Fully Qualified Domain Name (FQDN) |
