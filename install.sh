#!/bin/bash
# Gitwatch Automation Installer

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}Gitwatch Automation Installer${NC}"
echo "=============================="
echo ""

# Detect installation directory
INSTALL_DIR="${HOME}/.local/bin"
CONFIG_DIR="${HOME}/.config/gitwatch-automation"

# Create directories
echo -e "${YELLOW}Creating directories...${NC}"
mkdir -p "$INSTALL_DIR"
mkdir -p "$CONFIG_DIR"

# Ensure ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    echo -e "${YELLOW}Adding ~/.local/bin to PATH...${NC}"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
    echo -e "${RED}Note: Run 'source ~/.bashrc' or restart your terminal for PATH changes to take effect${NC}"
fi

# Copy scripts
echo -e "${YELLOW}Installing scripts...${NC}"
cp -f scripts/setup-gitwatch "$INSTALL_DIR/"
cp -f scripts/gitwatch-manage "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/setup-gitwatch"
chmod +x "$INSTALL_DIR/gitwatch-manage"

# Copy templates
echo -e "${YELLOW}Installing templates...${NC}"
cp -rf templates/* "$CONFIG_DIR/"

# Install gitwatch if not present
if ! command -v gitwatch &> /dev/null; then
    echo -e "${YELLOW}Installing gitwatch...${NC}"
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    git clone https://github.com/gitwatch/gitwatch.git
    sudo cp gitwatch/gitwatch.sh /usr/local/bin/gitwatch
    sudo chmod +x /usr/local/bin/gitwatch
    cd - > /dev/null
    rm -rf "$TEMP_DIR"
fi

# Install inotify-tools if not present
if ! command -v inotifywait &> /dev/null; then
    echo -e "${YELLOW}Installing inotify-tools...${NC}"
    sudo apt-get update && sudo apt-get install -y inotify-tools
fi

# Create uninstall script
cat > "$INSTALL_DIR/gitwatch-uninstall" << 'EOF'
#!/bin/bash
# Uninstall gitwatch automation

echo "Uninstalling gitwatch automation..."

# Remove scripts
rm -f ~/.local/bin/setup-gitwatch
rm -f ~/.local/bin/gitwatch-manage
rm -f ~/.local/bin/gitwatch-uninstall

# Remove config
rm -rf ~/.config/gitwatch-automation

# List services but don't remove them
echo ""
echo "Gitwatch services are still running. To remove them:"
echo "gitwatch-manage list"
echo "gitwatch-manage remove <service-name>"

echo "Uninstall complete!"
EOF

chmod +x "$INSTALL_DIR/gitwatch-uninstall"

echo ""
echo -e "${GREEN}✅ Installation complete!${NC}"
echo ""
echo "Available commands:"
echo "  setup-gitwatch    - Set up gitwatch for a project"
echo "  gitwatch-manage   - Manage gitwatch services"
echo "  gitwatch-uninstall - Uninstall this automation system"
echo ""
echo "To get started:"
echo "  cd /path/to/your/project"
echo "  setup-gitwatch"
echo ""