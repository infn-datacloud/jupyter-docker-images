#!/bin/bash
# AI-INFN wrapper: replicates the docker-stacks run-hooks (the Debian 13 base
# no longer provides it) and runs the before-notebook.d hooks, then delegates
# to the jlab-base entrypoint.
set -u

# Align HOME with /etc/passwd (for root -> /home/private, see the sed in the
# Dockerfile): the base ENV points to /home/jovyan, which the
# 99_cleanup_jovyan.sh hook removes.
passwd_home=$(getent passwd "$(id -u)" | cut -d: -f6)
if [ -n "$passwd_home" ] && [ -d "$passwd_home" ]; then
  export HOME="$passwd_home"
fi

HOOKS_DIR=/usr/local/bin/before-notebook.d
if [ -d "$HOOKS_DIR" ]; then
  for hook in "$HOOKS_DIR"/*; do
    [ -f "$hook" ] || continue
    case "$hook" in
      *.sh)
        echo "[entrypoint-aiinfn] sourcing: $hook" >&2
        source "$hook" || echo "[entrypoint-aiinfn] hook failed: $hook" >&2
        ;;
      *)
        if [ -x "$hook" ]; then
          echo "[entrypoint-aiinfn] running: $hook" >&2
          "$hook" || echo "[entrypoint-aiinfn] hook failed: $hook" >&2
        fi
        ;;
    esac
  done
fi

exec /usr/local/bin/entrypoint.sh "$@"
