#!/bin/sh
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
FBCONVPATH="$CODE_ROOT/private/html2fb"
CALPATH="$CODE_ROOT/calibre"
COMMENT="'Released under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported license. CC BY-NC-SA 3.0'"

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
BOOKNAME[32]="Самодостаточные материалы"
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
    wget ${URL}${BOOKURL}${NUM} --output-document=${SAVEPATH}/tmp/${NUM}
    sed -f ${FBCONVPATH}/clean.sed ${SAVEPATH}/tmp/${NUM} > ${SAVEPATH}/tmp/${NUM}a
    awk '/<\/h1>/{p=1;print}/<div class="field field-name-field-author/{p=0}!p' ${SAVEPATH}/tmp/${NUM}a > ${SAVEPATH}/tmp/${NUM}b.html
    # Convert files
    ython ${FBCONVPATH}/html2fb.py -i ${SAVEPATH}/tmp/${NUM}b.html -o ${SAVEPATH}/${FILE}.fb2.zip -f utf-8 -t utf-8
    ${CALPATH}/ebook-convert ${SAVEPATH}/tmp/${NUM}b.html ${SAVEPATH}/${NUM}.mobi --cover ${SAVEPATH}/lwlogo.gif --authors "${AUTHOR}" --level1-toc "//h:h1" --level2-toc "//h:h2" -v 
    ${CALPATH}/ebook-convert ${SAVEPATH}/tmp/${NUM}b.html ${SAVEPATH}/${NUM}.epub --cover ${SAVEPATH}/lwlogo.jpg --authors "${AUTHOR}" --level1-toc "//h:h1" --level2-toc "//h:h2" -v 
    # Rename files
    mv ${SAVEPATH}/${NUM}.mobi ${SAVEPATH}/${FILE}.mobi
    mv ${SAVEPATH}/${NUM}.epub ${SAVEPATH}/${FILE}.epub
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
rm ${SAVEPATH}/*.mobi
rm ${SAVEPATH}/*.epub
rm ${SAVEPATH}/*.zip
rm ${SAVEPATH}/*.fb2.zip
rm ${SAVEPATH}/tmp/*
rm ${CACHEPATH}/*
}

# Cleaning
cleanfiles

# Convert Loop
for everybook in ${!BOOKNAME[@]}; do
        ebook ${everybook}
done

# Make ebook list file
rm ${SAVEPATH}/content.md
for everybook in ${!BOOKNAME[@]}; do
        makelist ${everybook}
done
