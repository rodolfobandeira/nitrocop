# Self-Hosted Runner Investigation

Investigated using a Hetzner self-hosted runner to speed up CI.

## Conclusion

**Not worth it for this workload.** GitHub-hosted free tier (public repo) is the right answer. The queue clears itself within minutes during burst dispatches.

## Analysis

### The workload

Agent dispatches produce bursts of 10-20 PRs, each triggering a Checks workflow (build + test + 8 cop-check shards). The bottleneck is concurrent Checks runs competing for runners.

### Why self-hosted doesn't help

| Scenario | Self-hosted (1 machine) | GitHub-hosted |
|---|---|---|
| 20 concurrent Checks | Serialized, ~200 min | 20 parallel, ~10 min each |
| Warm cargo cache | Saves ~2-3 min per build | Cold every time |
| Net throughput | Much worse | Much better |

The warm cache advantage (~2-3 min saved per build) is dwarfed by the parallelism loss. Even with 2-3 runners on one machine, GitHub's effectively unlimited concurrency wins.

### Hetzner options considered

| Server | vCPU | RAM | Price | Notes |
|--------|------|-----|-------|-------|
| CX53 | 16 shared Intel | 32 GB | ~17/mo | Shared cores likely slower per-core than GitHub's dedicated AMD EPYC |
| CAX41 | 16 ARM64 | 32 GB | ~24/mo | Would need ARM cross-compilation, not worth the complexity |
| CPX41 | 8 dedicated AMD | 16 GB | ~14/mo | Good single-job perf but can't match 20-way parallelism |
| CPX62 | 16 dedicated AMD | 32 GB | ~38/mo | Fastest per-core but 2x the price, still can't match parallelism |

### What about specific workflows?

- **Checks**: Needs parallelism (20+ concurrent), GitHub-hosted wins.
- **agent-cop-fix**: Needs Codex/Claude CLIs and secrets, hard to set up on self-hosted. The agent is an API call that doesn't benefit from runner hardware.
- **agent-pr-repair**: Same as agent-cop-fix.
- **corpus-oracle**: Slowest workflow (25-60 min) but already shards across 20+ parallel GitHub-hosted jobs. A single self-hosted machine would be slower.

### When self-hosted would make sense

- Sustained pipeline with hundreds of PRs/day (not our case)
- Private repo burning through paid GitHub Actions minutes
- Workflows that are single-job and CPU-bound with no sharding

### Fallback routing

GitHub Actions has no built-in "try self-hosted, fall back to GitHub-hosted if busy." The pools are separate. You'd need to pick one at dispatch time via a workflow input, which adds complexity for marginal benefit.

## Setup (preserved for reference)

If we ever revisit, the Terraform setup is in `infra/hetzner/`. See git history for the full setup doc.
