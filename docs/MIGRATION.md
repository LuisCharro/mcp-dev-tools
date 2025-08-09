# Migration Guide

## Version History and Breaking Changes

### Current Version → v2.0.0 (Reorganization Update)

#### What Changed
- **📁 Complete folder restructure** - Scripts moved from root to organized subfolders
- **🔧 Updated all paths** - All script references updated for new structure
- **📚 Documentation reorganization** - All docs moved to `docs/` folder
- **🆕 New convenience launcher** - Added root-level launcher for backward compatibility

#### Migration Steps

**If you have existing .env.local or scripts:**

1. **Update any custom scripts** that reference old paths:
   ```diff
   - ./start-mcp-dev-tools.sh
   + ./scripts/server/start-mcp-dev-tools.sh
   # OR use the new convenience launcher:
   + ./start-mcp-dev-tools.sh
   ```

2. **Update documentation references**:
   ```diff
   - ./TROUBLESHOOTING.md
   + ./docs/TROUBLESHOOTING.md
   ```

3. **Your .env.local file works unchanged** - no action needed

#### New Structure Benefits
```
OLD (cluttered root):           NEW (organized):
├── start-mcp-dev-tools.sh     ├── scripts/server/start-mcp-dev-tools.sh
├── health-check.sh            ├── scripts/health/health-check.sh
├── TROUBLESHOOTING.md         ├── docs/TROUBLESHOOTING.md
├── (14 other files...)        ├── start-mcp-dev-tools.sh (convenience)
                               └── (clean root)
```

#### Compatibility
- ✅ **Configuration files unchanged** - Your `.env.local` still works
- ✅ **Server URLs unchanged** - Still `http://127.0.0.1:3333/`
- ✅ **MCP tools unchanged** - Same file operations and search
- ✅ **Convenience launcher added** - `./start-mcp-dev-tools.sh` still works
- ⚠️ **Script paths changed** - Use new paths or convenience launcher

---

## General Migration Guidelines

### Before Upgrading
1. **Stop all servers**:
   ```bash
   pkill -f supergateway
   ```

2. **Backup your configuration**:
   ```bash
   cp .env.local .env.local.backup
   ```

3. **Check current health**:
   ```bash
   ./scripts/health/health-check.sh
   ```

### After Upgrading
1. **Pull latest changes**:
   ```bash
   git pull origin main
   ```

2. **Update dependencies if needed**:
   ```bash
   npm ci
   ```

3. **Test health**:
   ```bash
   ./scripts/health/health-check.sh
   ./scripts/health/smoke-test.sh
   ```

4. **Restart servers**:
   ```bash
   ./start-mcp-dev-tools.sh
   ```

### Configuration Migration

#### Environment Variables
Configuration has remained stable across versions:

```bash
# .env.local - works across all versions
REPO_ROOT=/path/to/your/repository
PORT=3333
SEARCH_PORT=3334
MCP_REF_DIR=/custom/path/to/mcp-reference-servers
```

#### Client Configuration
AI assistant configuration unchanged:
- **Name**: MCP Dev Tools
- **URL**: `http://127.0.0.1:3333/`

### Getting Migration Help

For additional help:
- [Troubleshooting Guide](TROUBLESHOOTING.md)
- [Quick Reference](QUICK_REFERENCE.md)
- [Architecture Overview](STRUCTURE.md)
