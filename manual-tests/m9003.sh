#! /bin/sh
cd ..
python -m rhaptos.cnxmlutils.aloha2html ./rhaptos/cnxmlutils/tests/data/m9003.htm >/tmp/m9003.htm
python -m rhaptos.cnxmlutils.html2validcnxml /tmp/m9003.htm
