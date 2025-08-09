# MCP Server Troubleshooting & Maintenance Guide

## Common Issues and Solutions

### 1. Port Already in Use
**Problem:** Error message indicating port is already in use when starting servers.

**Solution:** Change the port flags in your startup commands:
```bash
# For HTTP server (default port 3000)
./start-http.sh --port 3001

# For stdio-proxy server (default port 5173)
./start-stdio.sh --port 5174

# Or check what's using the port
lsof -i :3000  # Check port 3000
lsof -i :5173  # Check port 5173
```

### 2. "Command not found" Errors
**Problem:** Node.js or npm commands not recognized.

**Solutions:**
1. **Verify Node.js and npm are installed:**
   ```bash
   node --version
   npm --version
   ```

2. **Ensure Node.js and npm are in PATH:**
   ```bash
   echo $PATH
   which node
   which npm
   ```

3. **Reinstall dependencies in mcp-ref:**
   ```bash
   cd /Users/luis/mcpServers/mcp-ref
   npm ci
   ```

### 3. Logging and Debugging

**Redirect logs to a file for easier debugging:**
```bash
# Start server with logs redirected to file
./start-http.sh &> dev.log

# Monitor logs in real-time
tail -f dev.log

# View last 50 lines of logs
tail -n 50 dev.log

# Search for errors in logs
grep -i error dev.log
```

**For stdio-proxy server:**
```bash
./start-stdio.sh &> stdio.log
tail -f stdio.log
```

### 4. Updating Reference Servers

**Keep your MCP reference servers up to date:**
```bash
cd /Users/luis/mcpServers/mcp-ref
git pull
npm ci
npm run build
```

**Full update sequence:**
```bash
# Stop running servers first
pkill -f mcp-stdio-proxy
pkill -f mcp-http-server

# Update and rebuild
cd /Users/luis/mcpServers/mcp-ref
git pull origin main
npm ci
npm run build

# Restart servers
./start-http.sh &> dev.log &
./start-stdio.sh &> stdio.log &
```

### 5. Stopping Servers

**Different methods to stop running servers:**

1. **If running in foreground:** Press `Ctrl+C` in the terminal

2. **Kill by process name:**
   ```bash
   pkill -f mcp-stdio-proxy
   pkill -f mcp-http-server
   ```

3. **Find and kill by port:**
   ```bash
   # Find process using port 3000
   lsof -ti:3000 | xargs kill
   
   # Find process using port 5173
   lsof -ti:5173 | xargs kill
   ```

4. **View all running MCP processes:**
   ```bash
   ps aux | grep -E "mcp-|proxy"
   ```

## Maintenance Best Practices

### Regular Maintenance Tasks

1. **Weekly Updates:**
   ```bash
   cd /Users/luis/mcpServers/mcp-ref
   git pull && npm ci && npm run build
   ```

2. **Clear npm cache (if experiencing issues):**
   ```bash
   npm cache clean --force
   ```

3. **Check disk space:**
   ```bash
   df -h /Users/luis/mcpServers
   ```

4. **Archive old logs:**
   ```bash
   # Create logs directory if it doesn't exist
   mkdir -p /Users/luis/mcpServers/logs/archive
   
   # Move old logs with timestamp
   mv dev.log /Users/luis/mcpServers/logs/archive/dev-$(date +%Y%m%d).log
   ```

### Health Checks

**Quick health check script:**
```bash
#!/bin/bash
echo "Checking MCP server status..."

# Check if servers are running
if pgrep -f "mcp-http-server" > /dev/null; then
    echo "✓ HTTP server is running"
else
    echo "✗ HTTP server is not running"
fi

if pgrep -f "mcp-stdio-proxy" > /dev/null; then
    echo "✓ STDIO proxy is running"
else
    echo "✗ STDIO proxy is not running"
fi

# Check ports
if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null ; then
    echo "✓ Port 3000 is listening"
else
    echo "✗ Port 3000 is not listening"
fi

if lsof -Pi :5173 -sTCP:LISTEN -t >/dev/null ; then
    echo "✓ Port 5173 is listening"
else
    echo "✗ Port 5173 is not listening"
fi
```

### Environment Variables

**Set custom environment variables for servers:**
```bash
# In your .bashrc or .zshrc
export MCP_HTTP_PORT=3000
export MCP_STDIO_PORT=5173
export MCP_LOG_LEVEL=debug
```

### Troubleshooting Checklist

- [ ] Node.js version 18+ installed
- [ ] npm properly configured
- [ ] All dependencies installed (`npm ci`)
- [ ] Ports 3000 and 5173 available
- [ ] Sufficient disk space
- [ ] Proper file permissions in project directory
- [ ] Latest code from repository
- [ ] Build completed successfully

## Quick Reference Commands

```bash
# Start servers
./start-http.sh &> dev.log &
./start-stdio.sh &> stdio.log &

# Monitor logs
tail -f dev.log
tail -f stdio.log

# Stop servers
pkill -f mcp-stdio-proxy
pkill -f mcp-http-server

# Update servers
cd /Users/luis/mcpServers/mcp-ref && git pull && npm ci && npm run build

# Check status
ps aux | grep mcp
lsof -i :3000
lsof -i :5173
```

## Need More Help?

- Check the official MCP documentation
- Review server logs for detailed error messages
- Ensure all prerequisites are installed
- Try running servers with increased verbosity/debug mode
