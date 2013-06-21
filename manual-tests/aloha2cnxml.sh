#! /bin/sh -vx
#Copyright (C) 2013 Rice University
#
#This software is subject to the provisions of the GNU AFFERO GENERAL PUBLIC LICENSE Version 3.0 (AGPL).  
#See LICENSE.txt for details.

cd ..

htmltemp=/tmp/$$.html
cnxmltemp=/tmp/$$.cnxml
python -m rhaptos.cnxmlutils.aloha2html $1 > $htmltemp
python -m rhaptos.cnxmlutils.html2validcnxml $htmltemp > $cnxmltemp
