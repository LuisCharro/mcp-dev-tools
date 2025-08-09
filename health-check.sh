#!/bin/bash

# MCP Server Health Check Script
# This script checks the status of MCP servers and provides diagnostic information

echo "========================================="
echo "     MCP Server Health Check"
echo "========================================="
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check Node.js and npm
echo "1. Checking Node.js and npm..."
if command_exists node; then
    NODE_VERSION=$(node --version)
    echo -e "${GREEN}\u2713${NC} Node.js installed: $NODE_VERSION"
else
    echo -e "${RED}\u2717${NC} Node.js not found in PATH"
fi

if command_exists npm; then
    NPM_VERSION=$(npm --version)
    echo -e "${GREEN}\u2713${NC} npm installed: $NPM_VERSION"
else
    echo -e "${RED}\u2717${NC} npm not found in PATH"
fi
echo ""

# Check if servers are running
echo "2. Checking server processes..."
if pgrep -f "supergateway" > /dev/null; then
    PID=$(pgrep -f "supergateway" | head -1)
    echo -e "${GREEN}\u2713${NC} supergateway is running (PID: $PID)"
else
    echo -e "${YELLOW}\u26a0${NC} supergateway is not running"
fi
echo ""

# Check ports
echo "3. Checking ports..."
if lsof -Pi :3333 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo -e "${GREEN}\u2713${NC} Port 3333 is listening"
    echo "   Process using port 3333:"
    lsof -i :3333 | grep LISTEN | head -1 | awk '{print "   ", $1, $2}'
else
    echo -e "${YELLOW}\u26a0${NC} Port 3333 is not listening (server may not be running)"
fi

if lsof -Pi :3334 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo -e "${GREEN}\u2713${NC} Port 3334 is listening"
    echo "   Process using port 3334:"
    lsof -i :3334 | grep LISTEN | head -1 | awk '{print "   ", $1, $2}'
else
    echo -e "${YELLOW}\u26a0${NC} Port 3334 is not listening (server may not be running)"
fi
echo ""

# Check if project directory exists
echo "4. Checking project directories..."
if [ -d "/Users/luis/mcpServers/mcp-reference-servers" ]; then
    echo -e "${GREEN}\u2713${NC} mcp-reference-servers directory exists"
    
    # Check if node_modules exists
    if [ -d "/Users/luis/mcpServers/mcp-reference-servers/node_modules" ]; then
        echo -e "${GREEN}\u2713${NC} node_modules installed"
    else
        echo -e "${YELLOW}\u26a0${NC} node_modules not found - run 'npm ci' in mcp-reference-servers directory"
    fi
    
    # Check if built
    if [ -d "/Users/luis/mcpServers/mcp-reference-servers/src/filesystem/dist" ]; then
        echo -e "${GREEN}\u2713${NC} Filesystem server build exists"
    else
        echo -e "${YELLOW}\u26a0${NC} Build directory not found - run 'npm run build' in mcp-reference-servers directory"
    fi
else
    echo -e "${RED}\u2717${NC} mcp-reference-servers directory not found at /Users/luis/mcpServers/mcp-reference-servers"
fi
echo ""

# Check log files
echo "5. Checking log files..."
if [ -f "mcp-gateway.log" ]; then
    SIZE=$(du -h mcp-gateway.log | cut -f1)
    echo -e "${GREEN}\u2713${NC} mcp-gateway.log exists (size: $SIZE)"
    
    # Check for recent errors
    ERROR_COUNT=$(tail -100 mcp-gateway.log 2>/dev/null | grep -i error | wc -l)
    if [ $ERROR_COUNT -gt 0 ]; then
    echo -e "${YELLOW}\u26a0${NC} Found $ERROR_COUNT error(s) in last 100 lines of mcp-gateway.log"
    fi
else
    echo "   mcp-gateway.log not found in current directory"
fi

if [ -f "mcp-search.log" ]; then
    SIZE=$(du -h mcp-search.log | cut -f1)
    echo -e "${GREEN}\u2713${NC} mcp-search.log exists (size: $SIZE)"
    
    # Check for recent errors
    ERROR_COUNT=$(tail -100 mcp-search.log 2>/dev/null | grep -i error | wc -l)
    if [ $ERROR_COUNT -gt 0 ]; then
        echo -e "${YELLOW}\u26a0${NC} Found $ERROR_COUNT error(s) in last 100 lines of mcp-search.log"
    fi
else
    echo "   mcp-search.log not found in current directory"
fi
echo ""

# Check disk space
echo "6. Checking disk space..."
DISK_USAGE=$(df -h /Users/luis/mcpServers 2>/dev/null | tail -1 | awk '{print $5}' | sed 's/%//')
if [ -n "$DISK_USAGE" ]; then
    if [ "$DISK_USAGE" -lt 80 ]; then
        echo -e "${GREEN}\u2713${NC} Disk usage: ${DISK_USAGE}%"
    elif [ "$DISK_USAGE" -lt 90 ]; then
        echo -e "${YELLOW}\u26a0${NC} Disk usage: ${DISK_USAGE}% (getting full)"
    else
        echo -e "${RED}\u2717${NC} Disk usage: ${DISK_USAGE}% (critically full)"
    fi
fi
echo ""

# Summary and recommendations
echo "========================================="
echo "Summary and Recommendations:"
echo "========================================="

ISSUES=0

if ! command_exists node || ! command_exists npm; then
    echo "• Install Node.js and npm"
    ((ISSUES++))
fi

if ! pgrep -f "supergateway" > /dev/null; then
    echo "• Start the servers using:"
    echo "  ./start-http.sh --port 3333 &> mcp-gateway.log &"
    echo "  ./start-search.sh &> mcp-search.log &"
    ((ISSUES++))
fi

if [ ! -d "/Users/luis/mcpServers/mcp-reference-servers/node_modules" ]; then
    echo "• Install dependencies: cd /Users/luis/mcpServers/mcp-reference-servers && npm ci && npm run build"
    ((ISSUES++))
fi

if [ $ISSUES -eq 0 ]; then
    echo -e "${GREEN}\u2713${NC} All systems operational!"
else
    echo ""
    echo "Found $ISSUES issue(s) that need attention."
fi

echo ""
echo "For more detailed troubleshooting, check TROUBLESHOOTING.md"
