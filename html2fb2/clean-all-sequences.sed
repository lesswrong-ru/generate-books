/^$/d
/^ *$/d
/Page cached by Boost/ d
/<script/,/<\/script>/d
/Yandex/,/\/Yandex/d
/<nav/,/\/nav>/d
#Работа с заголовками глав
s#caption>#h1\>#g
s#h6>#h2\>#g
s#<table#<div#g
s#table>#div>#g
#Работа со сносками
s/all-sequences#footnoteref/#footnoteref/g
s/all-sequences#footnote/#footnote/g
s#id="\(footnoteref\)#name="\1#
s#<li class="footnote" id="\(.*\)">\(<a.*\)</li>#<p><a name="\1"></a>\2</p>#
#s#<li class="footnote" id="\(.*\)">\(<a.*\)</li>#<section id="\1">\2</section>#
#Окончательные подчистки
s#<div class="field-items">##g
s# *<div id="node-[0-9]*" class="section-[0-9]*">##
s#</div>##g
s#</div></div></div></div>##
#s#</html>#\</section\>#
/class="section-1"/ d
/class="breadcrumb"/ d
/img style/ d
/span style/ d
/<td/ d
/td>/ d
/<tr/ d
/tr>/ d
/<tbody/ d
/tbody>/ d
/<header/ d
/header>/ d
/"view-/ d
/]]>/ d
