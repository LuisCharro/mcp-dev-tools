#!/usr/bin/env bash
set -euo pipefail
THIS_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$THIS_DIR/../.." && pwd)"

# Load .env if present
if [ -f "$PROJECT_ROOT/.env" ]; then
  # shellcheck disable=SC2046
  export $(grep -v '^#' "$PROJECT_ROOT/.env" | xargs -I{} echo {})
fi
if [ -f "$PROJECT_ROOT/.env.local" ]; then
  # shellcheck disable=SC2046
  export $(grep -v '^#' "$PROJECT_ROOT/.env.local" | xargs -I{} echo {})
fi

SEARCH_PORT="${SEARCH_PORT:-3334}"
MAX_SEARCH_RESULTS="${MAX_SEARCH_RESULTS:-1000}"

# Avoid starting if the port is already in use
if lsof -Pi :"$SEARCH_PORT" -sTCP:LISTEN -t >/dev/null 2>&1; then
  echo "⚠️  Search server already running on port $SEARCH_PORT (or port in use). Skipping start."
  exit 0
fi

echo "🔍 Starting MCP Search Server"
echo "   Port: $SEARCH_PORT"
echo "   Max Results: $MAX_SEARCH_RESULTS"
echo "   Repository: ${REPO_ROOT:-'(inherits from environment)'}"
echo ""

npx supergateway \
  --stdio "npx -y mcp-ripgrep" \
  --port "$SEARCH_PORT"
