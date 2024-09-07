# Proxmox - config cloud init
This is the guide i use to create a cloud init vm template in proxmox.

## Download Ubuntu Cloud Image
Get latest version of Ubuntu Cloud Image. Select "QCow2 UEFI/GPT Bootable disk image" type. Download links [here](https://cloud-images.ubuntu.com).

[Ubuntu 24.04 LTS (Noble Numbat)](https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img)

Storage 'local' on node 'proxmox' - ISOS Images - Download from URL and paste the link

## Proxmox node Shell:
> [!IMPORTANT]
> change "VMs" for the name of your proxmox storage where you have your vm's disks

```bash
qm create 5000 --memory 2048 --core 2 --name ubuntu-cloud --net0 virtio,bridge=vmbr0
qm importdisk 5000 /var/lib/vz/template/iso/noble-server-cloudimg-amd64.img VMs
qm set 5000 --scsihw virtio-scsi-pci --scsi0 VMs:vm-5000-disk-0
qm set 5000 --ide2 VMs:cloudinit
qm set 5000 --boot c --bootdisk scsi0
qm set 5000 --serial0 socket --vga serial0
```

## config vm hardware on the UI:

```text-plain
Memory: 2048 (balloming off)
Processors: Type host
Hard disk: SSD emulation on
```

## config cloud-init on the UI:

```text-plain
username: user
password: ******
ssh keys: copy proxmox cert from: cat /root/.ssh/id_rsa.pub
ip config: change to dhcp
```

**Right click on the VM: Convert to template**

> [!TIP]
> Deploy new VMs by cloning the template and select full clone. 

