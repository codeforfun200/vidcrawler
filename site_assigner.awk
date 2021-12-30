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







@include "array_lists.awk"

BEGIN { FS=">";RS="<" 
#vystupni_file="download_lnks.txt"

vystup_forum="for_analyzer.txt"
vystup_download_lnks="for_analyzer.txt"
vystup_youtube="youtube_alter.txt"
vystup_player="players.txt"
vystup_torrent="torrents.txt"
vystup_paysite="paysites.txt"
vystup_multiple="multiple_links.txt"
vystup_titulky="subtitle_sites.txt"
scraper_file="for_scraper.txt"


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
               print "opousti koment"
               is_in_comment=1 #false
            }   
        }    
        next
}  
if ( TAG ~ /^!--.*/ )
{
        if ( ! (VALUE ~ /.*--$/))
        {
           print "je v komentu"
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

END{

  if ( last_ind == 0 )
  {
    print "strom je prazdny"
    exit 1
  }  


  #zacatek hledani titulu
    hledany_str=tolower(hledany_str) 
    
    pom_iter=0
    nalezen=1 #false
    while ( pom_iter < last_ind )
    {
        if ( tree_val[pom_iter] ~ hledany_str ) 
        {
                  nalezen=0 #true
                  break
         }    
         pom_iter++
    }
    
    if ( nalezen == 1 ) #prohledat jeste url
    {
        if ( url ~ hledany_str )
        {
            nalezen=0
        }  
    }  
    
    if ( nalezen == 1 )
    {
        print "titul "hledany_str" nenalezen"
        exit   
    }  
    
    #konec hledani titulu
    
    #zacatek jestli neobsahuje skoro zadne obrazky
    
    if(imgs_array_cnt <= 1)
    {
        print "neobsahje skoro zadne obrazky"
        exit
    }
    
    
    #konec jestli neobsahuje skoro zadne obrazky
    
    #zacatek neobsahuje style ani link
    
    if (( style_cnt == 0) && (link_cnt==0))
    {
       print "neobsahuje style ani link"
       exit
    }
    
    #konec neobsahuje style ani link
    
    #zacatek obsahuje malo meta
    
    if (meta_cnt < 5)
    {
       print "obsahuje malo meta"
       exit
    }
    
    #konec obsahuje malo meta
    
    #zacatek hledani torrentu ve strance
    
    pom_iter=0
    nalezen=1 #false
    while ( pom_iter < last_ind )
    {
              if ( tree_val[pom_iter] ~ /torrent/ ) 
              {
                  nalezen=0 #true
                  break
              }    
              pom_iter++
    }
    
    if ( nalezen == 0 )
    {
        print "torrent site nalezena"
        print url >> vystup_torrent
        
        exit
    }
    
    #konec hledani torrentu ve strance
    #zacatek hledani titulku (subtitles) ve strance
    
    pom_iter=0
    subtitle_cnt=0 #false
    while ( pom_iter < last_ind )
    {
              if ( tree_val[pom_iter] ~ /subtitle/ ) 
              {
                  subtitle_cnt++
                  
              }    
              pom_iter++
    }
    
    if ( subtitle_cnt >= 10 )
    {
        print "titulkova site nalezena"
        print url >> vystup_titulky
        
        exit
    }
    
    #konec hledani subtitles ve strance
    #zacatek hledani podcast
    
    pom_iter=0
    podcast_cnt=0 #false
    while ( pom_iter < last_ind )
    {
              if ( tree_val[pom_iter] ~ /podcast/ ) 
              {
                  podcast_cnt++
                  
              }    
              pom_iter++
    }
    
    if ( podcast_cnt >= 2 )
    {
        print "podcastova site nalezena"
        #print url >> vystup_titulky
        
        exit
    }
    
    #konec hledani podcast
    
    #zacatek vylouceni traileru
    
    
    pom_iter=0
    trailer_cnt=0 #false
    while ( pom_iter < last_ind )
    {
              if ( tree_val[pom_iter] ~ /trailer/ ) 
              {
                  trailer_cnt++
                  
              }    
              pom_iter++
    }
    
    if ( trailer_cnt >= 5 )
    {
        print "trailer site nalezena"
        #print url >> vystup_torrent
        
        exit
    }
    
    
    #vylouceni traileru konec
    
    
    
    #zacatek hledani game site
    
    if (( domain ~ /game/ ) || (domain ~ /gaming/))
    {
            print "nalezena gamesite "
            exit
    }  
    
    #konec hledani gamesite
    
    #zacatek hledani paysite
    
    nalezen=1 #false
    for (pom_ind in paysites)
    {
         pom_iter=0
         while ( pom_iter < last_ind )
         {
              if ( tree_val[pom_iter] ~ paysites[pom_ind] )
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
    if ( nalezen == 0 )
    {
        print "paysite nalezena"
        print url >> vystup_paysite
        
        exit
    }  
    #konec hledani paysite
    
    
    #zacatek kategorizace podle meta
    
    
    meta_search_for[0][0]="download"
    meta_search_for[0][1]="movie"
    meta_search_for_limit[0]=2
    meta_search_for[1][0]="download"
    #meta_search_for[1][1]=hledany_str
    hledany_str_arr_cnt=split(hledany_str, hledany_str_arr," ")
    pom_iter=1
    while(pom_iter <= hledany_str_arr_cnt)
    {
       meta_search_for[1][pom_iter]=hledany_str_arr[pom_iter]
       pom_iter++
    }
    meta_search_for_limit[1]=hledany_str_arr_cnt+1
    pom_iter=0
    while(pom_iter < meta_cnt)
    {
       pom_iter2=0
       meta_nalezen=0
       while(pom_iter2 < 2)
       {
          pom_iter3=0
          meta_nalezen=0
          while(pom_iter3 < meta_search_for_limit[pom_iter2])
          {
          
             if(!( meta_array[pom_iter] ~ meta_search_for[pom_iter2][pom_iter3] ))
             {
                meta_nalezen=1 #false
             }
             pom_iter3++
          }
          if(meta_nalezen == 0) 
          {
             
             break
          }
        
          pom_iter2++
       }
       if (meta_nalezen == 0)
       {
         print "download site podle meta"
         print url >> vystup_forum
         exit
       }
       pom_iter++
    }
    
    #konec kategorizace podle meta
    
    
    #zacatek hledani prehravace
    pom_iter=0
    nalezen=1 #false
    while (pom_iter < last_ind )
    {
        if ( tree_tag[pom_iter] ~ /^<video/  ||  tree_tag[pom_iter] ~ /player/ )
        {
                  nalezen=0 #true
                  break
        }    
        pom_iter++
    }
    if ( nalezen == 0 )
    {
        print "prehravac nalezen"
        print url >> vystup_player
        
        exit
    }  
    
    
    
    #konec hledani prehravace
    #zacatek hledani fora
    
    if ( domain ~ /forum/ )
    {
            print "nalezeno forum"
            print url >> vystup_forum #zmena oproti bashi
            exit
    }  
    
    pom_iter=0
    nalezen=1 #false
    while ( pom_iter < last_ind )
    {
              if ( tree_val[pom_iter] ~ /forum/ ) 
              {
                  nalezen=0 #true
                  break
              }    
              pom_iter++
    }
    
    
    if ( nalezen == 1 )
    {
        pom_iter=0
        while ( pom_iter < last_ind )
        {
              if ( tree_tag[pom_iter] ~ /forum/ ) 
              {
                  nalezen=0 #true
                  break
              }                 
              pom_iter++
        }
    }  
    
    if ( nalezen == 0 )
    {
            print "nalezeno forum"
            print url >> vystup_forum
            
            exit
    }  
    
    #konec hledani fora
    
    #test na youtube alternativy
    
    if ( domain ~ /tube/ )
    {
            print "nalezena youtube alternativa"
            print url >> vystup_youtube
            
            exit
    }  
    
    pom_iter=0
    video_imgs_cnt=0
    #echo "pocet prvku v poli imgs_array je ${#imgs_array[@]}"
    while ( pom_iter < imgs_array_cnt )
    {  
         if ( imgs_array[pom_iter] ~ /video/ || imgs_array[pom_iter] ~ /thumb/ )
         {
             video_imgs_cnt++
         }  
         pom_iter++   
    } 
    
    if ( video_imgs_cnt > 27 )
    {
            print "nalezena youtube alternativa podle poctu obrazku"
            print url >> vystup_youtube
            
            exit
    }
    #konec testu na youtube alternativy
    
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
        print "\n"
        print "\n"
        print "byl nalezen fileshare nebo pripona v hodnote "tree_val[pom_iter]
    }    
    else
    {
        print "\n"
        print "\n"
        print "nebyl nalezen fileshare ani pripona"  
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
        print "\n"
        print "\n"
        print "byl nalezen fileshare nebo pripona v tagu "tree_tag[pom_iter]
        print url >> vystup_download_lnks
        
        exit
     }
        
      else
     { 
        print "\n"
        print "\n"
        print "nebyl nalezen fileshare ani pripona v zadnem tagu"  
      
        
        
    }   
    #konec testu na download linky
    
    
    #zacatek str to crawl 
    #vynechat titulek
    #unset found_str_to_crawl
    #unset found_str_to_crawl_index
    #unset found_str_to_crawl_cnt
    nalezen_cnt=0
    for_cycle_cnt=0
    found_str_to_crawl_index[0]=0
    for (pom_ind in str_to_crawl)
    {
         pom_iter=0
         while ( pom_iter < last_ind )
         {
              if ( tree_val[pom_iter] ~ str_to_crawl[pom_ind] )
              {
                  found_str_to_crawl[nalezen_cnt]=pom_iter
                  
                  nalezen_cnt++
                  
              }    
              pom_iter++
         }
         pom_predch_ind=for_cycle_cnt
         for_cycle_cnt++ 
         found_str_to_crawl_index[for_cycle_cnt]=nalezen_cnt #zacatek dalsiho
         
         found_str_to_crawl_cnt[pom_predch_ind]=(nalezen_cnt - found_str_to_crawl_index[pom_predch_ind])
    }
    
    pom_iter2=0
    pom_end_cyc=for_cycle_cnt #found_str_to_crawl_index[@]}-1)) #zmena oproti bashi
    
    while ( pom_iter2 < pom_end_cyc )
    {
       if ( found_str_to_crawl_cnt[pom_iter2] > 1 )
       {
           print "Nalezeno vicero str to crawl"
           print url >> vystup_multiple
       }    
       else if ( found_str_to_crawl_cnt[pom_iter2] == 1 )
       {
              res=found_str_to_crawl[found_str_to_crawl_index[pom_iter2]]
              print "Result z hledani je - nalezena jedna hodnota "tree_val[res]
              if ( tree_tag[res] ~ /^<a/ ) 
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
                  if ( (! ( odkaz ~ domain))  &&  (! (odkaz ~ /http.*:\/\//)) )
                  {
                          
                     print "nalezeny odkaz je https://"domain""odkaz 
                     print "https://"domain""odkaz >> scraper_file
                  }    
                  else
                  {  
                          
                     print "nalezeny odkaz je "odkaz  
                     print odkaz >> scraper_file
                  }
                  
                  
                  
                  
                  
              }   
                  
              else #odkaz neni primo nalezeny tag
              { 
                  #get_parent_node $res #parent by mel byt odkaz
                  curr_node=tree_parent[res]
                  while ( (! (tree_tag[curr_node] = /^<a/))  && ( curr_node != -1 ) )
                  {
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
                       if ( (! ( odkaz ~ domain))  &&  (! (odkaz ~ /http.*:\/\//)) )
                       {
                          
                         print "nalezeny odkaz je https://"domain""odkaz 
                         print "https://"domain""odkaz >> scraper_file
                       }    
                       else
                       {  
                          
                         print "nalezeny odkaz je "odkaz  
                         print odkaz >> scraper_file
                       }
                    
                       
                  }    
                  
              }  
              
       }  
       pom_iter2++
    }
    
    if ( nalezen_cnt >= 1 )
    {
        #echo "Nalezeno vicero str to crawl"
        
        exit
    }
    
    #konec str to crawl
    
    
} #konec END

