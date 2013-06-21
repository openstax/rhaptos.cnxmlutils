#! /bin/sh
cd ..
python -m rhaptos.cnxmlutils.aloha2html ./rhaptos/cnxmlutils/tests/data/underline.html >/tmp/underline.html
python -m rhaptos.cnxmlutils.html2validcnxml /tmp/underline.html
