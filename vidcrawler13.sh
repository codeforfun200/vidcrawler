#!/bin/bash

source tree_funcs2.sh
source array_lists.sh



#$1 je current node
#$2 tag ktery se hleda

find_child_tag(){
curr_node=$1
curr_depth=1

#pom_cnt[$curr_depth]=$(child_count $curr_node) #zmena 13.12.
pom_cnt[$curr_depth]=${tree_child_cnt[$curr_node]}
local j=1
curr_iter[$curr_depth]=$j
while [ 1 -eq 1 ]
do
  if [ $j -le ${pom_cnt[$curr_depth]} ]
    then
      #echo "${tree_tag[$curr_node]} pom cnt je ${pom_cnt[$curr_depth]} depth je $curr_depth"
      child_ind=$(get_next_node_leftorder2 $curr_node $j)
      #tree_depth[$child_ind]=$curr_depth
      if [[ ${tree_tag[$child_ind]} = *$2* ]] #mozna jsou nutne uvozovky
        then
           echo $child_ind
           return
      fi  
      #echo "child je ${tree_tag[$child_ind]} j je $j "
      #echo "${tree_tag[$child_ind]}"
      
      pom_cnt_next_lev=${tree_child_cnt[$child_ind]} #$(child_count $child_ind) #zmena 13.12.
      if [ $pom_cnt_next_lev -gt 0 ]
        then
         #echo "zanořuje se"
         curr_node=$child_ind
         curr_iter[$curr_depth]=$(($j+1))
         ((curr_depth++))
         pom_cnt[$curr_depth]=$pom_cnt_next_lev
         j=1
         curr_iter[$curr_depth]=1
         continue
      fi
  fi
  
  
  
  if [ $j -ge ${pom_cnt[$curr_depth]} ]
    then
      #echo "vynořuje se"
      if [ $curr_depth -eq 1 ]
        then
          break
      fi  
      #get_parent_node $curr_node  #zmena 13.12. # fce uz nastavuje curr_node
      curr_node=${tree_parent[$curr_node]}
      
      ((curr_depth--))
      j=${curr_iter[$curr_depth]}
      continue
  fi  
  
  ((j++))    
  curr_iter[$curr_depth]=$j
  
  
  
  
  #
done
echo "" #nic nenasel

}


#$1 je current node
#$2 tag ktery se hleda

find_child_tag_all(){
local str=""
local child_ind_cnt=1
curr_node=$1
curr_depth=1

#pom_cnt[$curr_depth]=$(child_count $curr_node) #zmena 13.12.
pom_cnt[$curr_depth]=${tree_child_cnt[$curr_node]}
local j=1
curr_iter[$curr_depth]=$j
while [ 1 -eq 1 ]
do
  if [ $j -le ${pom_cnt[$curr_depth]} ]
    then
      #echo "${tree_tag[$curr_node]} pom cnt je ${pom_cnt[$curr_depth]} depth je $curr_depth"
      child_ind=$(get_next_node_leftorder2 $curr_node $j)
      #tree_depth[$child_ind]=$curr_depth
      if [[ ${tree_tag[$child_ind]} = *$2* ]] #mozna jsou nutne uvozovky
        then
          if [ $child_ind_cnt -eq 1 ]
            then
              str="$child_ind"
            else 
              str="$str $child_ind"
          fi
          ((child_ind_cnt++))
      fi  
      #echo "child je ${tree_tag[$child_ind]} j je $j "
      #echo "${tree_tag[$child_ind]}"
      
      pom_cnt_next_lev=${tree_child_cnt[$child_ind]} #$(child_count $child_ind) #zmena 13.12.
      if [ $pom_cnt_next_lev -gt 0 ]
        then
         #echo "zanořuje se"
         curr_node=$child_ind
         curr_iter[$curr_depth]=$(($j+1))
         ((curr_depth++))
         pom_cnt[$curr_depth]=$pom_cnt_next_lev
         j=1
         curr_iter[$curr_depth]=1
         continue
      fi
  fi
  
  
  
  if [ $j -ge ${pom_cnt[$curr_depth]} ]
    then
      #echo "vynořuje se"
      if [ $curr_depth -eq 1 ]
        then
          break
      fi  
      #get_parent_node $curr_node  #zmena 13.12. # fce uz nastavuje curr_node
      curr_node=${tree_parent[$curr_node]}
      
      ((curr_depth--))
      j=${curr_iter[$curr_depth]}
      continue
  fi  
  
  ((j++))    
  curr_iter[$curr_depth]=$j
  
  
  
  
  #
done
if [ $child_ind_cnt -eq 1 ] 
  then 
    echo "" #nic nenasel
  else 
    echo "$str "
fi      

}







# print a list of all html tags




xmlgetnext () {
local IFS='>'
read -d '<' TAG VALUE
}


#zacatek main body
if [ $# -ne 3 ]
  then
    echo "Usage $0 url movie depth"
    exit 1
fi  

time_zac_programu=$(date +%s)
#asi vymenit za nahodny filename
vstupni_file="azlea.html"
vystupni_file="download_lnks.txt"


#echo >> $vystupni_file
#echo "For url $1" >> $vystupni_file
#echo >> $vystupni_file

for word in "${search_in[@]}"    
  do
    search_in_pom[${#search_in_pom[@]}]=$(echo "$word" | sed 's/\.//g' | sed 's/^[0-9]//g' | sed 's/-//g')
    
done

for word in "${koncovky[@]}"    
  do
    koncovky_pom[${#koncovky_pom[@]}]=$(echo "$word" | sed 's/\.//g' | sed 's/^[0-9]//g' )
    
done

for word in "${koncovky[@]}"    
  do
    koncovky_pom2[${#koncovky_pom2[@]}]=$(echo "${word}2" | sed 's/\.//g' | sed 's/^[0-9]//g' )
    
done


is_ulozto_type=1 #false
domain=$(sed -E -e 's_.*://([^/@]*@)?([^/:]+).*_\2_' <<< "$1") #reseni ze stack overflow
if [[ $1 = *filesmonster.net* ]]
  then
  is_ulozto_type=0 #true
   curl -s -m 120 -L -c "cookies.txt" -o "$vstupni_file" -H "Host: $domain" -H "User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:93.0) Gecko/20100101 Firefox/93.0" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8" -H "Accept-Language: cs,sk;q=0.8,en-US;q=0.5,en;q=0.3" -H "Content-Type: application/x-www-form-urlencoded" -H "Content-Length: 91" -H "Origin: https://$domain" -H "Connection: keep-alive" -H "Referer: https://$domain/" -H "Upgrade-Insecure-Requests: 1" -H "Sec-Fetch-Dest: document" -H "Sec-Fetch-Mode: navigate" -H "Sec-Fetch-Site: same-origin" -H "Sec-Fetch-User: ?1" "https://filesmonster.net"
   
   if [ $? -ne 0 ]
         then
           echo "curl failed            "         
           exit 1
   fi  
  
   curl -s -m 120 -L -c "cookies.txt" -b "cookies.txt" -o "$vstupni_file" -H "Host: $domain" -H "User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:93.0) Gecko/20100101 Firefox/93.0" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8" -H "Accept-Language: cs,sk;q=0.8,en-US;q=0.5,en;q=0.3" -H "Content-Type: application/x-www-form-urlencoded" -H "Content-Length: 87" -H "Origin: https://$domain" -H "Connection: keep-alive" -H "Referer: https://$domain/" -H "Upgrade-Insecure-Requests: 1" -H "Sec-Fetch-Dest: document" -H "Sec-Fetch-Mode: navigate" -H "Sec-Fetch-Site: same-origin" -H "Sec-Fetch-User: ?1" -d "keywords=godfather" -d "c%5Busers%5D=" -d "_xfToken=1640202399%2C58f1d87d76bac8de571b67c75e92d1bb" "https://filesmonster.net/search/search"
   
   if [ $? -ne 0 ]
         then
           echo "curl failed            "         
           exit 1
   fi  

  # curl -v -L -b "cookies.txt" -o "$vstupni_file" -H "Host: $domain" -H "User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:93.0) Gecko/20100101 Firefox/93.0" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8" -H "Accept-Language: cs,sk;q=0.8,en-US;q=0.5,en;q=0.3" -H "Content-Type: application/x-www-form-urlencoded" -H "Content-Length: 46" -H "Origin: https://$domain" -H "Connection: keep-alive" -H "Referer: https://$domain/" -H "Upgrade-Insecure-Requests: 1" -H "Sec-Fetch-Dest: document" -H "Sec-Fetch-Mode: navigate" -H "Sec-Fetch-Site: same-origin" -H "Sec-Fetch-User: ?1" -d "agree=Souhlas%C3%ADm" -d "_do=pornDisclaimer-submit" "$1"
   
#curl -v -L -b "cookies.txt" -o "$vstupni_file" -H "Host: $domain" -H "User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:93.0) Gecko/20100101 Firefox/93.0" -H "Accept: application/json, text/javascript, */*; q=0.01" -H "Accept-Language: cs,sk;q=0.8,en-US;q=0.5,en;q=0.3" -H "X-Requested-With: XMLHttpRequest" -H "Connection: keep-alive" -H "Referer: $1" -H "Upgrade-Insecure-Requests: 1" -H "Sec-Fetch-Dest: empty" -H "Sec-Fetch-Mode: cors" -H "Sec-Fetch-Site: same-origin" -H "Sec-Fetch-User: ?1" "$1"   
elif [[ $1 = *pornfile.cz* ]] || [[ $1 = *datoid.cz* ]]  # ve filesmonster najde spatne vysledky pro viceslovne nazvy, jsou oddeleny zvlast v tagach em
 then
 is_ulozto_type=0 #true
   curl -s -m 120 -L -c "cookies.txt" -o "$vstupni_file" -H "Host: $domain" -H "User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:93.0) Gecko/20100101 Firefox/93.0" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8" -H "Accept-Language: cs,sk;q=0.8,en-US;q=0.5,en;q=0.3" -H "Content-Type: application/x-www-form-urlencoded" -H "Content-Length: 46" -H "Origin: https://$domain" -H "Connection: keep-alive" -H "Referer: https://$domain/" -H "Upgrade-Insecure-Requests: 1" -H "Sec-Fetch-Dest: document" -H "Sec-Fetch-Mode: navigate" -H "Sec-Fetch-Site: same-origin" -H "Sec-Fetch-User: ?1" -d "agree=Souhlas%C3%ADm" -d "_do=pornDisclaimer-submit" "https://pornfile.cz/porn-disclaimer/?back=%2F"
   
   if [ $? -ne 0 ]
         then
           echo "Stranku se nepovedlo nacist"         
           exit 1
   fi  

   curl -s -m 120 -L -b "cookies.txt" -o "$vstupni_file" -H "Host: $domain" -H "User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:93.0) Gecko/20100101 Firefox/93.0" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8" -H "Accept-Language: cs,sk;q=0.8,en-US;q=0.5,en;q=0.3" -H "Content-Type: application/x-www-form-urlencoded" -H "Content-Length: 46" -H "Origin: https://$domain" -H "Connection: keep-alive" -H "Referer: https://$domain/" -H "Upgrade-Insecure-Requests: 1" -H "Sec-Fetch-Dest: document" -H "Sec-Fetch-Mode: navigate" -H "Sec-Fetch-Site: same-origin" -H "Sec-Fetch-User: ?1" -d "agree=Souhlas%C3%ADm" -d "_do=pornDisclaimer-submit" "$1"
   
   if [ $? -ne 0 ]
         then
           echo "Stranku se nepovedlo nacist"         
           exit 1
   fi  
   
curl -s -m 120 -L -b "cookies.txt" -o "$vstupni_file" -H "Host: $domain" -H "User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:93.0) Gecko/20100101 Firefox/93.0" -H "Accept: application/json, text/javascript, */*; q=0.01" -H "Accept-Language: cs,sk;q=0.8,en-US;q=0.5,en;q=0.3" -H "X-Requested-With: XMLHttpRequest" -H "Connection: keep-alive" -H "Referer: $1" -H "Upgrade-Insecure-Requests: 1" -H "Sec-Fetch-Dest: empty" -H "Sec-Fetch-Mode: cors" -H "Sec-Fetch-Site: same-origin" -H "Sec-Fetch-User: ?1" "$1"   
  if [ $? -ne 0 ]
         then
           echo "Stranku se nepovedlo nacist"         
           exit 1
  fi  
 elif [[ $1 = *webshare.cz* ]] #na tomto serveru najde jen text uvnitr tagu name #mezi slovy ve what maji asi byt plusy
   then
   is_ulozto_type=0 #true
   what=$(echo "$2" | sed 's/ /+/g')
   what_len=${#what}
   content_length=$((44+$what_len))
      curl -s -m 120 -L -c "cookies.txt" -o "$vstupni_file" -H "Host: $domain" -H "User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:93.0) Gecko/20100101 Firefox/93.0" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8" -H "Accept-Language: cs,sk;q=0.8,en-US;q=0.5,en;q=0.3" -H "Content-Type: application/x-www-form-urlencoded" -H "Content-Length: 46" -H "Origin: https://$domain" -H "Connection: keep-alive" -H "Referer: https://$domain/" -H "Upgrade-Insecure-Requests: 1" -H "Sec-Fetch-Dest: document" -H "Sec-Fetch-Mode: navigate" -H "Sec-Fetch-Site: same-origin" -H "Sec-Fetch-User: ?1" -d "agree=Souhlas%C3%ADm" -d "_do=pornDisclaimer-submit" "$1"
      
      if [ $? -ne 0 ]
         then
           echo "curl failed            "         
           exit 1
   fi  

   curl -s -m 120 -L -b "cookies.txt" -o "$vstupni_file" -H "Host: $domain" -H "User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:93.0) Gecko/20100101 Firefox/93.0" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8" -H "Accept-Language: cs,sk;q=0.8,en-US;q=0.5,en;q=0.3" -H "Content-Type: application/x-www-form-urlencoded" -H "Content-Length: 46" -H "Origin: https://$domain" -H "Connection: keep-alive" -H "Referer: https://$domain/" -H "Upgrade-Insecure-Requests: 1" -H "Sec-Fetch-Dest: document" -H "Sec-Fetch-Mode: navigate" -H "Sec-Fetch-Site: same-origin" -H "Sec-Fetch-User: ?1" -d "agree=Souhlas%C3%ADm" -d "_do=pornDisclaimer-submit" "$1"
   
   if [ $? -ne 0 ]
         then
           echo "curl failed            "         
           exit 1
   fi  
   
   curl -s -m 120 -L -b "cookies.txt" -o "$vstupni_file" -H "Host: $domain" -H "User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:93.0) Gecko/20100101 Firefox/93.0" -H "Accept: text/xml; charset=UTF-8" -H "Accept-Language: cs,sk;q=0.8,en-US;q=0.5,en;q=0.3" -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" -H "X-Requested-With: XMLHttpRequest" -H "Content-Length: $content_length" -H "Origin: https://$domain" -H "Connection: keep-alive" -H "Referer: $domain/" -H "Sec-Fetch-Dest: empty" -H "Sec-Fetch-Mode: cors" -H "Sec-Fetch-Site: same-origin" -d "what=$what" -d "category=" -d "sort=" -d "offset=0" -d "limit=25" -d "wst=" "https://$domain/api/search/"  
   if [ $? -ne 0 ]
         then
           echo "curl failed            "         
           exit 1
   fi  
 elif [[ $1 = *sdilej.cz* ]] #zatim nedokazu zpracovat parametr pozadavku GET je videt ve scriptu hlavni stranky
   then
   #exit 1
   is_ulozto_type=0 #true
      curl -s -m 120 -L -c "cookies.txt" -o "$vstupni_file" -H "Host: $domain" -H "User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:93.0) Gecko/20100101 Firefox/93.0" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8" -H "Accept-Language: cs,sk;q=0.8,en-US;q=0.5,en;q=0.3" -H "Origin: https://$domain" -H "Connection: keep-alive" -H "Referer: https://$domain/" -H "Upgrade-Insecure-Requests: 1" -H "Sec-Fetch-Dest: document" -H "Sec-Fetch-Mode: navigate" -H "Sec-Fetch-Site: same-origin" -H "Sec-Fetch-User: ?1" "$1"
   if [ $? -ne 0 ]
         then
           echo "curl failed            "         
           exit 1
   fi  

result_url=$(cat "$vstupni_file" | grep "results\.php" | cut -d " " -f2 | cut -d "'" -f2)


   curl -s -m 120 -L -b "cookies.txt" -o "$vstupni_file" -H "Host: $domain" -H "User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:93.0) Gecko/20100101 Firefox/93.0" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8" -H "Accept-Language: cs,sk;q=0.8,en-US;q=0.5,en;q=0.3" -H "Origin: https://$domain" -H "Connection: keep-alive" -H "Referer: https://$domain/" -H "Upgrade-Insecure-Requests: 1" -H "Sec-Fetch-Dest: document" -H "Sec-Fetch-Mode: navigate" -H "Sec-Fetch-Site: same-origin" -H "Sec-Fetch-User: ?1" "https://sdilej.cz$result_url"
   
   if [ $? -ne 0 ]
         then
           echo "curl failed            "         
           exit 1
   fi  
   
 #  curl -v -L -b "cookies.txt" -o "$vstupni_file" -H "Host: $domain" -H "User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:93.0) Gecko/20100101 Firefox/93.0" -H "Accept: text/xml; charset=UTF-8" -H "Accept-Language: cs,sk;q=0.8,en-US;q=0.5,en;q=0.3" -H "Content-Type: application/x-www-form-urlencoded; charset=UTF-8" -H "X-Requested-With: XMLHttpRequest" -H "Content-Length: 65" -H "Origin: https://$domain" -H "Connection: keep-alive" -H "Referer: $domain/" -H "Sec-Fetch-Dest: empty" -H "Sec-Fetch-Mode: cors" -H "Sec-Fetch-Site: same-origin" "$1"
 elif [[ $1 = *fastshare.cz* ]]
   then
     is_ulozto_type=0 #true
      curl -s -m 120 -L -c "cookies.txt" -o "$vstupni_file" -H "Host: $domain" -H "User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:93.0) Gecko/20100101 Firefox/93.0" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8" -H "Accept-Language: cs,sk;q=0.8,en-US;q=0.5,en;q=0.3" -H "Origin: https://$domain" -H "Connection: keep-alive" -H "Referer: https://$domain/" -H "Upgrade-Insecure-Requests: 1" -H "Sec-Fetch-Dest: document" -H "Sec-Fetch-Mode: navigate" -H "Sec-Fetch-Site: same-origin" -H "Sec-Fetch-User: ?1" "$1"
      
   if [ $? -ne 0 ]
         then
           echo "curl failed            "         
           exit 1
   fi  

result_url=$(cat "$vstupni_file" | grep "test2\.php" | cut -d ":" -f2 | cut -d "," -f1 | head -1 | cut -d "=" -f6)
search_token=$(cat "$vstupni_file" | grep "id=\"search_token" | cut -d "=" -f4 | cut -d "\"" -f2)

   curl -s -m 120 -L -b "cookies.txt" -o "$vstupni_file" -H "Host: $domain" -H "User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:93.0) Gecko/20100101 Firefox/93.0" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8" -H "Accept-Language: cs,sk;q=0.8,en-US;q=0.5,en;q=0.3" -H "Origin: https://$domain" -H "Connection: keep-alive" -H "Referer: https://$domain/" -H "Upgrade-Insecure-Requests: 1" -H "Sec-Fetch-Dest: document" -H "Sec-Fetch-Mode: navigate" -H "Sec-Fetch-Site: same-origin" -H "Sec-Fetch-User: ?1" "https://fastshare.cz/test2.php?token=$search_token&type=all&term=$result_url&plain_search=0&limit=1&step=3"
   if [ $? -ne 0 ]
         then
           echo "curl failed            "         
           exit 1
   fi  
 else
   wget -nv --timeout=120 -O "$vstupni_file" "$1"
   if [ $? -ne 0 ]
     then
       curl -s -m 120 -o "$vstupni_file" -H "User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:93.0) Gecko/20100101 Firefox/93.0" "$1"
       if [ $? -ne 0 ]
         then
           echo "curl failed                "         
           exit 1
       fi  
   fi   
fi   
#to do testovat exit code wgetu







hledany_str="$2" #pozor na vice mezer mezi slovy osetrit
hledany_str=$(echo "$hledany_str" | tr '[:upper:]' '[:lower:]') #should also work with locale
hledany_str=$(echo "$hledany_str" | iconv -f utf-8 -t ascii//TRANSLIT )
link_nalezen=1 #false
#blok pro ulozto



if [ $is_ulozto_type -eq 0 ]
  then
    cat "$vstupni_file" | iconv -f utf-8 -t ascii//TRANSLIT | awk -v "domain=$domain" -v "url=$1" -v "hledany_str=$hledany_str"  -f pornfile_parser.awk >/dev/null 2>/dev/null
  
    
fi  

  



#konec bloku pro ulozto




