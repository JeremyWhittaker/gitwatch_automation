# Gitwatch Automation - Compatibility Guide

## Supported Platforms

### ✅ Fully Supported
- **Ubuntu/Debian** (16.04+) with systemd
- **RHEL/CentOS/Fedora** (7+) with systemd
- **Arch Linux** with systemd
- **WSL2** with systemd enabled

### ⚠️ Experimental Support
- **macOS** (10.15+) with launchd
- **openSUSE** with systemd
- **Alpine Linux** (background mode only)
- **WSL1** (background mode only)

### ❌ Not Supported
- Windows (native) - Use WSL2 instead
- FreeBSD
- Older Linux without systemd (pre-2015)

## Installation Modes

### 1. Standard Installation (Default)
```bash
./install.sh
```
- Requires sudo for system packages
- Uses systemd on Linux
- Installs gitwatch to `/usr/local/bin`

### 2. User Mode Installation
```bash
./install.sh --user
```
- No sudo required
- Everything installed to user directories
- Gitwatch installed to `~/.local/bin`
- Perfect for shared servers or restricted environments

### 3. Portable Mode
```bash
./install.sh --portable
```
- Everything contained in the project directory
- No system modifications
- Ideal for testing or temporary use
- Add `./bin` to your PATH manually

### 4. Docker Mode
```bash
./install.sh --docker
```
- Creates Docker configuration
- Fully isolated environment
- Works on any system with Docker
- Best for CI/CD pipelines

### 5. macOS Mode
```bash
./install.sh --macos
```
- Uses launchd instead of systemd
- Installs fswatch for file monitoring
- Requires Homebrew for dependencies

### 6. Background Mode
```bash
./install.sh --background
```
- For systems without systemd/launchd
- Uses simple background processes
- Manual service management
- Works on minimal Linux systems

## Prerequisites by Platform

### Linux (systemd)
- Git
- systemd (v220+)
- **inotify-tools** (REQUIRED - must be installed with sudo)
- SSH client
- bash (v4.0+)

**IMPORTANT**: On Linux/WSL, you MUST install inotify-tools before running the installer:
```bash
# Ubuntu/Debian
sudo apt-get update && sudo apt-get install -y inotify-tools

# RHEL/CentOS/Fedora  
sudo yum install -y inotify-tools

# Arch
sudo pacman -S inotify-tools
```

### Linux (non-systemd)
- Git
- SSH client
- bash (v4.0+)
- Screen or tmux (recommended)

### macOS
- Git
- Homebrew (recommended)
- fswatch (via brew)
- SSH client
- bash or zsh

### Docker
- Docker (v19.03+)
- Docker Compose (v1.25+)

## Checking Compatibility

Run the compatibility check script:
```bash
./scripts/check-compatibility.sh
```

This will:
- Detect your OS and distribution
- Check for required tools
- Suggest the best installation mode
- Report any missing dependencies

## Package Manager Support

The installer automatically detects and uses:
- **apt-get** (Debian/Ubuntu)
- **yum** (RHEL/CentOS)
- **dnf** (Fedora)
- **pacman** (Arch)
- **zypper** (openSUSE)
- **brew** (macOS)

## File Watching Methods

### Linux
- **Primary**: inotify (efficient kernel-level monitoring)
- **Fallback**: Polling mode (higher CPU usage)

### macOS
- **Primary**: fswatch (FSEvents API)
- **Fallback**: Polling mode

### Docker
- Uses inotify inside containers
- May need increased watchers limit

## Service Management

### SystemD (Linux)
```bash
systemctl --user status gitwatch-projectname
systemctl --user start/stop/restart gitwatch-projectname
journalctl --user -u gitwatch-projectname -f
```

### Launchd (macOS)
```bash
launchctl list | grep gitwatch-projectname
launchctl load ~/Library/LaunchAgents/gitwatch-projectname.plist
launchctl unload ~/Library/LaunchAgents/gitwatch-projectname.plist
```

### Background Mode
```bash
~/.config/gitwatch-automation/services/gitwatch-projectname-control.sh status
~/.config/gitwatch-automation/services/gitwatch-projectname-control.sh start
~/.config/gitwatch-automation/services/gitwatch-projectname-control.sh stop
```

## Troubleshooting

### Common Issues

1. **"Command not found: gitwatch"**
   - Run the installer first
   - Check PATH includes installation directory
   - Try `source ~/.bashrc` or restart terminal

2. **"inotify-tools not installed"**
   - Install manually: `sudo apt-get install inotify-tools`
   - Or use `--user` mode (gitwatch will use polling)

3. **"systemctl: command not found"**
   - Your system doesn't have systemd
   - Use `--background` installation mode

4. **SSH Key Issues**
   - Generate key: `ssh-keygen -t ed25519`
   - Add to GitHub: `cat ~/.ssh/id_ed25519.pub`
   - Test: `ssh -T git@github.com`

5. **Service Won't Start**
   - Check logs (see Service Management above)
   - Verify project path exists
   - Ensure git repository is initialized

### Platform-Specific Issues

#### WSL
- WSL1: Use `--background` mode
- WSL2: Enable systemd first (see WSL documentation)

#### macOS
- Grant Terminal/iTerm Full Disk Access in Security settings
- Install Xcode Command Line Tools if git is missing
- Use Homebrew to install missing tools

#### Docker
- Ensure SSH keys are mounted correctly
- Increase inotify watchers if needed:
  ```bash
  echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf
  sudo sysctl -p
  ```

## Advanced Configuration

### Custom Installation Paths
Edit `~/.config/gitwatch-automation/install.conf` after installation:
```bash
INSTALL_MODE=user
GITWATCH_PATH=/custom/path/to/gitwatch
USE_SUDO=false
```

### Multiple Git Remotes
Edit the service file to push to multiple remotes:
```bash
ExecStart=/path/to/gitwatch -r origin -r backup -b main /project/path
```

### Custom Commit Messages
Modify gitwatch parameters in service file:
```bash
ExecStart=/path/to/gitwatch -m "Auto-commit: %d" -r origin /project/path
```

## Getting Help

1. Run compatibility check: `./scripts/check-compatibility.sh`
2. Check service logs for errors
3. Review this compatibility guide
4. Open an issue on GitHub with:
   - Your OS and version
   - Installation mode used
   - Error messages
   - Output of compatibility check