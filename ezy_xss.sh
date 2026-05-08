#!/bin/bash

# =============================================
#          EZY_XSS v1.3 - Final Enhanced
#          By e1Pr0f3ss0r
# =============================================

clear

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

printf """${CYAN}
                       _ ____________
  ___ ____ __ __ | |/ / ___/ ___/
 / _ \/_ // / / / | /\__ \\__ \\
/ __/ / // /_/ / / |___/ /__/ /
\___/ /___|__, /____/_/|_/____/____/
         /____/_____/
           V-1.3___By e1Pr0f3ss0r
${NC}
"""

# Load config
if [ -f ~/ezy_xss/.config ]; then
    . ~/ezy_xss/.config
else
    echo -e "${RED}[!] Config file ~/ezy_xss/.config not found!${NC}"
    exit 1
fi

[ -z "$xsshunter_domain" ] || [ -z "$xss_payload" ] && {
    echo -e "${RED}[!] Missing variables in config file${NC}"
    exit 1
}

# Argument
domain=$1
[ -z "$domain" ] && {
    echo -e "${RED}Usage: $0 <target.com>${NC}"
    exit 1
}

mkdir -p "$domain"

echo -e "${YELLOW}[+] Target: ${CYAN}$domain${NC}\n"

# Tool Check
for tool in paramspider dalfox gau waybackurls qsreplace; do
    if ! command -v "$tool" &> /dev/null; then
        echo -e "${YELLOW}[!] $tool not installed. Continuing without it...${NC}"
    fi
done

# ========================
echo -e "${YELLOW}[1] Collecting Parameters...${NC}"

> "$domain/params.txt"

echo -e "${CYAN}   → ParamSpider${NC}"
paramspider --domain "$domain" --output "$domain/params.txt" 2>/dev/null

# Fallback methods
if [ $(wc -l < "$domain/params.txt") -lt 10 ]; then
    echo -e "${YELLOW}   → ParamSpider returned very few results. Using fallbacks...${NC}"
    
    if command -v gau &> /dev/null; then
        echo -e "${CYAN}   → Running gau...${NC}"
        gau "$domain" --subs | grep '?' >> "$domain/params.txt" 2>/dev/null
    fi

    if command -v waybackurls &> /dev/null; then
        echo -e "${CYAN}   → Running waybackurls...${NC}"
        waybackurls "$domain" | grep '?' >> "$domain/params.txt" 2>/dev/null
    fi
fi

# Clean & remove duplicates
sort -u "$domain/params.txt" -o "$domain/params.txt"

param_count=$(wc -l < "$domain/params.txt")
echo -e "${GREEN}[✔] Total URLs with parameters: $param_count${NC}"

if [ "$param_count" -eq 0 ]; then
    echo -e "${RED}[!] No parameters found. Try a different domain or use Katana.${NC}"
    exit 1
fi

# ========================
echo -e "\n${YELLOW}[2] Scanning with Dalfox + Blind XSS...${NC}"
dalfox file "$domain/params.txt" -b "$xsshunter_domain" -o "$domain/dalfox-xss.txt" --silence --skip-bav

# ========================
echo -e "\n${YELLOW}[3] Custom Reflected XSS Testing...${NC}"

cat "$domain/params.txt" | qsreplace "$xss_payload" > "$domain/fuzz.txt" 2>/dev/null

> "$domain/Vuln-xss.txt"

while IFS= read -r host; do
    [[ -z "$host" ]] && continue
    echo -ne "${CYAN}Testing → ${host:0:70}...${NC}\r"
    
    if curl -s -k --max-time 10 "$host" | grep -q "$(echo "$xss_payload" | sed 's/[^a-zA-Z0-9]//g' | cut -c1-20)"; then
        echo -e "\n${RED}[VULNERABLE]${NC} $host"
        echo "$host" >> "$domain/Vuln-xss.txt"
    fi
done < "$domain/fuzz.txt"

echo -e "\n${GREEN}=====================================${NC}"
echo -e "${GREEN}Scan Completed for $domain${NC}"
echo -e "${GREEN}Results saved in folder: $domain/${NC}"
echo -e "${GREEN}=====================================${NC}"

if [ -s "$domain/Vuln-xss.txt" ]; then
    echo -e "${RED}[!!!] $(wc -l < "$domain/Vuln-xss.txt") Vulnerable URL(s) Found!${NC}"
fi
