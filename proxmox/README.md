# OpenTofu/terraform configs for proxmox
open tofu is fork of terraform, created as a response to hashicorp license change.
I recomend try it out. It's mostly drop in replacement
[link](https://opentofu.org/)
## Secrets setup (secrets file)
in project root create file `secrets.auto.tfvars`
with this content (change text in quotes):
```terraform
pm_address                  = "proxmox_ip_address"
ssh_password                = "ssh_password"
pm_password                 = "proxmox_safe_password"
```
## Linking secrets 
secrets symlink should already exist, but in case you need to create it this is how you do it:
```bash
cd selected_configuration_directory_name
ln -s ../secrets.auto.tfvars
```
## adding alias to .bashrc (optional)
```bash
alias tf=tofu
#or for terraform
alias tf=terraform
```
## Using OpenTofu/terraform (with alias)
```bash
tf init    
# apply configuration
tf apply
# destroy configuration
tf destroy
```
## Creating VM template
You need VM template for creating vm's with terraform, configruation that are based on vm starts with vm_
### Create VM 
1. Create VM button 
2. General
 - Node: your node name
 - Name: does not matter
 - VM ID: does not matter
3. OS 
 - Storage: local
 - ISO: iso with installation of your system
 - Type: Linux
 - Kernel: leave default
4. System
 - Qemu Agent = true
 - Leave rest
5. Disks
 - does not matter but give at least 10GB
6. CPU 
 - does not matter 
7. Memory 
 - does not matter
8. Web
 - Bridge: vmbr0
 - Model: VirtiO
9. Confirm
 - Start After Created
### System Installation 
#### Install cloud init package
this is needed for terraform
```bash
    apt update
    apt install cloud-init qemu-guest-agent -y
    systemctl enable qemu-guest-agent
```
 - remember about installing ssh server
 - other stuff does not matter too much, just make sure everything you wanted is installed
#### Execute this if you want to log in as a root via ssh (optional)
```bash
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config 
echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config 
```
#### Clear image (optional)
```bash
   cloud-init clean
   truncate -s 0 /etc/machine-id
```
### Prepare template
1. shutdown vm
2. Hardware -> Add -> CloudInit Drive
 - Storage: local-lvm
3. Options
 - make sure scsi0 is first in boot order
 - Qemu Guest Agent = Enabled
#### Turn into template
More -> Convert to template







  


