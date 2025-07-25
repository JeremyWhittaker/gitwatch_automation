#!/bin/bash
# Gitwatch Automation Installer - Cross-platform version

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Default values
INSTALL_MODE="auto"
USE_SUDO=true
PORTABLE=false
DOCKER_MODE=false
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --user)
            INSTALL_MODE="user"
            USE_SUDO=false
            shift
            ;;
        --portable)
            INSTALL_MODE="portable"
            PORTABLE=true
            USE_SUDO=false
            shift
            ;;
        --docker)
            INSTALL_MODE="docker"
            DOCKER_MODE=true
            shift
            ;;
        --macos)
            INSTALL_MODE="macos"
            shift
            ;;
        --background)
            INSTALL_MODE="background"
            shift
            ;;
        --help|-h)
            echo "Gitwatch Automation Installer"
            echo ""
            echo "Usage: ./install.sh [options]"
            echo ""
            echo "Options:"
            echo "  --user       Install in user mode (no sudo required)"
            echo "  --portable   Install everything in the current directory"
            echo "  --docker     Generate Docker configuration"
            echo "  --macos      Install with macOS-specific settings"
            echo "  --background Install without service manager support"
            echo "  --help       Show this help message"
            echo ""
            echo "If no options are specified, the installer will auto-detect the best method."
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

echo -e "${GREEN}Gitwatch Automation Installer${NC}"
echo "=============================="
echo ""

# Run compatibility check if auto mode
if [ "$INSTALL_MODE" = "auto" ]; then
    echo -e "${YELLOW}Running compatibility check...${NC}"
    if [ -f "$SCRIPT_DIR/scripts/check-compatibility.sh" ]; then
        if ! "$SCRIPT_DIR/scripts/check-compatibility.sh"; then
            echo -e "${RED}Compatibility check failed. Please run with --help for options.${NC}"
            exit 1
        fi
    fi
    echo ""
fi

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        if [ "$INSTALL_MODE" = "auto" ]; then
            INSTALL_MODE="macos"
        fi
    elif grep -qi microsoft /proc/version 2>/dev/null; then
        OS="wsl"
    else
        OS="unknown"
    fi
}

# Set installation directories based on mode
set_install_dirs() {
    case "$INSTALL_MODE" in
        "portable")
            INSTALL_DIR="$SCRIPT_DIR/bin"
            CONFIG_DIR="$SCRIPT_DIR/config"
            GITWATCH_PATH="$INSTALL_DIR/gitwatch"
            ;;
        "user"|"background"|"macos")
            INSTALL_DIR="${HOME}/.local/bin"
            CONFIG_DIR="${HOME}/.config/gitwatch-automation"
            GITWATCH_PATH="${HOME}/.local/bin/gitwatch"
            ;;
        *)
            INSTALL_DIR="${HOME}/.local/bin"
            CONFIG_DIR="${HOME}/.config/gitwatch-automation"
            if [ "$USE_SUDO" = true ]; then
                GITWATCH_PATH="/usr/local/bin/gitwatch"
            else
                GITWATCH_PATH="${HOME}/.local/bin/gitwatch"
            fi
            ;;
    esac
}

# Check sudo availability
check_sudo() {
    if [ "$USE_SUDO" = true ]; then
        if ! sudo -n true 2>/dev/null; then
            echo -e "${YELLOW}Sudo access required. You may be prompted for your password.${NC}"
            if ! sudo -v 2>/dev/null; then
                echo -e "${RED}Sudo access denied. Switching to user mode installation.${NC}"
                USE_SUDO=false
                GITWATCH_PATH="${HOME}/.local/bin/gitwatch"
            fi
        fi
    fi
}

# Detect package manager
detect_package_manager() {
    if command -v apt-get &> /dev/null; then
        PKG_MANAGER="apt"
        PKG_INSTALL="apt-get install -y"
    elif command -v yum &> /dev/null; then
        PKG_MANAGER="yum"
        PKG_INSTALL="yum install -y"
    elif command -v dnf &> /dev/null; then
        PKG_MANAGER="dnf"
        PKG_INSTALL="dnf install -y"
    elif command -v pacman &> /dev/null; then
        PKG_MANAGER="pacman"
        PKG_INSTALL="pacman -S --noconfirm"
    elif command -v brew &> /dev/null; then
        PKG_MANAGER="brew"
        PKG_INSTALL="brew install"
    elif command -v zypper &> /dev/null; then
        PKG_MANAGER="zypper"
        PKG_INSTALL="zypper install -y"
    else
        PKG_MANAGER="none"
    fi
}

# Install gitwatch
install_gitwatch() {
    if command -v gitwatch &> /dev/null || [ -f "$GITWATCH_PATH" ]; then
        echo -e "${GREEN}✓ Gitwatch already installed${NC}"
        return
    fi
    
    echo -e "${YELLOW}Installing gitwatch...${NC}"
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    if ! git clone https://github.com/gitwatch/gitwatch.git 2>/dev/null; then
        echo -e "${RED}Failed to clone gitwatch repository${NC}"
        cd - > /dev/null
        rm -rf "$TEMP_DIR"
        return 1
    fi
    
    if [ "$USE_SUDO" = true ] && [ "$GITWATCH_PATH" = "/usr/local/bin/gitwatch" ]; then
        sudo cp gitwatch/gitwatch.sh "$GITWATCH_PATH"
        sudo chmod +x "$GITWATCH_PATH"
    else
        mkdir -p "$(dirname "$GITWATCH_PATH")"
        cp gitwatch/gitwatch.sh "$GITWATCH_PATH"
        chmod +x "$GITWATCH_PATH"
    fi
    
    cd - > /dev/null
    rm -rf "$TEMP_DIR"
    echo -e "${GREEN}✓ Gitwatch installed${NC}"
}

# Install file watching tools
install_file_watchers() {
    if [[ "$OS" == "linux" ]] || [[ "$OS" == "wsl" ]]; then
        if ! command -v inotifywait &> /dev/null; then
            echo -e "${YELLOW}Installing inotify-tools...${NC}"
            case "$PKG_MANAGER" in
                "apt")
                    if [ "$USE_SUDO" = true ]; then
                        sudo apt-get update && sudo $PKG_INSTALL inotify-tools
                    else
                        echo -e "${RED}WARNING: inotify-tools is REQUIRED but not installed${NC}"
                        echo -e "${RED}Gitwatch will NOT work without it!${NC}"
                        echo -e "${YELLOW}Please run: sudo apt-get install inotify-tools${NC}"
                        echo -e "${YELLOW}Then run this installer again.${NC}"
                        MISSING_REQUIREMENTS=true
                    fi
                    ;;
                "yum"|"dnf")
                    if [ "$USE_SUDO" = true ]; then
                        sudo $PKG_INSTALL inotify-tools
                    else
                        echo -e "${RED}WARNING: inotify-tools is REQUIRED but not installed${NC}"
                        echo -e "${RED}Gitwatch will NOT work without it!${NC}"
                        echo -e "${YELLOW}Please run: sudo $PKG_INSTALL inotify-tools${NC}"
                        echo -e "${YELLOW}Then run this installer again.${NC}"
                        MISSING_REQUIREMENTS=true
                    fi
                    ;;
                "pacman")
                    if [ "$USE_SUDO" = true ]; then
                        sudo $PKG_INSTALL inotify-tools
                    else
                        echo -e "${RED}WARNING: inotify-tools is REQUIRED but not installed${NC}"
                        echo -e "${RED}Gitwatch will NOT work without it!${NC}"
                        echo -e "${YELLOW}Please run: sudo pacman -S inotify-tools${NC}"
                        echo -e "${YELLOW}Then run this installer again.${NC}"
                        MISSING_REQUIREMENTS=true
                    fi
                    ;;
                *)
                    echo -e "${RED}WARNING: inotify-tools is REQUIRED but not installed${NC}"
                    echo -e "${RED}Gitwatch will NOT work without it!${NC}"
                    echo -e "${YELLOW}Please install inotify-tools using your package manager${NC}"
                    MISSING_REQUIREMENTS=true
                    ;;
            esac
        else
            echo -e "${GREEN}✓ inotify-tools already installed${NC}"
        fi
    elif [[ "$OS" == "macos" ]]; then
        if ! command -v fswatch &> /dev/null; then
            echo -e "${YELLOW}Installing fswatch...${NC}"
            if [ "$PKG_MANAGER" = "brew" ]; then
                brew install fswatch
            else
                echo -e "${YELLOW}Please install fswatch manually or install Homebrew${NC}"
            fi
        else
            echo -e "${GREEN}✓ fswatch already installed${NC}"
        fi
    fi
}

# Create Docker configuration
create_docker_config() {
    echo -e "${YELLOW}Creating Docker configuration...${NC}"
    
    cat > "$SCRIPT_DIR/Dockerfile" << 'EOF'
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    inotify-tools \
    openssh-client \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -s /bin/bash gitwatch && \
    echo 'gitwatch ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Copy gitwatch automation
COPY . /opt/gitwatch-automation
RUN chown -R gitwatch:gitwatch /opt/gitwatch-automation

# Switch to non-root user
USER gitwatch
WORKDIR /home/gitwatch

# Install gitwatch automation
RUN cd /opt/gitwatch-automation && \
    ./install.sh --user

# Add local bin to PATH
ENV PATH="/home/gitwatch/.local/bin:${PATH}"

# Volume for projects
VOLUME ["/projects"]

# Entry point
ENTRYPOINT ["/bin/bash"]
EOF

    cat > "$SCRIPT_DIR/docker-compose.yml" << 'EOF'
version: '3.8'

services:
  gitwatch:
    build: .
    container_name: gitwatch-automation
    volumes:
      - ./projects:/projects
      - ~/.ssh:/home/gitwatch/.ssh:ro
    environment:
      - SSH_AUTH_SOCK=/ssh-agent
    volumes:
      - ssh-agent:/ssh-agent
    restart: unless-stopped

volumes:
  ssh-agent:
EOF

    echo -e "${GREEN}✓ Docker configuration created${NC}"
    echo ""
    echo "To use Docker mode:"
    echo "  1. Build: docker-compose build"
    echo "  2. Run: docker-compose run gitwatch"
    echo "  3. Inside container: setup-gitwatch /projects/your-project"
}

# Main installation
main() {
    detect_os
    detect_package_manager
    set_install_dirs
    check_sudo
    
    echo -e "${BLUE}Installation Mode: $INSTALL_MODE${NC}"
    echo -e "${BLUE}Install Directory: $INSTALL_DIR${NC}"
    echo -e "${BLUE}Config Directory: $CONFIG_DIR${NC}"
    echo ""
    
    # Create directories
    echo -e "${YELLOW}Creating directories...${NC}"
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$CONFIG_DIR"
    
    # Update PATH if needed
    if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
        echo -e "${YELLOW}Adding $INSTALL_DIR to PATH...${NC}"
        
        # Detect shell and update appropriate config file
        if [ -n "$BASH_VERSION" ]; then
            SHELL_RC="$HOME/.bashrc"
        elif [ -n "$ZSH_VERSION" ]; then
            SHELL_RC="$HOME/.zshrc"
        else
            SHELL_RC="$HOME/.profile"
        fi
        
        echo "export PATH=\"$INSTALL_DIR:\$PATH\"" >> "$SHELL_RC"
        echo -e "${RED}Note: Run 'source $SHELL_RC' or restart your terminal for PATH changes${NC}"
    fi
    
    # Copy scripts
    echo -e "${YELLOW}Installing scripts...${NC}"
    cp -f "$SCRIPT_DIR/scripts/setup-gitwatch" "$INSTALL_DIR/"
    cp -f "$SCRIPT_DIR/scripts/gitwatch-manage" "$INSTALL_DIR/"
    cp -f "$SCRIPT_DIR/scripts/check-compatibility.sh" "$INSTALL_DIR/gitwatch-check"
    
    # Update scripts with correct paths
    sed -i.bak "s|/usr/local/bin/gitwatch|$GITWATCH_PATH|g" "$INSTALL_DIR/setup-gitwatch" && rm "$INSTALL_DIR/setup-gitwatch.bak"
    
    chmod +x "$INSTALL_DIR/setup-gitwatch"
    chmod +x "$INSTALL_DIR/gitwatch-manage"
    chmod +x "$INSTALL_DIR/gitwatch-check"
    
    # Copy templates
    echo -e "${YELLOW}Installing templates...${NC}"
    cp -rf "$SCRIPT_DIR/templates/"* "$CONFIG_DIR/"
    
    # Create mode-specific configuration
    echo "INSTALL_MODE=$INSTALL_MODE" > "$CONFIG_DIR/install.conf"
    echo "GITWATCH_PATH=$GITWATCH_PATH" >> "$CONFIG_DIR/install.conf"
    echo "USE_SUDO=$USE_SUDO" >> "$CONFIG_DIR/install.conf"
    
    # Install dependencies based on mode
    if [ "$DOCKER_MODE" = true ]; then
        create_docker_config
    else
        install_gitwatch
        install_file_watchers
    fi
    
    # Create uninstall script
    cat > "$INSTALL_DIR/gitwatch-uninstall" << UNINSTALL_EOF
#!/bin/bash
# Uninstall gitwatch automation

echo "Uninstalling gitwatch automation..."

# Remove scripts
rm -f "$INSTALL_DIR/setup-gitwatch"
rm -f "$INSTALL_DIR/gitwatch-manage"
rm -f "$INSTALL_DIR/gitwatch-check"
rm -f "$INSTALL_DIR/gitwatch-uninstall"

# Remove config
rm -rf "$CONFIG_DIR"

# Remove gitwatch if in user directory
if [ -f "$GITWATCH_PATH" ] && [[ "$GITWATCH_PATH" == "\$HOME"* ]]; then
    rm -f "$GITWATCH_PATH"
fi

# List services but don't remove them
if command -v gitwatch-manage &> /dev/null; then
    echo ""
    echo "Gitwatch services may still be running. To remove them:"
    echo "gitwatch-manage list"
    echo "gitwatch-manage remove <service-name>"
fi

echo "Uninstall complete!"
UNINSTALL_EOF
    
    chmod +x "$INSTALL_DIR/gitwatch-uninstall"
    
    # Final message
    echo ""
    
    if [ "$MISSING_REQUIREMENTS" = true ]; then
        echo -e "${RED}⚠️  Installation completed with WARNINGS!${NC}"
        echo ""
        echo -e "${RED}IMPORTANT: Missing required dependencies!${NC}"
        echo -e "${YELLOW}Gitwatch will NOT function properly without them.${NC}"
        echo ""
        echo "Please install the missing dependencies listed above,"
        echo "then run this installer again."
    else
        echo -e "${GREEN}✅ Installation complete!${NC}"
    fi
    
    echo ""
    echo "Available commands:"
    echo "  setup-gitwatch     - Set up gitwatch for a project"
    echo "  gitwatch-manage    - Manage gitwatch services"
    echo "  gitwatch-check     - Check system compatibility"
    echo "  gitwatch-uninstall - Uninstall this automation system"
    echo ""
    
    if [ "$MISSING_REQUIREMENTS" = true ]; then
        echo -e "${RED}Note: setup-gitwatch will fail until dependencies are installed!${NC}"
    elif [ "$PORTABLE" = true ]; then
        echo "Portable installation complete. Add this to your PATH:"
        echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
    elif [ "$DOCKER_MODE" = true ]; then
        echo "Docker configuration created. See docker-compose.yml"
    else
        echo "To get started:"
        echo "  cd /path/to/your/project"
        echo "  setup-gitwatch"
    fi
    echo ""
}

# Run main installation
main