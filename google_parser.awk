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
vystupni_file="google_links.txt"




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


END {

#hledame odkazy z google search
i=0
nalezl=1 #false
pom_str="^<div class=\"g\""
print "pomocny string je "pom_str
while ( i < last_ind )
{
    if ( tree_tag[i] ~ pom_str )
    {
        print "tag g nalezen "tree_tag[i]
        res=find_child_tag(i, "^<a")
        if (  $res != -1 )
        {
            #nalezl=0 #true
            
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
              
                          
              print "nalezeny odkaz je "odkaz  
              print odkaz >> vystupni_file
              
           
            
           
           
           
        }  
    }  
    i++
}  

}

