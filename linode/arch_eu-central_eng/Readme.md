```bash
tf apply \
  -var="bootstrap_pubkey=$(cat ~/.ssh/cluster_test.pub)" \
  -var="bootstrap_privkey_b64=$(base64 -w0 ~/.ssh/cluster_test)"
```
```bash
ssh-keygen -t ed25519 -f ~/.ssh/cluster_test -N ""

```
