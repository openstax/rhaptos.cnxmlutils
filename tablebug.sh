#! /bin/sh
python -m rhaptos.cnxmlutils.aloha2html ./rhaptos/cnxmlutils/tests/data/tablebug.htm >/tmp/tablebug.htm
python -m rhaptos.cnxmlutils.html2validcnxml /tmp/tablebug.htm
