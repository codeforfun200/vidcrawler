#!/bin/bash

source array_lists.sh

#$1 string
#$2 titul
titul_in_str(){
if [[ $1 = *$2* ]]
  then
    return 0
fi
#echo "po prvni podmince"
local pom_iter=1
while [ $pom_iter -lt $((${#2}-1)) ]    
  do
    if [[ $1 = *${2:0:$((${#2}-$pom_iter))}* ]]
      then
        return 0
    fi  
    ((pom_iter++))
done  
#echo "po druhe podmince" 
while read -d ' ' slozka
  do
    pom_array[${#pom_array[@]}]="$slozka"
done < <(echo "$2 ")  

if [ ${#pom_array[@]} -gt 1 ]
  then
    pom_iter=0
    local str=""
    while [ $pom_iter -lt ${#pom_array[@]} ]
      do
        str=$str${pom_array[$pom_iter]:0:1}
        ((pom_iter++))
    done  
    #echo "str je $str"
    if [[ $1 = *$str* ]]
      then
        unset pom_array
        return 0
    fi    
fi
unset pom_array
return 1
}





if [ $# -ne 2 ]
  then 
    echo "Usage $0 \"title\" \"main actor/actress\""
    exit 1
fi

vstupni_file="azlea.html"
enc_title=$(printf %s "$1"|jq -sRr @uri)
enc_actor=$(printf %s "$2"|jq -sRr @uri)

title_plused=$(echo "$1" | sed 's/ /+/g' )
actor_plused=$(echo "$2" | sed 's/ /+/g' )


google_url="https://www.google.com/search?q="
url_for_gsearch="$google_url$actor_plused+%22$title_plused%22+download"

uloz_to_url="https://uloz.to/hledej?q="
title_ulozto=$(echo "$1" | sed 's/ /%20/g')
url_for_ulozto="$uloz_to_url$title_ulozto"

pornfile_url="https://pornfile.cz/hledej?q="
title_pornfile=$(echo "$1 $2" | sed 's/ /%20/g')
url_for_pornfile="$pornfile_url$title_pornfile"

fastshare_url="https://fastshare.cz/"
title_fastshare=$(echo "$1" | iconv -f utf-8 -t ascii//TRANSLIT | sed 's/ /-/g')
url_for_fastshare="$fastshare_url$title_fastshare/s"

datoid_url="https://datoid.cz/s/"
url_for_datoid="$datoid_url$title_fastshare"

webshare_url="https://webshare.cz/#/search?what="

sdilej_url="https://sdilej.cz/"
url_for_sdilej="$sdilej_url$title_fastshare/s"
#echo "$url_for_gsearch"
#echo $url_for_ulozto
rm "download_lnks.txt" 2>/dev/null

echo -ne "Checking uloz.to\r"
./ulozto.sh "$url_for_ulozto" >/dev/null

title_ascii=$(echo "$1" | iconv -f utf-8 -t ascii//TRANSLIT | tr '[:upper:]' '[:lower:]')
actor_ascii=$(echo "$2" | iconv -f utf-8 -t ascii//TRANSLIT | tr '[:upper:]' '[:lower:]')

echo -ne "Checking pornfile.cz        \r"
./vidcrawler13.sh "$url_for_pornfile" "$title_ascii" 4 > /dev/null


echo -ne "Checking datoid.cz          \r"
./vidcrawler13.sh "$url_for_datoid" "$title_ascii" 4 > /dev/null

echo -ne "Checking webshare.cz        \r"
./vidcrawler13.sh "$webshare_url" "$title_ascii $actor_ascii" 4 > /dev/null

echo -ne "Checking sdilej.cz        \r"
./vidcrawler13.sh "$url_for_sdilej" "$title_ascii" 4 > /dev/null

echo -ne "Checking fastshare.cz        \r"
./vidcrawler13.sh "$url_for_fastshare" "$title_ascii" 4 > /dev/null

echo -ne "Getting urls from google        \r"
./googlesearch4.sh "$url_for_gsearch" "$title_ascii" 


if [ -e for_analyzer.txt ]
then
while read url
  do
    
    domain=$(sed -E -e 's_.*://([^/@]*@)?([^/:]+).*_\2_' <<< "$url") #reseni ze stack overflow
    echo -ne "Analyzing $domain              \r"
    wget -nv -q --timeout=120 -O "$vstupni_file" "$url"
    if [ $? -ne 0 ]
     then
       curl -s -m 120 -o "$vstupni_file" -H "User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:93.0) Gecko/20100101 Firefox/93.0" "$url"
       if [ $? -ne 0 ]
         then
           echo "Stranku se nepovedlo nacist"         
           continue
       fi  
    fi   
    cat azlea.html | awk -v "url=$url" -v "hledany_str=$title_ascii" -v "limit=4" -v "domain=$domain" -f dlink_analyzer.awk > /dev/null 2>/dev/null
done < <(cat "for_analyzer.txt")  
fi  

#echo "Urls for analyzer:"
#cat "for_analyzer.txt"
echo
echo
echo
echo "Sites with direct download links:"
echo

IFS=$'\n'
RED='\033[0;31m'
NC='\033[0m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
if [ -e download_lnks.txt ]
then
while read line
  do
    if [[ $line = "For url"* ]]
      then 
               
        echo
        echo -e ${CYAN}$line${NC}
        echo
      else
        
        #zpracing filenamu
        titul_nalezen=1
        while read -d '/' part
          do
            : 
        done < <(echo "$line" | cut -d ' ' -f1)
        #echo "po cyklu je part $part"
        nalezen=1 
        for str_in_cycle in "${koncovky[@]}"
          do
            if [[ $part = *$str_in_cycle ]]
              then
                if [[ $part = *"-"* ]] || [[ $part = *"_"* ]] || [[ $part = *"%20"* ]] #nove 17.12.
                  then
                    nalezen=0
                    break
                fi    
            fi  
        done  
        if [ $nalezen -eq 0 ]
          then
      
           part=$(echo "$part" | tr '[:upper:]' '[:lower:]')
           title=$(echo "$1" | tr '[:upper:]' '[:lower:]')
           titul_in_str "$part" "$title"
           if [ $? -eq 0 ]
             then
               #echo "$line"
               titul_nalezen=0
           fi   
      #else
        #echo $line
        fi 
    #konec zpracing filenamu
    
    #zacatek zpracing hodnoty
    #while read part
    #  do
    #    : 
    #done < <(echo "$line" | cut -d '(' -f2)  
        part=$(echo "$line" | cut -d '(' -f2)  
    
        nalezen2=1 
        for str_in_cycle in "${koncovky[@]}"
          do
            if [[ $part = *$str_in_cycle* ]] 
              then
                nalezen2=0
                break
            fi  
        done  
        if [ $nalezen2 -eq 0 ]
          then
      
            part=$(echo "$part" | tr '[:upper:]' '[:lower:]')
            title=$(echo "$1" | tr '[:upper:]' '[:lower:]')
            titul_in_str "$part" "$title"
            if [ $? -eq 0 ]
              then
            #echo "$line"
                titul_nalezen=0
            fi   
      #else
        #echo $line
        fi 
    
        if [ $titul_nalezen -eq 0 ] || ([ $nalezen -eq 1 ] && [ $nalezen2 -eq 1 ]) #kdyz titul nalezen nebo koncovka nenalezena
          then
            #echo $line
            echo -e ${RED}$line${NC}
        fi  
        
        
        
        
    fi  
done < <(cat download_lnks.txt | awk '!seen[$0]++')
else
  echo "No urls found."
fi
echo
echo
echo
echo "Sites with embedded player (online streaming):"
echo
if [ -e players.txt ]
  then
    cat players.txt
  else
    echo "No urls found."  
fi    
echo
echo
echo
echo "Youtube alternative sites:"
echo
if [ -e youtube_alter.txt ]
  then
    cat youtube_alter.txt
  else
    echo "No urls found."
fi  
echo
echo
echo
echo "Paysites:"
echo
if [ -e paysites.txt ]
  then
    cat paysites.txt
  else
    echo "No urls found."  
fi    
echo
echo
echo
echo "Torrent sites:"
echo
if [ -e torrents.txt ]
  then
    cat torrents.txt
  else
    echo "No urls found."  
fi    
echo
echo
echo
echo "Another sites with potential download links (unsure)"
echo
if [ -e multiple_links.txt ]
  then
    cat multiple_links.txt
  else
    echo "No urls found."  
fi    
