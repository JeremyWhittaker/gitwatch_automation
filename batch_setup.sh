#!/bin/bash
# Batch setup gitwatch for multiple projects

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if setup-gitwatch is available
if ! command -v setup-gitwatch &> /dev/null; then
    if [ -f "$HOME/.local/bin/setup-gitwatch" ]; then
        export PATH="$HOME/.local/bin:$PATH"
    else
        echo -e "${RED}Error: setup-gitwatch not found. Please run install.sh first.${NC}"
        exit 1
    fi
fi

# Directory to scan
SRC_DIR="${1:-/mnt/data/src}"
SKIP_PROJECTS=("gitwatch_automation" "test" "autogen")
REPORT_FILE="/tmp/gitwatch_batch_report_$(date +%Y%m%d_%H%M%S).txt"

echo -e "${BLUE}Gitwatch Batch Setup${NC}"
echo "===================="
echo "Scanning: $SRC_DIR"
echo ""

# Initialize counters
TOTAL_PROJECTS=0
GIT_PROJECTS=0
ALREADY_CONFIGURED=0
SUCCESSFULLY_CONFIGURED=0
FAILED_CONFIGURATIONS=0
SKIPPED_PROJECTS=0

# Start report
echo "Gitwatch Batch Setup Report - $(date)" > "$REPORT_FILE"
echo "======================================" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Function to check if project should be skipped
should_skip() {
    local project="$1"
    for skip in "${SKIP_PROJECTS[@]}"; do
        if [ "$project" = "$skip" ]; then
            return 0
        fi
    done
    return 1
}

# Function to check if gitwatch is already configured
is_gitwatch_configured() {
    local project_name="$1"
    local service_name="gitwatch-$(echo $project_name | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"
    
    if systemctl --user list-unit-files | grep -q "${service_name}.service"; then
        return 0
    fi
    return 1
}

# Scan all directories
for dir in "$SRC_DIR"/*; do
    if [ -d "$dir" ]; then
        TOTAL_PROJECTS=$((TOTAL_PROJECTS + 1))
        PROJECT_NAME=$(basename "$dir")
        
        echo -e "\n${YELLOW}Checking: $PROJECT_NAME${NC}"
        
        # Check if should skip
        if should_skip "$PROJECT_NAME"; then
            echo -e "  ${BLUE}→ Skipping (in skip list)${NC}"
            SKIPPED_PROJECTS=$((SKIPPED_PROJECTS + 1))
            echo "SKIPPED: $PROJECT_NAME (in skip list)" >> "$REPORT_FILE"
            continue
        fi
        
        # Check if it's a git repository
        if [ ! -d "$dir/.git" ]; then
            echo -e "  ${YELLOW}→ Not a git repository${NC}"
            echo "SKIPPED: $PROJECT_NAME (not a git repo)" >> "$REPORT_FILE"
            continue
        fi
        
        GIT_PROJECTS=$((GIT_PROJECTS + 1))
        
        # Check if already configured
        if is_gitwatch_configured "$PROJECT_NAME"; then
            echo -e "  ${GREEN}→ Already configured${NC}"
            ALREADY_CONFIGURED=$((ALREADY_CONFIGURED + 1))
            echo "ALREADY CONFIGURED: $PROJECT_NAME" >> "$REPORT_FILE"
            continue
        fi
        
        # Check if has remote
        REMOTE_URL=$(git -C "$dir" remote get-url origin 2>/dev/null || echo "")
        if [ -z "$REMOTE_URL" ]; then
            echo -e "  ${YELLOW}→ No git remote configured${NC}"
            echo "  ${YELLOW}  Please add remote manually or project will only have local commits${NC}"
        fi
        
        # Try to set up gitwatch
        echo -e "  ${BLUE}→ Setting up gitwatch...${NC}"
        
        # Create a temporary expect script to handle interactive prompts
        EXPECT_SCRIPT="/tmp/gitwatch_setup_expect_$$.exp"
        cat > "$EXPECT_SCRIPT" << 'EOF'
#!/usr/bin/expect -f

set timeout 30
set project_path [lindex $argv 0]

spawn setup-gitwatch $project_path

expect {
    "GitHub URL:" {
        send "\r"
        exp_continue
    }
    "Create SSH key?" {
        send "n\r"
        exp_continue
    }
    "setup complete!" {
        exit 0
    }
    timeout {
        exit 1
    }
    eof {
        exit 0
    }
}
EOF
        
        chmod +x "$EXPECT_SCRIPT"
        
        if expect "$EXPECT_SCRIPT" "$dir" > /dev/null 2>&1; then
            echo -e "  ${GREEN}✓ Successfully configured${NC}"
            SUCCESSFULLY_CONFIGURED=$((SUCCESSFULLY_CONFIGURED + 1))
            echo "SUCCESS: $PROJECT_NAME" >> "$REPORT_FILE"
            
            # Show service status
            SERVICE_NAME="gitwatch-$(echo $PROJECT_NAME | tr '[:upper:]' '[:lower:]' | tr ' ' '-')"
            if systemctl --user is-active "$SERVICE_NAME" > /dev/null 2>&1; then
                echo -e "  ${GREEN}✓ Service is running${NC}"
            else
                echo -e "  ${RED}✗ Service failed to start${NC}"
            fi
        else
            echo -e "  ${RED}✗ Configuration failed${NC}"
            FAILED_CONFIGURATIONS=$((FAILED_CONFIGURATIONS + 1))
            echo "FAILED: $PROJECT_NAME" >> "$REPORT_FILE"
        fi
        
        rm -f "$EXPECT_SCRIPT"
    fi
done

# Summary
echo ""
echo -e "${BLUE}Summary${NC}"
echo "======="
echo "Total directories scanned: $TOTAL_PROJECTS"
echo "Git repositories found: $GIT_PROJECTS"
echo "Already configured: $ALREADY_CONFIGURED"
echo "Successfully configured: $SUCCESSFULLY_CONFIGURED"
echo "Failed configurations: $FAILED_CONFIGURATIONS"
echo "Skipped projects: $SKIPPED_PROJECTS"
echo ""
echo "Detailed report saved to: $REPORT_FILE"

# Show all running gitwatch services
echo ""
echo -e "${BLUE}All Gitwatch Services:${NC}"
gitwatch-manage list

# Add summary to report
echo "" >> "$REPORT_FILE"
echo "SUMMARY" >> "$REPORT_FILE"
echo "=======" >> "$REPORT_FILE"
echo "Total directories: $TOTAL_PROJECTS" >> "$REPORT_FILE"
echo "Git repositories: $GIT_PROJECTS" >> "$REPORT_FILE"
echo "Already configured: $ALREADY_CONFIGURED" >> "$REPORT_FILE"
echo "Successfully configured: $SUCCESSFULLY_CONFIGURED" >> "$REPORT_FILE"
echo "Failed: $FAILED_CONFIGURATIONS" >> "$REPORT_FILE"
echo "Skipped: $SKIPPED_PROJECTS" >> "$REPORT_FILE"

exit 0