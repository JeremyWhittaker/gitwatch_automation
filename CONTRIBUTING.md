# Contributing to Gitwatch Automation

Thank you for your interest in contributing to Gitwatch Automation! We welcome contributions from the community and are grateful for any help you can provide.

## 🤝 Code of Conduct

Please note that this project is released with a Contributor Code of Conduct. By participating in this project you agree to abide by its terms:

- Be respectful and inclusive
- Welcome newcomers and help them get started
- Focus on what is best for the community
- Show empathy towards other community members

## 🚀 Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/gitwatch_automation.git
   cd gitwatch_automation
   ```
3. **Create a branch** for your changes:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## 📋 Before You Contribute

### Check Existing Issues

- Look through [existing issues](https://github.com/JeremyWhittaker/gitwatch_automation/issues) to see if your idea is already being discussed
- Check [pull requests](https://github.com/JeremyWhittaker/gitwatch_automation/pulls) to ensure you're not duplicating work

### Discuss Major Changes

For significant changes, please open an issue first to discuss what you would like to change. This helps ensure your contribution aligns with the project's direction.

## 💻 Development Guidelines

### Code Style

- **Shell Scripts**: Follow [Google's Shell Style Guide](https://google.github.io/styleguide/shellguide.html)
- Use 4 spaces for indentation (not tabs)
- Keep lines under 80 characters when possible
- Add comments for complex logic
- Use meaningful variable names

### Testing Your Changes

1. **Run the compatibility checker**:
   ```bash
   ./scripts/check-compatibility.sh
   ```

2. **Test installation modes**:
   ```bash
   # Test user mode
   ./install.sh --user --dry-run
   
   # Test portable mode
   ./install.sh --portable --dry-run
   ```

3. **Test on multiple platforms** if possible:
   - Linux (Ubuntu/Debian)
   - macOS
   - WSL

### Commit Messages

Write clear, concise commit messages:
- Use present tense ("Add feature" not "Added feature")
- First line should be under 50 characters
- Reference issues when applicable (#123)

Example:
```
Add macOS launchd support for service management

- Implement launchd plist generation
- Add macOS-specific service commands
- Update documentation for macOS users

Fixes #45
```

## 🔧 Types of Contributions

### Bug Reports

Great bug reports include:
- A clear, descriptive title
- Steps to reproduce the issue
- Expected vs actual behavior
- System information (OS, shell version)
- Any relevant error messages or logs

### Feature Requests

When suggesting features:
- Explain the problem you're trying to solve
- Describe your proposed solution
- Consider alternative solutions
- Explain why this would benefit other users

### Code Contributions

We welcome:
- Bug fixes
- New features
- Documentation improvements
- Performance optimizations
- Platform support expansions
- Test additions

### Documentation

Help us improve:
- README clarity
- Installation guides
- Troubleshooting sections
- Code comments
- Example configurations

## 📝 Pull Request Process

1. **Update documentation** for any changed functionality
2. **Add tests** if applicable
3. **Ensure all tests pass**
4. **Update CHANGELOG.md** with your changes
5. **Submit your PR** with a clear description

### PR Checklist

- [ ] Code follows project style guidelines
- [ ] Tests pass locally
- [ ] Documentation is updated
- [ ] Commit messages are clear
- [ ] PR description explains the changes

## 🎯 Areas We Need Help

- **Cross-platform testing**: Especially BSD, Solaris, Alpine Linux
- **Integration guides**: For popular development tools
- **Performance optimization**: For large repositories
- **UI improvements**: Better progress indicators, interactive modes
- **Error handling**: More descriptive error messages
- **Internationalization**: Support for multiple languages

## 🏷️ Labels

We use labels to organize issues:
- `good first issue` - Perfect for newcomers
- `help wanted` - We need community input
- `bug` - Something isn't working
- `enhancement` - New features or improvements
- `documentation` - Documentation updates needed
- `platform` - Platform-specific issues

## 📮 Communication

- **Issues**: For bugs and feature requests
- **Discussions**: For general questions and ideas
- **Pull Requests**: For code contributions

## 🙏 Recognition

Contributors will be:
- Listed in our [Contributors](https://github.com/JeremyWhittaker/gitwatch_automation/graphs/contributors) page
- Mentioned in release notes for significant contributions
- Given credit in documentation for major features

## ❓ Questions?

Feel free to:
- Open an issue with the `question` label
- Start a discussion in the [Discussions](https://github.com/JeremyWhittaker/gitwatch_automation/discussions) tab

Thank you for helping make Gitwatch Automation better for everyone! 🎉