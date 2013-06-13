#! /bin/sh
cd ..
python -m rhaptos.cnxmlutils.aloha2html ./rhaptos/cnxmlutils/tests/data/math_ticket168.aloha.html >/tmp/math_ticket168.html
python -m rhaptos.cnxmlutils.html2validcnxml /tmp/math_ticket168.html
