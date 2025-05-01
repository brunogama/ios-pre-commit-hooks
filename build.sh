#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Pre-commit Hooks Installer Builder${NC}"
echo -e "${BLUE}=================================${NC}"

# Check if Swift is installed
if ! command -v swift &> /dev/null; then
    echo -e "${RED}Error: Swift is not installed on your system.${NC}"
    echo "Please install Swift and try again."
    exit 1
fi

# Download dependencies
echo -e "${YELLOW}Downloading dependencies...${NC}"
swift package resolve

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to download dependencies.${NC}"
    echo -e "${YELLOW}Checking if Rainbow package is available...${NC}"
    
    # Check if Rainbow package is available
    if ! swift package show-dependencies | grep -q "Rainbow"; then
        echo -e "${YELLOW}Rainbow package not found, attempting to add it...${NC}"
        
        # Update Package.swift to include Rainbow if needed
        if ! grep -q '\.package(url: "https://github.com/onevcat/Rainbow"' Package.swift; then
            echo -e "${YELLOW}Adding Rainbow dependency to Package.swift dependencies...${NC}"
            # Use awk for more reliable line insertion on macOS
            awk '/dependencies: \[/{print; print "        .package(url: \"https://github.com/onevcat/Rainbow\", from: \"4.0.0\"),"; next}1' Package.swift > Package.swift.tmp && mv Package.swift.tmp Package.swift
        fi
        if ! grep -q '"Rainbow"' Package.swift; then
            echo -e "${YELLOW}Adding Rainbow dependency to Package.swift target dependencies...${NC}"
            awk '/.product(name: "ArgumentParser", package: "swift-argument-parser"),/{print; print "                \"Rainbow\","; next}1' Package.swift > Package.swift.tmp && mv Package.swift.tmp Package.swift
        fi

        # Try resolving dependencies again
        echo -e "${YELLOW}Attempting to resolve dependencies again...${NC}"
        swift package resolve
        
        if [ $? -ne 0 ]; then
            echo -e "${RED}Error: Failed to resolve dependencies after adding Rainbow.${NC}"
            exit 1
        fi
    fi
fi

# Build the Swift package
echo -e "${YELLOW}Building installer...${NC}"
swift build

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to build Swift package.${NC}"
    exit 1
fi

echo -e "${GREEN}Build complete!${NC}"
echo "Run the installer with: ./install.sh" 