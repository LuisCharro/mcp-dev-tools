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

# Set ports from environment with defaults
MAIN_PORT="${PORT:-3333}"
SEARCH_PORT="${SEARCH_PORT:-3334}"
GIT_PORT="${GIT_PORT:-3335}"

echo "🚀 Starting MCP Dev Tools - All Services"
echo "   Repository: ${REPO_ROOT:-'(set in .env.local)'}"
echo "   Safe Write: ${SAFE_WRITE:-false}"
echo ""

# Check if services are already running
running_services=()
if lsof -Pi :"$MAIN_PORT" -sTCP:LISTEN -t >/dev/null 2>&1; then
  running_services+=("Filesystem ($MAIN_PORT)")
fi
if lsof -Pi :"$SEARCH_PORT" -sTCP:LISTEN -t >/dev/null 2>&1; then
  running_services+=("Search ($SEARCH_PORT)")
fi
if lsof -Pi :"$GIT_PORT" -sTCP:LISTEN -t >/dev/null 2>&1; then
  running_services+=("Git ($GIT_PORT)")
fi

if [ ${#running_services[@]} -gt 0 ]; then
  echo "⚠️  Some services already running:"
  printf '   - %s\n' "${running_services[@]}"
  echo ""
fi

# Start filesystem server
echo "Starting Filesystem Server on port $MAIN_PORT..."
PORT="$MAIN_PORT" "$THIS_DIR/start-http.sh" &> "$PROJECT_ROOT/mcp-gateway.log" &
FS_PID=$!

# Start search server
echo "Starting Search Server on port $SEARCH_PORT..."
SEARCH_PORT="$SEARCH_PORT" "$THIS_DIR/start-search.sh" &> "$PROJECT_ROOT/mcp-search.log" &
SEARCH_PID=$!

# Placeholder for git server (Phase 2)
# echo "Starting Git Server on port $GIT_PORT..."
# GIT_PORT="$GIT_PORT" "$THIS_DIR/start-git-http.sh" &> "$PROJECT_ROOT/mcp-git.log" &
# GIT_PID=$!

sleep 2

echo ""
echo "✅ MCP Dev Tools Started Successfully"
echo ""
echo "Active Services:"
echo "  🗂️  Filesystem: http://127.0.0.1:$MAIN_PORT/sse    (PID $FS_PID)"
echo "  🔍 Search:     http://127.0.0.1:$SEARCH_PORT/sse    (PID $SEARCH_PID)"
echo "  🚧 Git:        http://127.0.0.1:$GIT_PORT/sse      (Phase 2 - coming soon)"
echo ""
echo "📋 Next Steps:"
echo "  • Test with MCP Inspector: npx @modelcontextprotocol/inspector"
echo "  • Connect to: http://127.0.0.1:$MAIN_PORT/sse"
echo "  • Monitor logs: tail -f $PROJECT_ROOT/mcp-*.log"
echo "  • Stop all: pkill -f supergateway"
echo ""
