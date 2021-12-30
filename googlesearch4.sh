#!/bin/bash

source tree_funcs2.sh
source array_lists.sh



#$1 je current node
#$2 tag ktery se hleda

find_child_tag(){
curr_node=$1
curr_depth=1

#pom_cnt[$curr_depth]=$(child_count $curr_node) #zmena
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
      
      #pom_cnt_next_lev=$(child_count $child_ind) #zmena
      pom_cnt_next_lev=${tree_child_cnt[$child_ind]} 
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
      #get_parent_node $curr_node  # fce uz nastavuje curr_node #zmena
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






xmlgetnext () {
local IFS='>'
read -d '<' TAG VALUE
}

parse_to_tree(){
echo "zacatek parsingu"

parent_node=-1
is_in_script=1
is_in_comment=1
is_in_style=1
curr_node=0
while xmlgetnext 
  do 
    TAG_puv_case=$TAG
    VALUE_puv_case=$VALUE
    TAG=$(echo "$TAG" | tr '[:upper:]' '[:lower:]') #should also work with locale
    VALUE=$(echo "$VALUE" | tr '[:upper:]' '[:lower:]') #should also work with locale
    #echo "value je $VALUE tag je $TAG"
    if [ $is_in_comment -eq 1 ]
    then
      if [ $is_in_script -eq 0 ] 
        then
          if [[ $TAG = /script* ]]
            then
              is_in_script=1 #false
          fi    
          continue
      fi  
      if [[ $TAG = script* ]]
        then
          is_in_script=0  #true
          continue
      fi  
    fi
    
    if [ $is_in_comment -eq 1 ]
    then
      if [ $is_in_style -eq 0 ] 
        then
          if [[ $TAG = /style* ]]
           then
              is_in_style=1 #false
          fi    
          continue
      fi  
      if [[ $TAG = style* ]]
        then
          is_in_style=0  #true
          continue
      fi
    fi
    
    if [ $is_in_comment -eq 1 ]
    then
      if [[ $TAG = \!--*-- ]] || [[ $TAG = meta* ]] || [[ $TAG = link* ]] || [[ $TAG = \!doctype* ]] || [[ $TAG = br* ]] || [[ $TAG = img* ]] || [[ $TAG = hr* ]] || [[ $TAG = basefont* ]] || [[ $TAG = wbr* ]] || [[ $TAG = hr* ]] || [[ $TAG = area* ]] || [[ $TAG = col* ]] || [[ $TAG = colgroup* ]] || [[ $TAG = source* ]] || [[ $TAG = track* ]] || [[ $TAG = frame* ]] || [[ $TAG = param* ]] || [[ $TAG = input* ]] || [[ $TAG = option* ]] || [[ $TAG = /option* ]] || [[ $TAG = base* ]] || [[ $TAG = \!\[if* ]] || [[ $TAG = \[if* ]] #[[ $TAG = \!--\[if* ]]  #tag img jeste zapracovat, muze obsahovat cena data v popiscich
        then 
          tree_val[$curr_node]="${tree_val[$curr_node]}$VALUE" #toto je nove a snad to funguje spravne
          tree_val_puv_case[$curr_node]="${tree_val_puv_case[$curr_node]}$VALUE_puv_case"
          if [[ $TAG = img* ]]
            then
              imgs_array[${#imgs_array[@]}]="$TAG"
          fi  
          continue
      fi    
    fi
    
    if [ $is_in_comment -eq 0 ] #comment without tags inside them is handled above, this is for multiline comments which include tags
      then
        if [[ $VALUE = *--\>* ]] || [[ $TAG = *-- ]] || [[ $TAG = \!\[endif\]*-- ]] 
          then
            if [[ ! $TAG = \!--* ]]
              then
               is_in_comment=1 #false
            fi   
        fi    
        continue
    fi  
    if [[ $TAG = \!--* ]]
      then
        if [[ ! $VALUE = *--\>* ]]
          then
           is_in_comment=0  #true
        fi   
        continue
    fi  
    
    if [[ $TAG = \!\[endif\]*-- ]] 
      then
        continue 
    fi
    
    if [ $curr_node -eq -1 ]
      then
        echo "Neco je spatne. Vstupni soubor je mozna poskozeny. Vice uzaviracich tagu nez oteviracich."
        #i=0
        #while [ $i -lt $last_ind ]
        #do
        #  echo "index $i tag ${tree_tag[$i]} val ${tree_val[$i]}"
        #  ((i++))
        #done  
        #exit 1
        break
    fi  
    if [[ $TAG = /* ]] #koncovz tag
      then
        #get_parent_node $curr_node
        curr_node=${tree_parent[$curr_node]}
        tree_val[$curr_node]="${tree_val[$curr_node]}$VALUE" #toto je nove a snad to funguje spravne
        tree_val_puv_case[$curr_node]="${tree_val_puv_case[$curr_node]}$VALUE_puv_case"
        #curr_node=$?
      else
       if [ $last_ind -eq 0 ]
        then
          add_child_node $parent_node "$TAG" "$VALUE" "$TAG_puv_case" "$VALUE_puv_case"
          #curr_node=$?
        else
          parent_node=$curr_node
          #echo "parent node pred add child node je $parent_node"
          add_child_node $parent_node "$TAG" "$VALUE" "$TAG_puv_case" "$VALUE_puv_case"
          #curr_node=$?
      fi  
    fi  
    
done < "$vstupni_file"


if [ $last_ind -eq 0 ]
  then
    echo "strom je prazdny"
    return 1
fi  

if [ $last_ind -lt 5 ]
  then
    echo "strom je skoro prazdny"
    return 1
fi  


#zakomentovano 13.12.
#zacatek pre order pruchodu
#curr_node=0
#curr_depth=1
#max_tree_depth=0

#pom_cnt[$curr_depth]=$(child_count $curr_node)
#echo "prvni nastaveni pom cnt je ${pom_cnt[$curr_depth]}"
#j=1
#curr_iter[$curr_depth]=$j
#while [ 1 -eq 1 ]
#do
#  if [ $j -le ${pom_cnt[$curr_depth]} ]
#    then
#      #echo "${tree_tag[$curr_node]} pom cnt je ${pom_cnt[$curr_depth]} depth je $curr_depth"
#      child_ind=$(get_next_node_leftorder $curr_node $j)
#      tree_depth[$child_ind]=$curr_depth
#      if [ $max_tree_depth -lt $curr_depth ]
#        then
#          max_tree_depth=$curr_depth
#      fi  
#      #echo "child je ${tree_tag[$child_ind]} j je $j "
#      #echo "${tree_tag[$child_ind]}"
#      
#      pom_cnt_next_lev=$(child_count $child_ind)
#      if [ $pom_cnt_next_lev -gt 0 ]
#        then
#         #echo "zanořuje se"
#         curr_node=$child_ind
#         curr_iter[$curr_depth]=$(($j+1))
#         ((curr_depth++))
#         pom_cnt[$curr_depth]=$pom_cnt_next_lev
#         j=1
#         curr_iter[$curr_depth]=1
#         continue
#      fi
#  fi
  
  
  
#  if [ $j -ge ${pom_cnt[$curr_depth]} ]
#    then
#      #echo "vynořuje se"
#      if [ $curr_depth -eq 1 ]
#        then
#          break
#      fi  
#      get_parent_node $curr_node  # fce uz nastavuje curr_node
      
#      ((curr_depth--))
#      j=${curr_iter[$curr_depth]}
#      continue
#  fi  
  
#  ((j++))    
#  curr_iter[$curr_depth]=$j
  
  
  
  
  #
#done

#konec pre order pruchodu
return 0
} #konec fce parse_to_tree

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

#rm $vystup_forum 2>/dev/null
#rm $vystup_download_lnks 2>/dev/null
#rm $vystup_youtube 2>/dev/null
#rm $vystup_player 2>/dev/null
#rm $vystup_torrent 2>/dev/null
#rm $vystup_paysite 2>/dev/null
#rm $vystup_multiple 2>/dev/null
#rm $vystup_titulky 2>/dev/null
#rm $scraper_file 2>/dev/null

url_to_go_cnt=0
domain="www.google.com"
vstupni_file="google_pok.html"
url_to_load=$1
pruchod=1
nalezl=0

echo -ne "Getting urls from google\r"
while [ $nalezl -eq 0 ]
do

 curl -s -m 120 -L -c "cookies.txt" -o "$vstupni_file" -H "Host: $domain" -H "User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:93.0) Gecko/20100101 Firefox/93.0" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8" -H "Accept-Language: cs,sk;q=0.8,en-US;q=0.5,en;q=0.3" -H "Origin: https://$domain" -H "Connection: keep-alive" -H "Referer: https://$domain/" -H "Upgrade-Insecure-Requests: 1" -H "Sec-Fetch-Dest: document" -H "Sec-Fetch-Mode: navigate" -H "Sec-Fetch-Site: same-origin" -H "Sec-Fetch-User: ?1" "$url_to_load" 

if [ $? -ne 0 ]
      then
        echo "curl failed - connection to google failed"
        break
fi    

#parse_to_tree


#hledame odkazy z google search
rm $google_links_file 2>/dev/null
cat $vstupni_file | awk -f google_parser.awk > /dev/null 2>/dev/null

nalezl=1 #false
#pridat test na existenci google links file
if [ -e $google_links_file ]
  then
    while read google_link
      do
        nalezl=0
        google_link=$(echo "$google_link" | sed 's/&nbsp;/ /g; s/&amp;/\&/g; s/&lt;/\</g; s/&gt;/\>/g; s/&quot;/\"/g; s/#&#39;/\'"'"'/g; s/&ldquo;/\"/g; s/&rdquo;/\"/g;')
        add_url_to_go "$google_link"
    done < $google_links_file
fi    

pom_param=$(($pruchod*10))
url_to_load="$1&start=$pom_param"
#echo "url to load je $url_to_load"
((pruchod++))



done #konec vnejsiho while

#i=0
#cnt=0
#pom_str="\<div role\=\"navigation\""
#pom_str="\<td\>"
#while [ $i -lt ${#tree_tag[@]} ]
#  do
#    if [[ ${tree_tag[$i]} = $pom_str ]]
#      then
#        res=$(find_child_tag $i "<a")
#        if [[ ! $res = "" ]]
#          then
#            odkaz=$(echo "${tree_tag_puv_case[$res]}" | dos2unix | tr -d '\t\n' | awk '{i=1; while(i<=NF) {res=match($i,/^href=/);if(res != 0) break;i++}print $i}')
#            #echo "hledany odkaz je ${tree_tag[$res]}"
#            echo "odkaz z navigace je ${odkaz:6:$((${#odkaz}-7))}"  
#            ((cnt++))
#        fi  
#    fi  
#    ((i++))
#done  



#totalne nevyzkousene, ani bing parser!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
title_ascii_plused=$(echo "$2" | sed 's/ /+/g' )
actor_ascii_plused=$(echo "$3" | sed 's/ /+/g' )
domain="www.bing.com"
vstupni_file="google_pok.html"
url_to_load="https://www.bing.com/search?q=$actor_ascii_plused+%22$title_ascii_plused%22+download"
url_to_load_pom="https://www.bing.com/search?q=$actor_ascii_plused+%22$title_ascii_plused%22+download"
pruchod=1
nalezl=0
if [ ${#url_to_go[@]} -lt 5 ] && [[ ! $1 = *site%3A* ]]
then
while [ $nalezl -eq 0 ]
do

 curl -m 120 -s -L -c "cookies.txt" -b "cookies.txt" -o "$vstupni_file" -H "Host: $domain" -H "User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:93.0) Gecko/20100101 Firefox/93.0" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8" -H "Accept-Language: cs,sk;q=0.8,en-US;q=0.5,en;q=0.3" -H "Connection: keep-alive" -H "Upgrade-Insecure-Requests: 1" -H "Sec-Fetch-Dest: document" -H "Sec-Fetch-Mode: navigate" -H "Sec-Fetch-Site: none" -H "Sec-Fetch-User: ?1" "$url_to_load"

#-H "Origin: https://$domain" -H "Referer: https://$domain/"
if [ $? -ne 0 ]
      then
        echo "curl neuspel - pripojeni ke googlu selhalo"
        break
fi    

#parse_to_tree
#sleep 5 #to prevent google from knowing it is a script

#hledame odkazy z google search
rm $google_links_file 2>/dev/null
cat $vstupni_file | awk -f bing_parser.awk > /dev/null 2>/dev/null

nalezl=1 #false
#pridat test na existenci google links file
while read google_link
  do
    nalezl=0
    add_url_to_go "$google_link"
done < $google_links_file

pom_param=$((($pruchod*10)+1))
url_to_load="$url_to_load_pom&first=$pom_param"
#echo "url to load je $url_to_load"
((pruchod++))



done #konec vnejsiho while
fi








#echo "nalezeno $cnt navigacnich odkazu"
pom_url_cnt=0
while [ $pom_url_cnt -lt ${#url_to_go[@]} ]
  do
    #pom_url_str=${url_to_go[$pom_url_cnt]}
    #pom_url_str=${pom_url_str%\"}
    #url_to_go[$pom_url_cnt]=$pom_url_str
    domain=$(sed -E -e 's_.*://([^/@]*@)?([^/:]+).*_\2_' <<< "${url_to_go[$pom_url_cnt]}") #reseni ze stack overflow
    echo -ne "Checking $domain                                \r"  #${url_to_go[$pom_url_cnt]}\r"
    
    #zacatek kontroly whitelistu
    
    nalezen=1 #false
    for str_in_cycle in "${whitelist[@]}"
      do
                 
              if [[ ${url_to_go[$pom_url_cnt]} = *$str_in_cycle* ]]
                then
                  nalezen=0 #true
                  break
              fi    
        
    done
    if [ $nalezen -eq 0 ]
      then
        #echo "nalezen ve whitelistu"
        
        ((pom_url_cnt++))
        continue
    fi
    
    #konec kontroly whitelistu
    
    #kontrola torrentu v url zacatek
    
    if [[ ${url_to_go[$pom_url_cnt]} = *torrent* ]]
         then
            #echo "torrent site nalezena"
            echo ${url_to_go[$pom_url_cnt]} >> $vystup_torrent
            ((pom_url_cnt++))
            continue
    
    fi    
    
    #konec kontroly torrentu v url

    #detekce stazeni binarniho souboru
    
    if [[ ${url_to_go[$pom_url_cnt]} = https://*[/?]*.??? ]] || [[ ${url_to_go[$pom_url_cnt]} = https://*[/?]*.???? ]] || [[ ${url_to_go[$pom_url_cnt]} = http://*[/?]*.??? ]] || [[ ${url_to_go[$pom_url_cnt]} = http://*[/?]*.???? ]]
    then
      je_video_soubor=0
      for str_in_cycle in ".php" ".html"
        do
          if [[ ${url_to_go[$pom_url_cnt]} = *$str_in_cycle ]]
            then
              je_video_soubor=1
              break
          fi   
      done
    
      if [ $je_video_soubor -eq 0 ]
        then
          #echo "zamezeno stazeni jineho nez html souboru" 
          ((pom_url_cnt++))
          continue
      fi  
    fi
    #konec detekce stazeni binarniho souboru
    
    
    
    hlavicka=$(curl -s -m 120 -I -L -c "cookies.txt" -H "Host: $domain" -H "User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:93.0) Gecko/20100101 Firefox/93.0" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8" -H "Accept-Language: cs,sk;q=0.8,en-US;q=0.5,en;q=0.3" -H "Origin: https://$domain" -H "Connection: keep-alive" -H "Referer: https://$domain/" -H "Upgrade-Insecure-Requests: 1" -H "Sec-Fetch-Dest: document" -H "Sec-Fetch-Mode: navigate" -H "Sec-Fetch-Site: same-origin" -H "Sec-Fetch-User: ?1" "${url_to_go[$pom_url_cnt]}")
    
    if [ $? -ne 0 ]
      then
        echo "curl failed                   "
        ((pom_url_cnt++))
        continue
    fi    
    
    if [[ ! $hlavicka = *text/html* ]]
      then
        #echo "dokument je jineho typu nez text/html"
        ((pom_url_cnt++))
        continue
    fi  
    
    curl -s -m 120 -L -c "cookies.txt" -o "$vstupni_file" -H "Host: $domain" -H "User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:93.0) Gecko/20100101 Firefox/93.0" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8" -H "Accept-Language: cs,sk;q=0.8,en-US;q=0.5,en;q=0.3" -H "Origin: https://$domain" -H "Connection: keep-alive" -H "Referer: https://$domain/" -H "Upgrade-Insecure-Requests: 1" -H "Sec-Fetch-Dest: document" -H "Sec-Fetch-Mode: navigate" -H "Sec-Fetch-Site: same-origin" -H "Sec-Fetch-User: ?1" "${url_to_go[$pom_url_cnt]}" 

    if [ $? -ne 0 ]
      then
        echo "curl failed               "
        ((pom_url_cnt++))
        continue
    fi    
    
    typ_soub=$(file --mime "$vstupni_file")
    
    if [[ ! $typ_soub = *text/html*  ]]
      then
        #echo "typ souboru neni text/html"
        ((pom_url_cnt++))
        continue
    fi  
    
    
    
    cat "$vstupni_file" | iconv -f utf-8 -t ascii//TRANSLIT | awk -v "domain=$domain" -v "hledany_str=$2" -v "url=${url_to_go[$pom_url_cnt]}" -f site_assigner.awk >/dev/null 2>/dev/null
    
    #awk skript muze zapsat nove url do souboru scraper file
    if [ -e $scraper_file ]
      then
        while read url
          do
            url=$(echo "$url" | sed 's/&nbsp;/ /g; s/&amp;/\&/g; s/&lt;/\</g; s/&gt;/\>/g; s/&quot;/\"/g; s/#&#39;/\'"'"'/g; s/&ldquo;/\"/g; s/&rdquo;/\"/g;')
            add_url_to_go "$url"
        done < $scraper_file  
    fi
    ((pom_url_cnt++))
done  




