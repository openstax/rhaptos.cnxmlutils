#! /bin/sh

#Copyright (C) 2013 Rice University
#
#This software is subject to the provisions of the GNU AFFERO GENERAL PUBLIC LICENSE Version 3.0 (AGPL).  
#See LICENSE.txt for details.

cd ..
python -m rhaptos.cnxmlutils.aloha2html ./rhaptos/cnxmlutils/tests/data/math_ticket168.aloha.html >/tmp/math_ticket168.html
python -m rhaptos.cnxmlutils.html2validcnxml /tmp/math_ticket168.html
