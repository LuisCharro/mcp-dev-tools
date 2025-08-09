#!/usr/bin/env bash
set -euo pipefail
THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

# Load .env if present
if [ -f "$THIS_DIR/.env" ]; then
  # shellcheck disable=SC2046
  export $(grep -v '^#' "$THIS_DIR/.env" | xargs -I{} echo {})
fi
if [ -f "$THIS_DIR/.env.local" ]; then
  # shellcheck disable=SC2046
  export $(grep -v '^#' "$THIS_DIR/.env.local" | xargs -I{} echo {})
fi

PORT="${SEARCH_PORT:-${PORT:-3334}}"

# Avoid starting if the port is already in use
if lsof -Pi :"$PORT" -sTCP:LISTEN -t >/dev/null 2>&1; then
  echo "Search server already running on port $PORT (or port in use). Skipping start."
  exit 0
fi

echo "Starting ripgrep MCP server (mcp-ripgrep) on http port $PORT via supergateway"

npx supergateway \
  --stdio "npx -y mcp-ripgrep" \
  --port "$PORT"
