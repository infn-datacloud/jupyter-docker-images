#!/bin/bash
# Entrypoint jlab-base: lancia l'init per-utente (mount S3 rclone/FUSE,
# oidc-agent) in background e poi avvia il single-user. L'ENTRYPOINT non e'
# sovrascritto da DockerSpawner, quindi l'init parte sempre.
set -u
INIT=/jupyterlab-workspace/.init/spawn.sh
if [ -x "$INIT" ]; then
  echo "[entrypoint] avvio init: $INIT" >&2
  "$INIT" >/tmp/spawn.log 2>&1 &
else
  echo "[entrypoint] init mancante: $INIT" >&2
fi
exec tini -g -- "$@"
