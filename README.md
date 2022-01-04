# Vidcrawler
This set of bash and awk scripts called Vidcrawler is a tool for internet search for download links of movies. 
It searches in several file sharing services which have its own finder (uloz.to, pornfile.cz, webshare.cz, datoid.cz, fastshare.cz, sdilej.cz), in several warez sites
and it uses google too. It also tryes to categorize results. This tool might help to owners of copyright of movies to 
find, where their right is violated. It may be also helpfull to people who would like to download some movie and can not 
find download links. It searches only web pages, which are publicly accessible without need to login. 
By using this software you are agreeing with terms of use of google, uloz.to, pornfile.cz, webshare.cz, datoid.cz, 
fastshare.cz and sdilej.cz.



Usage

./starter_vid_crawlers.sh [-o filename] "movie title" "main actor or multiple actors"

For example for Batman movie and Michael Keaton: ./starter_vid_crawlers.sh "Batman" "Michael Keaton"

In brackets is optional parameter -o, which can be used to specify filename for html output of results.

So, for invoking Vidcrawler with the same movie and actor like above and with html output to file output.html,
we would have: ./starter_vid_crawlers.sh -o output.html "Batman" "Michael Keaton"


Installation

No installation is necessary, just unpack downloaded code and use it like it was described above. It should be unpacked in its own directory, like it's default when it is downloaded from github. It creates several text files, when it's working, so
if you do not keep it in its own directory, it could possibly overwrite some of your files if their name would be the same 
(which is unlikely).
It should work on Linux systems, where bash and awk is installed (which is almost always). It was tested on Linux Fedora 34, GNU Bash version 5.1.0 and GNU AWK 5.1.0.


Notes about code

Code in current version is very repetitive and should be put in functions. This is because it was previously written 
in pure bash, where function calls are expensive operation and i wanted script to be faster. Unfortunatelly it still was not 
enough so i had to rewrite it to awk. There are also other insufficiencies, theese are often caused by fact, that author
is beginner in both Bash and AWK.


Results

Results are shown in terminal, after script finishes. First block contains found direct download links.
Second block contains sites with embedded player, where streaming could be possible. Third block contains
youtube alternative sites, fourth block contains paysites, fifth block torrent sites and sixth block
contains sites, which according to some indices may include another download links, which were not 
identified for sure. Of course, there may be irrelevant results, relevancy depends on results of google search
and other finders, which scripts use. Even more results, than results shown in terminal, may contain file
download_lnks.txt, but theese are often duplicit and there may be more irrelevant results too.
