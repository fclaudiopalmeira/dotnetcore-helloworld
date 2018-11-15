#!/bin/bash
ls -la
echo "************* execute terraform apply  terraform apply -auto-approve -var manageddiskname=$6"

## execute terrafotm build and sendout to packer-build-output
export ARM_CLIENT_ID=1a2cc6ee-65fe-4e09-8e35-9c38b562040f
export ARM_CLIENT_SECRET=Caap1976@@13%
export ARM_SUBSCRIPTION_ID=84a68a68-a41a-4759-bc28-0ccd232569f1
export ARM_TENANT_ID=40fda9c3-8ec7-4be7-a2fb-bdb9ab85e345
export ARM_ACCESS_KEY=1KULLUw1oE5B9xuBeox/Yn6VZhw90WX6yxm+aVj16Y6RiOiJXkKard1xgyYOqD05vFMQnm9YRqqF4jUsSxoAog==

terraform apply -auto-approve -var "manageddiskname=$manageddiskname"
terraform output vm_ip > inventory

##echo " ansible_user=azureuser" >> inventory