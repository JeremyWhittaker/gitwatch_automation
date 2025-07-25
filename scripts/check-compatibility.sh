#!/bin/bash
# check-compatibility.sh - Check system compatibility for gitwatch automation

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Gitwatch Automation - System Compatibility Check${NC}"
echo "================================================"
echo ""

# Variables to track compatibility
COMPATIBLE=true
WARNINGS=""
ERRORS=""

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
        # Detect specific distribution
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            DISTRO=$ID
            DISTRO_VERSION=$VERSION_ID
        elif [ -f /etc/debian_version ]; then
            DISTRO="debian"
            DISTRO_VERSION=$(cat /etc/debian_version)
        elif [ -f /etc/redhat-release ]; then
            DISTRO="rhel"
            DISTRO_VERSION=$(cat /etc/redhat-release | grep -oE '[0-9]+\.[0-9]+')
        else
            DISTRO="unknown"
            DISTRO_VERSION="unknown"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        DISTRO="macos"
        DISTRO_VERSION=$(sw_vers -productVersion)
    elif [[ "$OSTYPE" == "cygwin" ]] || [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
        OS="windows"
        DISTRO="windows"
        DISTRO_VERSION="unknown"
    else
        OS="unknown"
        DISTRO="unknown"
        DISTRO_VERSION="unknown"
    fi
    
    # Check if running in WSL
    if grep -qi microsoft /proc/version 2>/dev/null; then
        OS="wsl"
        WSL_VERSION=$(wsl.exe -l -v 2>/dev/null | grep -E "Ubuntu|Debian" | awk '{print $4}' | head -1 || echo "unknown")
    fi
}

# Detect init system
detect_init_system() {
    if command -v systemctl &> /dev/null && systemctl --version &> /dev/null; then
        INIT_SYSTEM="systemd"
        SYSTEMD_VERSION=$(systemctl --version | head -1 | awk '{print $2}')
    elif command -v launchctl &> /dev/null; then
        INIT_SYSTEM="launchd"
    elif [ -d /etc/init.d ]; then
        INIT_SYSTEM="sysvinit"
    else
        INIT_SYSTEM="none"
    fi
}

# Detect package manager
detect_package_manager() {
    if command -v apt-get &> /dev/null; then
        PKG_MANAGER="apt"
    elif command -v yum &> /dev/null; then
        PKG_MANAGER="yum"
    elif command -v dnf &> /dev/null; then
        PKG_MANAGER="dnf"
    elif command -v pacman &> /dev/null; then
        PKG_MANAGER="pacman"
    elif command -v brew &> /dev/null; then
        PKG_MANAGER="brew"
    elif command -v zypper &> /dev/null; then
        PKG_MANAGER="zypper"
    else
        PKG_MANAGER="none"
    fi
}

# Check for required commands
check_requirements() {
    echo -e "${YELLOW}Checking requirements...${NC}"
    
    # Check git
    if command -v git &> /dev/null; then
        GIT_VERSION=$(git --version | awk '{print $3}')
        echo -e "  ${GREEN}✓${NC} Git: $GIT_VERSION"
    else
        echo -e "  ${RED}✗${NC} Git: Not found"
        ERRORS="${ERRORS}Git is required but not installed\n"
        COMPATIBLE=false
    fi
    
    # Check SSH
    if command -v ssh &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} SSH: Found"
    else
        echo -e "  ${RED}✗${NC} SSH: Not found"
        ERRORS="${ERRORS}SSH is required but not installed\n"
        COMPATIBLE=false
    fi
    
    # Check for SSH key
    SSH_KEY_FOUND=false
    for key in ~/.ssh/id_ed25519 ~/.ssh/id_rsa ~/.ssh/id_ecdsa; do
        if [ -f "$key" ]; then
            SSH_KEY_FOUND=true
            echo -e "  ${GREEN}✓${NC} SSH Key: Found at $key"
            break
        fi
    done
    if [ "$SSH_KEY_FOUND" = false ]; then
        echo -e "  ${YELLOW}!${NC} SSH Key: Not found"
        WARNINGS="${WARNINGS}No SSH key found. You'll need to create one with ssh-keygen\n"
    fi
    
    # Check gitwatch
    if command -v gitwatch &> /dev/null; then
        echo -e "  ${GREEN}✓${NC} Gitwatch: Already installed"
    else
        echo -e "  ${YELLOW}!${NC} Gitwatch: Not installed (will be installed)"
    fi
    
    # Check file watching tools
    if [[ "$OS" == "linux" ]] || [[ "$OS" == "wsl" ]]; then
        if command -v inotifywait &> /dev/null; then
            echo -e "  ${GREEN}✓${NC} inotify-tools: Installed"
        else
            echo -e "  ${YELLOW}!${NC} inotify-tools: Not installed (will be installed)"
        fi
    elif [[ "$OS" == "macos" ]]; then
        if command -v fswatch &> /dev/null; then
            echo -e "  ${GREEN}✓${NC} fswatch: Installed"
        else
            echo -e "  ${YELLOW}!${NC} fswatch: Not installed (will be installed)"
        fi
    fi
    
    # Check sudo access
    if sudo -n true 2>/dev/null; then
        echo -e "  ${GREEN}✓${NC} Sudo: Available without password"
        SUDO_AVAILABLE="yes"
    elif sudo -v 2>/dev/null; then
        echo -e "  ${YELLOW}!${NC} Sudo: Available (password required)"
        SUDO_AVAILABLE="password"
    else
        echo -e "  ${YELLOW}!${NC} Sudo: Not available"
        SUDO_AVAILABLE="no"
        WARNINGS="${WARNINGS}No sudo access. Will use user-mode installation\n"
    fi
    
    # Check for critical dependencies that require sudo
    if [[ "$OS" == "linux" ]] || [[ "$OS" == "wsl" ]]; then
        if ! command -v inotifywait &> /dev/null && [ "$SUDO_AVAILABLE" = "no" ]; then
            echo -e "  ${RED}✗${NC} CRITICAL: inotify-tools required but not installed"
            ERRORS="${ERRORS}inotify-tools is REQUIRED for gitwatch to function on Linux\n"
            ERRORS="${ERRORS}Please run: sudo apt-get install inotify-tools\n"
            COMPATIBLE=false
        fi
    fi
}

# Display system information
display_system_info() {
    echo ""
    echo -e "${BLUE}System Information:${NC}"
    echo "  OS: $OS"
    echo "  Distribution: $DISTRO $DISTRO_VERSION"
    echo "  Init System: $INIT_SYSTEM"
    echo "  Package Manager: $PKG_MANAGER"
    echo ""
}

# Check compatibility
check_compatibility() {
    echo -e "${BLUE}Compatibility Analysis:${NC}"
    
    # Check OS compatibility
    case "$OS" in
        "linux"|"wsl")
            echo -e "  ${GREEN}✓${NC} Operating System: Supported"
            ;;
        "macos")
            echo -e "  ${YELLOW}!${NC} Operating System: Partially supported (experimental)"
            WARNINGS="${WARNINGS}macOS support is experimental. Some features may not work\n"
            ;;
        "windows")
            echo -e "  ${RED}✗${NC} Operating System: Not supported"
            ERRORS="${ERRORS}Windows is not supported. Please use WSL2\n"
            COMPATIBLE=false
            ;;
        *)
            echo -e "  ${RED}✗${NC} Operating System: Unknown"
            ERRORS="${ERRORS}Unknown operating system\n"
            COMPATIBLE=false
            ;;
    esac
    
    # Check init system compatibility
    case "$INIT_SYSTEM" in
        "systemd")
            echo -e "  ${GREEN}✓${NC} Init System: Fully supported"
            ;;
        "launchd")
            echo -e "  ${YELLOW}!${NC} Init System: Partially supported"
            WARNINGS="${WARNINGS}launchd support is experimental\n"
            ;;
        "sysvinit")
            echo -e "  ${YELLOW}!${NC} Init System: Limited support"
            WARNINGS="${WARNINGS}Will use background processes instead of services\n"
            ;;
        *)
            echo -e "  ${YELLOW}!${NC} Init System: Not available"
            WARNINGS="${WARNINGS}No init system detected. Will use background processes\n"
            ;;
    esac
    
    # Check package manager
    if [ "$PKG_MANAGER" = "none" ]; then
        echo -e "  ${YELLOW}!${NC} Package Manager: Not detected"
        WARNINGS="${WARNINGS}No package manager found. Manual installation required\n"
    else
        echo -e "  ${GREEN}✓${NC} Package Manager: $PKG_MANAGER"
    fi
}

# Suggest installation method
suggest_installation() {
    echo ""
    echo -e "${BLUE}Recommended Installation Method:${NC}"
    
    if [ "$COMPATIBLE" = false ]; then
        echo -e "  ${RED}System is not compatible with gitwatch automation${NC}"
        return
    fi
    
    if [ "$SUDO_AVAILABLE" = "no" ]; then
        echo "  • Use user-mode installation: ./install.sh --user"
        echo "  • Or use portable mode: ./install.sh --portable"
    elif [[ "$OS" == "macos" ]]; then
        echo "  • Use macOS installation: ./install.sh --macos"
    elif [[ "$INIT_SYSTEM" != "systemd" ]]; then
        echo "  • Use background mode: ./install.sh --background"
    else
        echo "  • Use standard installation: ./install.sh"
    fi
    
    echo ""
    echo -e "${BLUE}Alternative Options:${NC}"
    echo "  • Docker mode: ./install.sh --docker"
    echo "  • Manual setup: See MANUAL_SETUP.md"
}

# Main execution
detect_os
detect_init_system
detect_package_manager
display_system_info
check_requirements
echo ""
check_compatibility

# Display warnings
if [ -n "$WARNINGS" ]; then
    echo ""
    echo -e "${YELLOW}Warnings:${NC}"
    echo -e "$WARNINGS"
fi

# Display errors
if [ -n "$ERRORS" ]; then
    echo ""
    echo -e "${RED}Errors:${NC}"
    echo -e "$ERRORS"
fi

# Final recommendation
suggest_installation

# Exit with appropriate code
if [ "$COMPATIBLE" = false ]; then
    exit 1
else
    exit 0
fi