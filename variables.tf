variable "resourceGroupName" {
    description = "Name of Resource Group holding Grid Test VM."
    default = "GridPerfTestRg"
}

variable "location" {
  description = "Azure Region for deployment."
  default = "canadacentral"
}

variable "numAvailabilityZones" {
  description = "Number of clients to create (number of availability zones)"
  default = 3
}

variable "serverName" {
  description = "VM Name"
  default = "gridvm"
}

variable "adminUsername" {
  description = "Username"
  default = "adminuser"
}

variable "adminPassword" {
  description = "Password"
  default = ""
}

variable "subnetId" {
  description = "Id of the subnet to attach VM to."
  default = "" #/subscriptions/<subId>/resourceGroups/<rgName>/providers/Microsoft.Network/virtualNetworks/<vnetName>/subnets/<subnetName>
}