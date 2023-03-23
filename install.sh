#!/bin/bash

green=`echo -en "\e[32m"`
blue=`echo -en "\e[34m"`
NC='\033[0m'
TOOLS=( "dalfox"
        "qsreplace"
        "python3 paramspider.py"
        "waybackurls"
      )
echo -e "${green}[*] Installing Essentials${NC}"
apt-get update -y --silent 
apt-get upgrade -y -silent

mkdir ~/tools

for tool in "${TOOLS[@]}"; do
    if ! command -v "$tool" &> /dev/null; then
        echo "$tool is not installed. Installing..."
        if [ "$tool" = "dalfox" ]; then
            GO111MODULE=on go install github.com/hahwul/dalfox/v2@latest
        elif [ "$tool" = "paramspider" ]; then
            echo "${blue} [*] Installing Parampsider..... ${NC}"
            cd  ~/tools
            git clone https://github.com/devanshbatham/ParamSpider.git
            cd ParamSpider
            pip3 install -r requirements.txt
            cd .. 
             echo "${green}Installed Parampsider..${NC}"
        elif [ "$tool" = "waybackurls" ]; then
             echo "${green}Installing Waybackurls..${NC}"
             GO111MODULE=on go install github.com/tomnomnom/waybackurls@latest
             echo "${green}Installed Waybackurls..${NC}"
        elif [ "$tool" = "qsreplace" ]; then  
             echo "${green}Installing qsrepace..${NC}"
             GO111MODULE=on go install github.com/tomnomnom/qsreplace@latest
             echo "${green}Installed qsrepace${NC}"
        fi
        else
        echo "$tool is already installed"
        fi
done
