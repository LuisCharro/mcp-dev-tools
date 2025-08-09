# Migration from chatgpt-coder-mcp to mcp-dev-tools

## Changes Made

### 1. **Name Change**
- **Old name**: `chatgpt-coder-mcp`
- **New name**: `mcp-dev-tools`
- **Reason**: More universal, not tied to a specific AI assistant

### 2. **Files Renamed**
- `start-chatgpt-coder.sh` → `start-mcp-dev-tools.sh`
- Log file: `chatgpt-coder.log` → `mcp-gateway.log`

### 3. **Documentation Updated**
- Updated `README.md` to reflect new name and broader compatibility
- Updated `STRUCTURE.md` with new folder and script names
- Changed references from "ChatGPT Desktop" to "AI assistants"

### 4. **Directory Structure**
- Original location: `$HOME/mcpServers/chatgpt-coder-mcp`
- Renamed to: `$HOME/mcpServers/mcp-dev-tools`
- Copied to: `/path/to/mcp-dev-tools`

### 5. **Compatibility**
The server remains fully compatible with:
- ChatGPT Desktop
- Claude Desktop
- Any MCP-compatible AI assistant

## Testing Performed

✅ Server starts successfully
✅ HTTP endpoint responds at http://127.0.0.1:3333/
✅ Process management works (start/stop)
✅ Logs are created correctly
✅ Repository access functions properly

## Usage

The usage remains the same, just with the new script name:

```bash
# Start with default repository
./start-mcp-dev-tools.sh

# Start with custom repository
REPO_ROOT=/path/to/your/repo ./start-mcp-dev-tools.sh

# Stop the server
pkill -f 'supergateway.*3333'
```

## Configuration for AI Assistants

Add in your AI assistant's MCP settings:
- **Name**: MCP Dev Tools
- **URL**: `http://127.0.0.1:3333/`

## Notes

- All functionality remains identical
- The server is now positioned as a universal development tool
- Works with any MCP-compatible client, not just ChatGPT
