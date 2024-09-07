# Deploying Kubernetes High Availability k3s cluster
## Create the VMs
I always use a Ubuntu Cloud Image in a preconfigured cloud init template to speed up VMs deployment. You can create one by following my guide [here](/Proxmox/cloud-init-VM-template/README.md).

Create 7 virtual machines as follows:

+ **Master Nodes**
  + 3 Virtual machines
    + Memory:     2GB (balloon off)
    + Processor:  2 Cores
    + HDD:        10GB
+ **Worker Nodes**
  + 3 Vistual machines
    + Memory:     4GB (balloon off)
    + Processor:  4 Cores
    + HDD:        40GB
+ **Admin VM**
  + 1 Virtual machine to administer the cluster and run the deployment [pbk3s.sh](/Proxmox/Kubernetes-HA-k3s-cluster/pbk3s.sh) script.
    + Memory:     2GB
    + Processor:  2 Cores
    + HDD:        4GB

> [!IMPORTANT]
> You should assigh a static ip for every vm's mac adresses in you router/firewall.

## Start all the VMs
1. start up all the Vms and make sure all IPs are as expected.
2. edit the [pbk3s.sh](/Proxmox/Kubernetes-HA-k3s-cluster/pbk3s.sh) script with all your information.
3. ssh or use proxmox console and connect to the **Admin VM**.
4. copy proxmox **/root/.ssh/id_rsa.pub** and **/root/.ssh/id_rsa** to the server user home folder.
5. edit "VARS" section, copy and run the [pbk3s.sh](/Proxmox/Kubernetes-HA-k3s-cluster/pbk3s.sh) script to/from the server user home folder.
   + make file executable: ***sudo chmod +x pbk3s.sh***
   + run the script: ***./pbk3s.sh***

> [!NOTE]
> All should be running fine. Take a look at the script logs.