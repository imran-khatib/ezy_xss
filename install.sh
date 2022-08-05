#!/bin/bash

green=`echo -en "\e[32m"`
blue=`echo -en "\e[34m"`
NC='\033[0m'


echo -e "${green}[*] Installing Essentials${NC}"
apt-get update -y --silent 
apt-get upgrade -y -silent
cd $HOME
mkdir tools
echo "${blue} [*] Installing Parampsider..... ${NC}"
cd  ~/tools
git clone https://github.com/devanshbatham/ParamSpider.git
cd ParamSpider
pip3 install -r requirements.txt
cd .. 
echo "${blue}[*] Installing Dalfox..... ${NC}"
cd  ~/tools
go install -v github.com/hahwul/dalfox/v2@latest

cd ..
echo "${blue}[*] Installing qsreplace..... ${NC}"
cd  ~/tools
go install -v github.com/tomnomnom/qsreplace@latest

