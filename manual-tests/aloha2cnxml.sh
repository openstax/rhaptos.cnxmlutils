#! /bin/sh -vx
cd ..
htmltemp=/tmp/$$.html
cnxmltemp=/tmp/$$.cnxml
python -m rhaptos.cnxmlutils.aloha2html $1 > $htmltemp
python -m rhaptos.cnxmlutils.html2validcnxml $htmltemp > $cnxmltemp
