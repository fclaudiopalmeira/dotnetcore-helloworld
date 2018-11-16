#!/bin/bash
ls -la
echo "************* execute terraform apply  terraform apply -auto-approve -var manageddiskname=$manageddiskname"

## execute terrafotm build and sendout to packer-build-output
export ARM_CLIENT_ID= < -- az ad sp credential list --id -- or create one with -- az ad sp create-for-rbac --name ServicePrincipalName --password PASSWORD -- >
export ARM_CLIENT_SECRET= < -- az ad sp credential list --id -- or create one with -- az ad sp create-for-rbac --name ServicePrincipalName --password PASSWORD -- >
export ARM_SUBSCRIPTION_ID= <run -- az account list -- to obtain the subscriptionId>
export ARM_TENANT_ID= <run -- az account list -- to obtain the tenantId>
export ARM_ACCESS_KEY= < run -- az storage account keys list -g YOURResourceGroup -n YOURStorageAccount -->

terraform apply -auto-approve -var "manageddiskname=$manageddiskname"
terraform output vm_ip > inventory