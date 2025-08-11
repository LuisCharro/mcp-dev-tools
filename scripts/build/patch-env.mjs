#!/usr/bin/env node

/**
 * Cross-platform environment file patcher
 * 
 * Replaces the macOS-specific `sed -i ''` command with a portable Node.js solution
 * that works on both macOS and Linux.
 * 
 * Usage:
 *   node patch-env.mjs <env-file> <key> <value>
 * 
 * Example:
 *   node patch-env.mjs .env.local REPO_ROOT /path/to/repo
 */

import { readFileSync, writeFileSync, existsSync } from 'fs';
import { dirname, resolve } from 'path';

function patchEnvFile(filePath, key, value) {
    // Resolve to absolute path
    const envPath = resolve(filePath);
    
    // Check if file exists
    if (!existsSync(envPath)) {
        console.error(`Error: Environment file '${envPath}' does not exist`);
        process.exit(1);
    }
    
    try {
        // Read the current content
        const content = readFileSync(envPath, 'utf8');
        
        // Escape special regex characters in the key
        const escapedKey = key.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
        
        // Pattern to match the key=value line (with optional comments)
        const pattern = new RegExp(`^(\\s*)(${escapedKey}\\s*=)(.*)$`, 'm');
        
        let newContent;
        if (pattern.test(content)) {
            // Key exists, replace the value
            newContent = content.replace(pattern, `$1$2${value}`);
            console.log(`Updated ${key} in ${filePath}`);
        } else {
            // Key doesn't exist, append it
            newContent = content.trim() + `\n${key}=${value}\n`;
            console.log(`Added ${key} to ${filePath}`);
        }
        
        // Write the updated content back
        writeFileSync(envPath, newContent, 'utf8');
        
        console.log(`Successfully updated ${filePath}: ${key}=${value}`);
        
    } catch (error) {
        console.error(`Error processing ${filePath}:`, error.message);
        process.exit(1);
    }
}

function main() {
    const args = process.argv.slice(2);
    
    if (args.length !== 3) {
        console.error('Usage: node patch-env.mjs <env-file> <key> <value>');
        console.error('');
        console.error('Examples:');
        console.error('  node patch-env.mjs .env.local REPO_ROOT /path/to/repo');
        console.error('  node patch-env.mjs .env PORT 3333');
        process.exit(1);
    }
    
    const [envFile, key, value] = args;
    
    // Validate inputs
    if (!key) {
        console.error('Error: Key cannot be empty');
        process.exit(1);
    }
    
    if (!key.match(/^[A-Z_][A-Z0-9_]*$/)) {
        console.error(`Error: Key '${key}' should contain only uppercase letters, digits, and underscores`);
        process.exit(1);
    }
    
    patchEnvFile(envFile, key, value);
}

// Only run if this script is executed directly
if (import.meta.url === `file://${process.argv[1]}`) {
    main();
}

export { patchEnvFile };
