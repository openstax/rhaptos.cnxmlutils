#! /bin/sh
# 
# Processes CNXML Plus to HTML to show which elements/attributes are preserved
#

cd ..

# Switches dir to the correct rhaptos
current_dir=pwd
testbed_output_dir='cnxml2htmlpreview/testbed_cnx_output'

# Prettifies the input
# xsltproc cnxml2htmlpreview/indent.xsl $1 > cnxml_input_clean.xml
cat $1  | tidy -utf8 -xml -w 255 -i -c -q -asxml > cnxml_input_clean.xml

# Generates an html preview of the xslt transform
python cnxml2htmlpreview/cnxml2htmlpreview.py $1 > $testbed_output_dir/cnxml2html_output.html

# Uses the aloha to html transform to convert it to 'structured' html
./aloha2html.sh  $testbed_output_dir/cnxml2html_output.html > $testbed_output_dir/alohahtml2html_output.html

# Transforms html back to cnxml
./html2validcnxml.sh $testbed_output_dir/alohahtml2html_output.html > $testbed_output_dir/cnxml_output.cnxml

# Prettifies the output
# xsltproc indent.xsl cnxml_output.xml > cnxml_output_clean.xml
cat $testbed_output_dir/cnxml_output.cnxml  | tidy -utf8 -xml -w 255 -i -c -q -asxml > cnxml_output_clean.xml
