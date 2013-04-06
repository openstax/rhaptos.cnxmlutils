#! /bin/sh
## Converts all the cnxml iles in the dir passed in through the first arg
dir=pwd
FILES=$1/*.cnxml
for f in $FILES
do
	echo "Processing file $f"
	./cnxml_plus_2_html.sh $f 2>> batch_result.txt
done