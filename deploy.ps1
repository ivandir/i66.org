# deploy.ps1 — Sync i66.org command files and website to S3
# Usage:  .\deploy.ps1 [-DryRun]
param(
  [switch]$DryRun
)

$Bucket    = "s3://i66.org"
$DryRunArg = if ($DryRun) { "--dryrun" } else { $null }

if ($DryRun) { Write-Host ">>> DRY RUN — no files will be uploaded <<<" -ForegroundColor Yellow }

# Verify AWS CLI is available
if (-not (Get-Command aws -ErrorAction SilentlyContinue)) {
  Write-Error "AWS CLI not found. Install from https://aws.amazon.com/cli/"
  exit 1
}

Write-Host "Target bucket: $Bucket" -ForegroundColor Cyan
Write-Host ""

# ── 1. Sync command files (text/plain) ───────────────────────────────────────
Write-Host "▶ Syncing command files (text/plain)..." -ForegroundColor Green
$syncArgs = @(
  "s3", "sync", ".", $Bucket,
  "--exclude", "*",
  "--include", "aws/*",
  "--include", "azure/*",
  "--include", "gcp/*",
  "--include", "sys/*",
  "--include", "net/*",
  "--include", "ssl/*",
  "--include", "docker/*",
  "--include", "k8s/*",
  "--include", "cpucredits",
  "--include", "aws-cli-describe-stack-resources",
  "--content-type", "text/plain; charset=utf-8",
  "--cache-control", "no-cache, no-store, must-revalidate"
)
if ($DryRunArg) { $syncArgs += $DryRunArg }
& aws @syncArgs

# ── 2. Upload HTML files (text/html) ─────────────────────────────────────────
Write-Host "▶ Uploading HTML files (text/html)..." -ForegroundColor Green
$htmlArgs = @(
  "--content-type", "text/html; charset=utf-8",
  "--cache-control", "no-cache, no-store, must-revalidate"
)
if ($DryRunArg) { $htmlArgs += $DryRunArg }

& aws s3 cp index.html "$Bucket/index.html" @htmlArgs
& aws s3 cp error.html "$Bucket/error.html" @htmlArgs

Write-Host ""
Write-Host "✓ Deploy complete → http://i66.org" -ForegroundColor Cyan
