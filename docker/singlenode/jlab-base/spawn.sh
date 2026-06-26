#!/bin/bash
# Init per-utente: oidc-agent + mount S3 (rclone/FUSE). Robusto e idempotente.
set -uo pipefail
BASE_DIR=/jupyterlab-workspace/.init
S3_ROOT=/jupyterlab-workspace/s3

# oidc-agent
echo 'eval `oidc-keychain`' >> ~/.bashrc
eval "$(OIDC_CONFIG_DIR=$HOME/.config/oidc-agent oidc-keychain)"
oidc-gen infncloud --issuer "$IAM_SERVER" \
  --client-id "$IAM_CLIENT_ID" --client-secret "$IAM_CLIENT_SECRET" \
  --rt "$REFRESH_TOKEN" --confirm-yes --scope "openid profile email" \
  --redirect-uri http://localhost:8843 --pw-cmd "echo 'DUMMY PWD'"

# Stale mounts/processes cleaning
for mp in "$S3_ROOT/$USERNAME" "$S3_ROOT/scratch"; do
  fusermount -uz "$mp" 2>/dev/null || true
done
pids=$(pgrep -f "rclone .*mount" || true)
[ -n "$pids" ] && kill $pids 2>/dev/null || true

# mountpoint + mount
mkdir -p "$S3_ROOT/$USERNAME" "$S3_ROOT/scratch"
"$BASE_DIR/rclone-cmd.sh"