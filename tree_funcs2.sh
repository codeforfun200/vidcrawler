#!/bin/bash

#promenne stromu

last_ind=0  #index pole pro novy node

#struktura stringu 1)parent node 2)pocet deti 3)indexy deti 4)tag data 5)data


#fce musi inkrementovat pole retezce s poctem deti u parenta

#inc_children_cnt(){
#  local par1
#  local i=1
#  #local IFS=' '
#  new_str=""
#  
#  while read -d ' ' par1 
#      do
#      if [ $i -eq 1 ]
#        then
#          new_str="$par1"
#        else 
#          if [ $i -eq 2 ]   
#            then
#              #((par1++))
#              par1=$(($par1 + 1))
#          fi      
#          new_str="$new_str $par1"
#      fi   
      
#      ((i++))
#  done < <(echo "${tree[$1]}")
#  #if [ $i -eq 2 ]   
#  #  then
#  #    #((par1++))
#  #    par1=$(($par1 + 1))
#  #fi      
#  new_str="$new_str $par1"  #velice divne !!! cyklus vynecha posledni polozku, proto je nutne toto
#  #echo "last par je $par1"
#  #echo "new string je $new_str i je $i"
#  tree[$1]=$new_str
#  tree_child_cnt[$1]=$((${tree_child_cnt[$1]}+1))
#}


#child_count(){
#  local par1
#  local i=1
#  local pocet_deti=0
  
#  while read -d ' ' par1 
#   do
#      if [ $i -eq 2 ]   
#        then
#         pocet_deti=$par1
#         #return $pocet_deti #predelat pres echo nebo eval !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#         echo $pocet_deti
#         return
#      fi      
#      ((i++))
#   done < <(echo "${tree[$1]}")
   
#}


#fce prida index ditete do stringu parenta

add_child_ind(){
  local par1
  local i=1
  local pocet_deti=0
  local index_posl_dite=0
  new_str=""
  
   pocet_deti=${tree_child_cnt[$1]} #$(child_count $1)
   #pocet_deti=$?
   i=1
   index_posl_dite=$(($pocet_deti+2))
   while read -d ' ' par1 
      do
      if [ $i -eq 1 ]
        then
          new_str="$par1"
        else 
          if [ $i -eq $index_posl_dite ]   
            then
              new_str="$new_str $2"    
          fi      
          new_str="$new_str $par1"
      fi   
      
      ((i++))
  done < <(echo "${tree[$1]}")
  #if [ $i -eq $index_posl_dite ]   
  #  then
  #    new_str="$new_str $2"    
  #  fi     
  new_str="$new_str $par1"
  tree[$1]=$new_str 
}

#$1 je parent node
#pridat kontrolu preteceni integeru u promenne last_ind

add_child_node(){
  #echo "funkce add child node spustena \$1 je $1 \$2 je $2 \$3 je $3"
  tree[$last_ind]=""
  if [ $last_ind -ne 0 ]
    then
      #process parent
      #echo "\$1 je $1"
      tree[$last_ind]=$1
      #inc_children_cnt $1
      tree_child_cnt[$1]=$((${tree_child_cnt[$1]}+1))
      add_child_ind $1 $last_ind
      tree_parent[$last_ind]=$1
    else 
      tree[$last_ind]="-1"
      tree_parent[$last_ind]=-1
  fi
  #echo "tree[last_ind] ve funkci ${tree[$last_ind]}"
  tree[$last_ind]="${tree[$last_ind]} 0 POMEND1 POMEND2" #$2 bude tag $3 pripadna data
  tree_tag[$last_ind]="<$2>"
  tree_val[$last_ind]="$3"
  #echo "tree[last_ind] ve funkci ${tree[$last_ind]}"
  tree_tag_puv_case[$last_ind]="<$4>"
  tree_val_puv_case[$last_ind]="$5"
  tree_child_cnt[$last_ind]=0
  ((last_ind++))
  #echo "navratova hodnota ve fci "$(($last_ind-1))
  curr_node=$(($last_ind-1))
}


# $1 je current node

get_parent_node(){
  local par1
  local i=1
  
  #if [ $1 -eq 0 ]
  #  then
  #    return -1
  #fi
  while read -d ' ' par1 
   do
      if [ $i -eq 1 ]   
        then
          curr_node=$par1
          return 0
      fi      
      ((i++))
   done < <(echo "${tree[$1]}")
   
}

# $1 je node pro ktereho se vypisi deti
# $2 je promenna do ktere se ulozi vysledek

child_nodes(){
   local pocet_deti=0
   local ind_konce=0
   new_str=""
   local par1
   local i=1
   
   pocet_deti=${tree_child_cnt[$1]}  #$(child_count $1)
   #pocet_deti=$?
   ind_konce=$(($pocet_deti+2))
   while read -d ' ' par1 
   do
      if [ $i -gt 2 ] && [ $i -le $ind_konce ]  
        then
          if [ $i -eq 3 ]
            then
              new_str=$par1
            else
              new_str="$new_str $par1"
          fi
           
      fi      
      ((i++))
   done < <(echo "${tree[$1]}")
   #return "$new_str"  #fce nemuze vratit retezec
   #echo "$new_str"
   eval "$2=\"$new_str\""
}


# $1 je aktualni index uzlu
# $2 kolikate dite ma vratit
get_next_node_leftorder(){
  local pom_cnt
  local i=1
  local par1
  
  #pom_cnt=$(child_count $1)
  ind_ditete=$(($2+2))
    
  while read -d ' ' par1 
   do
      if [ $i -eq $ind_ditete ]   
        then
          echo $par1
          return 0
      fi      
      ((i++))
   done < <(echo "${tree[$1]}")
}



get_next_node_leftorder2(){
  local pom_iter=0
  local space_cnt=0
  local ind_ditete=$(($2+1))
  while [ $pom_iter -lt ${#tree[$1]} ]
    do
      if [ $ind_ditete -eq $space_cnt ]
        then
          local vysledek=""
          while [[ ${tree[$1]:$pom_iter:1} = [0-9] ]]
            do
              vysledek=$vysledek${tree[$1]:$pom_iter:1}
              ((pom_iter++))
          done    
          echo $vysledek
          return 0
      fi  
      if [[ ${tree[$1]:$pom_iter:1} = " " ]]
        then
          ((space_cnt++))
      fi  
      ((pom_iter++))
  done  

}





#$1 je current node
#$2 text ktery se hleda

find_child_val(){
curr_node=$1
curr_depth=1

#pom_cnt[$curr_depth]=$(child_count $curr_node) #zmena 13.12.
pom_cnt[$curr_depth]=${tree_child_cnt[$curr_node]}
local j=1 #zmena 9.12.
curr_iter[$curr_depth]=$j
while [ 1 -eq 1 ]
do
  if [ $j -le ${pom_cnt[$curr_depth]} ]
    then
      #echo "${tree_tag[$curr_node]} pom cnt je ${pom_cnt[$curr_depth]} depth je $curr_depth"
      child_ind=$(get_next_node_leftorder2 $curr_node $j)
      #tree_depth[$child_ind]=$curr_depth
      if [[ ${tree_val[$child_ind]} = *$2* ]] #mozna jsou nutne uvozovky
        then
           echo $child_ind
           return
      fi  
      #echo "child je ${tree_tag[$child_ind]} j je $j "
      #echo "${tree_tag[$child_ind]}"
      
      #pom_cnt_next_lev=$(child_count $child_ind) #zmena 13.12.
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
      #get_parent_node $curr_node  # fce uz nastavuje curr_node #zmena 13.12.
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
#$2 text ktery se hleda
#hleda vyskyt jen na konci retezce

find_child_val_end(){
curr_node=$1
curr_depth=1

#pom_cnt[$curr_depth]=$(child_count $curr_node) #zmena 13.12.
pom_cnt[$curr_depth]=${tree_child_cnt[$curr_node]}
j=1
curr_iter[$curr_depth]=$j
while [ 1 -eq 1 ]
do
  if [ $j -le ${pom_cnt[$curr_depth]} ]
    then
      #echo "${tree_tag[$curr_node]} pom cnt je ${pom_cnt[$curr_depth]} depth je $curr_depth"
      child_ind=$(get_next_node_leftorder2 $curr_node $j)
      #tree_depth[$child_ind]=$curr_depth
      if [[ ${tree_val[$child_ind]} = *$2 ]] #mozna jsou nutne uvozovky
        then
           echo $child_ind
           return
      fi  
      #echo "child je ${tree_tag[$child_ind]} j je $j "
      #echo "${tree_tag[$child_ind]}"
      
      #pom_cnt_next_lev=$(child_count $child_ind) #zmena 13.12.
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
      #get_parent_node $curr_node  # fce uz nastavuje curr_node #zmena 13.12.
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


