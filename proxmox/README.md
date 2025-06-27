# OpenTofu/terraform configs for proxmox
open tofu is fork of terraform, created as a response to hashicorp license change.
I recomend try it out. It's mostly drop in replacement
[link](https://opentofu.org/)
## Secrets setup
in project root create file `secrets.auto.tfvars`
with this content:
```go
pm_address                  = "proxmox_ip_address"
ssh_password                = "ssh_password"
pm_password                 = "proxmox_safe_password"
```
## Using OpenTofu/terraform
i recomend adding alias to .bashrc
```bash
alias tf=tofu
#or for terraform
alias tf=terraform
```
```bash
tf init    
# apply configuration
tf apply
# destroy configuration
tf destroy
```
## Linking secrets
```bash
cd selected_configuration_directory_name
ln -s ../secrets.auto.tfvars
```
