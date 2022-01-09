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

function strip_rubish(title,               pom_array)
{
   split(title,pom_array,"/")
   split(pom_array[1],pom_array,"[")
   split(pom_array[1],pom_array,"(")
   split(pom_array[1],pom_array,"-")
   gsub(/:/,"",pom_array[1])
   gsub(/^ +/,"",pom_array[1])
   gsub(/ +$/,"",pom_array[1])
   gsub(/  /," ",pom_array[1])
   return pom_array[1]
}





@include "array_lists.awk"

BEGIN { FS=">";RS="<" 
vystupni_file="download_lnks.txt"
scraper_file="blog_crawler.txt"


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
#print "zacatek parsingu"
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
               meta_array[meta_cnt]=TAG
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
    
}

END{
  if(start==1)
  {
  #zacatek testu na download linky
    nalezen=1 #false
    for (pom_ind in search_in)
    {
         pom_iter=0
         while ( pom_iter < last_ind )
         {
              if ( tree_val[pom_iter] ~ search_in[pom_ind] )
              {
                  nalezen=0 #true
                  break
              }    
              pom_iter++
         }
         if ( nalezen == 0 ) 
         {
             break
         }  
    }
    
    if ( nalezen == 1 )
    {
        for (pom_ind in koncovky)
        {
            pom_iter=0
            while ( pom_iter < last_ind )
            {
                 pom_var="\\"koncovky[pom_ind]"$"
                 if ( tree_val[pom_iter] ~ pom_var )
                 {
                     nalezen=0 #true
                     break
                 }    
                 pom_iter++
            }
            if ( nalezen == 0 ) 
            {
                  break
            }
        }
    }
    #asi jeste pridat cykly pro odkazy cili tree_tag a kontrolovat koncovky i fileshare
    if ( nalezen == 0 ) 
    {
        #print "\n"
        #print "\n"
        #print "byl nalezen fileshare nebo pripona v hodnote "tree_val[pom_iter]
    }    
    else
    {
        #print "\n"
        #print "\n"
        #print "nebyl nalezen fileshare ani pripona"  
    }   
    
    
    #nalezen=1 #false
    if ( nalezen == 1 )
    {
       for ( pom_ind in search_in)
       {
         pom_iter=0
         while ( pom_iter < last_ind )
         {
              if ( (tree_tag[pom_iter] ~ /^<a/) && (tree_tag[pom_iter] ~ search_in[pom_ind] )) 
              {
                  nalezen=0 #true
                  break
              }    
              pom_iter++
         }
         if ( nalezen == 0 ) 
         {
             break
         }  
       }
    
       if ( nalezen == 1 )
       {
          for (pom_ind in koncovky)
          {
            pom_iter=0
            while ( pom_iter < last_ind )
            {
                 pom_var="\\"koncovky[pom_ind]"\"" #overit
                 if ( (tree_tag[pom_iter] ~ /^<a/)  && ( tree_tag[pom_iter] ~ pom_var )) #zmena 11.12. predtim prava strana *$str_in_cycle\> ]]
                 {
                     nalezen=0 #true
                     break
                 }    
                 pom_iter++
            }
            if ( nalezen == 0 ) 
            {
                  break
            }
          }
       }
    }  #konec if nenalezen
    
    if ( nalezen == 0 ) 
    {
        #print "\n"
        #print "\n"
        #print "byl nalezen fileshare nebo pripona v tagu "tree_tag[pom_iter]
        if(url ~ /xsava.xyz/) #koresponduje s tavaz
        {
          pom_iter=0
          while(pom_iter < last_ind)
          {
             if((tree_tag[pom_iter] ~ /^<h1/)&&(tree_tag[pom_iter] ~ /class..title.link./))
             {
                #print "strip rubish titulu je "strip_rubish(tree_val[pom_iter])
                #print "strip rubish hledany_str je "strip_rubish(hledany_str)
                if(strip_rubish(tree_val[pom_iter]) == strip_rubish(hledany_str))
                {
                   print "For url "url  >> vystupni_file #pokud mozno pridat jeste hodnotu
                }
             }
             pom_iter++
          }
        }else if ((url ~ /movieparadise/)||(url ~ /dl4all.org/)||(url ~ /warezlover/)||(url ~ /ulmovies/)||(url ~ /go-movie/)||(url ~ /mobilism.site/))
        { 
          pom_iter=0
          while(pom_iter < last_ind)
          {
             if(tree_tag[pom_iter] ~ /^<h1/)
             {
                #print "strip rubish titulu je "strip_rubish(tree_val[pom_iter])
                #print "strip rubish hledany_str je "strip_rubish(hledany_str)
                if(strip_rubish(tree_val[pom_iter]) == strip_rubish(hledany_str))
                {
                   print "For url "url  >> vystupni_file #pokud mozno pridat jeste hodnotu
                }
             }
             pom_iter++
          } 
        }else if(url ~ /rmz.cr/)
        {
           pom_iter=0
          while(pom_iter < last_ind)
          {
             if(tree_tag[pom_iter] ~ /^<span itemprop/)
             {
                #print "strip rubish titulu je "strip_rubish(tree_val[pom_iter])
                #print "strip rubish hledany_str je "strip_rubish(hledany_str)
                if(strip_rubish(tree_val[pom_iter]) == strip_rubish(hledany_str))
                {
                   print "For url "url  >> vystupni_file #pokud mozno pridat jeste hodnotu
                }
             }
             pom_iter++
          } 
        }else if(url ~ /warez-serbia/)
        {
           pom_iter=0
          while(pom_iter < last_ind)
          {
             if(tree_tag[pom_iter] ~ /^<div class=\"post-title/)
             {
                while((!(tree_tag[pom_iter] ~ /^<a/)) && (pom_iter < last_ind))
                { 
                   pom_iter++
                }
                if(tree_tag[pom_iter] ~ /^<a/)
                {
                  #print "strip rubish titulu je "strip_rubish(tree_val[pom_iter])
                  #print "strip rubish hledany_str je "strip_rubish(hledany_str)
                  if(strip_rubish(tree_val[pom_iter]) == strip_rubish(hledany_str))
                  {
                     print "For url "url  >> vystupni_file #pokud mozno pridat jeste hodnotu
                  }
                }
             }
             pom_iter++
          } 
        }else if(url ~ /filmsofts/)
        {
           pom_iter=0
          while(pom_iter < last_ind)
          {
             if(tree_tag[pom_iter] ~ /^<span class=\"active\"/)
             {
                  #print "hodnota code "tree_val[pom_iter]
                  #split(tree_val[pom_iter],pom_pole_code,":")  
                  #split(pom_pole_code[2],pom_pole_code,"]")  
                  #gsub(/\n/,"",pom_pole_code[2])
                  #gsub(/\r/,"",pom_pole_code[2])
                  #print "titul raw je "pom_pole_code[2]
                  #print "strip rubish titulu je "strip_rubish(tree_val[pom_iter])
                  #print "strip rubish hledany_str je "strip_rubish(hledany_str)
                  if(strip_rubish(tree_val[pom_iter]) == strip_rubish(hledany_str))
                  {
                     print "For url "url  >> vystupni_file #pokud mozno pridat jeste hodnotu
                  }
                  
                
             }
             pom_iter++
          } 
        }else if(url ~ /3dsbs4u/)
        {
          pom_iter=0
          while(pom_iter < last_ind)
          {
             if(tree_tag[pom_iter] ~ /^<span class=\"ntitle\"/)
             {
                  if (((pom_iter + 2) < last_ind)&&(tree_tag[pom_iter+2] ~ /^<b/))
                  {
                    print "strip rubish titulu je "strip_rubish(tree_val[pom_iter+2])
                    print "strip rubish hledany_str je "strip_rubish(hledany_str)
                    if(strip_rubish(tree_val[pom_iter+2]) == strip_rubish(hledany_str))
                    {
                       print "For url "url  >> vystupni_file #pokud mozno pridat jeste hodnotu
                    }
                  }
                
             }
             pom_iter++
          } 
        }else if (url ~ /ugmovies/)
        {
          pom_iter=0
          while(pom_iter < last_ind)
          {
             if(tree_tag[pom_iter] ~ /^<h3/)
             {
                if(((pom_iter + 1) < last_ind)&&(tree_tag[pom_iter+1] ~ /^<a/))
                {
                  print "strip rubish titulu je "strip_rubish(tree_val[pom_iter+1])
                  print "strip rubish hledany_str je "strip_rubish(hledany_str)
                  if(strip_rubish(tree_val[pom_iter+1]) == strip_rubish(hledany_str))
                  {
                     print "For url "url  >> vystupni_file #pokud mozno pridat jeste hodnotu
                  }
                }
             }
             pom_iter++
          }
        }
        else
        {
           print "For url "url  >> vystupni_file #pokud mozno pridat jeste hodnotu
        }
        
        
        exit
     }
        
      else
     { 
        #print "\n"
        #print "\n"
        #print "nebyl nalezen fileshare ani pripona v zadnem tagu"  
      
        
        
    }   
    #konec testu na download linky
  }  
  
    str_to_crawl[str_to_crawl_cnt++]=tolower(hledany_str)
    url_to_go_cnt=0
    for ( pom_ind in str_to_crawl)
    {
         pom_iter=0
         #print str_to_crawl[pom_ind]
         while ( pom_iter < last_ind )
         {
              #print tree_val[pom_iter]  
              if ( ((tree_tag[pom_iter] ~ /^<a/) || (tree_tag[tree_parent[pom_iter]] ~ /^<a/)) && (tree_val[pom_iter] ~ str_to_crawl[pom_ind] )) 
              {
                  nalezen=0 #true
                  #url_to_go[url_to_go_cnt++]=
                  if(tree_tag[pom_iter] ~ /^<a/)
                  {
                     odkaz_cely=tree_tag_puv_case[pom_iter]
                  }else
                  {
                     odkaz_cely=tree_tag_puv_case[tree_parent[pom_iter]]
                  }
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
                  if ( (! ( odkaz ~ domain)) && (!(odkaz ~ /http:\/\//)) && (!(odkaz ~ /https:\/\//)))  #&&  (! (odkaz ~ str_to_crawl[pom_ind])) )
                  {
                          
                    #print "nalezeny odkaz pro scrapper je https://"domain""odkaz 
                    if(domain ~ /filmsofts/)
                    {  
                       print "https://"domain"/"odkaz >> scraper_file
                    }else
                    {
                       print "https://"domain""odkaz >> scraper_file
                    }
                  }    
                  else
                  {  
                          
                    #print "nalezeny odkaz pro scrapper je "odkaz  
                    print odkaz >> scraper_file
                  }
              }    
              pom_iter++
         }
         
    }
    
  
} #konec END

