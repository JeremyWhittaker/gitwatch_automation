#!/bin/bash
# Simple batch setup for gitwatch - non-interactive

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
SETUP_CMD="$HOME/.local/bin/setup-gitwatch"
LOG_FILE="/tmp/gitwatch_batch_$(date +%Y%m%d_%H%M%S).log"

# Projects to skip
SKIP_PROJECTS=("test" "gitwatch_automation")

echo -e "${BLUE}Gitwatch Batch Setup - Non-Interactive${NC}"
echo "======================================"
echo "Log file: $LOG_FILE"
echo ""

# Initialize counters
SUCCESS=0
FAILED=0
SKIPPED=0

# Function to setup project non-interactively
setup_project() {
    local project_dir="$1"
    local project_name="$2"
    
    echo -e "\n${YELLOW}Setting up: $project_name${NC}" | tee -a "$LOG_FILE"
    
    # Create a wrapper script that handles the prompts
    cat > /tmp/setup_wrapper.sh << 'EOF'
#!/bin/bash
# Auto-respond to prompts
PROJECT_DIR="$1"

# Temporarily disable interactive prompts
export DEBIAN_FRONTEND=noninteractive

# Run setup-gitwatch with empty input for GitHub URL prompt
echo "" | '$SETUP_CMD' "$PROJECT_DIR" 2>&1
EOF
    
    chmod +x /tmp/setup_wrapper.sh
    
    if /tmp/setup_wrapper.sh "$project_dir" >> "$LOG_FILE" 2>&1; then
        echo -e "  ${GREEN}✓ Success${NC}"
        SUCCESS=$((SUCCESS + 1))
        
        # Check service status
        local service_name="gitwatch-$(echo $project_name | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"
        if systemctl --user is-active "$service_name" > /dev/null 2>&1; then
            echo -e "  ${GREEN}✓ Service running${NC}"
        else
            echo -e "  ${YELLOW}! Service not running - check logs${NC}"
        fi
        return 0
    else
        echo -e "  ${RED}✗ Failed${NC}"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

# Process each project
for dir in /mnt/data/src/*/; do
    if [ ! -d "$dir" ]; then
        continue
    fi
    
    project=$(basename "$dir")
    
    # Skip certain projects
    for skip in "${SKIP_PROJECTS[@]}"; do
        if [ "$project" = "$skip" ]; then
            echo -e "\n${BLUE}Skipping: $project (in skip list)${NC}"
            SKIPPED=$((SKIPPED + 1))
            continue 2
        fi
    done
    
    # Check if it's a git repo
    if [ ! -d "$dir/.git" ]; then
        echo -e "\n${YELLOW}Skipping: $project (not a git repo)${NC}"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi
    
    # Check if already configured
    service_name="gitwatch-$(echo $project | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"
    if systemctl --user list-unit-files | grep -q "${service_name}.service"; then
        echo -e "\n${GREEN}Already configured: $project${NC}"
        SKIPPED=$((SKIPPED + 1))
        continue
    fi
    
    # Fix Tmux-Orchestrator remote to SSH format
    if [ "$project" = "Tmux-Orchestrator" ]; then
        echo "  Converting HTTPS remote to SSH..."
        git -C "$dir" remote set-url origin git@github.com:Jedward23/Tmux-Orchestrator.git 2>/dev/null || true
    fi
    
    # Set up the project
    setup_project "$dir" "$project"
done

# Clean up
rm -f /tmp/setup_wrapper.sh

# Summary
echo ""
echo -e "${BLUE}Summary${NC}"
echo "======="
echo "Successfully configured: $SUCCESS"
echo "Failed: $FAILED"
echo "Skipped: $SKIPPED"
echo ""
echo "Log file: $LOG_FILE"
echo ""

# Show all services
echo -e "${BLUE}All Gitwatch Services:${NC}"
"$HOME/.local/bin/gitwatch-manage" list

exit 0