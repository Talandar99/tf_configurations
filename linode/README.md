# OpenTofu/terraform configs for linode
open tofu is fork of terraform, created as a response to hashicorp license change.
I recomend try it out. It's mostly drop in replacement
[link](https://opentofu.org/)
## Secrets setup
in project root create file `secrets.auto.tfvars`
with this content:
```hcl
linode_token   = "" # your linode token
ssh_username   = "" # your linode ssh username
root_password  = "" # generate save password for linode server
cloudflare_domain = "" # your domain something like xyz.dev
cloudflare_api_token = "" # your api token for cloudflare

```
## Using OpenTofu/terraform
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
secrets symlink should already exist, but in case you need to create it this is how you do it:
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
