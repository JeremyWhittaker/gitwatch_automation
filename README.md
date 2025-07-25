# 🚀 Gitwatch Automation System

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20WSL-blue)](https://github.com/JeremyWhittaker/gitwatch_automation)
[![Shell](https://img.shields.io/badge/shell-bash-green)](https://github.com/JeremyWhittaker/gitwatch_automation)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/JeremyWhittaker/gitwatch_automation/pulls)

> **Never lose code again!** Automated Git commits and pushes for every file change. Perfect for developers who want continuous version control without the hassle.

<p align="center">
  <img src="https://raw.githubusercontent.com/JeremyWhittaker/gitwatch_automation/main/docs/demo.gif" alt="Gitwatch Demo" width="600">
</p>

## ✨ Features

- 🔄 **Automatic commits** on every file save
- 🚀 **Auto-push** to GitHub/GitLab/Bitbucket
- 🌍 **Cross-platform** support (Linux, macOS, WSL)
- 🔧 **Multiple installation modes** (sudo, user, portable, Docker)
- 📊 **Service management** UI for all your projects
- 🔐 **SSH key management** with interactive setup
- 🎯 **Smart .gitignore** templates included
- ⚡ **Lightweight** - uses inotify for efficient file watching

## 🎥 Demo

Watch your code being automatically versioned:

```bash
# Make a change
echo "Hello World" > test.py

# Within seconds, it's committed and pushed!
git log --oneline
# a1b2c3d Scripted auto-commit on change (2024-01-20 15:30:45)
```

## 🚀 Quick Start

### Prerequisites (Linux/WSL)

```bash
# Ubuntu/Debian
sudo apt-get update && sudo apt-get install -y inotify-tools

# RHEL/CentOS/Fedora
sudo yum install -y inotify-tools

# Arch
sudo pacman -S inotify-tools

# macOS (requires Homebrew)
brew install fswatch
```

### Installation

```bash
# Clone the repository
git clone https://github.com/JeremyWhittaker/gitwatch_automation.git
cd gitwatch_automation

# Run the installer
sudo ./install.sh  # Auto-installs dependencies
# OR
./install.sh --user  # No sudo (manual dependency install required)
```

### Set Up Your First Project

```bash
# Navigate to your project
cd ~/my-awesome-project

# Run setup (interactive)
setup-gitwatch

# That's it! Your project is now under continuous version control
```

## 📦 What's Included

| Tool | Description |
|------|-------------|
| **setup-gitwatch** | One-command project setup |
| **gitwatch-manage** | Service management CLI |
| **check-compatibility** | System compatibility checker |
| **batch_setup.sh** | Configure multiple projects at once |

## 🎯 Use Cases

Perfect for:
- 📝 **Note-taking** and documentation
- 🧪 **Experimentation** without fear of losing work
- 📊 **Data analysis** with automatic result tracking
- 🎨 **Creative coding** with full history
- 🔬 **Research projects** requiring detailed versioning
- 👥 **Team projects** with real-time synchronization

## 🛠️ Installation Options

### Standard (with sudo)
```bash
sudo ./install.sh
```

### User Mode (no sudo)
```bash
./install.sh --user
```

### Portable Mode
```bash
./install.sh --portable
# Everything in current directory
```

### Docker Mode
```bash
./install.sh --docker
docker-compose up -d
```

## 📋 Managing Your Projects

### List All Monitored Projects
```bash
gitwatch-manage list
```

### Check Project Status
```bash
gitwatch-manage status my-project
```

### View Real-time Logs
```bash
gitwatch-manage logs my-project
```

### Stop/Start Monitoring
```bash
gitwatch-manage stop my-project
gitwatch-manage start my-project
```

## 🔧 Advanced Configuration

### Custom Commit Messages
Edit the service file to customize commit messages:
```bash
systemctl --user edit gitwatch-projectname
# Change: ExecStart=/path/to/gitwatch -m "🚀 Auto-save: %d" -r origin /project/path
```

### Multiple Remotes
Push to multiple repositories:
```bash
ExecStart=/path/to/gitwatch -r origin -r backup -b main /project/path
```

### Exclude Patterns
Add to your `.gitignore`:
```
*.log
temp/
*.tmp
```

## 🤝 Contributing

We love contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Quick Contribution Guide
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 🐛 Troubleshooting

### Common Issues

<details>
<summary>Service won't start</summary>

Check logs:
```bash
gitwatch-manage logs project-name
journalctl --user -u gitwatch-projectname -f
```
</details>

<details>
<summary>Push failures</summary>

1. Check SSH key: `ssh -T git@github.com`
2. Verify remote: `git remote -v`
3. Check branch: `git branch`
</details>

<details>
<summary>High CPU usage</summary>

Large repositories may need exclusions:
```bash
echo "node_modules/" >> .gitignore
echo "*.log" >> .gitignore
```
</details>

## 📊 Performance

- **CPU**: < 1% idle, spikes only on file changes
- **Memory**: ~10-20MB per project
- **Latency**: Commits within 1-2 seconds of file save

## 🌟 Success Stories

> "Gitwatch has saved me countless hours. I never worry about losing experimental code anymore!" - *Developer*

> "Perfect for Jupyter notebooks - every execution is automatically versioned!" - *Data Scientist*

> "We use it for our documentation wiki. Real-time collaboration with full history!" - *Tech Writer*

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built on top of [gitwatch](https://github.com/gitwatch/gitwatch)
- Inspired by the need for effortless version control
- Thanks to all [contributors](https://github.com/JeremyWhittaker/gitwatch_automation/graphs/contributors)

## 📞 Support

- 💬 [Discussions](https://github.com/JeremyWhittaker/gitwatch_automation/discussions)
- 🐛 [Issues](https://github.com/JeremyWhittaker/gitwatch_automation/issues)

---

<p align="center">Made with ❤️ by developers, for developers</p>

<p align="center">
  <a href="https://github.com/JeremyWhittaker/gitwatch_automation/stargazers">⭐ Star us on GitHub!</a>
</p>
