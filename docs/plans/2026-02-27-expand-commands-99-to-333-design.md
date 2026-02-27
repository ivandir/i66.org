# Design: Expand Command Library from 99 to 333

**Date:** 2026-02-27
**Status:** Approved

---

## Goal

Grow the i66.org command library from 99 to 333 commands (+234) by deepening all existing
categories and adding 7 new top-level categories.

## Approach

Balanced expansion across two axes:

- **+85 commands** in 7 brand-new top-level categories
- **+149 commands** deepening the 8 existing categories proportionally

This matches the tool's quick-reference philosophy: broad, practical, fast.

---

## New Categories (+85 commands)

### `git/` — 15 commands

| Command | Description |
|---|---|
| `git/status` | Dirty files (staged, unstaged, untracked) |
| `git/branch` | All local branches |
| `git/branches-remote` | All remote branches |
| `git/log` | Last 20 commits: hash, author, date, message |
| `git/log-today` | Commits from today |
| `git/remotes` | Configured remotes and URLs |
| `git/stash` | Stash list |
| `git/tags` | All tags sorted by date |
| `git/diff-stat` | Staged diff summary |
| `git/contributors` | Commit count per author |
| `git/large-files` | Top 20 largest tracked files |
| `git/ahead-behind` | Commits ahead/behind remote tracking branch |
| `git/merged` | Branches merged into HEAD |
| `git/unmerged` | Branches not yet merged |
| `git/config` | Repo-level git config |

### `helm/` — 12 commands

| Command | Description |
|---|---|
| `helm/releases` | All installed releases across namespaces |
| `helm/failed` | Releases in failed/pending state |
| `helm/repos` | Configured chart repositories |
| `helm/history` | Release history (`RELEASE=name`) |
| `helm/values` | Deployed values for a release (`RELEASE=name`) |
| `helm/chart` | Chart metadata for a release (`RELEASE=name`) |
| `helm/notes` | Release notes (`RELEASE=name`) |
| `helm/manifests` | Rendered manifests for a release (`RELEASE=name`) |
| `helm/outdated` | Releases whose chart version is behind the repo |
| `helm/hooks` | Hooks for a release (`RELEASE=name`) |
| `helm/test` | Run release tests (`RELEASE=name`) |
| `helm/version` | Helm CLI version |

### `terraform/` — 10 commands

| Command | Description |
|---|---|
| `terraform/workspace` | Current and all workspaces |
| `terraform/state` | All resources in state |
| `terraform/state-count` | Count of managed resources |
| `terraform/output` | All outputs (`DIR=./path`) |
| `terraform/providers` | Provider versions in use |
| `terraform/modules` | Modules declared in config |
| `terraform/version` | Terraform and provider versions |
| `terraform/validate` | Validate config (`DIR=./path`) |
| `terraform/drift` | Plan summary showing resources that need changes |
| `terraform/locks` | Lock file contents |

### `db/` — 20 commands (Postgres + MySQL)

| Command | Description |
|---|---|
| `db/pg/databases` | All databases with size |
| `db/pg/connections` | Active connections by database/user |
| `db/pg/max-connections` | Max connections and current usage |
| `db/pg/tables` | Top 20 tables by size (`DB=mydb`) |
| `db/pg/slow-queries` | Queries over 1 second (pg_stat_statements) |
| `db/pg/locks` | Current lock waits |
| `db/pg/users` | Roles and privileges |
| `db/pg/replication` | Replication lag and slot status |
| `db/pg/bloat` | Top 10 tables by dead tuple ratio |
| `db/pg/vacuum-status` | Tables not vacuumed recently |
| `db/mysql/databases` | All databases with size |
| `db/mysql/connections` | Active connections |
| `db/mysql/tables` | Top 20 tables by size (`DB=mydb`) |
| `db/mysql/slow-queries` | Slow query log summary |
| `db/mysql/locks` | InnoDB lock waits |
| `db/mysql/users` | MySQL user accounts |
| `db/mysql/replication` | Replication status |
| `db/mysql/variables` | Key system variables |
| `db/mysql/processlist` | Running queries |
| `db/mysql/size` | Total database server size |

### `redis/` — 10 commands

| Command | Description |
|---|---|
| `redis/info` | Server info: version, uptime, memory |
| `redis/memory` | Memory usage breakdown |
| `redis/keyspace` | Key counts per database |
| `redis/clients` | Connected clients |
| `redis/slowlog` | Last 10 slow commands |
| `redis/stats` | Command stats: hits, misses, evictions |
| `redis/persistence` | RDB/AOF status |
| `redis/replication` | Master/replica topology |
| `redis/config` | Key config values |
| `redis/latency` | Latency history |

### `nginx/` — 8 commands

| Command | Description |
|---|---|
| `nginx/status` | Active connections and requests (stub_status) |
| `nginx/test` | Config syntax test |
| `nginx/version` | Nginx version and compile flags |
| `nginx/sites` | Enabled virtual hosts |
| `nginx/access-top` | Top 10 IPs by request count (last 1000 lines) |
| `nginx/errors` | Last 50 error log lines |
| `nginx/status-codes` | HTTP status code distribution (last 1000 lines) |
| `nginx/bandwidth` | Top 10 URLs by bytes served (last 1000 lines) |

### `vault/` — 10 commands

| Command | Description |
|---|---|
| `vault/status` | Seal/unseal status, HA mode |
| `vault/secrets` | Enabled secrets engines with paths |
| `vault/auth` | Enabled auth methods |
| `vault/policies` | All policies |
| `vault/tokens` | Token accessor list (no secret values) |
| `vault/leases` | Active lease count per path |
| `vault/audit` | Enabled audit devices |
| `vault/health` | Vault health endpoint |
| `vault/version` | Vault server version |
| `vault/namespaces` | Namespaces (Enterprise) |

---

## Existing Category Expansions (+149 commands)

### AWS — +57 (33 → 90)

**New subdirectories:**

| Subdir | New commands |
|---|---|
| `aws/eks/` | clusters, nodegroups, addons, fargate-profiles, access-entries |
| `aws/vpc/` | list, subnets, igw, nat, route-tables, eips, peering, sg-rules |
| `aws/sqs/` | list, depth, dlq, attributes |
| `aws/sns/` | topics, subscriptions, sms-attrs |
| `aws/ecr/` | repos, images, untagged, lifecycle-policies, scan-findings |
| `aws/ssm/` | parameters, sessions, patch-compliance, patch-summary, documents |
| `aws/secrets/` | list, rotation-status, replication |
| `aws/dynamo/` | tables, table-stats, indexes, streams, exports |
| `aws/cloudfront/` | distributions, origins, behaviors, invalidations |
| `aws/apigw/` | apis, stages, usage, keys |

**Additions to existing dirs:**

| Target | New commands |
|---|---|
| `aws/ec2/` | elastic-ips, launch-templates, asg |
| `aws/r53/` | record-sets, health-checks, resolvers |
| `aws/s3/` | size, versioning |
| `aws/iam/` | groups, mfa-devices, password-policy |

### Azure — +24 (8 → 32)

| Subdir | New commands |
|---|---|
| `azure/network/` | vnet-list, nsg-list, lb-list, public-ips, dns-zones, app-gw, routes, peerings |
| `azure/db/` | sql-servers, cosmosdb, postgres, mysql, redis |
| `azure/monitor/` | alerts, metrics, activity-log, action-groups |
| `azure/app/` | web-apps, function-apps, app-plans, container-apps |
| `azure/security/` | key-vault, defender-status, locks |

### GCP — +24 (8 → 32)

| Subdir | New commands |
|---|---|
| `gcp/network/` | networks, subnets, firewall, static-ips, lb, routes, peerings, dns |
| `gcp/run/` | services, revisions, jobs, domains |
| `gcp/functions/` | list, triggers, logs |
| `gcp/pubsub/` | topics, subscriptions, snapshots |
| `gcp/monitor/` | alerts, uptime, metrics, incidents |
| `gcp/iam/` | + service-accounts |
| `gcp/sql/` | + users |

### `sys/` — +15 (15 → 30)

| Area | New commands |
|---|---|
| Security posture | `suid`, `world-writable`, `sudoers`, `open-files` |
| Storage details | `lvm-vgs`, `lvm-lvs`, `large-files`, `mount-options` |
| Performance I/O | `iostat`, `net-io`, `cpu-cores` |
| Logs & audit | `syslog-errors`, `auth-log`, `dmesg`, `reboots` |

### `k8s/` — +10 (11 → 21)

`namespaces`, `configmaps`, `daemonsets`, `statefulsets`, `jobs`, `cronjobs`, `hpa`, `quotas`,
`network-policies`, `crds`

### `net/` — +8 (16 → 24)

| Command | Description |
|---|---|
| `net/dig/aaaa` | IPv6 address records (`DOMAIN=`) |
| `net/dig/soa` | SOA record (`DOMAIN=`) |
| `net/dig/caa` | CAA record (`DOMAIN=`) |
| `net/dig/srv` | SRV record (`DOMAIN=`) |
| `net/http-status` | HTTP status code (`URL=`) |
| `net/redirects` | Follow redirect chain (`URL=`) |
| `net/port-check` | Check if port open (`HOST=`, `PORT=`) |
| `net/ssl-tls-version` | TLS protocol version offered (`DOMAIN=`) |

### `docker/` — +6 (6 → 12)

`stats`, `info`, `dangling-images`, `dangling-volumes`, `compose-ps`, `build-cache`

### `ssl/` — +5 (2 → 7)

`chain`, `ciphers`, `hsts`, `san`, `ct`

---

## Final Command Count

| Category | Before | After |
|---|---|---|
| aws/ | 33 | 90 |
| azure/ | 8 | 32 |
| gcp/ | 8 | 32 |
| sys/ | 15 | 30 |
| net/ | 16 | 24 |
| k8s/ | 11 | 21 |
| docker/ | 6 | 12 |
| ssl/ | 2 | 7 |
| git/ | 0 | 15 |
| helm/ | 0 | 12 |
| terraform/ | 0 | 10 |
| db/ | 0 | 20 |
| redis/ | 0 | 10 |
| nginx/ | 0 | 8 |
| vault/ | 0 | 10 |
| **Total** | **99** | **333** |

---

## Implementation Notes

- Every file is plain-text, no shebang, no extension — same convention as existing commands.
- Commands requiring a target use environment variables (`DOMAIN=`, `HOST=`, `IP=`, `URL=`,
  `RELEASE=`, `DB=`, `PORT=`, `DIR=`).
- Each new directory should include at least one "list" or zero-arg entry point so the category
  is immediately useful without needing to know the env-var convention.
- Implement in batches by category; deploy and test each batch independently via `make deploy`.
- Update `README.md` command table after each batch.
