# AzureVmPerAvailabilityZone

This repository will deploy a single linux VM into each Availability Zone by setting the variable `numAvailabilityZones` (defaults to 3) to the total number of Availability Zones in a region.

This code will create a new resource group for the VMs and connect them to an existing subnet within a VNet by setting the `subnetId` variable.

You will need a create a `variables.tfvars` file and add set the required variables for the deployment:
-  `subnetId`
    - Example: `/subscriptions/<subId>/resourceGroups/<rgName>/providers/Microsoft.Network/virtualNetworks/<vnetName>/subnets/<subnetName>`
-  `adminPassword`

Optional variables that can be overriden for the deployment:
-  `resourceGroupName`
-  `location`
    - `numAvailabilityZones` - if the location is changed, you will need to confirm the region has 3 zones.
-  `serverName`
-  `adminUsername`
-  `vmSKU`

## Testing
Run the following commands to test the Terraform example:
```bash

az login

terraform init 
terraform apply -input=false -auto-approve

```