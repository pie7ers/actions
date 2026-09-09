#!/usr/bin/env bash

#-e fails immediately when a command returns != 0
#-u fails if a variable is undefined
#-o pipefail if a command  in a pipe fails, all pipe fail

set -euo pipefail

URL="${1:?ERROR: URL input arg is required}"
RETRIES="${2:-30}"
INTERVAL="${3:-10}"

[[ "$RETRIES" =~ ^[0-9]+$ ]] || { echo "RETRIES must be numeric"; exit 1; }
[[ "$INTERVAL" =~ ^[0-9]+$ ]] || { echo "INTERVAL must be numeric"; exit 1; }

for i in $(seq 1 "$RETRIES"); do
  echo "checking [$URL] [$i/$RETRIES]"
  if curl \
    --silent \
    --show-error \
    --fail \
    --connect-timeout 5 \
    --max-time 10 \
    --connect-timeout 5 \
    "$URL"; 
  then
    echo "Resource is ready"
    exit 0
  fi
  
  if [[ "$i" -lt "$RETRIES" ]]; then
    echo "Waiting for $INTERVAL seconds befor next attempt..."
    sleep "$INTERVAL"
  fi
done
echo "Resource did not become ready"
exit 1