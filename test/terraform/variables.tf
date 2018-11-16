variable "credentials" {
  default = ""
}

variable "project" {
  default = "NAME_OF_THE_PROJECT"
}

variable "manageddiskname-rg" {
  default = "NAME_OF_THE_RESOURCE_GROUP -- can be obtained using az storage account list you will find it under
"id": "/subscriptions/RANDOM_NUMBER/resourceGroups/ARM_RESOURCE_GROUP_DISKS_will_be_here/providers/Microsoft.Storage/storageAccounts/YOUR_STORAGE_ACCOUNT_NAME",
    "resourceGroup": "ARM_RESOURCE_GROUP_DISKS_will_be_here""
}

variable "baked_image_url" {
  default = ""
}

variable "manageddiskname" {
  default = ""
}
