# Self-Hosted Runner Setup

## Prerequisites

- Terraform: https://developer.hashicorp.com/terraform/install
- Hetzner Cloud account: https://console.hetzner.cloud
- SSH key pair

## Steps

### 1. Get tokens

**Hetzner API token:**
Console → your project → Security → API Tokens → Generate API Token (read/write)

**GitHub runner registration token:**
https://github.com/6/nitrocop/settings/actions/runners/new → copy token from the `./config.sh --token XXXXX` line

### 2. Configure

```bash
cd infra/hetzner
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:
```
hcloud_token        = "your-hetzner-token"
github_runner_token = "your-github-runner-token"
github_repo         = "6/nitrocop"
ssh_public_key      = "ssh-ed25519 AAAA..."
server_type         = "cpx42"
```

### 3. Deploy

```bash
terraform init
terraform apply
```

### 4. Wait for setup (~10 min)

```bash
ssh runner@$(terraform output -raw server_ip) tail -f /var/log/runner-setup.log
```

Look for `=== Setup complete ===` at the end.

### 5. Verify

Check https://github.com/6/nitrocop/settings/actions/runners — "nitrocop-runner" should show as Idle.

### 6. Tear down (when needed)

```bash
terraform destroy
```
