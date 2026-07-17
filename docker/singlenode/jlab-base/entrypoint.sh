#!/bin/bash
# jlab-base entrypoint: starts the per-user init (S3 rclone/FUSE mount,
# oidc-agent) in the background and then launches the single-user server. The
# ENTRYPOINT is not overridden by DockerSpawner, so the init always runs.
set -u
INIT=/jupyterlab-workspace/.init/spawn.sh
if [ -x "$INIT" ]; then
  echo "[entrypoint] starting init: $INIT" >&2
  "$INIT" >/tmp/spawn.log 2>&1 &
else
  echo "[entrypoint] init missing: $INIT" >&2
fi
exec tini -g -- "$@"
