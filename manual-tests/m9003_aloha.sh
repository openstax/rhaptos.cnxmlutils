#! /bin/sh
cd ..
python -m rhaptos.cnxmlutils.aloha2html ./rhaptos/cnxmlutils/tests/data/m9003_aloha_preview.htm  >/tmp/m9003_aloha.htm
python -m rhaptos.cnxmlutils.html2validcnxml /tmp/m9003_aloha.htm
