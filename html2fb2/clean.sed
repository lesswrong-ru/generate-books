/^$/d
/^ *$/d
/Page cached by Boost/ d
/<script /,/<\/script>/d
/<meta / d
s#<ul class="links.*</ul>##
s#<div class="field field-name-body field-type-text-with-summary field-label-hidden view-mode-print">##
s#<div class="field-item even" property="content:encoded">##
s#<div class="tex2jax">##
s#<div class="field field-name-field-author field-type-text field-label-hidden view-mode-print"><div class="field-items"><div class="field-item even">\(.*\)</div></div></div>#\<p\>\<i\>\1\</i\>\<\/p\>#
#Работа со строкой "Оригинал: ..."
s#<div class="field field-name-field-original-link field-type-link-field field-label-hidden view-mode-print"><div class="field-items"><div class="field-item even">\(.*\)</div></div></div>#\<p\>\<i\>Оригинал: \1\<\/i\>\<\/p\>\<p\>\<\/p\>\n#
#Работа со строкой "Перевод: ...
s#<section class="field field-name-field-translators field-type-text field-label-inline clearfix view-mode-print">##
s#</section>#\</i\>\</p\>\n#
s#<div class="field-item even">\(.*\)</div></div>#\1#
s#<h2 class="field-label">\(.*\)</h2>#\<p\>\<i\>\1#
#Работа с заголовками глав
s#<h1 class="book-heading">\(.*\)</h1>#\<h1\>\1\<\/h1\>#
#Окончательные подчистки
s#<div class="field-items">##g
s# *<div id="node-[0-9]*" class="section-[0-9]*">##
s#</div>##g
s#</div></div></div></div>##
#s#</html>#\</section\>#
/class="section-1"/ d
/class="breadcrumb"/ d
