# Deploy a Linux VM Per Availability Zone

This repository will deploy a single linux VM into each Azure Availability Zone by setting the variable `numAvailabilityZones` (defaults to 3) to the total number of Availability Zones in a region.

This code will create a new resource group for the VMs and connect them to an existing subnet within a VNet by setting the `subnetId` variable.

You will need a create a `variables.tfvars` file and set the __required variables__ for the deployment:
-  `subnetId`
    - Example: `/subscriptions/<subId>/resourceGroups/<rgName>/providers/Microsoft.Network/virtualNetworks/<vnetName>/subnets/<subnetName>`
-  `adminPassword`

__Optional variables__ that can be overriden for the deployment:
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

# NFS Testing

If you are planning to test performance against an NFS share, you can start by configuring each VM with the following initial commands:

```bash
sudo yum update -y --disablerepo='*' --enablerepo='*microsoft*'
sudo yum install -y nfs-utils
sudo yum install -y fio
sudo mkdir /mnt/nfsshare #(or use a permanent directory)
sudo mount -t nfs -o rw,hard,rsize=65536,wsize=65536,nconnect=8,vers=3,tcp 10.0.1.1:/nfssharename /mnt/nfsshare
```
To test with fio, create a config file simliar to below:

filename: `fio.cfg`
```bash
[global]
name=fio-test
directory=/mnt/nfsshare #This is the directory where files are written
ioengine=libaio #Async threads, jobs turned over to asynch threads and core moves on
direct=1 #Use directio, if you use libaio and NFS this must be set to 1 enabling directio
numjobs=1 #To match how many users on the system
nrfiles=4 #Num files per job
runtime=30 #If time_based is set, run for this amount of time
group_reporting #This is used to aggregate the job results, otherwise you have lots of data to parse
time_based #This setting says run the jobs until this much time has elapsed
stonewall
bs=64K
rw=rw #choose rw if sequential io, choose randrw for random io
#size=1024G #Aggregate file size per job (if nrfiles = 4, files=2.5GiB)
#size=62G #Aggregate file size per job (if nrfiles = 4, files=2.5GiB)
size=15872M #Aggregate file size per job (if nrfiles = 4, files=2.5GiB)
ramp_time=2 #Warm up
rwmixread=100
[rw]
```

You can then test using the following command:
```bash
fio fio.cfg
```

Optionally you may use the iodepth parameter to control the amount of I/O units used during testing.

For Example:
-  `--iodepth=1` (default)
-  `--iodepth=37`

# Notes
- Generation 1 VMs are currently being deployed due to the image defined in the `source_image_reference` resource object in `main.tf`. It is recommended to migrate to a generation 2 image.
- The OS disk is being set to `Premium_LRS` as this is the Azure portal default even though the terraform example use `Standard_LRS`. This configuration provides almost 6x more burstable IOPS.
- This deployment is configuring a Public IP which should be used for __testing only__.
- This deployment is allows a password which should be used for __testing only__. It is __strongly recommended__ to use SSH Keys insead. This can be accomplished by adding the following block to the the `azurerm_linux_virtual_machine` resouce and enabling `disable_password_authentication` parameter:
- ```terraform
    admin_ssh_key {
        username   = "adminuser"
        public_key = file("~/.ssh/id_rsa.pub")
    }
  ```