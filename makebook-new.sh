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
CALPATH="$CODE_ROOT/calibre"
COMMENT="'Released under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported license. CC BY-NC-SA 3.0'"
OPDS="$SAVEPATH/opds2.xml"

declare -A BOOKNAME
BOOKNAME[164]="Против рационализации"
BOOKNAME[218]="Ложные убеждения"
BOOKNAME[219]="Замечая замешательсво"
BOOKNAME[217]="Предсказуемо неправы"
BOOKNAME[192]="Редукционизм"
BOOKNAME[109]="Смертельные спирали и аттрактор культа"
BOOKNAME[111]="Бросая вызов сложностям"
BOOKNAME[146]="Свежий взгляд на вещи"
BOOKNAME[220]="Мистические ответы"
BOOKNAME[221]="Чрезвычайно удобные оправдания"
BOOKNAME[222]="Политика и рациональность"
BOOKNAME[224]="Против двоемыслия"
BOOKNAME[76]="Живя осознанно"
 BOOKNAME[499]="Время молотка"
#BOOKNAME[32]="Самодостаточные материалы"
#BOOKNAME[]=

function ebook {
    # usage: ebook id
    NUM=$1 # ${NUM}
    FILE=${BOOKNAME[$1]// /_} # ${FILE}
    AUTHOR="Eliezer Yudkowsky" 

    if [[ "${NUM}" == "76" ]]; then
    AUTHOR="Hanna Finley"
    echo Author ${AUTHOR} is set for book ${FILE}
    fi

    if [[ "${NUM}" == "32" ]]; then
    AUTHOR="Different authors"
    echo Author ${AUTHOR} is set for book ${FILE}
    fi

    echo Converting book №${NUM}, title ${FILE}
    echo Download ${URL}${BOOKURL}${NUM} --output-document=${SAVEPATH}/tmp/${NUM}
    wget ${URL}${BOOKURL}${NUM} --output-document=${SAVEPATH}/tmp/${NUM}
    sed -f ${FBCONVPATH}/clean.sed ${SAVEPATH}/tmp/${NUM} > ${SAVEPATH}/tmp/${NUM}b.html
    sed -ie "/^ *$/d" ${SAVEPATH}/tmp/${NUM}b.html
    sed -ie "s#<body#\<meta name=\"author\" content=\"$AUTHOR\"\>\<body#" ${SAVEPATH}/tmp/${NUM}b.html

#    awk '/<\/h1>/{p=1;print}/<div class="field field-name-field-author/{p=0}!p' ${SAVEPATH}/tmp/${NUM}a > ${SAVEPATH}/tmp/${NUM}b.html
    # Convert files
    python ${FBCONVPATH}/html2fb.py  --no_zip_output -i ${SAVEPATH}/tmp/${NUM}b.html -o ${SAVEPATH}/${FILE}.fb2 -f utf-8 -t utf-8
    sed -ie 's#</section></section>#\<\/section\>#' ${SAVEPATH}/${FILE}.fb2
    cd  ${SAVEPATH}/
    zip ${FILE}.fb2.zip ${FILE}.fb2
    ebook-convert ${SAVEPATH}/tmp/${NUM}b.html ${SAVEPATH}/${NUM}.mobi --cover ${SAVEPATH}/lwlogo.gif --authors "${AUTHOR}" --level1-toc "//h:h1" --level2-toc "//h:h2" -v 
    ebook-convert ${SAVEPATH}/tmp/${NUM}b.html ${SAVEPATH}/${NUM}.epub --cover ${SAVEPATH}/lwlogo.jpg --authors "${AUTHOR}" --level1-toc "//h:h1" --level2-toc "//h:h2" -v 
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

function makelist {
# usage: ebook id
    NUM=$1 # ${NUM}
    NAME=${BOOKNAME[$1]} # ${NAME}
    FILE=`nameencode ${BOOKNAME[$1]// /_}` # ${FILE}
    echo \#\# Цепочка «${NAME}» \#\#>> ${SAVEPATH}/content.md
    echo \<ul  class=\"links inline\"\>>> ${SAVEPATH}/content.md
    echo \<li\>\<a href=\"/files/${FILE}.epub\"\>\[EPUB\]\</a\>\</li\>>> ${SAVEPATH}/content.md
    echo \<li\>\<a href=\"/files/${FILE}.fb2.zip\"\>\[FB2\]\</a\>\</li\>>> ${SAVEPATH}/content.md
    echo \<li\>\<a href=\"/files/${FILE}.mobi\"\>\[MOBI\]\</a\>\</li\>>> ${SAVEPATH}/content.md
    echo \</ul\>>> ${SAVEPATH}/content.md
    echo >> ${SAVEPATH}/content.md
    echo >> ${SAVEPATH}/content.md
}

function cleanfiles 
{
# Cleanin of old books
rm -f ${SAVEPATH}/*.mobi
rm -f ${SAVEPATH}/*.epub
rm -f ${SAVEPATH}/*.zip
rm -f ${SAVEPATH}/*.fb2.zip
rm -f ${SAVEPATH}/tmp/*
rm -f ${CACHEPATH}/*
}

# Cleaning
cleanfiles

cat >$OPDS <<END
<?xml version='1.0' encoding='utf-8'?>
<feed xmlns:opds="http://opds-spec.org/2010/catalog" xmlns:dc="http://purl.org/dc/terms/" xmlns="http://www.w3.org/2005/Atom">
  <title>Рациональное мышление</title>
  <subtitle>Статьи и художественная литература</subtitle>
  <author>
      <name>Элиезер Юдковский</name>
      <uri>http://lesswrong.ru/files/opds2.xml</uri>
  </author>
  <id>calibre-all:timestamp</id>
  <icon>http://lesswrong.ru/favicon.ico</icon>
  <updated>$(date +%Y-%m-%dT%H:%M:%S%:z)</updated>
  <link type="application/atom+xml;type=feed;profile=opds-catalog" rel="start" href="http://lesswrong.ru/files/opds2.xml"/>
  <link type="application/atom+xml;type=feed;profile=opds-catalog" rel="up" href="http://lesswrong.ru/files/opds2.xml"/>
END

# Convert Loop
for everybook in ${!BOOKNAME[@]}; do
        ebook ${everybook}
done

# Make ebook list file
rm ${SAVEPATH}/content.md
for everybook in ${!BOOKNAME[@]}; do
        makelist ${everybook}
done

cat >>$OPDS <<END
</feed>
END
