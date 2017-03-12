#!/bin/bash
#
# This Script is use to generate ready to print rapport wrote with markdown 
# 
# Dependency :
#	- Markdown
#	- Wkhtlmtopdf
#	- vi ex mode
#
# Bourdelas Pablo - 2017 - pablo.bourdelas@gmail.com
#

CSS="$HOME/.script/MarkDownPdf/printer_friendly.css"
HEAD="$HOME/.script/MarkDownPdf/head.html"
HTML=$(echo $1 | cut -d . -f 1).html
OUT=$(echo $1 | cut -d . -f 1).pdf


#Toc optional
TOC=""
if test $2 = "t" >> /dev/null ; then
	TOC="toc --xsl-style-sheet $HOME/.script/MarkDownPdf/toc.xsl"
fi

#Construct 

echo HTML BODY CONSTRUCT

#Convert TABLE csv into html table using vi 

Bal=($(cat $1 | grep -n TABLE | cut -d : -f 1))

for i in $(seq 0 2 $((${#Bal[@]}-1)) ) ; do
	ex -s -c "${Bal[$i]},${Bal[$((i+1))]}s/^TABLE/<table>/|${Bal[$i]},${Bal[$((i+1))]}s/^ENDTABLE/<\/table>/|${Bal[$i]},${Bal[$((i+1))]}s/\([^;]*\);/<td>\1<\/td>/g|${Bal[$i]},${Bal[$((i+1))]}s/\(.*<td>.*\)/<tr>\1<\/tr>/|wq" $1
done

#end

# Convert PAGEBRK into page break html

ex -s -c "1,\$s/PAGEBRK/<div class="pagebreak"><\/div>/g|wq" $1

#end


markdown $1 > .tmp      #COnvert Md to html
cp $CSS style.css	#Copie style to working directory
cat $HEAD .tmp > $HTML  #Add Head to html file
echo "</body>		
</html>" >> $HTML 	#Proper end file 

rm .tmp			#clean tmp

#Page gard handeling
GARD=""
if test -f gard.rmd ; then 
	cp $HOME/.script/MarkDownPdf/gard.html .gard.html 
	cp $HOME/.script/MarkDownPdf/gard.css .gard.css

	TITLE=$(cat gard.rmd | cut -d : -f 1)
	IMG=$(cat gard.rmd | cut -d : -f 2)
	AUTH=$(cat gard.rmd | cut -d : -f 3)
	DATE=$(date +%d-%m-%y)
	echo GARD PAGE
	GARD=".gard.html"
	ex -s -c "1,\$s/DATE/$DATE/|1,\$s/TITLE/$TITLE/|1,\$s/AUTH/$AUTH/|1,\$s/IMG/$IMG/|wq" .gard.html
fi


#end

echo GEN PDF

wkhtmltopdf --title "$TITLE" $GARD $TOC $HTML --footer-right "[doctitle] - [page] / [topage]" $OUT #Final convertion to PDF
