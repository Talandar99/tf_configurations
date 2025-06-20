# OpenTofu/terraform configs for linode
open tofu is fork of terraform, created as a response to hashicorp license change.
I recomend try it out. It's mostly drop in replacement
[link](https://opentofu.org/)
## Secrets setup
in project root create file `secrets.auto.tfvars`
with this content:
```go
linode_token   = ""
ssh_username   = ""
root_password  = ""
```
## Using OpenTofu
i recomend adding alias to .bashrc
```bash
alias tf=tofu
#or for terraform
alias tf=terraform
```
```bash
cd selected_configuration_directory_name
# init terraform in new place
tf init    
tf init    
# apply configuration
tf apply
# destroy configuration
tf destroy
```
## Usefull commands
### Linking secrets
```bash
cd selected_configuration_directory_name
ln -s ../secrets.auto.tfvars
```
### Using jq for checking things
```bash
# show configuration
tf show -json | jq ".values.root_module.resources[]"
# show ip address
tf show -json | jq ".values.root_module.resources[].values.ipv4"
```
