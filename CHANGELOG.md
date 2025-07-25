# Changelog

All notable changes to Gitwatch Automation will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- GitHub Actions CI/CD workflows
- CONTRIBUTING.md guide for contributors
- CHANGELOG.md for tracking changes
- GitHub setup documentation
- Professional README with badges
- MIT LICENSE file

## [1.0.0] - 2025-01-25

### Added
- Initial release of Gitwatch Automation System
- Cross-platform support (Linux, macOS, WSL)
- Multiple installation modes (sudo, user, portable, docker)
- SystemD service management for Linux
- Launchd service management for macOS
- Background process support for systems without service managers
- Interactive SSH key creation
- Batch setup for multiple projects
- Compatibility checker script
- Service management CLI (gitwatch-manage)
- Comprehensive documentation
- Smart .gitignore templates
- Support for multiple package managers

### Features
- Automatic Git commits on file changes
- Automatic push to remote repositories
- Service status monitoring
- Real-time log viewing
- Easy start/stop/restart controls
- Custom commit message support
- Multiple remote support

### Supported Platforms
- Ubuntu/Debian
- RHEL/CentOS/Fedora
- Arch Linux
- macOS (via Homebrew)
- Windows Subsystem for Linux (WSL)

[Unreleased]: https://github.com/JeremyWhittaker/gitwatch_automation/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/JeremyWhittaker/gitwatch_automation/releases/tag/v1.0.0