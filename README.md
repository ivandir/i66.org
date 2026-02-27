# i66.org

**[i66.org](http://i66.org)** — A self-hosted library of plain-text shell commands served from S3, consumed by a minimal Go CLI.

---

## How it works

1. This repo contains the command files (plain-text shell scripts) and the Go CLI source.
2. The command files live in subdirectories (`aws/`, `sys/`, `k8s/`, etc.) and are synced to an S3 static website bucket (`s3://i66.org`).
3. The CLI fetches `http://i66.org/<command>`, receives the plain-text shell command, and executes it locally via `bash -c`.

```text
user runs: i66 aws/ec2/list
              │
              ▼
        GET http://i66.org/aws/ec2/list
              │
              ▼
       S3 returns plain-text shell command
              │
              ▼
        bash -c "<command>"
```

---

## Repository structure

```text
i66.org/
├── i66.org.go          # CLI source (single Go file, stdlib only)
├── Makefile            # Build targets: build, build-all, clean
├── deploy.sh           # Sync command files to S3 (bash)
├── deploy.ps1          # Sync command files to S3 (PowerShell)
├── index.html          # Web UI served from the S3 bucket root
├── error.html          # S3 error page
│
├── aws/                # AWS commands (EC2, VPC, EKS, S3, IAM, RDS, Lambda, ECS, CFN, etc.)
├── azure/              # Azure commands (VM, AKS, network, db, monitor, etc.)
├── gcp/                # GCP commands (Compute, GKE, Cloud SQL, Run, Pub/Sub, etc.)
├── sys/                # Linux system commands (disk, memory, CPU, security, logs, etc.)
├── net/                # Network / DNS commands (dig, ping, whois, HTTP, etc.)
├── ssl/                # SSL/TLS certificate commands
├── docker/             # Docker commands
├── k8s/                # Kubernetes commands
├── git/                # Git repository inspection commands
├── helm/               # Helm release management commands
├── terraform/          # Terraform state and workspace commands
├── db/                 # Database commands (PostgreSQL, MySQL)
├── redis/              # Redis inspection commands
├── nginx/              # Nginx status and log commands
└── vault/              # HashiCorp Vault commands
```

Each file in the command directories is a plain-text shell script — no extension, no shebang. Example (`aws/ec2/list`):

```bash
aws ec2 describe-instances --query '...' --output table
```

---

## Adding or editing commands

1. Create or edit a plain-text file at the desired path (e.g. `aws/ec2/newcommand`).
2. Run `make deploy` (or `./deploy.sh`) to sync to S3.
3. The command is immediately available via `i66 aws/ec2/newcommand`.

Commands that require a target (domain, IP, URL) use environment variables — e.g. `DOMAIN=example.com i66 net/dig/a` — since the CLI passes no positional arguments to the fetched command.

---

## Deployment

The deploy scripts sync all command directories and HTML files to `s3://i66.org`:

```bash
./deploy.sh           # deploy
./deploy.sh --dry-run # preview changes
```

```powershell
.\deploy.ps1           # deploy
.\deploy.ps1 -DryRun   # preview changes
```

Requires the AWS CLI and appropriate credentials for the `i66.org` bucket.

Files are uploaded as `text/plain` with `Cache-Control: no-cache, no-store, must-revalidate`.

---

## CLI

The CLI (`i66.org.go`) is a single Go file with no external dependencies.

**Build for current platform:**

```bash
make build
```

**Cross-compile for all platforms** (outputs to `build/<os>-<arch>/i66`):

```bash
make build-all
```

Output layout:

```text
build/
├── linux-amd64/i66
├── linux-arm/i66
├── linux-arm64/i66
├── darwin-amd64/i66
├── darwin-arm64/i66
└── windows-amd64/i66.exe
```

---

## Releases

Every push to `main` triggers [`.github/workflows/release.yml`](.github/workflows/release.yml):

1. Auto-bumps the semantic version based on commit message prefix
2. Builds binaries for all 6 platforms
3. Creates a GitHub Release with the binaries attached

| Commit prefix | Version bump |
| --- | --- |
| `fix:`, `perf:` | patch |
| `feat:` | minor |
| `BREAKING CHANGE` or `!` | major |
| anything else | patch |

---

## Available commands

Commands that take a target use environment variables (`DOMAIN`, `HOST`, `IP`, `URL`, `RELEASE`, `DB`, `PORT`, `DIR`, etc.).

<details>
<summary><strong>AWS</strong> — 90 commands (EC2, VPC, EKS, S3, IAM, RDS, Lambda, ECS, CFN, SQS, SNS, ECR, SSM, Secrets, DynamoDB, CloudFront, API GW, Route53, Cost, CloudWatch)</summary>

### EC2

| Command | Description |
| --- | --- |
| `aws/ec2/list` | All instances: ID, name, type, state, IPs |
| `aws/ec2/running` | Only running instances |
| `aws/ec2/stopped` | Only stopped instances |
| `aws/ec2/cpucredits` | CPU credit balance (auto-detects instance + region) |
| `aws/ec2/sg` | All security groups |
| `aws/ec2/amis` | Your own AMIs |
| `aws/ec2/keypairs` | Key pairs |
| `aws/ec2/volumes` | EBS volumes: size, state, attachment |
| `aws/ec2/snapshots` | 20 most recent snapshots |
| `aws/ec2/elastic-ips` | All Elastic IPs with allocation and association |
| `aws/ec2/launch-templates` | Launch templates with version info |
| `aws/ec2/asg` | Auto Scaling Groups: min, max, desired capacity |

### VPC / Networking

| Command | Description |
| --- | --- |
| `aws/vpc/list` | All VPCs with CIDR and state |
| `aws/vpc/subnets` | All subnets: VPC, CIDR, AZ, available IPs |
| `aws/vpc/igw` | Internet gateways and attached VPCs |
| `aws/vpc/nat` | NAT gateways: state and public IP |
| `aws/vpc/route-tables` | Route tables and route count |
| `aws/vpc/eips` | Unassociated (wasted) Elastic IPs |
| `aws/vpc/peering` | VPC peering connections and status |
| `aws/vpc/sg-rules` | Security groups with inbound/outbound rule counts |

### CloudFormation

| Command | Description |
| --- | --- |
| `aws/cfn/stacks` | All active stacks with status |
| `aws/cfn/failed` | Stacks in failed/rollback state |
| `aws/cfn/drifted` | Stacks with drift detected |

### S3

| Command | Description |
| --- | --- |
| `aws/s3/list` | All buckets with creation date |
| `aws/s3/public` | Per-bucket public access block audit |
| `aws/s3/size` | Per-bucket object count and total size |
| `aws/s3/versioning` | Versioning status per bucket |

### IAM

| Command | Description |
| --- | --- |
| `aws/iam/whoami` | Current caller identity |
| `aws/iam/users` | All IAM users + last login |
| `aws/iam/roles` | All IAM roles |
| `aws/iam/keys` | Access keys per user + creation date |
| `aws/iam/mfa` | Users without MFA enabled |
| `aws/iam/groups` | All IAM groups |
| `aws/iam/mfa-devices` | Virtual MFA devices and assigned users |
| `aws/iam/password-policy` | Account password policy |

### Cost

| Command | Description |
| --- | --- |
| `aws/cost/today` | Estimated charges today |
| `aws/cost/month` | Current month cost by service |
| `aws/cost/forecast` | Month-end cost forecast |

### CloudWatch

| Command | Description |
| --- | --- |
| `aws/cw/alarms` | Alarms currently in ALARM state |
| `aws/cw/alarms-all` | All alarms with their state |
| `aws/cw/logs` | Log groups sorted by last event |

### RDS

| Command | Description |
| --- | --- |
| `aws/rds/instances` | All RDS instances: class, engine, status |
| `aws/rds/snapshots` | 20 most recent manual snapshots |
| `aws/rds/events` | RDS events from last 24 hours |

### Lambda

| Command | Description |
| --- | --- |
| `aws/lambda/list` | All functions: runtime, memory, last modified |
| `aws/lambda/errors` | Error and throttle counts (last 1 hour) |

### ECS

| Command | Description |
| --- | --- |
| `aws/ecs/clusters` | All clusters with task/service counts |
| `aws/ecs/tasks` | Running tasks per cluster |

### EKS

| Command | Description |
| --- | --- |
| `aws/eks/clusters` | All EKS clusters |
| `aws/eks/nodegroups` | Node groups per cluster |
| `aws/eks/addons` | Installed add-ons per cluster |
| `aws/eks/fargate-profiles` | Fargate profiles per cluster |
| `aws/eks/access-entries` | Access entries per cluster |

### Route 53

| Command | Description |
| --- | --- |
| `aws/r53/zones` | All hosted zones |
| `aws/r53/record-sets` | Record sets for first zone (or `ZONE_ID=`) |
| `aws/r53/health-checks` | Health checks and configuration |
| `aws/r53/resolvers` | Route53 Resolver endpoints |

### SQS

| Command | Description |
| --- | --- |
| `aws/sqs/list` | All SQS queues |
| `aws/sqs/depth` | Message depth per queue |
| `aws/sqs/dlq` | Dead-letter queues (by name pattern) |
| `aws/sqs/attributes` | Queue attributes (`QUEUE_URL=`) |

### SNS

| Command | Description |
| --- | --- |
| `aws/sns/topics` | All SNS topics |
| `aws/sns/subscriptions` | All subscriptions: protocol, endpoint |
| `aws/sns/sms-attrs` | SMS delivery attributes |

### ECR

| Command | Description |
| --- | --- |
| `aws/ecr/repos` | All ECR repositories |
| `aws/ecr/images` | Images in a repo (`REPO=`) |
| `aws/ecr/untagged` | Repos with untagged images |
| `aws/ecr/lifecycle-policies` | Lifecycle policy status per repo |
| `aws/ecr/scan-findings` | Vulnerability scan results (`REPO=`, `TAG=`) |

### SSM

| Command | Description |
| --- | --- |
| `aws/ssm/parameters` | Parameter Store entries |
| `aws/ssm/sessions` | Active SSM sessions |
| `aws/ssm/patch-compliance` | Patch compliance summary |
| `aws/ssm/patch-summary` | Patch group state (`PATCH_GROUP=`) |
| `aws/ssm/documents` | Self-owned SSM documents |

### Secrets Manager

| Command | Description |
| --- | --- |
| `aws/secrets/list` | All secrets with last changed date |
| `aws/secrets/rotation-status` | Rotation enabled status per secret |
| `aws/secrets/replication` | Replicated secrets and target regions |

### DynamoDB

| Command | Description |
| --- | --- |
| `aws/dynamo/tables` | All DynamoDB tables |
| `aws/dynamo/table-stats` | Table stats: items, size, capacity (`TABLE=`) |
| `aws/dynamo/indexes` | Global secondary indexes (`TABLE=`) |
| `aws/dynamo/streams` | DynamoDB Streams |
| `aws/dynamo/exports` | Table export history |

### CloudFront

| Command | Description |
| --- | --- |
| `aws/cloudfront/distributions` | All distributions with status |
| `aws/cloudfront/origins` | Origins per distribution |
| `aws/cloudfront/behaviors` | Cache behaviors (`DIST_ID=`) |
| `aws/cloudfront/invalidations` | Invalidation history (`DIST_ID=`) |

### API Gateway

| Command | Description |
| --- | --- |
| `aws/apigw/apis` | All REST APIs |
| `aws/apigw/stages` | Stages per API |
| `aws/apigw/usage` | Usage plans and throttle limits |
| `aws/apigw/keys` | API keys |

</details>

<details>
<summary><strong>Azure</strong> — 32 commands (VMs, AKS, networking, databases, monitor, app services, security)</summary>

### Core

| Command | Description |
| --- | --- |
| `azure/whoami` | Current account and subscription |
| `azure/subs` | All subscriptions |
| `azure/vm/list` | All VMs with power state |
| `azure/vm/running` | Only running VMs |
| `azure/rg/list` | All resource groups |
| `azure/storage/list` | All storage accounts |
| `azure/aks/list` | All AKS clusters |
| `azure/cost/month` | Current month spend by service |

### Networking

| Command | Description |
| --- | --- |
| `azure/network/vnet-list` | All Virtual Networks |
| `azure/network/nsg-list` | All Network Security Groups |
| `azure/network/lb-list` | All load balancers |
| `azure/network/public-ips` | All public IP addresses |
| `azure/network/dns-zones` | All DNS zones and record set counts |
| `azure/network/app-gw` | All Application Gateways |
| `azure/network/routes` | All route tables |
| `azure/network/peerings` | VNet peering connections |

### Databases

| Command | Description |
| --- | --- |
| `azure/db/sql-servers` | Azure SQL servers |
| `azure/db/cosmosdb` | Cosmos DB accounts |
| `azure/db/postgres` | PostgreSQL flexible servers |
| `azure/db/mysql` | MySQL flexible servers |
| `azure/db/redis` | Azure Cache for Redis |

### Monitor

| Command | Description |
| --- | --- |
| `azure/monitor/alerts` | Metric alert rules |
| `azure/monitor/metrics` | Metric definitions for a resource (`RESOURCE_ID=`) |
| `azure/monitor/activity-log` | Last 20 activity log events |
| `azure/monitor/action-groups` | Action groups |

### App Services

| Command | Description |
| --- | --- |
| `azure/app/web-apps` | All Web Apps |
| `azure/app/function-apps` | All Function Apps |
| `azure/app/app-plans` | App Service Plans |
| `azure/app/container-apps` | Azure Container Apps |

### Security

| Command | Description |
| --- | --- |
| `azure/security/key-vault` | All Key Vaults |
| `azure/security/defender-status` | Defender for Cloud pricing tier per service |
| `azure/security/locks` | Resource locks |

</details>

<details>
<summary><strong>GCP</strong> — 32 commands (Compute, GKE, Cloud SQL, Cloud Run, Functions, Pub/Sub, networking, monitoring)</summary>

### Core

| Command | Description |
| --- | --- |
| `gcp/whoami` | Current account and project |
| `gcp/projects` | All projects |
| `gcp/vm/list` | All Compute Engine instances |
| `gcp/vm/running` | Only running instances |
| `gcp/buckets` | All GCS buckets |
| `gcp/sql/list` | All Cloud SQL instances |
| `gcp/sql/users` | Users in a Cloud SQL instance (`INSTANCE=`) |
| `gcp/gke/list` | All GKE clusters |
| `gcp/iam/users` | Project IAM policy bindings |
| `gcp/iam/service-accounts` | All service accounts |

### Networking

| Command | Description |
| --- | --- |
| `gcp/network/networks` | All VPC networks |
| `gcp/network/subnets` | All subnets across regions |
| `gcp/network/firewall` | Firewall rules |
| `gcp/network/static-ips` | Reserved static IP addresses |
| `gcp/network/lb` | Forwarding rules (load balancers) |
| `gcp/network/routes` | Custom routes |
| `gcp/network/peerings` | VPC peering connections |
| `gcp/network/dns` | Cloud DNS managed zones |

### Cloud Run

| Command | Description |
| --- | --- |
| `gcp/run/services` | All Cloud Run services |
| `gcp/run/revisions` | All revisions |
| `gcp/run/jobs` | Cloud Run jobs |
| `gcp/run/domains` | Domain mappings |

### Cloud Functions

| Command | Description |
| --- | --- |
| `gcp/functions/list` | All Cloud Functions |
| `gcp/functions/triggers` | Trigger types per function |
| `gcp/functions/logs` | Recent function logs |

### Pub/Sub

| Command | Description |
| --- | --- |
| `gcp/pubsub/topics` | All topics |
| `gcp/pubsub/subscriptions` | All subscriptions with ack deadline |
| `gcp/pubsub/snapshots` | All snapshots |

### Monitoring

| Command | Description |
| --- | --- |
| `gcp/monitor/alerts` | Alert policies |
| `gcp/monitor/uptime` | Uptime check configs |
| `gcp/monitor/metrics` | Custom log-based metrics |
| `gcp/monitor/incidents` | Active incidents |

</details>

<details>
<summary><strong>System</strong> — 30 commands (disk, memory, CPU, processes, ports, security, storage, I/O, logs)</summary>

| Command | Description |
| --- | --- |
| `sys/disk` | Disk usage for all filesystems |
| `sys/memory` | Memory and swap usage |
| `sys/cpu` | CPU model, cores, threads, MHz |
| `sys/load` | Load average and uptime |
| `sys/top10cpu` | Top 10 processes by CPU |
| `sys/top10mem` | Top 10 processes by memory |
| `sys/ports` | Listening TCP and UDP ports |
| `sys/connections` | Established TCP connections |
| `sys/who` | Logged-in users |
| `sys/logins` | Last 20 logins |
| `sys/failed-logins` | Recent failed SSH login attempts |
| `sys/kernel` | Kernel version and OS info |
| `sys/services` | Failed systemd units |
| `sys/crons` | System crontabs |
| `sys/inodes` | Inode usage per filesystem |
| `sys/suid` | SUID files |
| `sys/world-writable` | World-writable files |
| `sys/sudoers` | Sudoers config and drop-in files |
| `sys/open-files` | Top processes by open file count |
| `sys/lvm-vgs` | LVM volume groups |
| `sys/lvm-lvs` | LVM logical volumes |
| `sys/large-files` | Files over 100 MB |
| `sys/mount-options` | Filesystems with mount options |
| `sys/iostat` | Disk I/O statistics |
| `sys/net-io` | Network interface byte counters (from /proc) |
| `sys/cpu-cores` | Per-core CPU architecture details |
| `sys/syslog-errors` | Recent error-level syslog entries |
| `sys/auth-log` | Recent SSH/auth log entries |
| `sys/dmesg` | Kernel warnings and errors |
| `sys/reboots` | System reboot history |

</details>

<details>
<summary><strong>Docker</strong> — 12 commands</summary>

| Command | Description |
| --- | --- |
| `docker/ps` | Running containers |
| `docker/all` | All containers including stopped |
| `docker/images` | Local images |
| `docker/top10mem` | Containers sorted by memory |
| `docker/volumes` | Volumes and disk usage |
| `docker/networks` | Networks and their subnets |
| `docker/stats` | Container resource usage snapshot |
| `docker/info` | Docker engine info |
| `docker/dangling-images` | Untagged dangling images |
| `docker/dangling-volumes` | Dangling volumes |
| `docker/compose-ps` | docker compose services |
| `docker/build-cache` | Build cache and disk usage |

</details>

<details>
<summary><strong>Kubernetes</strong> — 21 commands</summary>

| Command | Description |
| --- | --- |
| `k8s/contexts` | All kubeconfig contexts |
| `k8s/nodes` | Node status and roles |
| `k8s/pods` | All pods in all namespaces |
| `k8s/pods-failed` | Failed and crashlooping pods |
| `k8s/svc` | All services |
| `k8s/pvc` | Persistent volume claims |
| `k8s/ingress` | All ingresses |
| `k8s/deploys` | All deployments |
| `k8s/top-nodes` | Node CPU and memory usage |
| `k8s/top-pods` | Pod CPU and memory usage |
| `k8s/events` | Recent warning events |
| `k8s/namespaces` | All namespaces |
| `k8s/configmaps` | All ConfigMaps |
| `k8s/daemonsets` | All DaemonSets |
| `k8s/statefulsets` | All StatefulSets |
| `k8s/jobs` | All Jobs |
| `k8s/cronjobs` | All CronJobs |
| `k8s/hpa` | Horizontal Pod Autoscalers |
| `k8s/quotas` | Resource quotas per namespace |
| `k8s/network-policies` | Network policies |
| `k8s/crds` | Custom Resource Definitions |

</details>

<details>
<summary><strong>Network / DNS</strong> — 24 commands</summary>

| Command | Description |
| --- | --- |
| `net/myip` | Public IP and local interfaces |
| `net/interfaces` | Network interfaces and IPs |
| `net/routes` | Routing table |
| `net/arp` | ARP / neighbour table |
| `net/dns` | DNS resolver config and /etc/hosts |
| `net/bandwidth` | Interface byte counters |
| `net/dig/a` | A records (`DOMAIN=example.com`) |
| `net/dig/mx` | MX records (`DOMAIN=example.com`) |
| `net/dig/ns` | Nameservers (`DOMAIN=example.com`) |
| `net/dig/txt` | TXT / SPF / DMARC records (`DOMAIN=example.com`) |
| `net/dig/cname` | CNAME chain (`DOMAIN=example.com`) |
| `net/dig/ptr` | Reverse DNS (`IP=1.2.3.4`) |
| `net/dig/aaaa` | IPv6 AAAA records (`DOMAIN=example.com`) |
| `net/dig/soa` | SOA record (`DOMAIN=example.com`) |
| `net/dig/caa` | CAA record (`DOMAIN=example.com`) |
| `net/dig/srv` | SRV record (`DOMAIN=example.com`) |
| `net/whois` | Whois lookup (`DOMAIN=example.com`) |
| `net/ping` | Ping 5 times (`HOST=example.com`) |
| `net/trace` | Traceroute (`HOST=example.com`) |
| `net/headers` | HTTP response headers (`URL=https://example.com`) |
| `net/http-status` | HTTP status code (`URL=`) |
| `net/redirects` | Follow redirect chain (`URL=`) |
| `net/port-check` | Check if port open (`HOST=`, `PORT=`) |
| `net/ssl-tls-version` | TLS protocol and cipher (`DOMAIN=`) |

</details>

<details>
<summary><strong>SSL / TLS</strong> — 7 commands</summary>

| Command | Description |
| --- | --- |
| `ssl/check` | Certificate subject, issuer, dates (`DOMAIN=example.com`) |
| `ssl/expiry` | Days until certificate expires (`DOMAIN=example.com`) |
| `ssl/chain` | Certificate chain issuers (`DOMAIN=`) |
| `ssl/ciphers` | Cipher suite enumeration (`DOMAIN=`) |
| `ssl/hsts` | HSTS and security headers (`DOMAIN=`) |
| `ssl/san` | Subject Alternative Names (`DOMAIN=`) |
| `ssl/ct` | Certificate Transparency log entries (`DOMAIN=`) |

</details>

<details>
<summary><strong>Git</strong> — 15 commands</summary>

| Command | Description |
| --- | --- |
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

</details>

<details>
<summary><strong>Helm</strong> — 12 commands</summary>

| Command | Description |
| --- | --- |
| `helm/releases` | All installed releases across namespaces |
| `helm/failed` | Releases in failed/pending state |
| `helm/repos` | Configured chart repositories |
| `helm/history` | Release history (`RELEASE=name`) |
| `helm/values` | Deployed values (`RELEASE=name`) |
| `helm/chart` | Chart metadata (`RELEASE=name`) |
| `helm/notes` | Release notes (`RELEASE=name`) |
| `helm/manifests` | Rendered manifests (`RELEASE=name`) |
| `helm/outdated` | Releases behind their repo chart version |
| `helm/hooks` | Release hooks (`RELEASE=name`) |
| `helm/test` | Run release tests (`RELEASE=name`) |
| `helm/version` | Helm CLI version |

</details>

<details>
<summary><strong>Terraform</strong> — 10 commands</summary>

| Command | Description |
| --- | --- |
| `terraform/workspace` | Current and all workspaces |
| `terraform/state` | All resources in state |
| `terraform/state-count` | Count of managed resources |
| `terraform/output` | All outputs (`DIR=./path`) |
| `terraform/providers` | Provider versions in use |
| `terraform/modules` | Modules declared in config |
| `terraform/version` | Terraform and provider versions |
| `terraform/validate` | Validate config (`DIR=./path`) |
| `terraform/drift` | Plan summary: resources that need changes |
| `terraform/locks` | Lock file contents |

</details>

<details>
<summary><strong>Databases</strong> — 20 commands (PostgreSQL, MySQL)</summary>

### PostgreSQL

| Command | Description |
| --- | --- |
| `db/pg/databases` | All databases with size |
| `db/pg/connections` | Active connections by database/user/state |
| `db/pg/max-connections` | Max connections vs. current usage |
| `db/pg/tables` | Top 20 tables by size (`DB=mydb`) |
| `db/pg/slow-queries` | Queries over 1 second (pg_stat_statements) |
| `db/pg/locks` | Current lock waits |
| `db/pg/users` | Roles and privileges |
| `db/pg/replication` | Replication lag and slot status |
| `db/pg/bloat` | Top 10 tables by dead tuple ratio |
| `db/pg/vacuum-status` | Tables not vacuumed recently |

### MySQL

| Command | Description |
| --- | --- |
| `db/mysql/databases` | All databases with size |
| `db/mysql/connections` | Active connection count |
| `db/mysql/tables` | Top 20 tables by size (`DB=mydb`) |
| `db/mysql/slow-queries` | Slow query log summary |
| `db/mysql/locks` | InnoDB lock waits |
| `db/mysql/users` | MySQL user accounts |
| `db/mysql/replication` | Replication status |
| `db/mysql/variables` | Key system variables |
| `db/mysql/processlist` | Running queries |
| `db/mysql/size` | Total database server size |

</details>

<details>
<summary><strong>Redis</strong> — 10 commands</summary>

| Command | Description |
| --- | --- |
| `redis/info` | Server info: version, uptime, port, OS |
| `redis/memory` | Memory usage and fragmentation |
| `redis/keyspace` | Key counts per database |
| `redis/clients` | Connected clients |
| `redis/slowlog` | Last 10 slow commands |
| `redis/stats` | Hits, misses, evictions, connections |
| `redis/persistence` | RDB/AOF status |
| `redis/replication` | Master/replica topology |
| `redis/config` | maxmemory, save, appendonly config |
| `redis/latency` | Latency history |

</details>

<details>
<summary><strong>Nginx</strong> — 8 commands</summary>

| Command | Description |
| --- | --- |
| `nginx/status` | Active connections (stub_status) |
| `nginx/test` | Config syntax test |
| `nginx/version` | Nginx version and compile flags |
| `nginx/sites` | Enabled virtual hosts |
| `nginx/access-top` | Top 10 IPs by request count |
| `nginx/errors` | Last 50 error log lines |
| `nginx/status-codes` | HTTP status code distribution |
| `nginx/bandwidth` | Top 10 URLs by bytes served |

</details>

<details>
<summary><strong>HashiCorp Vault</strong> — 10 commands</summary>

| Command | Description |
| --- | --- |
| `vault/status` | Seal/unseal status, HA mode |
| `vault/secrets` | Enabled secrets engines |
| `vault/auth` | Enabled auth methods |
| `vault/policies` | All policies |
| `vault/tokens` | Token accessor list |
| `vault/leases` | Active leases by path |
| `vault/audit` | Enabled audit devices |
| `vault/health` | Vault health endpoint |
| `vault/version` | Vault server version |
| `vault/namespaces` | Namespaces (Enterprise) |

</details>

**Legacy:** `cpucredits` → see `aws/ec2/cpucredits`

---

## Security

Commands are downloaded over plain HTTP and executed without validation. Ensure you control the S3 bucket contents and that the bucket is not publicly writable.

---

## License

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/ivandir/i66.org/blob/main/LICENSE)

MIT License © 2025 i66.org
