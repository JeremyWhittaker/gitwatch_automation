# Gitwatch Automation System

Automated setup and management tools for gitwatch - continuous version control for any project.

## 🚀 Quick Install

```bash
# Clone this repository
git clone https://github.com/YOUR_USERNAME/gitwatch-automation.git
cd gitwatch-automation

# Run the installer
./install.sh
```

## 📦 What's Included

- **setup-gitwatch**: One-command setup for any project
- **gitwatch-manage**: Service management utility
- **Automated SSH agent setup**: Handles authentication
- **Smart .gitignore templates**: Pre-configured exclusions

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

- Linux with systemd
- Git
- SSH key for GitHub

## 📄 License

MIT License - Feel free to use and modify!