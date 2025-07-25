# Gitwatch Automation - Implementation Guide

## 🎯 Best Practices for Saving & Using This System

### Option 1: GitHub Repository (Recommended)
```bash
# 1. Create a new repository on GitHub called 'gitwatch-automation'

# 2. Push this code (Already done!)
cd ~/projects/gitwatch-automation
git remote add origin git@github.com:JeremyWhittaker/gitwatch_automation.git
git push -u origin main

# 3. Install on any machine
git clone git@github.com:JeremyWhittaker/gitwatch_automation.git
cd gitwatch_automation
./install.sh

# 4. Update to latest version
cd gitwatch-automation
./update.sh
```

### Option 2: Private Git Server
If you have a private Git server, same process but with your server URL.

### Option 3: Portable Archive
```bash
# Create a portable archive
cd ~/projects
tar -czf gitwatch-automation.tar.gz gitwatch-automation/

# Copy to new machine and extract
tar -xzf gitwatch-automation.tar.gz
cd gitwatch-automation
./install.sh
```

## 📦 What Gets Installed Where

| Component | Location | Purpose |
|-----------|----------|---------|
| setup-gitwatch | ~/.local/bin/ | Main setup script |
| gitwatch-manage | ~/.local/bin/ | Service management |
| Templates | ~/.config/gitwatch-automation/ | Configuration templates |
| Services | ~/.config/systemd/user/ | Per-project services |

## 🔄 Keeping It Updated

### If using GitHub:
```bash
cd ~/gitwatch-automation
git pull
./update.sh
```

### Manual update:
```bash
# Just re-run the installer
cd gitwatch-automation
./install.sh
```

## 🚀 Usage Examples

### Example 1: New Python Project
```bash
mkdir ~/my-python-app
cd ~/my-python-app
git init
setup-gitwatch
# Answer: git@github.com:username/my-python-app.git
```

### Example 2: Existing Project
```bash
cd ~/existing-project
setup-gitwatch
# Automatically detects git remote
```

### Example 3: Multiple Projects
```bash
setup-gitwatch ~/project1
setup-gitwatch ~/project2
setup-gitwatch ~/project3

# View all
gitwatch-manage list
```

## 🛠️ Customization

### Custom .gitignore Template
Edit `~/.config/gitwatch-automation/gitignore_template` to add your own exclusions.

### Different Branch Names
Edit the service file after creation:
```bash
systemctl --user edit gitwatch-projectname.service
# Change 'main' to your branch name
```

## 🔍 Troubleshooting

### SSH Key Issues
```bash
# Check SSH agent
systemctl --user status ssh-agent
systemctl --user status ssh-add

# Test GitHub connection
ssh -T git@github.com
```

### Service Issues
```bash
# Check specific service
gitwatch-manage status projectname

# View detailed logs
gitwatch-manage logs projectname

# Restart service
gitwatch-manage restart projectname
```

## 🎁 Sharing With Others

### Quick Share Command
```bash
echo "Install gitwatch automation:"
echo "git clone git@github.com:JeremyWhittaker/gitwatch_automation.git && cd gitwatch_automation && ./install.sh"
```

### For Teams
1. Fork the repository
2. Customize templates for your team
3. Share your fork URL

## 💡 Pro Tips

1. **Backup Services List**: 
   ```bash
   gitwatch-manage list > my-gitwatch-services.txt
   ```

2. **Bulk Operations**:
   ```bash
   # Stop all gitwatch services
   systemctl --user stop 'gitwatch-*'
   
   # Start all gitwatch services  
   systemctl --user start 'gitwatch-*'
   ```

3. **Check Resource Usage**:
   ```bash
   systemctl --user status 'gitwatch-*' | grep -E "Memory|CPU"
   ```

## 📝 Version History

- v1.0 - Initial release with basic functionality
- Future: Support for custom commit messages, multiple remotes, etc.

---

Remember: This system is designed to be shared and improved. Feel free to customize for your needs!