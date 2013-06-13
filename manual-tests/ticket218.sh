#! /bin/sh
cd ..
python -m rhaptos.cnxmlutils.aloha2html ./rhaptos/cnxmlutils/tests/data/ticket218.aloha.html >/tmp/temp218.html
python -m rhaptos.cnxmlutils.html2validcnxml /tmp/temp218.html
