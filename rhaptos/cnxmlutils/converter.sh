#! /bin/sh

if [ "." = ".${1}" ]; then
  echo "--------------------------------------"
  echo 'Pass in odt doc, or docx files as arguments'
  echo "You will need to add a macro to Open Office. See this script's source"
  echo "Also, be sure to change the OOFFICE_BIN in this file to point to open office"
  echo "Feel free to replace '${XSLTPROC}' with a simple java class file on Windows machines"
  echo "Finally, when importing you can safely ignore everything except lines that begin with 'ERROR:'. I use 'WARNING' and 'DEBUG' in the obvious way"
  echo "--------------------------------------"
fi

# When more than 1 file is provided run in batch mode (less printing)
[ '.' == ".${2}" ]
BATCH=$?

if [ ${BATCH} -ne 0 ]; then
  TMP_DIR=$(mktemp -d -t 'odt2cnxml')
  STDERR=${TMP_DIR}/stderr.txt
else
  TMP_DIR=$(pwd)
  STDERR="/dev/stderr"
  VERBOSE="-v"
fi


OOFFICE_BIN='/Applications/OpenOffice.org.app/Contents/MacOS/soffice'
OOFFICE_MACRO='macro:///Standard.Module1.SaveAsOOO'
#' The content of the Macro is as follows
#' (Tools, Macros, Organize Macros, Open Office.org Basic..., click Standard, click New:
#
#' Save document as an OpenOffice 2 file. 
#Sub SaveAsOOO( cFile, dFile ) 
#   ' mostly a copy of SaveAsPDF. Save as an OpenOffice file. 
#   cURL = ConvertToURL( cFile )
#   oDoc = StarDesktop.loadComponentFromURL( cURL, "_blank", 0, _
#            Array(MakePropertyValue( "Hidden", True ),))
#   dURL = ConvertToURL( dFile )
#   
#   On Error Goto ErrorHandler
#   	 oDoc.storeAsURL( dURL, Array() )
#   	 oDoc.close( True )
#   ErrorHandler:
#
#End Sub



ROOT=`dirname "$0"`
ROOT=`cd "$ROOT"; pwd`

JING_BIN="java -jar ${ROOT}/jing/jing.jar"
SCHEMA="${ROOT}/jing/schema/cnxml-jing.rng"

XSLTPROC="xsltproc -xinclude"

ODT_FILE="${TMP_DIR}/temp.odt"

# For comparing word counts
WF_ORIG=${TMP_DIR}/wf-orig.txt
WF_CONV=${TMP_DIR}/wf-conv.txt
WF_XSL=${TMP_DIR}/wf-xsl.txt
WF_TEMP=${TMP_DIR}/wf-temp.txt

echo '
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:c="http://cnx.rice.edu/cnxml"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0"
  xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
  >
  <xsl:template match="text()">
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>
  <!-- Ignore "Untitled Document" -->
  <xsl:template match="c:document/c:title"/>
  <!-- ignore math text nodes because they are not in content.xml -->
  <xsl:template match="mml:*"/>
  <!-- Just the text "formula" -->
  <xsl:template match="svg:desc"/>
  <!-- Ignore change sets -->
  <xsl:template match="text:changed-region|text:change-start|text:change-end"/>
</xsl:stylesheet>
' > ${WF_XSL}


test ${BATCH} -ne 0 && echo "Filename \tErrors-or-Warnings \t#-Diffs \t%of-text-diff \tRNG-invalid"


for f in $*
do
		
	if [ ${BATCH} -ne 0 ]; then
	if [ -e ${f}.cnxml ]; then
		echo "Skipping ${f} because it was successfully converted"
		continue
	fi
	fi
	
  if [ ${BATCH} -eq 0 ]; then
    echo "--------------------------"
    echo "Starting ${f}"
    echo "--------------------------"
  fi
  
  # Batch-mode: Just print stats
  test ${BATCH} -ne 0 && printf "${f}"


  if [ "odt" = $(echo ${f#*.}) ]; then
    ODT_FILE=${f}
  else
  	#rm ${ODT_FILE}
    ${OOFFICE_BIN} -invisible "${OOFFICE_MACRO}(${f},${ODT_FILE})"

    # If there was an error or the file didn't generate print error
    if [ 0 != $? -o ! -s ${ODT_FILE} ]; then
      echo "ERROR: Could not convert document to Open Office"
      continue
    fi
  fi
	
  python odt2cnxml.py ${VERBOSE} ${ODT_FILE} ${TMP_DIR} > ${f}.xml 2> ${STDERR}
  
  # Print the number of warnings/errors
  test ${BATCH} -ne 0 && printf "\t$(cat ${STDERR} | wc -l)"
  
  # So, here goes:
  # - Take all the text content from the original document
  # - Remove all spaces
  # - Put 1 character/line
  # - (then diff) to see how much was lost
  unzip -p ${ODT_FILE} content.xml | xsltproc ${WF_XSL} - | grep -o "[^\ ]\+" | tr -d '\n' | sed "s/\(.\)/\1\n/g" > ${WF_ORIG}
	xsltproc ${WF_XSL} ${f}.xml | grep -o "[^\ ]\+" | tr -d '\n' | sed "s/\(.\)/\1\n/g" > ${WF_CONV}
	
	DIFF_COUNT=0    # If there are no diffs then these are 0 by default
	DIFF_PERCENT=0
	if [ -s ${WF_ORIG} ]; then
	if [ -s ${WF_CONV} ]; then
    if [ $(cat ${WF_ORIG} | wc -l) -lt $(cat ${WF_CONV} | wc -l) ]; then
      MAX_SIZE=$(cat ${WF_CONV} | wc -l)
    else
      MAX_SIZE=$(cat ${WF_ORIG} | wc -l)
    fi
	  
	  diff ${WF_ORIG} ${WF_CONV} > ${WF_TEMP}

  	if [ -s ${WF_TEMP} ]; then

      # The diff has entries like:
      # < h
      # < i
      DIFF_COUNT=$(awk "
        BEGIN { }
        /</         { orig += 1; acc1 = acc1 \$2 }
        />/         { conv += 1; acc2 = acc2 \$2 }
        /[0-9,cd]+/ {
                      if(${BATCH} == 0) {
                        print acc1 \" ]vs[ \" acc2 > \"/dev/stderr\";
                      }
                      acc1 = \"\"; acc2 = \"\";
                    }
        /---/       { acc1 = acc1 \" \"; acc2 = acc2 \" \" }
        END         {
                      if(${BATCH} == 0) {
                        print acc1 \" ]vs[ \" acc2 > \"/dev/stderr\";
                      }
                      d  = orig  + conv;
                      print d
                    }
      " ${WF_TEMP})
      
      DIFF_PERCENT=$(echo "scale=2;(${DIFF_COUNT} *100) / ${MAX_SIZE}" | bc)
    fi
	fi
	fi

  test ${BATCH} -ne 0 && printf "\t${DIFF_COUNT}\t${DIFF_PERCENT}"
  
  test ${BATCH} -eq 0 && echo "DIFFS: " ${DIFF_COUNT} ${DIFF_PERCENT}


  # Validate!
  #if [ 0 != $? ]; then
  if [ -e ${SCHEMA} ]; then
    test ${BATCH} -eq 0 && echo "INFO: Validating against Relax-NG Schema"

    ${JING_BIN} ${SCHEMA} ${f}.xml > ${STDERR} 2>&1
    VALID=$?

  	if [ 0 != ${VALID} ]; then

  	  test ${BATCH} -eq 0 && echo "ERROR: Invalid CNXML ${f}"
  	  test ${BATCH} -ne 0 && echo "\tinvalid" #newline

  	  continue
	  fi
	fi
	#fi
	
	test ${BATCH} -ne 0 && echo "" # newline
	if [ ${BATCH} -eq 0 ]; then
    echo "--------------------------"
    echo "INFO: Success!!!!!"
    echo "--------------------------"
  fi

  mv ${f}.xml ${f}.cnxml
done

if [ '.' != ".${2}" ]; then
  rm -d -f ${TMP_DIR}
fi
