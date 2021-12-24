# Vidcrawler
This set of bash and awk scripts called Vidcrawler is a tool for internet search for download links of movies. 
It searches in several file sharing services which have its own finder (uloz.to, webshare.cz, datoid.cz, fastshare.cz, sdilej.cz)
and it uses google too. It also tryes to categorize results. This tool might help to owners of copyright of movies to 
find, where their right is violated. It may be also helpfull to people who would like to download some movie and can not 
find download links. It searches only web pages, which are publicly accesible without need to login. 
By using this software you are agreeing with terms of use of google, uloz.to, webshare.cz, datoid.cz, 
fastshare.cz and sdilej.cz.



Usage

./starter_vid_crawlers.sh "movie title" "main actor or multiple actors"

For example for Batman movie and Michael Keaton: ./starter_vid_crawlers.sh "Batman" "Michael Keaton"


Installation

No installation is necessary, just unpack downloaded code and use it like it was described above. It should be unpacked in its own directory, like it's default when it is downloaded from github. It creates several text files, when it's working, so
if you do not keep it in its own directory, it could possibly overwrite some of your files if their name would be the same 
(which is unlikely).
It should work on Linux systems, where bash and awk is installed (which is almost always). It was tested on Linux Fedora 34, GNU Bash version 5.1.0 and GNU awk 5.1.0.


Notes about code

Code in current version is very repetitive and should be put in functions. This is because it was previously written 
in pure bash, where function calls are expensive operation and i wanted script to be faster. Unfortunatelly it still was not 
enough so i had to rewrite it to awk. There are also other insufficiencies, theese are often caused by fact, that author
is beginner in both bash and awk.
 
