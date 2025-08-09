# MCP Server Quick Reference Card

## 🚀 Starting Servers

```bash
# Start main HTTP server (default port 3333)
./start-mcp-dev-tools.sh

# Start HTTP gateway only (wraps stdio filesystem MCP)
./start-http.sh --port 3333 &> mcp-gateway.log &

# Start search server (ripgrep) on 3334
./start-search.sh &> mcp-search.log &
```

Custom ports:
```bash
PORT=3334 ./start-mcp-dev-tools.sh
SEARCH_PORT=4444 ./start-search.sh
```

## 🛑 Stopping Servers

```bash
# Stop all HTTP gateways (supergateway)
pkill -f supergateway

# Stop by port
lsof -ti:3333 | xargs kill  # Kill process on port 3333
lsof -ti:3334 | xargs kill  # Kill process on port 3334

# If running in foreground, press Ctrl+C
```

## 🔍 Checking Status

```bash
# Health/diagnostics
./health-check.sh

# Check running processes
ps aux | grep supergateway

# Check specific ports
lsof -i :3333
lsof -i :3334

# SSE endpoint (continuous stream indicates alive)

```

## 📝 Viewing Logs

```bash
# Real-time log monitoring
tail -f mcp-gateway.log         # Main HTTP gateway
tail -f mcp-search.log          # Search server

# View last N lines
tail -n 100 mcp-gateway.log

# Search for errors
grep -i error mcp-gateway.log
grep -i "failed" mcp-gateway.log

# Count errors
grep -ci error mcp-gateway.log
```

## 🔧 Fixing Common Issues

### Port Already in Use
```bash
# Find what's using a port
lsof -i :3333

# Change port when starting
PORT=3334 ./start-mcp-dev-tools.sh
```

### Command Not Found
```bash
# Check Node/npm installation
node --version
npm --version

# Check PATH
echo $PATH
which node

# Ensure MCP reference servers exist (filesystem MCP)
ls -la /Users/luis/mcpServers/mcp-reference-servers/src/filesystem/dist/index.js
```

### Missing Dependencies (reference servers)
```bash
cd /Users/luis/mcpServers/mcp-reference-servers
npm ci
npm run build
```

## 🔄 Updating Reference Servers

```bash
cd /Users/luis/mcpServers/mcp-reference-servers && git pull && npm ci && npm run build
```

## 🧹 Maintenance

```bash
# Clear npm cache
npm cache clean --force

# Check disk space
df -h /Users/luis/mcpServers

# Archive old logs
mkdir -p logs/archive
mv mcp-gateway.log logs/archive/mcp-gateway-$(date +%Y%m%d).log
```

## 🎯 One-Liners

```bash
# Restart main HTTP server on 3333
pkill -f 'supergateway.*3333' && ./start-http.sh --port 3333 &> mcp-gateway.log &

# Check everything
./health-check.sh
```

## 📁 Important Paths

- MCP Servers Root: `/Users/luis/mcpServers`
- MCP Reference: `/Users/luis/mcpServers/mcp-reference-servers`
- Default Repo: `<your-repo-path>` (configure in .env)
- Logs: `mcp-gateway.log`, `mcp-search.log`
- Start scripts: `./start-mcp-dev-tools.sh`, `./start-http.sh`, `./start-search.sh`

## ⚡ Emergency Commands

```bash
# Kill all supergateway processes immediately
pkill -9 -f supergateway

# Force stop everything on common ports
lsof -ti:3333,3334 | xargs kill -9
```

---
For detailed troubleshooting, see `TROUBLESHOOTING.md`.
Run `./health-check.sh` for diagnostics.
- **MCP Servers Root:** `/Users/luis/mcpServers`
