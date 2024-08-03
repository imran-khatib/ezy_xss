#!/bin/bash

# Color codes
green=$(echo -en "\e[32m")
blue=$(echo -en "\e[34m")
NC='\033[0m'

# List of tools to be installed
TOOLS=(
    "dalfox"
    "qsreplace"
    "python3 paramspider.py"
    "waybackurls"
)

echo -e "${green}[*] Installing Essentials${NC}"

# Update and upgrade packages silently
apt-get update -y --silent 
apt-get upgrade -y --silent

# Create tools directory
mkdir -p ~/tools

# Install required tools
for tool in "${TOOLS[@]}"; do
    if ! command -v "${tool%% *}" &> /dev/null; then
        echo "$tool is not installed. Installing..."
        
        if [ "$tool" = "dalfox" ]; then
            GO111MODULE=on go install github.com/hahwul/dalfox/v2@latest
        elif [ "$tool" = "python3 paramspider.py" ]; then
            echo -e "${blue}[*] Installing ParamSpider...${NC}"
            cd ~/tools
            git clone https://github.com/devanshbatham/ParamSpider.git
            cd ParamSpider
            pip3 install -r requirements.txt
            cd ..
            echo -e "${green}Installed ParamSpider.${NC}"
        elif [ "$tool" = "waybackurls" ]; then
            echo -e "${green}Installing Waybackurls...${NC}"
            GO111MODULE=on go install github.com/tomnomnom/waybackurls@latest
            echo -e "${green}Installed Waybackurls.${NC}"
        elif [ "$tool" = "qsreplace" ]; then
            echo -e "${green}Installing qsreplace...${NC}"
            GO111MODULE=on go install github.com/tomnomnom/qsreplace@latest
            echo -e "${green}Installed qsreplace.${NC}"
        fi
    else
        echo "$tool is already installed"
    fi
done
