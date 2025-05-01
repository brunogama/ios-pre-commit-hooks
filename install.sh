#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Pre-commit Hooks Installer${NC}"
echo -e "${BLUE}===========================${NC}"

# Check if Swift is installed
if ! command -v swift &> /dev/null; then
    echo -e "${RED}Error: Swift is not installed on your system.${NC}"
    echo "Please install Swift and try again."
    exit 1
fi

# Check if the executable exists, if not, build it
if [ ! -f "./.build/debug/PreCommitInstaller" ]; then
    echo -e "${YELLOW}Executable not found. Building project...${NC}"
    ./build.sh
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Build failed.${NC}"
        exit 1
    fi
fi

# Run the installer
echo -e "${GREEN}Starting installer...${NC}"
./.build/debug/PreCommitInstaller "$@" 