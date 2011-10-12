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

# Open Office is only needed if the file extension isn't "odt"
OOFFICE_BIN='/Applications/OpenOffice.org.app/Contents/MacOS/soffice'
OOFFICE_MACRO='macro:///Standard.Module1.SaveAsOOO'
#' The content of the Macro is as follows
#' (Tools, Macros, Organize Macros, Open Office.org Basic..., click Standard, click New:
#
#Function MakePropertyValue( Optional cName As String, Optional uValue ) _
#   As com.sun.star.beans.PropertyValue
#   Dim oPropertyValue As New com.sun.star.beans.PropertyValue
#   If Not IsMissing( cName ) Then
#      oPropertyValue.Name = cName
#   EndIf
#   If Not IsMissing( uValue ) Then
#      oPropertyValue.Value = uValue
#   EndIf
#   MakePropertyValue() = oPropertyValue
#End Function
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
TEMP_XML=${TMP_DIR}/temp-content.xml
WF_ORIG=${TMP_DIR}/temp-orig.txt
WF_CONV=${TMP_DIR}/temp-conv.txt
WF_XSL=${TMP_DIR}/temp-xsl.txt
WF_TEMP=${TMP_DIR}/temp-wf.txt
ELEMENTS_XSL=${TMP_DIR}/temp-element-xsl.txt

# Extracts just the text content out of ODT and cnxml documents for diffing
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

# Prints every time an element occurs
echo '
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:c="http://cnx.rice.edu/cnxml"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  >
  <xsl:template match="c:*|mml:math">
    <xsl:message>
      <xsl:value-of select="name()"/>
      <xsl:apply-templates select="@*"/>
    </xsl:message>
    <xsl:apply-templates select="node()"/>
  </xsl:template>
  <!-- Print out the attributes (except for @id and @xml:id) -->
  <xsl:template match="@*">
    <xsl:text> </xsl:text>
    <xsl:value-of select="name()"/>
    <xsl:text>="</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>"</xsl:text>
  </xsl:template>

  <!-- Attributes that only get a printed name (but not value) get listed below -->
  <xsl:template match="@src|@document|@cols|@colname|@colnum|@url|@target-id">
    <xsl:text> </xsl:text>
    <xsl:value-of select="name()"/>
  </xsl:template>
  
  <!-- Ignored attributes and elements get listed below -->
  <xsl:template match="@id|@xml:id|@src"/>
  <xsl:template match="node()|c:document|c:content">
    <xsl:apply-templates select="node()"/>
  </xsl:template>
  
  <!-- Uncomment this to exclude "simple" conversions -->
  <xsl:template match="c:title|c:para|c:emphasis|c:list|c:item|c:table|c:tbody|c:tgroup|c:colspec|c:row|c:entry|c:link[@url]|c:figure|c:image|c:media">
    <xsl:message>__misc__</xsl:message>
    <xsl:apply-templates select="node()"/>
  </xsl:template>
</xsl:stylesheet>
' > ${ELEMENTS_XSL}


test ${BATCH} -ne 0 && echo "Filename \tErrors-or-Warnings \t#-Diffs \t%of-text-diff \tRichness \tRNG-invalid"

SCORE=0 # At the end of the run, a tally will show a "Richness" score. higher = better

for f in "$@"
do
		
  FULL_PATH=$(realpath "${f}")

  if [ ${BATCH} -eq 0 ]; then
    echo "--------------------------"
    echo "Starting ${f}"
    echo "--------------------------"
  fi
  
  # Batch-mode: Just print stats
  test ${BATCH} -ne 0 && printf "${f}"


  if [ "odt" = $(echo ${f#*.}) -o "doc.odt" = $(echo ${f#*.}) ]; then
    ODT_FILE=${f}
  else
    ${OOFFICE_BIN} -invisible "${OOFFICE_MACRO}(${FULL_PATH},${ODT_FILE})"

    # If there was an error or the file didn't generate print error
    if [ 0 != $? -o ! -s "${ODT_FILE}" ]; then
      echo "ERROR: Could not convert document to Open Office"
      continue
    fi
  fi
	
  python odt2cnxml.py ${VERBOSE} "${ODT_FILE}" ${TMP_DIR} > ${TEMP_XML} 2> ${STDERR}
  INVALID=$?
  
  # Print the number of warnings/errors
  MESSAGE_COUNT=0
  if [ ${BATCH} -ne 0 ]; then
    MESSAGE_COUNT=$(cat ${STDERR} | wc -l)
    printf "\t${MESSAGE_COUNT}"
  fi
  
  # So, here goes:
  # - Take all the text content from the original document
  # - Remove all spaces
  # - Put 1 character/line
  # - (then diff) to see how much was lost
  unzip -p "${ODT_FILE}" content.xml | xsltproc ${WF_XSL} - | grep -o "[^\ ]\+" | tr -d '\n' | sed "s/\(.\)/\1\n/g" > ${WF_ORIG}
	xsltproc ${WF_XSL} ${TEMP_XML} | grep -o "[^\ ]\+" | tr -d '\n' | sed "s/\(.\)/\1\n/g" > ${WF_CONV}
	
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

  # Print out all the "uncommon" elements generated by the conversion
  test ${BATCH} -eq 0 && xsltproc ${ELEMENTS_XSL} ${TEMP_XML} 2>&1 | sort | uniq -c | sort -n -r
  # Print out just a "richness" number, meaning a count of all the "uncommon" elements
    COMMON=$(xsltproc ${ELEMENTS_XSL} ${TEMP_XML} 2>&1 | grep "__misc__" | wc -l)
  UNCOMMON=$(xsltproc ${ELEMENTS_XSL} ${TEMP_XML} 2>&1 | grep -v "__misc__" | wc -l)
  RICHNESS=$(echo "scale=2;(${UNCOMMON}) / (${UNCOMMON} + ${COMMON})" | bc)
  test ${BATCH} -ne 0 && printf "\t${RICHNESS}"

  
  test ${BATCH} -ne 0 -a ${INVALID} -ne 0 && printf "\tinvalid"
  test ${BATCH} -ne 0 && echo "" #newline


  # Validate!
  if [ ${BATCH} -eq 0 -a -e ${SCHEMA} ]; then
    echo "INFO: Validating against Relax-NG Schema"

    ${JING_BIN} ${SCHEMA} ${TEMP_XML}
    VALID=$?

  	if [ 0 != ${VALID} ]; then
  	  echo "ERROR: Invalid CNXML ${f}"
    else
      echo "INFO: Success!!!!!"
	  fi
	fi
	
  VALID_POINTS=0
	if [ ${INVALID} -eq 0 ]; then
	  VALID_POINTS=200
	fi

  test ${BATCH} -ne 0 && rm ${TEMP_XML}
  
  SCORE=$(echo "scale=2;${SCORE} + ${MESSAGE_COUNT} + (100 - ${DIFF_PERCENT}) + (1000 * ${RICHNESS}) + ${VALID_POINTS}" | bc)

done

if [ '.' != ".${2}" ]; then
  rm -r -d -f ${TMP_DIR}
fi

# Score is weighted # of:
#   warnings (low)
# + %text-preserved (med)
# + semantically-rich-content (high)
# + validates (very-high)
#
# With each checkin this number should be monotonically increasing
echo "Score:" ${SCORE}
