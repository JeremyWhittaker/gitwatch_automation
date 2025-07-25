# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Gitwatch Automation System - a collection of tools for automated setup and management of gitwatch services for continuous version control. The system provides automated SSH agent setup, smart .gitignore templates, and systemd service management for monitoring Git repositories.

## Key Commands

### Development Commands
```bash
# Install the system (from repo root)
./install.sh

# Update to latest version
./update.sh

# Run shellcheck on scripts
shellcheck scripts/setup-gitwatch scripts/gitwatch-manage install.sh update.sh
```

### Usage Commands (after installation)
```bash
# Set up gitwatch for a project
setup-gitwatch /path/to/project

# Manage gitwatch services
gitwatch-manage list              # List all services
gitwatch-manage status [name]     # Check status
gitwatch-manage logs [name]       # View logs
gitwatch-manage stop [name]       # Stop monitoring
gitwatch-manage remove [name]     # Remove completely

# Uninstall the system
gitwatch-uninstall
```

## Architecture

### Core Components

1. **install.sh** - Main installer that:
   - Creates ~/.local/bin and ~/.config/gitwatch-automation directories
   - Installs scripts and templates
   - Installs gitwatch and inotify-tools if missing
   - Creates uninstall script
   - Updates PATH if needed

2. **scripts/setup-gitwatch** - Project setup script that:
   - Validates project directory and initializes git if needed
   - Creates SSH agent systemd services (ssh-agent.service, ssh-add.service)
   - Configures .gitignore using templates
   - Converts GitHub URLs to SSH format
   - Creates systemd service for continuous monitoring
   - Tests SSH connection to GitHub

3. **scripts/gitwatch-manage** - Service management utility that:
   - Lists all gitwatch services with status
   - Provides control commands (start/stop/restart/enable/disable/remove)
   - Shows logs for debugging
   - Handles service name normalization (adds "gitwatch-" prefix)

4. **templates/gitignore_template** - Comprehensive .gitignore template covering:
   - Database files, logs, data files
   - ML models and checkpoints
   - Cache, virtual environments
   - IDE and OS files
   - Secrets and credentials

### Service Architecture

The system creates systemd user services following this pattern:
- **ssh-agent.service**: Runs SSH agent with socket at %t/ssh-agent.socket
- **ssh-add.service**: Adds SSH keys to agent on startup
- **gitwatch-{project}.service**: Per-project monitoring service that:
  - Depends on ssh-agent.service
  - Uses SSH_AUTH_SOCK environment variable
  - Runs gitwatch with auto-commit and auto-push to origin/main
  - Restarts on failure with 30s delay

### File Locations

- Scripts: `~/.local/bin/`
- Configuration: `~/.config/gitwatch-automation/`
- Services: `~/.config/systemd/user/`
- Each project gets: `gitwatch-{projectname}.service`

## Important Implementation Details

1. **SSH Authentication**: 
   - Checks for existing SSH keys (ed25519, rsa, ecdsa)
   - Offers to create SSH key interactively if missing
   - Creates persistent SSH agent services for background authentication
   - Shows public key for user to add to GitHub

2. **Git Remote Handling**:
   - Auto-detects existing git remotes
   - Prompts for GitHub URL if no remote exists
   - Automatically converts HTTPS URLs to SSH format
   - Allows skipping (local commits only)

3. **Dependency Management**:
   - Checks for inotify-tools (Linux) or fswatch (macOS)
   - Clear warnings if dependencies missing
   - Falls back to polling mode if file watchers unavailable

4. **Service Naming**: Project names are normalized (lowercase, spaces to hyphens) for service names.

5. **Error Handling**: 
   - Scripts use `set -e` for fail-fast behavior
   - Services restart on failure with 30s delay
   - Push failures don't stop local commits

6. **Duplicate Prevention**: The setup script checks for existing SSH services and gitignore sections to avoid duplicates.

## Cross-Platform Support

The system now supports multiple platforms and installation modes:

1. **Platform Detection**: Automatically detects OS (Linux/macOS/WSL) and init system
2. **Installation Modes**: 
   - Standard (with sudo)
   - User mode (no sudo required)
   - Portable (self-contained)
   - Docker (fully isolated)
   - Background (for systems without service managers)

3. **Service Backends**:
   - SystemD (Linux with systemd)
   - Launchd (macOS)
   - Background processes (fallback)

4. **Package Managers**: Supports apt, yum, dnf, pacman, zypper, and brew

## Security Considerations

- Never modify gitwatch to capture or log sensitive information
- SSH keys are loaded into agent memory, not stored in service files
- The system respects existing .gitignore patterns and adds security-focused exclusions
- User mode installation avoids sudo requirements for better security

## Testing and Validation

The system has been tested on:
- Ubuntu 25.04 with systemd (verified working)
- User mode installation without sudo
- Projects with and without existing git remotes
- Missing SSH key scenarios (now handled interactively)
- Missing inotify-tools (clear error messages)

Successfully tested features:
- Auto-commit on file changes (within seconds)
- Auto-push to GitHub
- Service management commands
- Compatibility checking
- Multiple installation modes