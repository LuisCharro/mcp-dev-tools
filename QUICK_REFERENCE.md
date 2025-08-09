# MCP Server Quick Reference Card

## 🚀 Starting Servers

```bash
# Start HTTP server (default port 3000)
./start-http.sh &> dev.log &

# Start STDIO proxy (default port 5173)
./start-stdio.sh &> stdio.log &

# Start with custom ports
./start-http.sh --port 3001 &> dev.log &
./start-stdio.sh --port 5174 &> stdio.log &
```

## 🛑 Stopping Servers

```bash
# Stop all MCP servers
pkill -f mcp-stdio-proxy
pkill -f mcp-http-server

# Stop by port
lsof -ti:3000 | xargs kill  # Kill process on port 3000
lsof -ti:5173 | xargs kill  # Kill process on port 5173

# Interactive stop (if running in foreground)
# Press Ctrl+C
```

## 🔍 Checking Status

```bash
# Run health check
./health-check.sh

# Check running processes
ps aux | grep mcp

# Check specific ports
lsof -i :3000
lsof -i :5173

# Check if servers are running
pgrep -f mcp-http-server
pgrep -f mcp-stdio-proxy
```

## 📝 Viewing Logs

```bash
# Real-time log monitoring
tail -f dev.log        # HTTP server logs
tail -f stdio.log      # STDIO proxy logs

# View last N lines
tail -n 100 dev.log

# Search for errors
grep -i error dev.log
grep -i "failed" dev.log

# Count errors
grep -c -i error dev.log
```

## 🔧 Fixing Common Issues

### Port Already in Use
```bash
# Find what's using a port
lsof -i :3000

# Change port when starting
./start-http.sh --port 3001
```

### Command Not Found
```bash
# Check Node/npm installation
node --version
npm --version

# Check PATH
echo $PATH
which node

# Reinstall dependencies
cd /Users/luis/mcpServers/mcp-ref
npm ci
```

### Missing Dependencies
```bash
cd /Users/luis/mcpServers/mcp-ref
npm ci
npm run build
```

## 🔄 Updating Servers

```bash
# Quick update
cd /Users/luis/mcpServers/mcp-ref && git pull && npm ci && npm run build

# Full update with restart
pkill -f mcp-stdio-proxy
pkill -f mcp-http-server
cd /Users/luis/mcpServers/mcp-ref
git pull origin main
npm ci
npm run build
./start-http.sh &> dev.log &
./start-stdio.sh &> stdio.log &
```

## 🧹 Maintenance

```bash
# Clear npm cache
npm cache clean --force

# Check disk space
df -h /Users/luis/mcpServers

# Archive old logs
mkdir -p logs/archive
mv dev.log logs/archive/dev-$(date +%Y%m%d).log

# Clean old log files
find logs/archive -name "*.log" -mtime +30 -delete
```

## 🎯 One-Liners

```bash
# Restart HTTP server
pkill -f mcp-http-server && ./start-http.sh &> dev.log &

# Restart STDIO proxy
pkill -f mcp-stdio-proxy && ./start-stdio.sh &> stdio.log &

# Check everything
./health-check.sh

# Full system restart
pkill -f mcp && ./start-http.sh &> dev.log & && ./start-stdio.sh &> stdio.log &
```

## 📁 Important Paths

- **MCP Servers Root:** `/Users/luis/mcpServers`
- **MCP Reference:** `/Users/luis/mcpServers/mcp-ref`
- **PDFExtractorAI:** `/Users/luis/Repos/PDFExtractorAI`
- **Log files:** `dev.log` and `stdio.log` (in current directory)
- **Start scripts:** `./start-http.sh` and `./start-stdio.sh`

## ⚡ Emergency Commands

```bash
# Kill all MCP processes immediately
pkill -9 -f mcp

# Force stop everything on common ports
lsof -ti:3000,5173 | xargs kill -9

# Check system resources
top -o cpu | head -20
ps aux | sort -rk 3,3 | head -10
```

---
*For detailed troubleshooting, see `TROUBLESHOOTING.md`*
*Run `./health-check.sh` for system diagnostics*
