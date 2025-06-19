# Terraform configs for linode
## Secrets setup
in project root create file `secrets.auto.tfvars`
with this content:
```terraform
linode_token   = ""
ssh_username   = ""
root_password  = ""
```
## Using terraform
```bash
cd selected_configuration_directory_name
# init terraform in new place
terraform init    
# apply configuration
terraform apply
# destroy configuration
terraform destroy
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
terraform show -json | jq ".values.root_module.resources[]"
# show ip address
terraform show -json | jq ".values.root_module.resources[].values.ipv4"
```
