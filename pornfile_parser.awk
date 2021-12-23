
function get_next_node_leftorder(ind, which){
  #local pom_cnt
  #local i=1
  #local par1
  
  #pom_cnt=$(child_count $1)
  #ind_ditete=$(($2+2))
   
  return tree[ind][which-1]
  
}


function add_child_node(parent, tag, val, tag_puvc, val_puvc){

  #echo "funkce add child node spustena \$1 je $1 \$2 je $2 \$3 je $3"
  #tree[last_ind]=""
  if ( last_ind != 0 )
  {
      #process parent
      #echo "\$1 je $1"
      #tree[last_ind][0]=parent
      #inc_children_cnt $1
      tree_child_cnt[parent]=tree_child_cnt[parent]+1
      #add_child_ind $1 $last_ind
      tree[parent][tree_child_cnt[parent]-1]=last_ind
      tree_parent[last_ind]=parent
   }   
    else {
      #tree[last_ind]="-1"
      tree_parent[last_ind]=-1
  }
  #echo "tree[last_ind] ve funkci ${tree[$last_ind]}"
  #tree[$last_ind]="${tree[$last_ind]} 0 POMEND1 POMEND2" #$2 bude tag $3 pripadna data
  tree_tag[last_ind]="<"tag">"
  tree_val[last_ind]=val
  #echo "tree[last_ind] ve funkci ${tree[$last_ind]}"
  tree_tag_puv_case[last_ind]="<"tag_puvc">"
  tree_val_puv_case[last_ind]=val_puvc
  tree_child_cnt[last_ind]=0
  last_ind++
  #echo "navratova hodnota ve fci "$(($last_ind-1))
  curr_node=last_ind-1

}


BEGIN { FS=">";RS="<" 
vystupni_file="download_lnks.txt"




last_ind=0
parent_node=-1
is_in_script=1
is_in_comment=1
is_in_style=1
curr_node=0
delete imgs_array[0]
imgs_array_cnt=0
style_cnt=0
link_cnt=0
meta_cnt=0
print "zacatek parsingu"
}

#zacatek zpracovani souboru
{

TAG_puv_case=$1
VALUE_puv_case=$2
TAG=tolower(TAG_puv_case)
VALUE=tolower(VALUE_puv_case)

#print "value je "VALUE" tag je "TAG

if ( is_in_comment == 1 )
{  
      if ( is_in_script == 0 ) 
      {  
          pom_var="^\/script.*"
          if ( TAG ~ pom_var )
          {
              is_in_script=1 #false
              #print "konec skriptu"
          }    
          next
      }  
      pom_var="^script.*"
      if ( TAG ~ pom_var )
      {
          is_in_script=0  #true
          #print "zacatek skriptu"
          next
      }  
}
    
if ( is_in_comment == 1 )
{
      if ( is_in_style == 0 ) 
      { 
          pom_var="^\/style.*"
          if ( TAG ~ pom_var )
          {
              #print "konec stylu"
              is_in_style=1 #false
          }    
          next
      }  
      pom_var="^style.*"
      if ( TAG ~ pom_var )
      {
          #print "zacatek stylu"
          is_in_style=0  #true
          style_cnt++
          next
      }
}     


if ( is_in_comment == 1 )
{
        if ( TAG ~ /^!--.*--$/  || TAG ~ /^meta.*/ || TAG ~ /^link.*/ || TAG ~ /^!doctype.*/ || TAG ~ /^br.*/ || TAG ~ /^img.*/ || TAG ~ /^hr.*/ || TAG ~ /^basefont.*/ || TAG ~ /^wbr.*/ || TAG ~ /^hr.*/ || TAG ~ /^area.*/ || TAG ~ /^col.*/  || TAG ~ /^colgroup.*/ || TAG ~ /^source.*/ || TAG ~ /^track.*/ || TAG ~ /^frame.*/ || TAG ~ /^param.*/ || TAG ~ /^input.*/  || TAG ~ /^option.*/ || TAG ~ /^\/option.*/ || TAG ~ /^base.*/ || TAG ~ /^!\[if.*/ || TAG ~ /^\[if.*/ ) #|| [[ $TAG = \!--\[if* ]]  #tag img jeste zapracovat, muze obsahovat cena data v popiscich
        { 
            #print "tag ignorovan"
            tree_val[curr_node]=tree_val[curr_node]VALUE  #toto je nove a snad to funguje spravne
            tree_val_puv_case[curr_node]=tree_val_puv_case[curr_node]VALUE_puv_case
            if ( TAG ~ /^img.*/ )
            {
                imgs_array[imgs_array_cnt]=TAG
                imgs_array_cnt++
            }  
            if (TAG ~ /^link.*/)
            {
               link_cnt++
            }
            if ( TAG ~ /^meta.*/ )
            {
               meta_cnt++
            }
            next
        }    
}
    

if ( is_in_comment == 0 ) #comment without tags inside them is handled above, this is for multiline comments which include tags
{
        if ( VALUE ~ /.*--$/  ||  TAG ~ /.*--$/  ||  TAG ~ /^!\[endif\].*--$/ ) 
        {
            if ( ! (TAG ~ /^!--.*/ ))
            {
               #print "opousti koment"
               is_in_comment=1 #false
            }   
        }    
        next
}  
if ( TAG ~ /^!--.*/ )
{
        if ( ! (VALUE ~ /.*--$/))
        {
           #print "je v komentu"
           is_in_comment=0  #true
        }   
        next
}  


if ( TAG ~ /^!\[endif\]*--$/ ) 
{
        next 
}    
 
if ( curr_node == -1 )
{
        print "Neco je spatne. Vstupni soubor je mozna poskozeny. Vice uzaviracich tagu nez oteviracich."
        #i=0
        #while [ $i -lt $last_ind ]
        #do
        #  echo "index $i tag ${tree_tag[$i]} val ${tree_val[$i]}"
        #  ((i++))
        #done  
        #exit 1
        exit
}      

if ( TAG ~ /^\/.*/ ) #koncovz tag
{     
        #get_parent_node $curr_node
        curr_node=tree_parent[curr_node]
        tree_val[curr_node]=tree_val[curr_node]VALUE #toto je nove a snad to funguje spravne
        tree_val_puv_case[curr_node]=tree_val_puv_case[curr_node]VALUE_puv_case
        #curr_node=$?
}        
else
{
  if ( last_ind == 0 )
  {
          add_child_node(parent_node, TAG,VALUE,TAG_puv_case,VALUE_puv_case)
          #curr_node=$?
  }    
  else
  {  
          parent_node=curr_node
          #echo "parent node pred add child node je $parent_node"
          add_child_node(parent_node, TAG, VALUE, TAG_puv_case, VALUE_puv_case)
          #curr_node=$?
  }  
}  
    
}

#nezapomenout zkonvertovat vstupni soubor do ASCII !!!!!!!!!!!!!!!!!!!!!!!!!
END {

if((domain ~ /pornfile/)||(domain ~ /datoid/))
{
  link_nalezen=1
  i=0
  while ( i < last_ind ) 
  {
      if ( tree_val[i] ~ "nebyla nalezena presna shoda" )
      {
          exit 2
      }  
      #if [[ ${tree_val[$i]} = *"nebylo nic nalezeno"* ]]
      #  then
      #    exit 2
      #fi  
    
      i++
  }  

    
    #IFS=' ' read -a hledany_words_arr <<< "$hledany_str" #take reseni ze stack overflow
    split(hledany_str, hledany_words_arr, " ")
    #echo "je to ulozto typ"
    print "obsah pole hledany words arr 0 "hledany_words_arr[0]"a 1 "hledany_words_arr[1]
    result_str=""
    i=0
    while ( i < last_ind ) 
    {
         #echo "index pole je $i delka pole ${#tree_val[*]}"
         #echo "hodnota tree val ${tree_val[$i]}"
         nasel=0 #true
         for (temp_str in hledany_words_arr)
         {
            if ( ! (tree_val[i] ~ hledany_words_arr[temp_str]) )
            {
                nasel=1 #false
            } 
         }
        if ( nasel == 0 )
        {
             print "hledany retezec nalezen v tagu "tree_tag[i]
             print "nalezeny text v tagu je "tree_val[i]
             if ( tree_tag[i] ~ /^<a/ )
             {
                     
                  odkaz_cely=tree_tag_puv_case[i]
                  gsub(/\n/,"",odkaz_cely)
                  gsub(/\r/,"",odkaz_cely)
                  gsub(/\t/,"",odkaz_cely)
                  delete pom_pole[0]
                  elems=split(odkaz_cely,pom_pole,"\"")
         
                  for (f=2; f<=elems; f++) 
                    if (pom_pole[f-1] ~ /href=\\$/) 
                    {
                       gsub(/ /, "%20", pom_pole[f]);
                       odkaz=pom_pole[f]
                       #print $f
                    }
                  if ( (! ( odkaz ~ domain))  &&  (! (odkaz ~ /.*http.*:\/\/.*/)) )
                  {
                          
                     print "nalezeny odkaz je https://"domain""odkaz 
                     #print "https://"domain""odkaz" ("tree_val_puv_case[res]")" >> vystupni_file
                     result_str=result_str"https://"domain""substr(odkaz,0,length(odkaz)-1)"\n\n"
                  }    
                  else
                  {  
                          
                     print "nalezeny odkaz je "odkaz  
                     #print odkaz" ("tree_val_puv_case[res]")" >> vystupni_file
                     result_str=result_str""substr(odkaz,0,length(odkaz)-1)"\n\n"
                  }   
                  link_nalezen=0
              
                 
              }   
              else #odkaz neni primo nalezeny tag
              {  
                  #get_parent_node $i #parent by mel byt odkaz
                  curr_node=tree_parent[i]
                  while (( ! (tree_tag[curr_node] ~ /^<a/ )) && ( curr_node != -1 ))
                  {
                      print "parent tag je "tree_tag[curr_node]
                      #get_parent_node $curr_node 
                      curr_node=tree_parent[curr_node]
                  }
                  #echo "od"
                  if ( curr_node != -1 )
                  {
                  
                      
                      odkaz_cely=tree_tag_puv_case[curr_node]
                      gsub(/\n/,"",odkaz_cely)
                      gsub(/\r/,"",odkaz_cely)
                      gsub(/\t/,"",odkaz_cely)
                      delete pom_pole[0]
                      elems=split(odkaz_cely,pom_pole,"\"")
         
                     for (f=2; f<=elems; f++) 
                        if (pom_pole[f-1] ~ /href=\\$/) 
                        {
                          gsub(/ /, "%20", pom_pole[f]);
                          odkaz=pom_pole[f]
                          #print $f
                        }
                     if ( (! ( odkaz ~ domain))  &&  (! (odkaz ~ /.*http.*:\/\/.*/)) )
                     {
                          
                        print "nalezeny odkaz je https://"domain""odkaz 
                        #print "https://"domain""odkaz" ("tree_val_puv_case[res]")" >> vystupni_file
                        result_str=result_str"https://"domain""substr(odkaz,0,length(odkaz)-1)"\n\n"
                     }    
                     else
                     {  
                          
                        print "nalezeny odkaz je "odkaz  
                        #print odkaz" ("tree_val_puv_case[res]")" >> vystupni_file
                        result_str=result_str""substr(odkaz,0,length(odkaz)-1)"\n\n"
                     }   
                     link_nalezen=0
                      
                      
                  }    
                  
              }  
         }  
      i++   
    }     
   

  if ( link_nalezen == 0 )
  {
     print "\n" >> vystupni_file
     print "For url "url >> vystupni_file
     print "\n" >> vystupni_file
    
     print result_str >> vystupni_file
    
  }  

} else #konec if pornfile or datoid
if(domain ~ /webshare/)
{
  link_nalezen=1
  i=0
  
  split(hledany_str, hledany_words_arr, " ")
  #echo "je to ulozto typ"
  print "obsah pole hledany words arr 0 "hledany_words_arr[0]"a 1 "hledany_words_arr[1]
  result_str=""
  i=0
  while ( i < last_ind ) 
  {
         if(tree_tag[i] ~ /^<ident/)
         {
           hash=tree_val_puv_case[i]
           odkaz_raw=tree_val_puv_case[i+1]
           gsub(/ /,"-",odkaz_raw)
           gsub(/\./,"-",odkaz_raw)
           #print "odkaz je https://webshare.cz/#/file/"hash"/"odkaz_raw
           odkaz="https://webshare.cz/#/file/"hash"/"odkaz_raw
           
           nasel=0 #true
           for (temp_str in hledany_words_arr)
           {
             if ( ! (tolower(odkaz) ~ hledany_words_arr[temp_str]) )
             {
                 nasel=1 #false
             } 
           }
           if (nasel == 0)
           {
             print "nalezeny odkaz je "odkaz 
             result_str=result_str""odkaz"\n\n"
             link_nalezen=0
           }
         }
  
         
         
         
         i++
  }
  if ( link_nalezen == 0 )
  {
     print "\n" >> vystupni_file
     print "For url "url >> vystupni_file
     print "\n" >> vystupni_file
    
     print result_str >> vystupni_file
    
  }  
}else
if((domain ~ /sdilej/) || (domain ~ /fastshare/))
{
  link_nalezen=1
  i=0   
  
  split(hledany_str, hledany_words_arr, " ")
    #echo "je to ulozto typ"
    print "obsah pole hledany words arr 0 "hledany_words_arr[0]"a 1 "hledany_words_arr[1]
    result_str=""
    i=0
    while ( i < last_ind ) 
    {
         #echo "index pole je $i delka pole ${#tree_val[*]}"
         #echo "hodnota tree val ${tree_val[$i]}"
         nasel=0 #true
         for (temp_str in hledany_words_arr)
         {
            if ( ! (tree_val[i] ~ hledany_words_arr[temp_str]) )
            {
                nasel=1 #false
            } 
         }
        if ( nasel == 0 )
        {
             print "hledany retezec nalezen v tagu "tree_tag[i]
             print "nalezeny text v tagu je "tree_val[i]
             if ( tree_tag[i] ~ /^<a/ )
             {
                     
                  odkaz_cely=tree_tag_puv_case[i]
                  gsub(/\n/,"",odkaz_cely)
                  gsub(/\r/,"",odkaz_cely)
                  gsub(/\t/,"",odkaz_cely)
                  delete pom_pole[0]
                  elems=split(odkaz_cely,pom_pole,"\"")
         
                  for (f=2; f<=elems; f++) 
                    if (pom_pole[f-1] ~ /href=$/) 
                    {
                       gsub(/ /, "%20", pom_pole[f]);
                       odkaz=pom_pole[f]
                       #print $f
                    }
                  if ( (! ( odkaz ~ domain))  &&  (! (odkaz ~ /.*http.*:\/\/.*/)) )
                  {
                          
                     print "nalezeny odkaz je https://"domain""odkaz 
                     #print "https://"domain""odkaz" ("tree_val_puv_case[res]")" >> vystupni_file
                     result_str=result_str"https://"domain""odkaz"\n\n"
                  }    
                  else
                  {  
                          
                     print "nalezeny odkaz je "odkaz  
                     #print odkaz" ("tree_val_puv_case[res]")" >> vystupni_file
                     result_str=result_str""odkaz"\n\n"
                  }   
                  link_nalezen=0
              
                 
              }   
              else #odkaz neni primo nalezeny tag
              {  
                  #get_parent_node $i #parent by mel byt odkaz
                  curr_node=tree_parent[i]
                  while (( ! (tree_tag[curr_node] ~ /^<a/ )) && ( curr_node != -1 ))
                  {
                      print "parent tag je "tree_tag[curr_node]
                      #get_parent_node $curr_node 
                      curr_node=tree_parent[curr_node]
                  }
                  #echo "od"
                  if ( curr_node != -1 )
                  {
                  
                      
                      odkaz_cely=tree_tag_puv_case[curr_node]
                      gsub(/\n/,"",odkaz_cely)
                      gsub(/\r/,"",odkaz_cely)
                      gsub(/\t/,"",odkaz_cely)
                      delete pom_pole[0]
                      elems=split(odkaz_cely,pom_pole,"\"")
         
                     for (f=2; f<=elems; f++) 
                        if (pom_pole[f-1] ~ /href=$/) 
                        {
                          gsub(/ /, "%20", pom_pole[f]);
                          odkaz=pom_pole[f]
                          #print $f
                        }
                     if ( (! ( odkaz ~ domain))  &&  (! (odkaz ~ /.*http.*:\/\/.*/)) )
                     {
                          
                        print "nalezeny odkaz je https://"domain""odkaz 
                        #print "https://"domain""odkaz" ("tree_val_puv_case[res]")" >> vystupni_file
                        result_str=result_str"https://"domain""odkaz"\n\n"
                     }    
                     else
                     {  
                          
                        print "nalezeny odkaz je "odkaz  
                        #print odkaz" ("tree_val_puv_case[res]")" >> vystupni_file
                        result_str=result_str""odkaz"\n\n"
                     }   
                     link_nalezen=0
                      
                      
                  }    
                  
              }  
         }  
      i++   
    }     
   

  if ( link_nalezen == 0 )
  {
     print "\n" >> vystupni_file
     print "For url "url >> vystupni_file
     print "\n" >> vystupni_file
    
     print result_str >> vystupni_file
    
  } 
}
} #konec END


