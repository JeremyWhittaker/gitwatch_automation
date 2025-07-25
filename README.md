# Gitwatch Automation System

Automated setup and management tools for gitwatch - continuous version control for any project.

## 🚀 Quick Install

### Prerequisites (Linux/WSL)
If you're on Linux/WSL, you need to install inotify-tools first:
```bash
# Ubuntu/Debian
sudo apt-get update && sudo apt-get install -y inotify-tools

# RHEL/CentOS/Fedora
sudo yum install -y inotify-tools

# Arch
sudo pacman -S inotify-tools
```

### Installation
```bash
# Clone this repository
git clone git@github.com:JeremyWhittaker/gitwatch_automation.git
cd gitwatch_automation

# Check system compatibility
./scripts/check-compatibility.sh

# Run the installer
./install.sh
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

### Set up gitwatch on a project:
```bash
setup-gitwatch /path/to/project
# or from within a project:
cd /path/to/project
setup-gitwatch
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