# Gitwatch Automation System

Automated setup and management tools for gitwatch - continuous version control for any project.

## 🚀 Quick Install

### Installation
```bash
# Clone this repository
git clone git@github.com:JeremyWhittaker/gitwatch_automation.git
cd gitwatch_automation

# Check system compatibility first
./scripts/check-compatibility.sh

# Option 1: Install with sudo (recommended - auto-installs dependencies)
sudo ./install.sh

# Option 2: Install without sudo (you must install dependencies first)
# First install required dependencies:
# Ubuntu/Debian: sudo apt-get install -y inotify-tools
# RHEL/CentOS: sudo yum install -y inotify-tools
# Then run:
./install.sh --user
```

## 📦 What's Included

- **setup-gitwatch**: Cross-platform setup for any project
- **gitwatch-manage**: Service management utility
- **check-compatibility**: System compatibility checker
- **Multiple installation modes**: User, portable, Docker, and more
- **Automated SSH agent setup**: Handles authentication
- **Smart .gitignore templates**: Pre-configured exclusions

## 🎯 Installation Options

```bash
# Auto-detect best method
./install.sh

# User mode (no sudo)
./install.sh --user

# Portable mode
./install.sh --portable

# Docker mode
./install.sh --docker

# Check system compatibility
./scripts/check-compatibility.sh
```

## 🔧 Usage

### Quick Start:
```bash
# 1. Set up on a new project
mkdir my-project && cd my-project
setup-gitwatch
# Follow prompts to add GitHub repo URL

# 2. Set up on existing project
cd /path/to/existing/project
setup-gitwatch
# Auto-detects git remote if present

# 3. Verify it's working
touch test.txt
git log --oneline -1
# Should see auto-commit within seconds
```

### Manage services:
```bash
gitwatch-manage list              # List all services
gitwatch-manage status [name]     # Check status
gitwatch-manage logs [name]       # View logs
gitwatch-manage stop [name]       # Stop monitoring
gitwatch-manage remove [name]     # Remove completely
```

## 📋 Requirements

- **Operating System**: Linux, macOS, or WSL
- **Git**: Version control system
- **SSH key**: For GitHub authentication
- **Optional**: systemd (Linux), launchd (macOS), or Docker

See [COMPATIBILITY.md](COMPATIBILITY.md) for detailed platform support.

## 📄 License

MIT License - Feel free to use and modify!