#!/usr/bin/env bash
set -euo pipefail
THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

npx supergateway \
  --stdio "$THIS_DIR/run-filesystem.sh" \
  --port 3333
