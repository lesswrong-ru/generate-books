#!/bin/bash -e
#
#
# Make electronic book versions for lesswrong.ru

# Define main variables
WEB_ROOT="/srv/lesswrong.ru"
CODE_ROOT="/home/berekuk/books"

SAVEPATH="$WEB_ROOT/files"
CACHEPATH="$WEB_ROOT/cache/normal/lesswrong.ru/book/export/html"
BOOKURL="book/export/html/"
URL="http://lesswrong.ru/"
FBCONVPATH="$CODE_ROOT/html2fb2"
PYTHONPATH=$FBCONVPATH
CALPATH="$CODE_ROOT/calibre"
COMMENT="'Released under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported license. CC BY-NC-SA 3.0'"
OPDS="$SAVEPATH/opds2.xml"

function ebook {
    AUTHOR="Eliezer Yudkowsky" 
    FILE='all-sequences'
    echo Download ${URL}${FILE} --output-document=${SAVEPATH}/tmp/${FILE}
    wget ${URL}${FILE} -k --output-document=${SAVEPATH}/tmp/${FILE}
    sed -ie "/logo-150/d" ${SAVEPATH}/tmp/${FILE}
    sed -ie 's#<h2>#\<h3\>#' ${SAVEPATH}/tmp/${FILE}
    sed -ie 's#| LessWrong на русском##' ${SAVEPATH}/tmp/${FILE}
    sed -ie 's#</h2>#\<\/h3\>#' ${SAVEPATH}/tmp/${FILE}
    sed -ie 's#{depth2}#\<h1\>#' ${SAVEPATH}/tmp/${FILE}
    sed -ie 's#{/depth2}#\</h1\>#' ${SAVEPATH}/tmp/${FILE}
    sed -ie 's#{depth3}#\<h2\>#' ${SAVEPATH}/tmp/${FILE}
    sed -ie 's#{/depth3}#\</h2\>#' ${SAVEPATH}/tmp/${FILE}
    sed -ie 's#{depth4}#\<h3\>#' ${SAVEPATH}/tmp/${FILE}
    sed -ie 's#{/depth4}#\</h3\>#' ${SAVEPATH}/tmp/${FILE}
    sed -ie 's#{\(nid-[0-9]*\)}#\<a name="\1"\>\</a\>#' ${SAVEPATH}/tmp/${FILE}


    sed -ie 's#<li\(.*\)<br />#\<li\1ttt#' ${SAVEPATH}/tmp/${FILE}
    sed -ie '/ttt/{N;s/ttt\n//}' ${SAVEPATH}/tmp/${FILE}


    sed -ie 's/\&\#x2c\;/./g' ${SAVEPATH}/tmp/${FILE}
    sed -ie 's#http://lesswrong.ru#https://lesswrong.ru#g' ${SAVEPATH}/tmp/${FILE}
    grep 's$https://' ${SAVEPATH}/tmp/${FILE} | sed -e 's#</div>##' >${FBCONVPATH}/replace-some-urls.sed
    sed -e's/%\([0-9A-F][0-9A-F]\)/\\\\\x\1/g' ${FBCONVPATH}/replace-some-urls.sed | xargs echo -ne | sed 's/ s/\ns/g' >${FBCONVPATH}/replace-some-urls.sed2

    echo ${FBCONVPATH}/replace-some-urls.sed
    echo ${FBCONVPATH}/replace-some-urls.sed2

    sed '/--sed/,/sed--/d' ${SAVEPATH}/tmp/${FILE} >${SAVEPATH}/tmp/${FILE}-1
    sed -f ${FBCONVPATH}/replace-some-urls.sed ${SAVEPATH}/tmp/${FILE}-1 > ${SAVEPATH}/tmp/${FILE}-2
    sed -ie 's/<a href="#nid/\<a href="#nid/' ${SAVEPATH}/tmp/${FILE}-2

    sed -f ${FBCONVPATH}/clean-all-sequences.sed ${SAVEPATH}/tmp/${FILE}-2 > ${SAVEPATH}/tmp/${FILE}b.html
#exit
    sed -ie "/^ *$/d" ${SAVEPATH}/tmp/${FILE}b.html
    sed -ie "s#<body#\<meta name=\"author\" content=\"$AUTHOR\"\>\<body#" ${SAVEPATH}/tmp/${FILE}b.html

     echo $FBCONVPATH
    # Convert files
    python ${FBCONVPATH}/html2fb.py  --no_zip_output -i ${SAVEPATH}/tmp/${FILE}b.html -o ${SAVEPATH}/${FILE}.fb2 -f utf-8 -t utf-8
    echo ${SAVEPATH}/${FILE}.fb2
    sed -ie 's#</section></section></section></section></body>#\<\/section\>\<\/section\>\<\/section\>\<\/body\>#' ${SAVEPATH}/${FILE}.fb2
    sed -ie 's@xlink:href="#footnote\(.[^"]*\)"@ type="note" name="footnoteref\1" xlink:href="#footnote\1"@g' ${SAVEPATH}/${FILE}.fb2
    sed -ie 's@<a.*footnoterefref[^>]*>\([^<]*\)</a>@\<b\>\1\<\/b\>@' ${SAVEPATH}/${FILE}.fb2
#    sed -ie 's@footnoterefref@footnote@g' ${SAVEPATH}/${FILE}.fb2
#exit
    ebook-convert ${SAVEPATH}/tmp/${FILE}b.html ${SAVEPATH}/${FILE}.mobi --cover ${SAVEPATH}/lw.png --authors "${AUTHOR}" --level1-toc "//h:h1" --level2-toc "//h:h2" -v 
    #ebook-convert ${SAVEPATH}/tmp/${FILE}b.html ${SAVEPATH}/${FILE}.epub --cover ${SAVEPATH}/lw.png --authors "${AUTHOR}" --level1-toc "//h:h1" --level2-toc "//h:h2" -v 
    #ebook-convert ${SAVEPATH}/tmp/${FILE}b.html ${SAVEPATH}/${FILE}.mobi --cover ${SAVEPATH}/lwlogo.gif --authors "${AUTHOR}" --level1-toc "//h:h1" --level2-toc "//h:h2" -v 
    #ebook-convert ${SAVEPATH}/tmp/${FILE}b.html ${SAVEPATH}/${FILE}.epub --cover ${SAVEPATH}/lwlogo.jpg --authors "${AUTHOR}" --level1-toc "//h:h1" --level2-toc "//h:h2" -v 
   
    cd  ${SAVEPATH}/
    zip ${FILE}.fb2.zip ${FILE}.fb2
    ebook-convert ${SAVEPATH}/tmp/${NUM}b.html ${SAVEPATH}/${NUM}.mobi --cover https://lesswrong.ru/sites/all/themes/lw_testtheme/lw.png --authors "${AUTHOR}" --level1-toc "//h:h1" --level2-toc "//h:h2" -v 
    ebook-convert ${SAVEPATH}/tmp/${NUM}b.html ${SAVEPATH}/${NUM}.epub --cover https://lesswrong.ru/sites/all/themes/lw_testtheme/lw.png --authors "${AUTHOR}" --level1-toc "//h:h1" --level2-toc "//h:h2" -v 
    # Rename files
    mv ${SAVEPATH}/${NUM}.mobi ${SAVEPATH}/${FILE}.mobi
    mv ${SAVEPATH}/${NUM}.epub ${SAVEPATH}/${FILE}.epub
#    echo http://lesswrong.ru/files/${FILE}.new.tmp.fb2.zip
#    echo http://lesswrong.ru/files/${NUM}.new.tmp.epub
#    echo http://lesswrong.ru/files/${NUM}.new.tmp.mobi
#exit
#<div xmlns="http://www.w3.org/1999/xhtml">$(sed -n -e"/<annotation>/,/<\/annotation>/p" ${SAVEPATH}/${FILE}.fb2  |grep -v annotation)</div>
cat >>$OPDS <<END
  <entry>
    <title>${BOOKNAME[$NUM]}</title>
    <author>
      <name>$AUTHOR</name>
    </author>
    <id>urn:uuid:$(uuid)</id>
    <updated>$(date +%Y-%m-%dT%H:%M:%S%:z)</updated>
    <content type="xhtml">
      <div xmlns="http://www.w3.org/1999/xhtml">$(sed -n -f ${FBCONVPATH}/clean-opds.sed ${SAVEPATH}/${FILE}.fb2 |grep -v annotation)</div>
    </content>
    <link href="http://lesswrong.ru/files/${FILE}.epub" rel="http://opds-spec.org/acquisition/open-access" type="application/epub+zip" />
    <link href="http://lesswrong.ru/files/${FILE}.fb2.zip" rel="http://opds-spec.org/acquisition/open-access" type="application/fb2+zip"/>
    <link href="http://lesswrong.ru/files/${FILE}.mobi" rel="http://opds-spec.org/acquisition/open-access" type="application/x-mobipocket-ebook"/>
  </entry>

END
}

function nameencode {
    # usage: ebook id
     python -c "import urllib, sys; print urllib.quote(sys.argv[1])" $1
}

cd /home/berekuk/books/
        ebook
