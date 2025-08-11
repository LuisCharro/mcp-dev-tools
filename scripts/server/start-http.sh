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

PORT="${PORT:-3333}"
if [[ "${1:-}" == "--port" && -n "${2:-}" ]]; then
  PORT="$2"
fi

echo "🚀 Starting MCP Dev Tools HTTP Proxy"
echo "   Port: $PORT"
echo "   SSE Endpoint: http://localhost:$PORT/sse"
echo "   POST Endpoint: http://localhost:$PORT/message"
echo "   Repository: ${REPO_ROOT:-'(not set - will be validated by filesystem server)'}"
echo ""

npx supergateway \
  --stdio "$THIS_DIR/run-filesystem.sh" \
  --port "$PORT"
