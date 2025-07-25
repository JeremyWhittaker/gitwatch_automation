#!/bin/bash
# Update gitwatch automation to latest version

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Updating Gitwatch Automation...${NC}"

# Pull latest changes
git pull origin main

# Run installer to update scripts
./install.sh

echo -e "${GREEN}✅ Update complete!${NC}"