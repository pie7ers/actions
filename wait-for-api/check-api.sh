#!/usr/bin/env bash

#-e fails immediately when a command returns != 0
#-u fails if a variable is undefined
#-o pipefail if a command  in a pipe fails, all pipe fail

set -euo pipefail

URL_HEALTH="${1:?ERROR: URL_HEALTH input arg is required}"
RETRIES="${2:-30}"
INTERVAL="${3:-10}"

[[ "$RETRIES" =~ ^[0-9]+$ ]] || { echo "RETRIES must be numeric"; exit 1; }
[[ "$INTERVAL" =~ ^[0-9]+$ ]] || { echo "INTERVAL must be numeric"; exit 1; }

for i in $(seq 1 "$RETRIES"); do
  echo "checking /health [$i/$RETRIES]"
  if curl -sSf "$URL_HEALTH"; then
    echo "Service is ready"
    exit 0
  fi
  sleep "$INTERVAL"
done
echo "Service did not become ready"
exit 1