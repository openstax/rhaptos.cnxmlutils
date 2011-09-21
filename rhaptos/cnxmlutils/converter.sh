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

VERBOSE="" # Set to "-v" for additional debugging lines

# If more than one argument, use a temp dir
if [ '.' != ".${2}" ]; then
  echo "Creating temp dir for batch conversion"
  TMP_DIR=$(mktemp -d -t 'odt2cnxml')
else
  TMP_DIR=$(pwd)
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
  >
  <xsl:template match="text()">
    <xsl:value-of select="concat(&quot; &quot;, normalize-space(.), &quot; &quot;)"/>
<!--
    <xsl:value-of select="."/>
-->
  </xsl:template>
  <!-- Ignore "Untitled Document" -->
  <xsl:template match="c:document/c:title"/>
  <!-- ignore math text nodes because they are not in content.xml -->
  <xsl:template match="mml:*"/>
  <!-- Just the text "formula" -->
  <xsl:template match="svg:desc"/>
</xsl:stylesheet>
' > ${WF_XSL}

for f in $*
do
	
	if [ "." != ".${2}" ]; then
	if [ -e ${f}.xml ]; then
		echo "Skipping ${f} because it was successfully converted"
		continue
	fi
	fi
	
	echo "--------------------------"
	echo "Starting ${f}"
	echo "--------------------------"

  if [ "odt" = $(echo ${f#*.}) ]; then
    ODT_FILE=${f}
  else
  	#rm ${ODT_FILE}
    ${OOFFICE_BIN} -invisible "${OOFFICE_MACRO}(${f},${ODT_FILE})"

    #[ 0 = $? ] || echo "ERROR: Could not convert document to Open Office" && continue
    if [ 0 != $? ]; then
      echo "ERROR: Could not convert document to Open Office"
      continue
    fi
  fi
	
  python odt2cnxml.py ${VERBOSE} ${ODT_FILE} ${TMP_DIR} > ${f}.xml
  
  #if [ 0 != $? ]; then
  if [ -e ${SCHEMA} ]; then
    echo "INFO: Validating against Relax-NG Schema"
    ${JING_BIN} ${SCHEMA} ${f}.xml

  	if [ 0 != $? ]; then
	    echo "ERROR: Invalid CNXML ${f}"
	    mv ${f}.xml ${f}.xml.broken
  	  continue
	  fi
	fi
	#fi
	
  # So, here goes:
  # - Take all the text content from the original document
  # - Remove all spaces
  # - Put 1 character/line
  # - (then diff) to see how much was lost
  unzip -p ${ODT_FILE} content.xml | xsltproc ${WF_XSL} - | grep -o "[^\ ]\+" | tr -d '\n' | sed "s/\(.\)/\1\n/g" > ${WF_ORIG}
	xsltproc ${WF_XSL} ${f}.xml | grep -o "[^\ ]\+" | tr -d '\n' | sed "s/\(.\)/\1\n/g" > ${WF_CONV}
	
	
	if [ -s ${WF_ORIG} ]; then
	if [ -s ${WF_CONF} ]; then
	
	  
	  diff ${WF_ORIG} ${WF_CONV} > ${WF_TEMP}

  	if [ -s ${WF_TEMP} ]; then

      # When only running 1 conversion show the diff
      if [ "." = ".${2}" ]; then
        cat ${WF_TEMP}
      fi
  
      # The diff has entries like:
      # < h
      # < i
      awk '
        BEGIN { }
        /</     { orig += 1; acc1 = acc1 $2 }
        />/     { conv += 1; acc2 = acc2 $2 }
        /[0-9,cd]+/    { print acc1 " ]vs[ " acc2; acc1 = ""; acc2 = "" }
        /---/   { acc1 = acc1 " "; acc2 = acc2 " " }
        END   {
                print acc1 " ]vs[ " acc2;
                d  = orig  - conv;
                # Skirt Divide by 0 Error
                if(orig + conv == 0) {
                  orig = 1;
                }
                print d, "=DIFFS", (d / (orig + conv)), "=DIFFS/LINEISH"
        }
      ' ${WF_TEMP}
    fi
	fi
	fi

	echo "--------------------------"
	echo "INFO: Success!!!!!"
	echo "--------------------------"
done

if [ '.' != ".${2}" ]; then
  rm -d -f ${TMP_DIR}
fi
