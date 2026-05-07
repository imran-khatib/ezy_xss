#!/bin/bash

# =============================================
#          EZY_XSS v1.2 - Enhanced
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
           V-1.2___By e1Pr0f3ss0r
${NC}
"""

# Load config
if [ -f ~/ezy_xss/.config ]; then
    . ~/ezy_xss/.config
else
    echo -e "${RED}[!] Config file not found!${NC}"
    exit 1
fi

if [ -z "$xsshunter_domain" ] || [ -z "$xss_payload" ]; then
    echo -e "${RED}[!] Missing xsshunter_domain or xss_payload in config${NC}"
    exit 1
fi

# Argument check
while getopts ":d:" opt; do
    case "$opt" in
        d) domain="${OPTARG}" ;;
        *) echo -e "${RED}Usage: $0 -d target.com${NC}"; exit 1 ;;
    esac
done

[ -z "$domain" ] && { echo -e "${RED}Usage: $0 -d target.com${NC}"; exit 1; }

mkdir -p "$domain"

echo -e "${YELLOW}[+] Target:${CYAN} $domain ${NC}\n"

# ========================
echo -e "${YELLOW}[1] Collecting parameters...${NC}"

> "$domain/params.txt"

echo -e "${CYAN}   → Running ParamSpider...${NC}"
paramspider --domain "$domain" --output "$domain/params.txt" 2>/dev/null

# Additional methods if ParamSpider gives nothing
if [ ! -s "$domain/params.txt" ] || [ $(wc -l < "$domain/params.txt") -lt 5 ]; then
    echo -e "${YELLOW}   → ParamSpider found very few results. Trying more methods...${NC}"
    
    # Method 2: Waybackurls / gau
    if command -v gau &> /dev/null; then
        echo -e "${CYAN}   → Running gau (Wayback Machine)...${NC}"
        gau "$domain" --subs | grep '?' >> "$domain/params.txt" 2>/dev/null
    fi

    if command -v waybackurls &> /dev/null; then
        echo -e "${CYAN}   → Running waybackurls...${NC}"
        waybackurls "$domain" | grep '?' >> "$domain/params.txt" 2>/dev/null
    fi
fi

# Remove duplicates
sort -u "$domain/params.txt" -o "$domain/params.txt"

param_count=$(wc -l < "$domain/params.txt")

if [ "$param_count" -eq 0 ]; then
    echo -e "${RED}[!] No parameters found even after additional tools.${NC}"
    echo -e "${YELLOW}Tips:${NC}"
    echo -e "   • Try a subdomain: -d sub.particleth.com"
    echo -e "   • Crawl manually with Katana or Hakrawler"
    echo -e "   • The site may not have many query parameters."
    exit 1
else
    echo -e "${GREEN}[✔] Found ${param_count} URLs with parameters.${NC}"
fi

# ========================
echo -e "\n${YELLOW}[2] Scanning with Dalfox...${NC}"
dalfox file "$domain/params.txt" -b "$xsshunter_domain" -o "$domain/dalfox-xss.txt" --silence --skip-bav

echo -e "\n${YELLOW}[3] Custom Reflected XSS Check...${NC}"
cat "$domain/params.txt" | qsreplace "$xss_payload" > "$domain/fuzz.txt" 2>/dev/null

> "$domain/Vuln-xss.txt"

while IFS= read -r host; do
    [[ -z "$host" ]] && continue
    if curl -s -k --max-time 10 "$host" | grep -q "$xss_payload"; then
        echo -e "${RED}[VULN]${NC} $host"
        echo "$host" >> "$domain/Vuln-xss.txt"
    fi
done < "$domain/fuzz.txt"

# Final Summary
echo -e "\n${GREEN}=====================================${NC}"
echo -e "${GREEN}Scan Finished for $domain${NC}"
echo -e "${GREEN}Parameters found : $param_count${NC}"
echo -e "${GREEN}Results saved in : $domain/${NC}"
ls "$domain" | sed 's/^/   • /'
echo -e "${GREEN}=====================================${NC}"

[[ -s "$domain/Vuln-xss.txt" ]] && echo -e "${RED}[!!!] Found $(wc -l < "$domain/Vuln-xss.txt") potential vulnerable links!${NC}"
