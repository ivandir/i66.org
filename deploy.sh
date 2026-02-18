#!/usr/bin/env bash
# deploy.sh — Sync i66.org command files and website to S3
# Usage:  ./deploy.sh [--dry-run]
set -euo pipefail

BUCKET="s3://i66.org"
DRY_RUN=""
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN="--dryrun"
  echo ">>> DRY RUN — no files will be uploaded <<<"
fi

# Verify AWS CLI is available
if ! command -v aws &>/dev/null; then
  echo "Error: AWS CLI not found. Install from https://aws.amazon.com/cli/" >&2
  exit 1
fi

echo "Target bucket: $BUCKET"
echo ""

# ── 1. Sync command files (text/plain) ───────────────────────────────────────
# These are the plain-text bash scripts fetched and executed by the i66 CLI.
# text/plain is required so browsers render them instead of downloading them.
echo "▶ Syncing command files (text/plain)..."
aws s3 sync . "$BUCKET" \
  $DRY_RUN \
  --exclude "*" \
  --include "aws/*" \
  --include "azure/*" \
  --include "gcp/*" \
  --include "sys/*" \
  --include "net/*" \
  --include "ssl/*" \
  --include "docker/*" \
  --include "k8s/*" \
  --include "cpucredits" \
  --include "aws-cli-describe-stack-resources" \
  --content-type "text/plain; charset=utf-8" \
  --cache-control "no-cache, no-store, must-revalidate"

# ── 2. Sync HTML files (text/html) ───────────────────────────────────────────
echo "▶ Syncing HTML files (text/html)..."
aws s3 cp index.html "$BUCKET/index.html" \
  $DRY_RUN \
  --content-type "text/html; charset=utf-8" \
  --cache-control "no-cache, no-store, must-revalidate"

aws s3 cp error.html "$BUCKET/error.html" \
  $DRY_RUN \
  --content-type "text/html; charset=utf-8" \
  --cache-control "no-cache, no-store, must-revalidate"

echo ""
echo "✓ Deploy complete → http://i66.org"
