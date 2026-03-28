# Self-Hosted Runner (Hetzner)

A self-hosted runner gives agent workflows persistent cargo cache, more CPU, and no GitHub-imposed time limits. Agent test iterations drop from ~2-3 min (cold GitHub runner) to seconds (warm local cache).

## Why

| | GitHub-hosted | Self-hosted (Hetzner CPX41) |
|---|---|---|
| CPU | 4 vCPU (shared) | 8 vCPU (dedicated AMD) |
| RAM | 16 GB | 16 GB |
| Cargo cache | Cold every run | Persistent across runs |
| `cargo test` (1 cop, incremental) | ~2-3 min | ~5-10 sec |
| Max job time | 6 hours | 5 days |
| Cost | Free (public repo) | ~€14/mo |

## Quick Setup

### 1. Get tokens

**Hetzner**: Create an API token at https://console.hetzner.cloud → Project → Security → API Tokens

**GitHub runner**: Go to https://github.com/6/nitrocop/settings/actions/runners/new → copy the registration token from the `./config.sh` command shown

### 2. Deploy

```bash
cd infra/hetzner
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

terraform init
terraform apply
```

The server boots, installs Rust/Ruby/Node, registers the GitHub runner, and pre-warms the cargo cache (~10 min total). Check progress:

```bash
ssh runner@$(terraform output -raw server_ip) tail -f /var/log/runner-setup.log
```

### 3. Verify

The runner should appear at https://github.com/6/nitrocop/settings/actions/runners as "nitrocop-runner" with status "Idle".

### 4. Route Checks workflow to self-hosted

In `checks.yml`, change the build/test jobs:
```yaml
runs-on: ubuntu-24.04
```
to:
```yaml
runs-on: [self-hosted, linux, x64, nitrocop]
```

**Why Checks and not agent-cop-fix?** The agent workflow needs Codex/Claude
CLIs and secrets that are difficult to set up on self-hosted. The agent
itself is an API call that doesn't benefit from runner hardware. Meanwhile,
Checks runs on every push to every PR — when 20+ agent PRs land around the
same time, Checks is the bottleneck. A warm cargo cache on self-hosted makes
incremental builds near-instant.

`agent-cop-fix` and `agent-pr-repair` stay on GitHub-hosted runners (they
need Codex/Claude CLIs and secrets).

`corpus-oracle.yml` is also a good candidate for self-hosted — it's the
slowest workflow (25-60 min) and typically runs during quiet periods when
nothing else needs the runner. A warm cargo cache would cut build time
significantly.

## Runner Management

### SSH access
```bash
ssh runner@$(terraform output -raw server_ip)
```

### Check runner status
```bash
ssh runner@<ip> "cd ~/actions-runner && ./svc.sh status"
```

### Update runner
```bash
ssh runner@<ip> "cd ~/actions-runner && ./svc.sh stop"
# Re-run setup or update runner binary
ssh runner@<ip> "cd ~/actions-runner && ./svc.sh start"
```

### Clear cargo cache (if needed)
```bash
ssh runner@<ip> "rm -rf ~/nitrocop/target/"
```

### Destroy
```bash
cd infra/hetzner
terraform destroy
```

## Runner Token Expiration

The GitHub runner registration token is **one-time use** and expires after 1 hour. The runner itself stays registered indefinitely once configured. If you need to re-register:

1. Get a new token from Settings → Actions → Runners → New
2. SSH in and re-run `./config.sh`

## Security Notes

- The runner has access to `GITHUB_TOKEN` during workflow runs (same as GitHub-hosted)
- Agent credential isolation works the same as on GitHub-hosted
- The runner's persistent disk means previous run artifacts may be visible — the workspace cleanup step handles this
- Consider using ephemeral runners (`--ephemeral` flag) if you want a fresh environment each run (trades warm cache for isolation)
