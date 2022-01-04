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


PARAMS=""
html_output=1
while (( "$#" )); do
  case "$1" in
  #  -a|--my-boolean-flag)
  #    MY_FLAG=0
  #    shift
  #    ;;
    -o)
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        HTML_FILE=$2
        html_output=0
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    -*|--*=) # unsupported flags
      echo "Error: Unsupported flag $1" >&2
      exit 1
      ;;
    *) # preserve positional arguments
      PARAMS="$PARAMS \"$1\""
      shift
      ;;
  esac
done
 #set positional arguments in their proper place
eval set -- "$PARAMS"



if [ $# -ne 2 ]
  then 
    echo "Usage $0 [-o filename] \"title\" \"main actor/actress\""
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


vystup_forum="for_analyzer.txt"
vystup_download_lnks="for_analyzer.txt"
vystup_youtube="youtube_alter.txt"
vystup_player="players.txt"
vystup_torrent="torrents.txt"
vystup_paysite="paysites.txt"
vystup_multiple="multiple_links.txt"
vystup_titulky="subtitle_sites.txt"
scraper_file="for_scraper.txt"
google_links_file="google_links.txt"

rm $vystup_forum 2>/dev/null
rm $vystup_download_lnks 2>/dev/null
rm $vystup_youtube 2>/dev/null
rm $vystup_player 2>/dev/null
rm $vystup_torrent 2>/dev/null
rm $vystup_paysite 2>/dev/null
rm $vystup_multiple 2>/dev/null
rm $vystup_titulky 2>/dev/null
rm $scraper_file 2>/dev/null



echo -ne "Checking uloz.to\r"
./ulozto.sh "$url_for_ulozto" >/dev/null

title_ascii=$(echo "$1" | iconv -f utf-8 -t ascii//TRANSLIT | tr '[:upper:]' '[:lower:]')
title_ascii_plused=$(echo "$title_ascii" | sed 's/ /+/g' )
actor_ascii=$(echo "$2" | iconv -f utf-8 -t ascii//TRANSLIT | tr '[:upper:]' '[:lower:]')
actor_ascii_plused=$(echo "$actor_ascii" | sed 's/ /+/g' )

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

echo -ne "Checking https://tavaz.xyz/        \r"
./blog_crawler.sh "https://tavaz.xyz/search/?category_slug=video&query=$title_ascii_plused+$actor_ascii_plused&language=&age=&author=" "$title_ascii" >/dev/null

echo -ne "Checking https://rmz.cr/search/        \r"
./blog_crawler.sh "https://rmz.cr/search/$title_ascii_plused" "$title_ascii" >/dev/null

echo -ne "Checking https://movieparadise.org/        \r"
./blog_crawler.sh "https://movieparadise.org/?s=$title_ascii_plused" "$title_ascii" >/dev/null

echo -ne "Checking https://dl4all.org/        \r"
./blog_crawler.sh "https://dl4all.org/index.php?do=search" "$title_ascii" >/dev/null

echo -ne "Checking https://filmsofts.com/        \r"
./blog_crawler.sh "https://filmsofts.com/search.php" "$title_ascii" >/dev/null

echo -ne "Checking https://www.warez-serbia.com        \r"
./blog_crawler.sh "https://www.warez-serbia.com" "$title_ascii" >/dev/null

echo -ne "Checking https://puzo.org        \r"
./googlesearch4.sh "${google_url}site%3Apuzo.org+$actor_plused+%22$title_plused%22" "$title_ascii" "$actor_ascii" > /dev/null

echo -ne "Checking https://filesmonster.net        \r"
./googlesearch4.sh "${google_url}site%3Afilesmonster.net+$actor_plused+%22$title_plused%22" "$title_ascii" "$actor_ascii" > /dev/null

echo -ne "Checking https://www.downduck.com        \r"
./googlesearch4.sh "${google_url}site%3Awww.downduck.com+$actor_plused+%22$title_plused%22" "$title_ascii" "$actor_ascii" > /dev/null

echo -ne "Checking https://www.avaxshare.com        \r"
./googlesearch4.sh "${google_url}site%3Awww.avaxshare.com+$actor_plused+%22$title_plused%22" "$title_ascii" "$actor_ascii" > /dev/null #tady by bylo lepsi reseni pres jejich advanced search, jestli to pujde



echo -ne "Getting urls from google                \r"
./googlesearch4.sh "$url_for_gsearch" "$title_ascii" "$actor_ascii"



if [ -e for_analyzer.txt ]
then
while read url
  do
    
    domain=$(sed -E -e 's_.*://([^/@]*@)?([^/:]+).*_\2_' <<< "$url") #reseni ze stack overflow
    echo -ne "Analyzing $domain              \r"
    wget --header="User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:93.0) Gecko/20100101 Firefox/93.0" -nv -q --timeout=120 -O "$vstupni_file" "$url"
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
           #title=$(echo "$1" | tr '[:upper:]' '[:lower:]')
           titul_in_str "$part" "$title_ascii"
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
            #title=$(echo "$1" | tr '[:upper:]' '[:lower:]')
            titul_in_str "$part" "$title_ascii"
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

if [ $html_output = 0 ]
  then
    echo "<html>" > $HTML_FILE
    echo "<head>" >> $HTML_FILE
    echo "<style> li a{color:red} h2 {margin-top:40px} </style>" >> $HTML_FILE
    echo "<title>Results of $1 (starring $2) search:</title>" >> $HTML_FILE
    echo "</head>" >> $HTML_FILE
    echo "<body>" >> $HTML_FILE
    echo "<h1>Results of $1 (starring $2) search </h1>" >> $HTML_FILE
    echo "<h2>Sites with direct download links:</h2>" >> $HTML_FILE
    echo "<span style=\"color:blue\">blue color</span> - sites where download links were found<br>" >> $HTML_FILE
    echo "<span style=\"color:red\">red color</span> - found download links<br>" >> $HTML_FILE
    echo "<ol>" >> $HTML_FILE
    if [ -e download_lnks.txt ]
    then
    while read line
    do
    if [[ $line = "For url"* ]]
      then 
               
        echo "</ol>" >> $HTML_FILE
        echo "<a href=\"${line:8:$((${#line}-8))}\">${line:8:$((${#line}-8))}</a>" >> $HTML_FILE
        echo "<ol>" >> $HTML_FILE
      else
        
        #zpracing filenamu
        title=$(echo "$1" | iconv -f utf-8 -t ascii//TRANSLIT  | tr '[:upper:]' '[:lower:]')
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
                if [[ $part = *"-"* ]] || [[ $part = *"_"* ]] || [[ $part = *"%20"* ]] || [[ ! $title = *" "* ]] #nove 4.1.
                  then
                    nalezen=0
                    break
                fi    
            fi  
        done  
        if [ $nalezen -eq 0 ]
          then
      
           part=$(echo "$part" | tr '[:upper:]' '[:lower:]')
           #title=$(echo "$1" | tr '[:upper:]' '[:lower:]')
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
            #title=$(echo "$1" | tr '[:upper:]' '[:lower:]')
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
            odkaz=$(echo "$line" | cut -d "(" -f1)
            if [[ $part = ")" ]] || [[ $part = " )" ]] #part ted obsahuje hodnotovou cast odkazu v zavorkach
              then
                part="link has no value"
            fi  
            if [[ ! $odkaz = "" ]]
               then
                 echo "<li><a href=\"$odkaz\">${part%)}</a></li>" >> $HTML_FILE
            fi     
        fi  
        
        
        
        
    fi  
    done < <(cat download_lnks.txt | awk '!seen[$0]++')
    else #if download_lnks does not exist
      echo "No sites with direct download links found." >> $HTML_FILE
    fi
    
    echo "</ol>" >> $HTML_FILE
    echo "<h2>Sites with embedded player (online streaming):</h2>" >> $HTML_FILE
    if [ -e players.txt ]
      then
        
        while read line
          do
            echo "<a href=\"$line\">$line</a><br>" >> $HTML_FILE
        done <players.txt
      else 
        echo "<p>No sites of that type found.</p>" >> $HTML_FILE
    fi    
    
    echo "<h2>Youtube alternative sites:</h2>" >> $HTML_FILE
    if [ -e youtube_alter.txt ]
      then
        
        while read line
          do
            echo "<a href=\"$line\">$line</a><br>" >> $HTML_FILE
        done <youtube_alter.txt
      else 
        echo "<p>No sites of that type found.</p>" >> $HTML_FILE
    fi    
    
    echo "<h2>Paysites:</h2>" >> $HTML_FILE
    if [ -e paysites.txt ]
      then
        
        while read line
          do
            echo "<a href=\"$line\">$line</a><br>" >> $HTML_FILE
        done <paysites.txt
      else 
        echo "<p>No sites of that type found.</p>" >> $HTML_FILE
    fi    
    
    
    echo "<h2>Torrent sites:</h2>" >> $HTML_FILE
    if [ -e torrents.txt ]
      then
        
        while read line
          do
            echo "<a href=\"$line\">$line</a><br>" >> $HTML_FILE
        done <torrents.txt
      else 
        echo "<p>No sites of that type found.</p>" >> $HTML_FILE
    fi    
    
    echo "<h2>Another sites with potential download links (unsure):</h2>" >> $HTML_FILE
    if [ -e multiple_links.txt ]
      then
        
        while read line
          do
            echo "<a href=\"$line\">$line</a><br>" >> $HTML_FILE
        done <multiple_links.txt
      else 
        echo "<p>No sites of that type found.</p>" >> $HTML_FILE
    fi    
    
    echo "</body>" >> $HTML_FILE
    echo "</html>" >> $HTML_FILE
fi  
 
