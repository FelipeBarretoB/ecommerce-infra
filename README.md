# ecommerce-infra

This repository contains Terraform code and GitHub Actions workflows to provision and manage Azure Kubernetes Service (AKS) clusters and supporting infrastructure for an [e-commerce platform](https://github.com/FelipeBarretoB/ecommerce-microservice-backend-app).

## Features

- **Two AKS clusters** in separate Azure regions/resource groups for high availability or resource distribution.
- **Remote Terraform state** stored securely in Azure Storage.
- **Automated GitHub Actions workflow** to bootstrap and manage backend state and infrastructure.


## Structure

- `main.tf`: Main Terraform configuration for Azure resources and AKS clusters.
- `backend.tf`: Terraform backend configuration for remote state.
- `provieders.tf`: Terraform provider configuration.
- `.github/workflows/terraform-aks.yml`: GitHub Actions workflow for automated provisioning and state management.

## Prerequisites

- Azure subscription with sufficient permissions.
- Service principal credentials stored as GitHub secrets:
  - `AZURE_CLIENT_ID`
  - `AZURE_CLIENT_SECRET`
  - `AZURE_SUBSCRIPTION_ID`
  - `AZURE_TENANT_ID`
- Terraform CLI installed (for local use).

## Usage

### 1. Configure Backend

The first workflow run will create the Azure Storage Account for Terraform state and update `backend.tf` automatically.

### 2. Deploy Infrastructure

Push changes to the `main` branch or trigger the workflow manually. The workflow will:

- Check if the backend storage account is set.
- If not, create it and update `backend.tf`.
- Initialize Terraform and apply the configuration to provision AKS clusters and supporting resources.

### 3. Deploy Applications

After the clusters are provisioned, you can deploy workloads using Kubernetes manifests or Terraform resources.

## Outputs

- `kube_config_aks1`: Raw kubeconfig for the first AKS cluster.
- `kube_config_aks2`: Raw kubeconfig for the second AKS cluster.
- `azurerm_storage_account_tfstate1_name`: Name of the storage account used for Terraform state.

## Notes

- If you created Azure resources outside of Terraform, import them into the state before running `terraform apply`.
- The workflow auto-commits backend changes to avoid manual intervention.
- Adjust VM sizes, node counts, and regions as needed in `main.tf`.

## Terraform pipelines

We used github actions to automate the deployment of the infrastructure. The workflow is defined in `.github/workflows/terraform-aks.yml`.

Also, to make the state more secure, its added to a storage account in Azure.

If you want to use this workflow, youll need your own storage account

heres the pipeline:

```mermaid
sequenceDiagram
    participant Developer
    participant GitHubActions
    participant Azure

    Developer->>GitHubActions: Push or PR to main branch
    GitHubActions->>GitHubActions: Trigger "Terraform AKS Infra" workflow
    GitHubActions->>GitHubActions: Checkout code (actions/checkout@v4)
    GitHubActions->>GitHubActions: Set up Terraform (hashicorp/setup-terraform@v3)
    GitHubActions->>Azure: Azure Login (azure/login@v2)
    GitHubActions->>Azure: Create storage account and container (az cli)
    GitHubActions->>Azure: Terraform Init (terraform init)
    GitHubActions->>GitHubActions: Terraform Format (terraform fmt -check)
    GitHubActions->>GitHubActions: Terraform Validate (terraform validate)
    GitHubActions->>Azure: Terraform Apply (terraform apply -auto-approve)
    alt All steps successful
        GitHubActions-->>Developer: Notify success
    else Any step fails
        GitHubActions-->>Developer: Notify failure
    end
```

---

# Ansible

In the repository there's an ansible playbook to install ArgoCD on the AKS cluster.
The app was used in all of the project.

To run the playbook you need
- Azure CLI installed and configured
- logged in to the Azure CLI
- Kubectl installed and configured to connect to the AKS cluster
- Ansible installed
- An existing cluster

The playbook will install ArgoCD on the AKS cluster and expose it on a public IP.
It will do this to the two clusters defined in the `main.tf` file.

heres the pipeline 

```mermaid
sequenceDiagram
    participant Ansible
    participant AKS

    Ansible->>Ansible: Start playbook
    loop For each cluster
        Ansible->>AKS: Get AKS credentials
        Ansible->>AKS: Create ArgoCD namespace
        Ansible->>AKS: Install ArgoCD
        Ansible->>AKS: Expose ArgoCD via LoadBalancer
        Ansible->>AKS: Get initial ArgoCD admin password
        Ansible->>Ansible: Show initial ArgoCD admin password
    end
    Ansible->>Ansible: End playbook
```

---