
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


# $1 je aktualni index uzlu
# $2 kolikate dite ma vratit
# prvni je asi which 1
function get_next_node_leftorder(ind, which){
  #local pom_cnt
  #local i=1
  #local par1
  
  #pom_cnt=$(child_count $1)
  #ind_ditete=$(($2+2))
   
  return tree[ind][which-1]
  
}



#$1 je current node
#$2 text ktery se hleda

function find_child_val(node, searched_text      , j,curr_node,curr_depth,pom_cnt,curr_iter){
curr_node=node
curr_depth=1

#pom_cnt[$curr_depth]=$(child_count $curr_node) #zmena 13.12.
pom_cnt[curr_depth]=tree_child_cnt[curr_node]
#local j=1 #zmena 9.12.
j=1
curr_iter[curr_depth]=j
while ( 1 )
{
  if ( j <= pom_cnt[curr_depth] )
  {
      #echo "${tree_tag[$curr_node]} pom cnt je ${pom_cnt[$curr_depth]} depth je $curr_depth"
      child_ind=get_next_node_leftorder(curr_node, j)
      #tree_depth[$child_ind]=$curr_depth
      pom_searched_text=searched_text
      if ( tree_val[child_ind] ~ pom_searched_text ) #mozna jsou nutne uvozovky
      {  
           #echo $child_ind
           return child_ind
      }  
      #echo "child je ${tree_tag[$child_ind]} j je $j "
      #echo "${tree_tag[$child_ind]}"
      
      #pom_cnt_next_lev=$(child_count $child_ind) #zmena 13.12.
      pom_cnt_next_lev=tree_child_cnt[child_ind]
      if ( pom_cnt_next_lev > 0 )
      {  
         #echo "zanořuje se"
         curr_node=child_ind
         curr_iter[curr_depth]=j+1
         curr_depth++
         pom_cnt[curr_depth]=pom_cnt_next_lev
         j=1
         curr_iter[curr_depth]=1
         continue
      }
  }
  
  
  
  if ( j >= pom_cnt[curr_depth] )
  {  
      #echo "vynořuje se"
      if ( curr_depth == 1 )
      {
          break
      }  
      #get_parent_node $curr_node  # fce uz nastavuje curr_node #zmena 13.12.
      curr_node=tree_parent[curr_node]
      curr_depth--
      j=curr_iter[curr_depth]
      continue
  }  
  
  j++    
  curr_iter[curr_depth]=j
  
  
  
  
  #
}
#echo "" #nic nenasel
return -1
}



#$1 je current node
#$2 text ktery se hleda

function find_child_val_end(node, searched_text      , j,curr_node,pom_cnt,curr_iter,curr_depth){
curr_node=node
curr_depth=1

#pom_cnt[$curr_depth]=$(child_count $curr_node) #zmena 13.12.
pom_cnt[curr_depth]=tree_child_cnt[curr_node]
#local j=1 #zmena 9.12.
j=1
curr_iter[curr_depth]=j
while ( 1 )
{
  if ( j <= pom_cnt[curr_depth] )
  {
      #echo "${tree_tag[$curr_node]} pom cnt je ${pom_cnt[$curr_depth]} depth je $curr_depth"
      child_ind=get_next_node_leftorder(curr_node, j)
      #tree_depth[$child_ind]=$curr_depth
      pom_searched_text=searched_text"$"
      #print "pred porovnanim stringu "pom_searched_text" tree_val je  "tree_val[child_ind]
      #if(length(tree_val[child_ind]) < 10000) #toto je nove chybu ktera se tu deje jsem nepochopil, ale pomohlo to
      if ( tree_val[child_ind] ~ pom_searched_text ) #mozna jsou nutne uvozovky
      {  
           #echo $child_ind
           #print "konec returnem"
           return child_ind
      }  
      #print "po porovnani stringu"
      #echo "child je ${tree_tag[$child_ind]} j je $j "
      #echo "${tree_tag[$child_ind]}"
      
      #pom_cnt_next_lev=$(child_count $child_ind) #zmena 13.12.
      pom_cnt_next_lev=tree_child_cnt[child_ind]
      if ( pom_cnt_next_lev > 0 )
      {  
         #print "zanořuje se"
         curr_node=child_ind
         curr_iter[curr_depth]=j+1
         curr_depth++
         pom_cnt[curr_depth]=pom_cnt_next_lev
         j=1
         curr_iter[curr_depth]=1
         continue
      }
  }
  
  
  
  if ( j >= pom_cnt[curr_depth] )
  {  
      #print "vynořuje se"
      if ( curr_depth == 1 )
      {
          break
      }  
      #get_parent_node $curr_node  # fce uz nastavuje curr_node #zmena 13.12.
      curr_node=tree_parent[curr_node]
      curr_depth--
      j=curr_iter[curr_depth]
      continue
  }  
  
  j++    
  curr_iter[curr_depth]=j
  
  
  
  
  #
}
#echo "" #nic nenasel
return -1
}





function find_child_tag(node, searched_text      , j, curr_node, curr_depth,curr_iter, pom_cnt){
curr_node=node
curr_depth=1

#pom_cnt[$curr_depth]=$(child_count $curr_node) #zmena 13.12.
pom_cnt[curr_depth]=tree_child_cnt[curr_node]
#local j=1 #zmena 9.12.
j=1
curr_iter[curr_depth]=j
while ( 1 )
{
  if ( j <= pom_cnt[curr_depth] )
  {
      #echo "${tree_tag[$curr_node]} pom cnt je ${pom_cnt[$curr_depth]} depth je $curr_depth"
      child_ind=get_next_node_leftorder(curr_node, j)
      #tree_depth[$child_ind]=$curr_depth
      #pom_searched_text=".*"searched_text".*"
      pom_searched_text=searched_text
      if ( tree_tag[child_ind] ~ pom_searched_text ) #mozna jsou nutne uvozovky
      {  
           #echo $child_ind
           return child_ind
      }  
      #echo "child je ${tree_tag[$child_ind]} j je $j "
      #echo "${tree_tag[$child_ind]}"
      
      #pom_cnt_next_lev=$(child_count $child_ind) #zmena 13.12.
      pom_cnt_next_lev=tree_child_cnt[child_ind]
      if ( pom_cnt_next_lev > 0 )
      {  
         #echo "zanořuje se"
         curr_node=child_ind
         curr_iter[curr_depth]=j+1
         curr_depth++
         pom_cnt[curr_depth]=pom_cnt_next_lev
         j=1
         curr_iter[curr_depth]=1
         continue
      }
  }
  
  
  
  if ( j >= pom_cnt[curr_depth] )
  {  
      #echo "vynořuje se"
      if ( curr_depth == 1 )
      {
          break
      }  
      #get_parent_node $curr_node  # fce uz nastavuje curr_node #zmena 13.12.
      curr_node=tree_parent[curr_node]
      curr_depth--
      j=curr_iter[curr_depth]
      continue
  }  
  
  j++    
  curr_iter[curr_depth]=j
  
  
  
  
  #
}
#echo "" #nic nenasel
return -1
}



function find_child_tag_all(node, searched_text, tag_ind_array      , j, tag_ind_array_cnt,curr_node,curr_depth,pom_cnt,curr_iter){
curr_node=node
curr_depth=1
tag_ind_array_cnt=0

#pom_cnt[$curr_depth]=$(child_count $curr_node) #zmena 13.12.
pom_cnt[curr_depth]=tree_child_cnt[curr_node]
#local j=1 #zmena 9.12.
j=1
curr_iter[curr_depth]=j
while ( 1 )
{
  if ( j <= pom_cnt[curr_depth] )
  {
      #echo "${tree_tag[$curr_node]} pom cnt je ${pom_cnt[$curr_depth]} depth je $curr_depth"
      child_ind=get_next_node_leftorder(curr_node, j)
      #tree_depth[$child_ind]=$curr_depth
      #pom_searched_text=".*"searched_text".*"
      pom_searched_text=searched_text
      if ( tree_tag[child_ind] ~ pom_searched_text ) #mozna jsou nutne uvozovky
      {  
           #echo $child_ind
           #return child_ind
           tag_ind_array[tag_ind_array_cnt]=child_ind
           tag_ind_array_cnt++
      }  
      #echo "child je ${tree_tag[$child_ind]} j je $j "
      #echo "${tree_tag[$child_ind]}"
      
      #pom_cnt_next_lev=$(child_count $child_ind) #zmena 13.12.
      pom_cnt_next_lev=tree_child_cnt[child_ind]
      if ( pom_cnt_next_lev > 0 )
      {  
         #echo "zanořuje se"
         curr_node=child_ind
         curr_iter[curr_depth]=j+1
         curr_depth++
         pom_cnt[curr_depth]=pom_cnt_next_lev
         j=1
         curr_iter[curr_depth]=1
         continue
      }
  }
  
  
  
  if ( j >= pom_cnt[curr_depth] )
  {  
      #echo "vynořuje se"
      if ( curr_depth == 1 )
      {
          break
      }  
      #get_parent_node $curr_node  # fce uz nastavuje curr_node #zmena 13.12.
      curr_node=tree_parent[curr_node]
      curr_depth--
      j=curr_iter[curr_depth]
      continue
  }  
  
  j++    
  curr_iter[curr_depth]=j
  
  
  
  
  #
}
#echo "" #nic nenasel
#return -1
return tag_ind_array_cnt
}



@include "array_lists.awk"
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
print "zacatek parsingu"
print "For url "url >> vystupni_file
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
        #print "Neco je spatne. Vstupni soubor je mozna poskozeny. Vice uzaviracich tagu nez oteviracich."
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
    

#add_child_node(-1,"a href=neco","hodnota1", "a href=neco","hodnota" ) #prvni se musi vlozit jeste pred parsingem

#add_child_node(0,"a href=neco","hodnota2", "a href=neco","hodnota" )

#add_child_node(0,"a href=neco","hodnota3", "a href=neco","hodnota" )

#add_child_node(0,"a href=neco","hodnota4", "a href=neco","hodnota" )

#add_child_node(2,"a href=neco","hodnota5", "a href=neco","hodnota" )

#add_child_node(4,"a href=neco","hodnota6", "a href=neco","hodnota" )

#add_child_node(4,"a href=neco","hodnota7", "a href=neco","hodnota" )

#print "pred cykly"

#for(i=0;i<last_ind;i++)
#{
#  for(j=0;j<tree_child_cnt[i];j++)
#  {
#    print "deti pro uzel "i" "tree[i][j]
#  }  
#  print   
#}

#print "find child val"
#print find_child_val(0,"hodnota2")
#print find_child_val(2,"hodnota1")
#print find_child_val(4,"hodnota6")
#print "find child val end"
#print find_child_val_end(0,"hodnota2")
#delete pole[0]
#find_child_tag_all(0,"neco",pole)
#for(j=0;j<length(pole);j++)
#  {
#    print "hodnoty indexu "j" "pole[j]
#  }  

#delete pole2[0]
#find_child_tag_all(0,"blbost",pole2)
#for(j=0;j<length(pole2);j++)
#  {
#    print "hodnoty indexu "j" "pole2[j]
#  }  



} #konec parsingu

#hledany str, domain, url a limit budu muset posilat pres -v parametr jako promenou
END{
hledany_str=tolower(hledany_str) 
link_nalezen=1 #false
i=0
#limit=$3


while (i < last_ind)
{
  if ( tree_val[i] ~ hledany_str ) #myslim ze neni potreba to balit do .*.*
  {
    print "nasel "hledany_str
    if ( tree_tag[i] ~ /^<title.*/ ) 
    {
        print "title obsahuje "hledany_str
        i++
        continue
    }  
    
    for(pom_ind in search_in)
    {
      print "for cyklus pro tagy <a spusten pro "search_in[pom_ind]
      res=find_child_tag(i,"^<a.*"search_in[pom_ind]".*")
      curr_node=i #nove 18.12.
      if ( res == -1 ) 
      {
        #print "i nyni "i" a potom current node "tree_parent[i]
        curr_node=tree_parent[i]
        if(curr_node==-1) break
        #print "po prvnim breaku"
        res=find_child_tag(curr_node, "^<a.*"search_in[pom_ind]".*")
      }
      j=0
      while ( (res == -1) && (j < limit) && (curr_node != 0) && (curr_node != -1) ) #mozna jeste pridat kontrolu uzlu -1
      {
         #print "curr node v cyklu je nahore "curr_node
         curr_node=tree_parent[curr_node]
         #print "curr node v cyklu je uprostred "curr_node
         res=find_child_tag(curr_node, "^<a.*"search_in[pom_ind]".*")
         j++
         #print "curr node v cyklu je dole "curr_node
      }
      
      if(res != -1)
      {
         delete tagy_pom_array
         delete tagy_pom_array[0]
         #print "current node pred ruhym breakem "curr_node
         if(curr_node==-1) break
         #print "po druhem breaku"
         tagy_ind=find_child_tag_all(curr_node, "^<a.*"search_in[pom_ind]".*",tagy_pom_array)
         for(tag_pom_ind in tagy_pom_array)
         { 
            #print "odkaz z find child tag all "tagy_pom_array[tag_pom_ind]
            odkaz_cely=tree_tag_puv_case[tagy_pom_array[tag_pom_ind]]
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
            if ( (! ( odkaz ~ domain))  &&  (! (odkaz ~ search_in[pom_ind])) )
            {
                          
                  print "nalezeny odkaz je https://"domain""odkaz 
                  print "https://"domain""odkaz" ("tree_val_puv_case[tagy_pom_array[tag_pom_ind]]")" >> vystupni_file
            }    
            else
            {  
                          
                  print "nalezeny odkaz je "odkaz  
                  print odkaz" ("tree_val_puv_case[tagy_pom_array[tag_pom_ind]]")" >> vystupni_file
            }   
            
         }
         #tady jeste pridat zpracovani odkazu pro index res
         odkaz_cely=tree_tag_puv_case[res]
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
         if ( (! ( odkaz ~ domain))  &&  (! (odkaz ~ search_in[pom_ind])) )
         {
                          
                  print "nalezeny odkaz je https://"domain""odkaz 
                  print "https://"domain""odkaz" ("tree_val_puv_case[res]")" >> vystupni_file
         }    
         else
         {  
                          
                  print "nalezeny odkaz je "odkaz  
                  print odkaz" ("tree_val_puv_case[res]")" >> vystupni_file
         }   
         link_nalezen=0
      }
    }
    for(pom_ind in koncovky)  
    {
      print "for cyklus pro tagy <a spusten pro "koncovky[pom_ind]
      res=find_child_tag(i,"^<a.*\\"koncovky[pom_ind]".*")
      curr_node=i #nove 18.12.
      if ( res == -1 ) 
      {
        curr_node=tree_parent[i]
        if(curr_node==-1) break
        res=find_child_tag(curr_node, "^<a.*\\"koncovky[pom_ind]".*")
      }
      j=0
      while ( (res == -1) && (j < limit) && (curr_node != 0) && (curr_node != -1) ) #mozna jeste pridat kontrolu uzlu -1
      {
         curr_node=tree_parent[curr_node]
         res=find_child_tag(curr_node, "^<a.*\\"koncovky[pom_ind]".*")
         j++
      }
      
      if(res != -1)
      {
         delete tagy_pom_array
         delete tagy_pom_array[0]
         if(curr_node==-1) break
         tagy_ind=find_child_tag_all(curr_node, "^<a.*\\"koncovky[pom_ind]".*",tagy_pom_array)
         for(tag_pom_ind in tagy_pom_array)
         { 
            #print "odkaz z find child tag all "tagy_pom_array[tag_pom_ind]
            odkaz_cely=tree_tag_puv_case[tagy_pom_array[tag_pom_ind]]
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
            pom_var=".*\\"koncovky[pom_ind]"$"
            pom_var2="\\"koncovky[pom_ind]
            if ( odkaz ~ pom_var ) 
            {
              if ( (! ( odkaz ~ domain))  &&  (! (odkaz ~ pom_var2)) )
              {
                          
                  print "nalezeny odkaz je https://"domain""odkaz 
                  print "https://"domain""odkaz" ("tree_val_puv_case[tagy_pom_array[tag_pom_ind]]")" >> vystupni_file
              }    
              else
              {  
                          
                  print "nalezeny odkaz je "odkaz  
                  print odkaz" ("tree_val_puv_case[tagy_pom_array[tag_pom_ind]]")" >> vystupni_file
              }   
            }
         }
         #tady jeste pridat zpracovani odkazu pro index res
         odkaz_cely=tree_tag_puv_case[res]
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
         pom_var=".*\\"koncovky[pom_ind]"$"
         pom_var2="\\"koncovky[pom_ind]
         if ( odkaz ~ pom_var )      
         {
            if ( (! ( odkaz ~ domain))  &&  (! (odkaz ~ pom_var2)) )
            {
                          
                  print "nalezeny odkaz je https://"domain""odkaz 
                  print "https://"domain""odkaz" ("tree_val_puv_case[res]")" >> vystupni_file
            }    
            else
            {  
                          
                  print "nalezeny odkaz je "odkaz  
                  print odkaz" ("tree_val_puv_case[res]")" >> vystupni_file
            }
         }   
         link_nalezen=0
      }
    }
    
    
    for(pom_ind in koncovky)  
    {
      print "for cyklus spusten pro "koncovky[pom_ind] #" tree val "tree_val[i]
      res=find_child_val_end(i,"\\"koncovky[pom_ind])
      #print "prvni find child val end"
      if ( res == -1 ) 
      {
        #print "pred druhy find child val end curr node curr_node val bude "tree_val[tree_parent[i]]
        curr_node=tree_parent[i]
        if(curr_node==-1) break
        res=find_child_val_end(curr_node, "\\"koncovky[pom_ind])
        #print "druhy find child val end"
      }
      j=0
      while ( (res == -1) && (j < limit) && (curr_node != 0) && (curr_node != -1) ) #mozna jeste pridat kontrolu uzlu -1
      {
         #print "cyklus while jede"
         curr_node=tree_parent[curr_node]
         res=find_child_val_end(curr_node, "\\"koncovky[pom_ind])
         j++
      }
      
      if ( res != -1 )
      { 
              print "Result z hledani "koncovky[pom_ind]" je "tree_val[res]
              if ( tree_tag[res] ~ /^<a.*/ ) #asi pridat jeste test na tag title a vyradit ho z hledani
              {
                  
                  odkaz_cely=tree_tag_puv_case[res]
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
                     print "https://"domain""odkaz" ("tree_val_puv_case[res]")" >> vystupni_file
                  }    
                  else
                  {  
                          
                     print "nalezeny odkaz je "odkaz  
                     print odkaz" ("tree_val_puv_case[res]")" >> vystupni_file
                  }   
                  link_nalezen=0
                    
                   
              }           
              else #odkaz neni primo nalezeny tag
              {  
                  #get_parent_node $res #parent by mel byt odkaz
                  curr_node=tree_parent[res]
                  while ( ! (tree_tag[curr_node] ~ /^<a.*/)  && ( curr_node != 0 ) && (curr_node != -1)) #zmena oproti bashi
                  {
                      #get_parent_node $curr_node 
                      curr_node=tree_parent[curr_node]
                  }
                  #echo "od"
                  if ( (tree_tag[curr_node] ~ /^<a.*/) ) #zmena oproti bashi
                  {
                  
                        
                      odkaz_cely=tree_tag_puv_case[res]
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
                          print "https://"domain""odkaz" ("tree_val_puv_case[res]")" >> vystupni_file
                       }    
                       else
                       {  
                          
                         print "nalezeny odkaz je "odkaz  
                         print odkaz" ("tree_val_puv_case[res]")" >> vystupni_file
                       }   
                       link_nalezen=0
                    
                    
                        
                  
                     
                  }    
                  
              }    
              
      }
      
    }  
      
  }
  i++
  
}
#print "po cyklu"


#pokud jsme nenalezli download link otestujeme jeste jestli neni youtube alternativa
vystup_youtube="youtube_alter.txt"
vystup_multiple="multiple_links.txt"


if ( link_nalezen == 1 )
{
    if ( domain ~ /tube/ )
    {
            print "nalezena youtube alternativa"
            print url >> vystup_youtube
            exit 0
    }  
    
    pom_iter=0
    video_imgs_cnt=0
    #print "pocet prvku v poli imgs_array je "${#imgs_array[@]}"
    while ( pom_iter < imgs_array_cnt )
    {
         if (imgs_array[pom_iter] ~ /video/  || imgs_array[pom_iter] ~ /thumb/ )
         {
             video_imgs_cnt++
         }  
         pom_iter++   
    } 
    
    if ( video_imgs_cnt > 27 )
    {
            print "nalezena youtube alternativa podle poctu obrazku"
            print url >> vystup_youtube
    }        
    else
    {   
            print "zarazeno do multiple"
            print url >> vystup_multiple  
    }
    #konec testu na youtube alternativy
  #else
  #  echo "zarazeno do multiple"
  #  echo "$1" >> $vystup_multiple  
}  



exit
}#konec END


