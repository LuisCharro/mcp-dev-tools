#!/usr/bin/env bash
set -euo pipefail
THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

# Load .env if present
if [ -f "$THIS_DIR/.env" ]; then
  # shellcheck disable=SC2046
  export $(grep -v '^#' "$THIS_DIR/.env" | xargs -I{} echo {})
fi

PORT="${PORT:-3333}"
if [[ "${1:-}" == "--port" && -n "${2:-}" ]]; then
  PORT="$2"
fi

echo "Starting supergateway on port $PORT (SSE: /sse, POST: /message)"

npx supergateway \
  --stdio "$THIS_DIR/run-filesystem.sh" \
  --port "$PORT"
