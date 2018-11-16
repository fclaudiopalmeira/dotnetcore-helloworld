#!/bin/bash

echo "************* set environment vars"
export ARM_CLIENT_ID=1a2cc6ee-65fe-4e09-8e35-9c38b562040f
export ARM_CLIENT_SECRET=Caap1976@@13%
export ARM_SUBSCRIPTION_ID=84a68a68-a41a-4759-bc28-0ccd232569f1
export ARM_TENANT_ID=40fda9c3-8ec7-4be7-a2fb-bdb9ab85e345
export ARM_RESOURCE_GROUP_DISKS=serkojenkins



rm packer-build-output.log
echo "************* execute packer build drop path $6"
## execute packer build and send out to packer-build-output file
packer build  -var playbook_drop_path=./drop ./app.json 2>&1 | tee packer-build-output.log

## export output variable to terraform 
export manageddiskname=$(cat ./packer-build-output.log | grep ManagedImageName: | awk '{print $2}')

echo "variable $manageddiskname"
##[ -z "$manageddiskname" ] && exit 1 || exit 0
