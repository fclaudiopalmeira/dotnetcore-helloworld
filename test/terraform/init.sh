#!/bin/bash
echo "************* execute terraform init *************"
## Initializes Terraform, fetches the necessary plugins and Load the backend.tfvars file
export ARM_CLIENT_ID= < -- az ad sp credential list --id -- or create one with -- az ad sp create-for-rbac --name ServicePrincipalName --password PASSWORD -- >
export ARM_CLIENT_SECRET= < -- az ad sp credential list --id -- or create one with -- az ad sp create-for-rbac --name ServicePrincipalName --password PASSWORD -- >
export ARM_SUBSCRIPTION_ID= <run -- az account list -- to obtain the subscriptionId>
export ARM_TENANT_ID= <run -- az account list -- to obtain the tenantId>
export ARM_ACCESS_KEY= < run -- az storage account keys list -g YOURResourceGroup -n YOURStorageAccount -->

terraform init -backend-config=backend.tfvars