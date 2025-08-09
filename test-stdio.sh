#!/usr/bin/env bash

echo "Testing MCP server in stdio mode for Claude Desktop..."
echo "======================================================="
echo ""

# Test if the script is executable
if [ -x "/Users/luis/mcpServers/chatgpt-coder-mcp/run-filesystem.sh" ]; then
    echo "✅ run-filesystem.sh is executable"
else
    echo "❌ run-filesystem.sh is NOT executable"
    exit 1
fi

# Check if MCP reference server exists
if [ -d "/Users/luis/mcpServers/mcp-reference-servers" ]; then
    echo "✅ MCP reference servers directory exists"
else
    echo "❌ MCP reference servers directory NOT found"
    exit 1
fi

# Check if the filesystem index.js exists
if [ -f "/Users/luis/mcpServers/mcp-reference-servers/src/filesystem/dist/index.js" ]; then
    echo "✅ Filesystem MCP server binary exists"
else
    echo "❌ Filesystem MCP server binary NOT found"
    exit 1
fi

# Test environment variable
export REPO_ROOT="/Users/luis/Repos/PDFExtractorAI"
echo "✅ REPO_ROOT set to: $REPO_ROOT"

# Test the script with a simple MCP initialize message
echo ""
echo "Testing MCP initialization..."
echo '{"jsonrpc":"2.0","method":"initialize","params":{"protocolVersion":"2025-06-18","capabilities":{},"clientInfo":{"name":"test","version":"1.0.0"}},"id":1}' | /Users/luis/mcpServers/chatgpt-coder-mcp/run-filesystem.sh 2>/dev/null | head -1 | jq -r '.result' > /dev/null 2>&1

if [ $? -eq 0 ]; then
    echo "✅ MCP server responds correctly to stdio input"
    echo ""
    echo "🎉 Everything looks good! Your MCP server should work with Claude Desktop."
    echo ""
    echo "Next steps:"
    echo "1. Quit Claude Desktop completely (Cmd+Q)"
    echo "2. Start Claude Desktop again"
    echo "3. The 'chatgpt-coder-mcp' server should appear in the MCP servers list"
    echo "4. You can change the repository by editing REPO_ROOT in claude_desktop_config.json"
else
    echo "❌ MCP server did not respond correctly"
    echo "   There might be an issue with the Node.js setup or MCP server"
fi
