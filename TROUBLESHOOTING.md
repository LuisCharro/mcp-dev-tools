# MCP Server Troubleshooting & Maintenance Guide

## Common Issues and Solutions

### 1. Port Already in Use
**Problem:** Error message indicating port is already in use when starting servers.

**Solution:** Change the port when starting:
```bash
# For HTTP server (default port 3333)
PORT=3334 ./start-mcp-dev-tools.sh

# Or check what's using the port
lsof -i :3333  # Check port 3333
lsof -i :3334  # Check port 3334 (search)
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

3. **Ensure MCP reference servers are installed/built:**
   ```bash
   cd /Users/luis/mcpServers/mcp-reference-servers
   npm ci && npm run build
   ```

### 3. Logging and Debugging

**Redirect logs to a file for easier debugging:**
```bash
# Start server with logs redirected to file
./start-http.sh &> mcp-gateway.log

# Monitor logs in real-time
tail -f mcp-gateway.log

# View last 50 lines of logs
tail -n 50 dev.log

# Search for errors in logs
grep -i error dev.log
```

**For search server:**
```bash
./start-search.sh &> mcp-search.log
tail -f mcp-search.log
```

### 4. Updating Reference Servers

**Keep your MCP reference servers up to date:**
```bash
cd /Users/luis/mcpServers/mcp-reference-servers
git pull
npm ci
npm run build
```

**Full update sequence:**
```bash
# Stop running servers first
pkill -f supergateway

# Update and rebuild
cd /Users/luis/mcpServers/mcp-reference-servers
git pull origin main
npm ci
npm run build

# Restart servers
./start-http.sh --port 3333 &> mcp-gateway.log &
./start-search.sh &> mcp-search.log &
```

### 5. Stopping Servers

**Different methods to stop running servers:**

1. **If running in foreground:** Press `Ctrl+C` in the terminal

2. **Kill by process name:**
   ```bash
   pkill -f supergateway
   ```

3. **Find and kill by port:**
   ```bash
   # Find process using port 3333
   lsof -ti:3333 | xargs kill
   
   # Find process using port 3334 (search)
   lsof -ti:3334 | xargs kill
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
if pgrep -f "supergateway" > /dev/null; then
   echo "✓ HTTP gateway is running"
else
   echo "✗ HTTP gateway is not running"
fi


# Check ports
if lsof -Pi :3333 -sTCP:LISTEN -t >/dev/null ; then
   echo "✓ Port 3333 is listening"
else
   echo "✗ Port 3333 is not listening"
fi

if lsof -Pi :3334 -sTCP:LISTEN -t >/dev/null ; then
   echo "✓ Port 3334 is listening"
else
   echo "✗ Port 3334 is not listening"
fi
```

### Environment Variables

**Set custom environment variables for servers:**
```bash
# In your .zshrc
export PORT=3333
export SEARCH_PORT=3334
export REPO_ROOT=/absolute/path/to/your/repository
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
./start-http.sh --port 3333 &> mcp-gateway.log &
./start-search.sh &> mcp-search.log &

# Monitor logs
tail -f dev.log
tail -f stdio.log

# Stop servers
pkill -f supergateway

# Update reference servers
cd /Users/luis/mcpServers/mcp-reference-servers && git pull && npm ci && npm run build

# Check status
ps aux | grep supergateway
lsof -i :3333
lsof -i :3334
```

## Need More Help?

- Check the official MCP documentation
- Review server logs for detailed error messages
- Ensure all prerequisites are installed
- Try running servers with increased verbosity/debug mode
