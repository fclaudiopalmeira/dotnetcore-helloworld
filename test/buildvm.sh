#!/bin/bash

echo "************* set environment vars *************"
export ARM_CLIENT_ID= < -- az ad sp credential list --id -- or create one with -- az ad sp create-for-rbac --name ServicePrincipalName --password PASSWORD -- >
export ARM_CLIENT_SECRET= < -- az ad sp credential list --id -- or create one with -- az ad sp create-for-rbac --name ServicePrincipalName --password PASSWORD -- >
export ARM_SUBSCRIPTION_ID= <run -- az account list -- to obtain the subscriptionId>
export ARM_TENANT_ID= <run -- az account list -- to obtain the tenantId>
export ARM_RESOURCE_GROUP_DISKS= <Name of a Resource Storage Group previously created to Store the Images or using --az storage account list-- you will find it under
"id": "/subscriptions/RANDOM_NUMBER/resourceGroups/ARM_RESOURCE_GROUP_DISKS_will_be_here/providers/Microsoft.Storage/storageAccounts/YOUR_STORAGE_ACCOUNT_NAME",
    "resourceGroup": "ARM_RESOURCE_GROUP_DISKS_will_be_here", >



rm packer-build-output.log
echo "************* execute packer build drop path --> $playbook_drop_path *************"

## execute packer build and send out to packer-build-output file
packer build  -var playbook_drop_path=./drop ./app.json 2>&1 | tee packer-build-output.log

## export output variable to terraform .
export manageddiskname=$(cat ./packer-build-output.log | grep ManagedImageName: | awk '{print $2}')

##Make sure that the Variable is stored where Terraform can find it.
sed -i 's/manageddiskname=$manageddiskname/'manageddiskname="$manageddiskname"'/g' /var/lib/jenkins/workspace/main/Company_Task/company/terraform/apply.sh

##Echo for troublehsooting the Script
echo "variable $manageddiskname"
