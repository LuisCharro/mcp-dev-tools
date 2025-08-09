#!/usr/bin/env bash

# MCP Dev Tools - Main Launcher
# This script starts the MCP server that allows AI assistants to code with you

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Default configuration
DEFAULT_PORT="3333"

# Load .env if present to get REPO_ROOT/PORT defaults
THIS_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -f "$THIS_DIR/.env" ]; then
  # shellcheck disable=SC2046
  export $(grep -v '^#' "$THIS_DIR/.env" | xargs -I{} echo {})
fi
if [ -f "$THIS_DIR/.env.local" ]; then
    # shellcheck disable=SC2046
    export $(grep -v '^#' "$THIS_DIR/.env.local" | xargs -I{} echo {})
fi

# Allow overrides via environment variables
PORT="${PORT:-$DEFAULT_PORT}"

# First-run prompt for REPO_ROOT if not set
if [ -z "${REPO_ROOT:-}" ]; then
    echo "No REPO_ROOT configured. Let's set it up."
    read -r -p "Enter absolute path to your repository: " INPUT_REPO
    if [ -z "$INPUT_REPO" ] || [ ! -d "$INPUT_REPO" ]; then
        echo -e "${RED}❌ Invalid repository path: '$INPUT_REPO'${NC}"
        echo "Please re-run with a valid path or set REPO_ROOT in .env"
        exit 1
    fi
    REPO_ROOT="$INPUT_REPO"
    # Persist to .env (create or update)
    if [ -f "$THIS_DIR/.env.local" ]; then
        if grep -q '^REPO_ROOT=' "$THIS_DIR/.env.local"; then
            sed -i '' "s#^REPO_ROOT=.*#REPO_ROOT=$REPO_ROOT#" "$THIS_DIR/.env.local"
        else
            printf "\nREPO_ROOT=%s\n" "$REPO_ROOT" >> "$THIS_DIR/.env.local"
        fi
    elif [ -f "$THIS_DIR/.env" ]; then
        if grep -q '^REPO_ROOT=' "$THIS_DIR/.env"; then
            sed -i '' "s#^REPO_ROOT=.*#REPO_ROOT=$REPO_ROOT#" "$THIS_DIR/.env"
        else
            printf "\nREPO_ROOT=%s\n" "$REPO_ROOT" >> "$THIS_DIR/.env"
        fi
    else
        printf "REPO_ROOT=%s\nPORT=%s\n" "$REPO_ROOT" "$PORT" > "$THIS_DIR/.env.local"
    fi
    echo -e "${GREEN}Saved REPO_ROOT to $THIS_DIR/.env.local${NC}"
fi

echo ""
echo "🤖 MCP Dev Tools Server"
echo "====================="
echo ""

# Check if repository exists
if [ ! -d "$REPO_ROOT" ]; then
    echo -e "${RED}❌ Repository not found: $REPO_ROOT${NC}"
    echo ""
    echo "Please set REPO_ROOT to a valid repository path:"
    echo "  REPO_ROOT=/path/to/your/repo $0"
    exit 1
fi

# Check if port is already in use
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Port $PORT is already in use${NC}"
    echo ""
    echo "Options:"
    echo "  1. Stop the existing server: pkill -f supergateway"
    echo "  2. Use a different port: PORT=3334 $0"
    exit 1
fi

echo -e "${GREEN}📁 Repository:${NC} $REPO_ROOT"
echo -e "${GREEN}🔌 Port:${NC} $PORT"
echo ""

# Start the server
echo "Starting server..."
export REPO_ROOT
./start-http.sh --port $PORT &> mcp-gateway.log &
SERVER_PID=$!

# Wait a moment for server to start
sleep 2

# Check if server started successfully
if ps -p $SERVER_PID > /dev/null; then
    echo -e "${GREEN}✅ Server started successfully!${NC}"
    echo ""
    echo "📋 Configuration for AI Assistants:"
    echo "  - Name: MCP Dev Tools"
    echo "  - URL: http://127.0.0.1:$PORT/"
    echo ""
    echo "📊 Server Info:"
    echo "  - PID: $SERVER_PID"
    echo "  - Logs: tail -f mcp-gateway.log"
    echo ""
    echo "🛑 To stop the server:"
    echo "  pkill -f 'supergateway.*$PORT'"
    echo ""
    echo -e "${GREEN}Ready for coding with AI assistants!${NC}"
else
    echo -e "${RED}❌ Failed to start server${NC}"
    echo "Check logs: cat mcp-gateway.log"
    exit 1
fi
