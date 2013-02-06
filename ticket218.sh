#! /bin/sh
python -m rhaptos.cnxmlutils.aloha2html ./rhaptos/cnxmlutils/tests/data/ticket218.aloha.html >./temp218.html
python -m rhaptos.cnxmlutils.html2validcnxml ./temp218.html
