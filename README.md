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
├── aws/                # AWS commands (EC2, S3, IAM, RDS, Lambda, ECS, CFN, etc.)
├── azure/              # Azure commands (VM, AKS, cost, etc.)
├── gcp/                # GCP commands (Compute, GKE, Cloud SQL, etc.)
├── sys/                # Linux system commands (disk, memory, CPU, etc.)
├── net/                # Network / DNS commands (dig, ping, whois, etc.)
├── ssl/                # SSL/TLS certificate commands
├── docker/             # Docker commands
└── k8s/                # Kubernetes commands
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

Commands that take a target use environment variables (`DOMAIN`, `HOST`, `IP`, `URL`).

### AWS — EC2

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

### AWS — CloudFormation

| Command | Description |
| --- | --- |
| `aws/cfn/stacks` | All active stacks with status |
| `aws/cfn/failed` | Stacks in failed/rollback state |
| `aws/cfn/drifted` | Stacks with drift detected |

### AWS — S3

| Command | Description |
| --- | --- |
| `aws/s3/list` | All buckets with creation date |
| `aws/s3/public` | Per-bucket public access block audit |

### AWS — IAM

| Command | Description |
| --- | --- |
| `aws/iam/whoami` | Current caller identity |
| `aws/iam/users` | All IAM users + last login |
| `aws/iam/roles` | All IAM roles |
| `aws/iam/keys` | Access keys per user + creation date |
| `aws/iam/mfa` | Users without MFA enabled |

### AWS — Cost

| Command | Description |
| --- | --- |
| `aws/cost/today` | Estimated charges today |
| `aws/cost/month` | Current month cost by service |
| `aws/cost/forecast` | Month-end cost forecast |

### AWS — CloudWatch

| Command | Description |
| --- | --- |
| `aws/cw/alarms` | Alarms currently in ALARM state |
| `aws/cw/alarms-all` | All alarms with their state |
| `aws/cw/logs` | Log groups sorted by last event |

### AWS — RDS

| Command | Description |
| --- | --- |
| `aws/rds/instances` | All RDS instances: class, engine, status |
| `aws/rds/snapshots` | 20 most recent manual snapshots |
| `aws/rds/events` | RDS events from last 24 hours |

### AWS — Lambda

| Command | Description |
| --- | --- |
| `aws/lambda/list` | All functions: runtime, memory, last modified |
| `aws/lambda/errors` | Error and throttle counts (last 1 hour) |

### AWS — ECS

| Command | Description |
| --- | --- |
| `aws/ecs/clusters` | All clusters with task/service counts |
| `aws/ecs/tasks` | Running tasks per cluster |

### AWS — Route 53

| Command | Description |
| --- | --- |
| `aws/r53/zones` | All hosted zones |

### Azure

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

### GCP

| Command | Description |
| --- | --- |
| `gcp/whoami` | Current account and project |
| `gcp/projects` | All projects |
| `gcp/vm/list` | All Compute Engine instances |
| `gcp/vm/running` | Only running instances |
| `gcp/buckets` | All GCS buckets |
| `gcp/sql/list` | All Cloud SQL instances |
| `gcp/gke/list` | All GKE clusters |
| `gcp/iam/users` | Project IAM policy bindings |

### System

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

### Docker

| Command | Description |
| --- | --- |
| `docker/ps` | Running containers |
| `docker/all` | All containers including stopped |
| `docker/images` | Local images |
| `docker/top10mem` | Containers sorted by memory |
| `docker/volumes` | Volumes and disk usage |
| `docker/networks` | Networks and their subnets |

### Kubernetes

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

### Network / DNS

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
| `net/whois` | Whois lookup (`DOMAIN=example.com`) |
| `net/ping` | Ping 5 times (`HOST=example.com`) |
| `net/trace` | Traceroute (`HOST=example.com`) |
| `net/headers` | HTTP response headers (`URL=https://example.com`) |

### SSL / TLS

| Command | Description |
| --- | --- |
| `ssl/check` | Certificate subject, issuer, dates (`DOMAIN=example.com`) |
| `ssl/expiry` | Days until certificate expires (`DOMAIN=example.com`) |

### Legacy

| Command | Description |
| --- | --- |
| `cpucredits` | EC2 CPU credit balance (see `aws/ec2/cpucredits`) |

---

## Security

Commands are downloaded over plain HTTP and executed without validation. Ensure you control the S3 bucket contents and that the bucket is not publicly writable.

---

## License

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/ivandir/i66.org/blob/main/LICENSE)

MIT License © 2025 i66.org
