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

GIT_PORT="${GIT_PORT:-3335}"
SAFE_WRITE="${SAFE_WRITE:-false}"

# Avoid starting if the port is already in use
if lsof -Pi :"$GIT_PORT" -sTCP:LISTEN -t >/dev/null 2>&1; then
  echo "⚠️  Git server already running on port $GIT_PORT (or port in use). Skipping start."
  exit 0
fi

echo "🚧 Git MCP Server (Placeholder)"
echo "   Port: $GIT_PORT"
echo "   Safe Write: $SAFE_WRITE"
echo "   Repository: ${REPO_ROOT:-'(not set)'}"
echo ""
echo "❌ Git server not yet implemented - this is Phase 2"
echo "   Will provide git/status, git/log, git/diff, etc."
echo ""
exit 1

# TODO: Phase 2 - Implement Git server
# npx supergateway \
#   --stdio "$PROJECT_ROOT/servers/git/dist/index.js" \
#   --port "$GIT_PORT"
