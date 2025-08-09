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
    echo -e "${GREEN}✓${NC} Node.js installed: $NODE_VERSION"
else
    echo -e "${RED}✗${NC} Node.js not found in PATH"
fi

if command_exists npm; then
    NPM_VERSION=$(npm --version)
    echo -e "${GREEN}✓${NC} npm installed: $NPM_VERSION"
else
    echo -e "${RED}✗${NC} npm not found in PATH"
fi
echo ""

# Check if servers are running
echo "2. Checking server processes..."
if pgrep -f "mcp-http-server" > /dev/null; then
    PID=$(pgrep -f "mcp-http-server")
    echo -e "${GREEN}✓${NC} HTTP server is running (PID: $PID)"
else
    echo -e "${YELLOW}⚠${NC} HTTP server is not running"
fi

if pgrep -f "mcp-stdio-proxy" > /dev/null; then
    PID=$(pgrep -f "mcp-stdio-proxy")
    echo -e "${GREEN}✓${NC} STDIO proxy is running (PID: $PID)"
else
    echo -e "${YELLOW}⚠${NC} STDIO proxy is not running"
fi
echo ""

# Check ports
echo "3. Checking ports..."
if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Port 3000 is listening"
    echo "   Process using port 3000:"
    lsof -i :3000 | grep LISTEN | head -1 | awk '{print "   ", $1, $2}'
else
    echo -e "${YELLOW}⚠${NC} Port 3000 is not listening (server may not be running)"
fi

if lsof -Pi :5173 -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Port 5173 is listening"
    echo "   Process using port 5173:"
    lsof -i :5173 | grep LISTEN | head -1 | awk '{print "   ", $1, $2}'
else
    echo -e "${YELLOW}⚠${NC} Port 5173 is not listening (server may not be running)"
fi
echo ""

# Check if project directory exists
echo "4. Checking project directories..."
if [ -d "/Users/luis/mcpServers/mcp-ref" ]; then
    echo -e "${GREEN}✓${NC} mcp-ref directory exists"
    
    # Check if node_modules exists
    if [ -d "/Users/luis/mcpServers/mcp-ref/node_modules" ]; then
        echo -e "${GREEN}✓${NC} node_modules installed"
    else
        echo -e "${YELLOW}⚠${NC} node_modules not found - run 'npm ci' in mcp-ref directory"
    fi
    
    # Check if built
    if [ -d "/Users/luis/mcpServers/mcp-ref/dist" ] || [ -d "/Users/luis/mcpServers/mcp-ref/build" ]; then
        echo -e "${GREEN}✓${NC} Project appears to be built"
    else
        echo -e "${YELLOW}⚠${NC} Build directory not found - run 'npm run build' in mcp-ref directory"
    fi
else
    echo -e "${RED}✗${NC} mcp-ref directory not found at /Users/luis/mcpServers/mcp-ref"
fi
echo ""

# Check log files
echo "5. Checking log files..."
if [ -f "dev.log" ]; then
    SIZE=$(du -h dev.log | cut -f1)
    echo -e "${GREEN}✓${NC} dev.log exists (size: $SIZE)"
    
    # Check for recent errors
    ERROR_COUNT=$(tail -100 dev.log 2>/dev/null | grep -i error | wc -l)
    if [ $ERROR_COUNT -gt 0 ]; then
        echo -e "${YELLOW}⚠${NC} Found $ERROR_COUNT error(s) in last 100 lines of dev.log"
    fi
else
    echo "   dev.log not found in current directory"
fi

if [ -f "stdio.log" ]; then
    SIZE=$(du -h stdio.log | cut -f1)
    echo -e "${GREEN}✓${NC} stdio.log exists (size: $SIZE)"
    
    # Check for recent errors
    ERROR_COUNT=$(tail -100 stdio.log 2>/dev/null | grep -i error | wc -l)
    if [ $ERROR_COUNT -gt 0 ]; then
        echo -e "${YELLOW}⚠${NC} Found $ERROR_COUNT error(s) in last 100 lines of stdio.log"
    fi
else
    echo "   stdio.log not found in current directory"
fi
echo ""

# Check disk space
echo "6. Checking disk space..."
DISK_USAGE=$(df -h /Users/luis/mcpServers 2>/dev/null | tail -1 | awk '{print $5}' | sed 's/%//')
if [ -n "$DISK_USAGE" ]; then
    if [ "$DISK_USAGE" -lt 80 ]; then
        echo -e "${GREEN}✓${NC} Disk usage: ${DISK_USAGE}%"
    elif [ "$DISK_USAGE" -lt 90 ]; then
        echo -e "${YELLOW}⚠${NC} Disk usage: ${DISK_USAGE}% (getting full)"
    else
        echo -e "${RED}✗${NC} Disk usage: ${DISK_USAGE}% (critically full)"
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

if ! pgrep -f "mcp-http-server" > /dev/null && ! pgrep -f "mcp-stdio-proxy" > /dev/null; then
    echo "• Start the servers using:"
    echo "  ./start-http.sh &> dev.log &"
    echo "  ./start-stdio.sh &> stdio.log &"
    ((ISSUES++))
fi

if [ ! -d "/Users/luis/mcpServers/mcp-ref/node_modules" ]; then
    echo "• Install dependencies: cd /Users/luis/mcpServers/mcp-ref && npm ci"
    ((ISSUES++))
fi

if [ $ISSUES -eq 0 ]; then
    echo -e "${GREEN}✓${NC} All systems operational!"
else
    echo ""
    echo "Found $ISSUES issue(s) that need attention."
fi

echo ""
echo "For more detailed troubleshooting, check TROUBLESHOOTING.md"
