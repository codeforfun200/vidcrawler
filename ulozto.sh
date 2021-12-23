
source tree_funcs2.sh

xmlgetnext () {
local IFS='>'
read -d '<' TAG VALUE
}

vstupni_file="azlea.html"

if [[ $1 = *uloz.to* ]]
  then
  
  curl -v -L -c "cookies.txt" -o "$vstupni_file" -H "Host: uloz.to" -H "User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:93.0) Gecko/20100101 Firefox/93.0" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8" -H "Accept-Language: cs,sk;q=0.8,en-US;q=0.5,en;q=0.3" -H "Connection: keep-alive" -H "Upgrade-Insecure-Requests: 1" -H "Sec-Fetch-Dest: document" -H "Sec-Fetch-Mode: navigate" -H "Sec-Fetch-Site: none" -H "Sec-Fetch-User: ?1" "https://uloz.to"
  
  if [ $? -ne 0 ]
    then
        echo "Stranku se nepovedlo nacist"         
        exit 1
  fi  
  
   curl -v -L -c "cookies.txt" -b "cookies.txt" -o "$vstupni_file" -H "Host: uloz.to" -H "User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:93.0) Gecko/20100101 Firefox/93.0" -H "Accept: application/json, text/javascript, */*; q=0.01" -H "Accept-Language: cs,sk;q=0.8,en-US;q=0.5,en;q=0.3" -H "X-Requested-With: XMLHttpRequest" -H "Connection: keep-alive" -H "Referer: https://uloz.to/" -H "Sec-Fetch-Dest: empty" -H "Sec-Fetch-Mode: cors" -H "Sec-Fetch-Site: same-origin" "https://uloz.to?do=adultConfirmation-confirm"
   
  if [ $? -ne 0 ]
    then
        echo "Stranku se nepovedlo nacist"         
        exit 1
  fi  


# curl --http2 -v -L -c "cookies.txt" -b "cookies.txt" -o "$vstupni_file" -H "Host: uloz.to" -H "User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:93.0) Gecko/20100101 Firefox/93.0" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8" -H "Accept-Language: cs,sk;q=0.8,en-US;q=0.5,en;q=0.3" -H "Connection: keep-alive" -H "Referer: https://uloz.to/" -H "Upgrade-Insecure-Requests: 1" -H "Sec-Fetch-Dest: document" -H "Sec-Fetch-Mode: navigate" -H "Sec-Fetch-Site: same-origin" -H "Sec-Fetch-User: ?1" -H "TE: trailers" "https://uloz.to/hledej?type=&q=the+godfather"

  curl --http2 -v -L -c "cookies.txt" -b "cookies.txt" -o "$vstupni_file" -H "Host: uloz.to" -H "User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:93.0) Gecko/20100101 Firefox/93.0" -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8" -H "Accept-Language: cs,sk;q=0.8,en-US;q=0.5,en;q=0.3" -H "Connection: keep-alive" -H "Referer: https://uloz.to/" -H "Upgrade-Insecure-Requests: 1" -H "Sec-Fetch-Dest: document" -H "Sec-Fetch-Mode: navigate" -H "Sec-Fetch-Site: same-origin" -H "Sec-Fetch-User: ?1" -H "TE: trailers" "$1"
  
  if [ $? -ne 0 ]
    then
        echo "Stranku se nepovedlo nacist"         
        exit 1
  fi  

  
  curl -v -L -b "cookies.txt" -o "$vstupni_file" -H "Host: uloz.to" -H "User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:93.0) Gecko/20100101 Firefox/93.0" -H "Accept: application/json, text/javascript, */*; q=0.01" -H "Accept-Language: cs,sk;q=0.8,en-US;q=0.5,en;q=0.3" -H "X-Requested-With: XMLHttpRequest" -H "Connection: keep-alive" -H "Referer: \$1" -H "Sec-Fetch-Dest: empty" -H "Sec-Fetch-Mode: cors" -H "Sec-Fetch-Site: same-origin" -H "TE: trailers" "$1"  
  
  if [ $? -ne 0 ]
    then
        echo "Stranku se nepovedlo nacist"         
        exit 1
  fi  

   
#curl -v -L -b "cookies.txt" -o "$vstupni_file" -H "Host: $domain" -H "User-Agent: Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:93.0) Gecko/20100101 Firefox/93.0" -H "Accept: application/json, text/javascript, */*; q=0.01" -H "Accept-Language: cs,sk;q=0.8,en-US;q=0.5,en;q=0.3" -H "X-Requested-With: XMLHttpRequest" -H "Connection: keep-alive" -H "Referer: $1" -H "Upgrade-Insecure-Requests: 1" -H "Sec-Fetch-Dest: empty" -H "Sec-Fetch-Mode: cors" -H "Sec-Fetch-Site: same-origin" -H "Sec-Fetch-User: ?1" "$1"     
fi





echo "zacatek parsingu"

last_ind=0
parent_node=-1
is_in_script=1
is_in_comment=1
is_in_style=1
curr_node=0

#cat "$vstupni_file" | sed 's/<!-->//g' > azlea2.html

#$vstupni_file="azlea2.html"

#pokud bude nejaky neznamy tag na nevhodnem miste uvnitr html komentare tak asi nasledujici parsing neobstoji
while xmlgetnext 
  do 
    #TAG=$(echo "$TAG" | tr -d "|")
    #VALUE=$(echo "$VALUE" | tr -d "|")
    TAG_puv_case="$TAG"
    VALUE_puv_case="$VALUE"
    TAG=$(echo "$TAG" | tr '[:upper:]' '[:lower:]') #should also work with locale
    VALUE=$(echo "$VALUE" | tr '[:upper:]' '[:lower:]') #should also work with locale
    echo "value je $VALUE tag je $TAG"
    
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
        if [[ $TAG = \!--*-- ]] || [[ $TAG = meta* ]] || [[ $TAG = link* ]] || [[ $TAG = \!doctype* ]] || [[ $TAG = br* ]] || [[ $TAG = img* ]] || [[ $TAG = hr* ]] || [[ $TAG = basefont* ]] || [[ $TAG = wbr* ]] || [[ $TAG = hr* ]] || [[ $TAG = area* ]] || [[ $TAG = col* ]] || [[ $TAG = colgroup* ]] || [[ $TAG = source* ]] || [[ $TAG = track* ]] || [[ $TAG = frame* ]] || [[ $TAG = param* ]] || [[ $TAG = input* ]] || [[ $TAG = option* ]] || [[ $TAG = /option* ]] || [[ $TAG = base* ]] || [[ $TAG = \!\[if* ]] || [[ $TAG = \[if* ]] #|| [[ $TAG = \!--\[if* ]]  #tag img jeste zapracovat, muze obsahovat cena data v popiscich
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
    
done < $vstupni_file #<(cat "$vstupni_file")


if [ $last_ind -eq 0 ]
  then
    echo "strom je prazdny"
    exit 1
fi  

#if [ $last_ind -lt 5 ]
#  then
#    echo "strom je skoro prazdny"
#    exit 1
#fi  

#zacatek zpracovani ulozto
vystupni_file="download_lnks.txt"
i=0
while [ $i -lt ${#tree_val[*]} ] 
  do
    if [[ ${tree_val[$i]} = *"nebyla nalezena přesná shoda"* ]]
      then
        exit 2
    fi  
    if [[ ${tree_val[$i]} = *"nebylo nic nalezeno"* ]]
      then
        exit 2
    fi  
    
  ((i++))
done  

echo "For url $1" >> $vystupni_file
echo "ulozto vratilo nejake vysledky"

i=0
vyskyty=0
while [ $i -lt ${#tree_tag[*]} ] 
  do
    if [[ ${tree_tag[$i]} = "<div data-icon"* ]]
      then
        ((vyskyty++))
    fi  
    
    
  ((i++))
done  

echo "$vyskyty vyskytu na ulozto"


