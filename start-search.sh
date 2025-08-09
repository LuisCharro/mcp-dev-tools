#!/usr/bin/env bash
set -euo pipefail
THIS_DIR="$(cd "$(dirname "$0")" && pwd)"

# Load .env if present
if [ -f "$THIS_DIR/.env" ]; then
  # shellcheck disable=SC2046
  export $(grep -v '^#' "$THIS_DIR/.env" | xargs -I{} echo {})
fi

PORT="${SEARCH_PORT:-${PORT:-3334}}"

echo "Starting ripgrep MCP server (mcp-ripgrep) on http port $PORT via supergateway"

npx supergateway \
  --stdio "npx -y mcp-ripgrep" \
  --port "$PORT"
