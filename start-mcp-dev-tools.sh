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
DEFAULT_REPO="/Users/luis/Repos/PDFExtractorAI"
DEFAULT_PORT="3333"

# Allow overrides via environment variables
REPO_ROOT="${REPO_ROOT:-$DEFAULT_REPO}"
PORT="${PORT:-$DEFAULT_PORT}"

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
./start-http.sh --port $PORT &> mcp-dev-tools.log &
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
    echo "  - Logs: tail -f mcp-dev-tools.log"
    echo ""
    echo "🛑 To stop the server:"
    echo "  pkill -f 'supergateway.*$PORT'"
    echo ""
    echo -e "${GREEN}Ready for coding with AI assistants!${NC}"
else
    echo -e "${RED}❌ Failed to start server${NC}"
    echo "Check logs: cat mcp-dev-tools.log"
    exit 1
fi
