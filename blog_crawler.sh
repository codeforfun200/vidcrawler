
# $1 je odkaz pro pridani
add_url_to_go(){
            local pom_url_cnt=0
            local url_nalezen=1 #false
            while [ $pom_url_cnt -lt ${#url_to_go[@]} ]
              do
                if [[ ${url_to_go[$pom_url_cnt]} = $1 ]]
                  then
                     url_nalezen=0 #true
                fi     
                ((pom_url_cnt++))
            done
            if [ $url_nalezen -eq 1 ]
              then
                url_to_go[${#url_to_go[@]}]="$1"
                ((url_to_go_cnt++))
            fi


}


vstupni_file="azlea.html"
domain=$(sed -E -e 's_.*://([^/@]*@)?([^/:]+).*_\2_' <<< "$1") #reseni ze stack overflow

if [[ $1 = *tavaz.xyz* ]]
  then 
    curl -s -m 120 -L -o "azlea.html" -H "User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:93.0) Gecko/20100101 Firefox/93.0" "$1" #https://tavaz.xyz/search/?category_slug=&query=zombie+strippers&language=&age=&author=
    if [ $? -ne 0 ]
      then
        echo "curl failed"
        exit
    fi
elif [[ $1 = *rmz.cr* ]]
  then
  curl -s -m 120 -L -o "azlea.html" -c "cookies.txt" -H "User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:93.0) Gecko/20100101 Firefox/93.0" "https://rmz.cr"
  if [ $? -ne 0 ]
      then
        echo "curl failed"
        exit
  fi
  title_plused=$(echo "$2" | sed 's/ /+/g')
  Content_Length=$((27+${#title_plused}))
  #echo $Content_Length
    curl -s -m 120 -L -o "azlea.html" -c "cookies.txt" -b "cookies.txt" -H "User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:93.0) Gecko/20100101 Firefox/93.0" -H "Content-Type: application/x-www-form-urlencoded" -H "Content-Length: $Content_Length" -d "search=$title_plused" -d "option=query" -d "mode=b" "$1" #https://rmz.cr/search/apocalypse+now
    if [ $? -ne 0 ]
      then
        echo "curl failed"
        exit
    fi
elif [[ $1 = *movieparadise.org* ]]
  then
    curl -s -m 120 -L -o "azlea.html" -H "User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:93.0) Gecko/20100101 Firefox/93.0" "$1" #https://movieparadise.org/?s=the+godfather
    if [ $? -ne 0 ]
      then
        echo "curl failed"
        exit
    fi
elif [[ $1 = *warez-serbia* ]]  
  then
    #exit #bude nutne resit specielne
    title_plused=$(echo "$2" | sed 's/ /+/g')
    Content_Length=$((45+${#title_plused}))
    curl -s -m 120 -L -o "azlea.html" -c "cookies.txt" -b "cookies.txt" -H "User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:93.0) Gecko/20100101 Firefox/93.0" -H "Content-Type: application/x-www-form-urlencoded" -H "Content-Length: $Content_Length" -d "do=search" -d "subaction=search" -d "titleonly=3" -d "story=$title_plused" "$1"
    if [ $? -ne 0 ]
      then
        echo "curl failed"
        exit
    fi
elif [[ $1 = *dl4all.org* ]]
  then
    title_plused=$(echo "$2" | sed 's/ /+/g')
    Content_Length=$((207+${#title_plused}))
    curl -s -m 120 -L -o "azlea.html" -c "cookies.txt" -b "cookies.txt" -H "User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:93.0) Gecko/20100101 Firefox/93.0" -H "Content-Type: application/x-www-form-urlencoded" -H "Content-Length: $Content_Length" -d "do=search" -d "subaction=search" -d "search_start=0" -d "full_search=1" -d "result_from=1" -d "story=$title_plused" -d "titleonly=0" -d "searchuser=" -d "replyless=0" -d "replylimit=0" -d "searchdate=0" -d "beforeafter=after" -d "sortby=" -d "resorder=desc" -d "showposts=0" -d "catlist%5B%5D=17" "$1"
    if [ $? -ne 0 ]
      then
        echo "curl failed"
        exit
    fi
elif [[ $1 = *warezheaven* ]]
  then
    exit #najde rapidgator hned na vyhledavaci strance, cloud flare
    title_plused=$(echo "$2" | sed 's/ /+/g')
    Content_Length=$((228+${#title_plused}))
    curl -s -m 120 -L -o "azlea.html" -c "cookies.txt" -b "cookies.txt" -H "User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:93.0) Gecko/20100101 Firefox/93.0" -H "Content-Type: application/x-www-form-urlencoded" -H "Content-Length: $Content_Length" -d "do=search" -d "subaction=search" -d "search_start=0" -d "full_search=1" -d "result_from=1" -d "story=$title_plused" -d "titleonly=0" -d "searchuser=" -d "replyless=0" -d "replylimit=0" -d "searchdate=0" -d "beforeafter=after" -d "sortby=date" -d "resorder=desc" -d "showposts=0" -d "catlist%5B%5D=10" -d "catlist%5B%5D=11" "$1"
    if [ $? -ne 0 ]
      then
        echo "curl failed"
        exit
    fi
elif [[ $1 = *filmsofts* ]]
  then
    
    title_plused=$(echo "$2" | sed 's/ /+/g')
    Content_Length=$((228+${#title_plused}))
    curl -s -m 120 -L -o "azlea.html" -c "cookies.txt" -b "cookies.txt" -H "User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:93.0) Gecko/20100101 Firefox/93.0" "https://filmsofts.com/search.php?action=do_search&keywords=$title_plused&postthread=1&forums%5B%5D=5" "$1"
    if [ $? -ne 0 ]
      then
        echo "curl failed"
        exit
    fi
    
    new_url=$(cat azlea.html | grep "http-equiv=\"refresh\""| cut -d " " -f3 | sed 's/&amp;/\&/g' | cut -d ";" -f2 | cut -d "?" -f2)
    curl -s -m 120 -L -o "azlea.html" -c "cookies.txt" -b "cookies.txt" -H "User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:93.0) Gecko/20100101 Firefox/93.0" "https://filmsofts.com/search.php?$new_url"    
    if [ $? -ne 0 ]
      then
        echo "curl failed"
        exit
    fi
    
fi  


scraper_file="blog_crawler.txt"
rm $scraper_file 2>/dev/null
pom_url_cnt=0
start=0
#echo " posledni url je $url_effective"
while [ $pom_url_cnt -lt ${#url_to_go[@]} ] || [ $start -eq 0 ]
  do
    if [ $start -eq 1 ]
      then
        domain=$(sed -E -e 's_.*://([^/@]*@)?([^/:]+).*_\2_' <<< "${url_to_go[$pom_url_cnt]}") #reseni ze stack overflow
        curl -s -m 120 -L -o "azlea.html" -b "cookies.txt" -H "User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:93.0) Gecko/20100101 Firefox/93.0" "${url_to_go[$pom_url_cnt]}"
    fi 
    if [ $start -eq 1 ]
      then
        cat "$vstupni_file" | iconv -f utf-8 -t ascii//TRANSLIT | awk -v "start=$start" -v "domain=$domain" -v "hledany_str=$2" -v "url=${url_to_go[$pom_url_cnt]}" -f blog_parser.awk >/dev/null 2>/dev/null
      else
        cat "$vstupni_file" | iconv -f utf-8 -t ascii//TRANSLIT | awk -v "start=$start" -v "domain=$domain" -v "hledany_str=$2" -v "url=$1" -f blog_parser.awk >/dev/null 2>/dev/null  
    fi
    #awk skript muze zapsat nove url do souboru scraper file
    if [ -e $scraper_file ]
      then
        while read url
          do
            url=$(echo "$url" | sed 's/&amp;/\&/g'  )
            add_url_to_go "$url"
        done < $scraper_file  
    fi
    if [ $start -eq 1 ]
      then
        ((pom_url_cnt++))
    fi   
    start=1
done    
