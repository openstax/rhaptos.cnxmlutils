<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:exsl="http://exslt.org/common"
  xmlns:c="http://cnx.rice.edu/cnxml"
  xmlns:m="http://www.w3.org/1998/Math/MathML"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:md="http://cnx.rice.edu/mdml/0.4"
  xmlns:qml="http://cnx.rice.edu/qml/1.0"
  xmlns:mod="http://cnx.rice.edu/#moduleIds"
  xmlns:bib="http://bibtexml.sf.net/"
  
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:x="http://www.w3.org/1999/xhtml"

  xmlns:cnhtml="http://cnxhtml"
  
  xmlns:data="http://dev.w3.org/html5/spec/#custom"
  extension-element-prefixes="exsl"
  exclude-result-prefixes="exsl x m mml"
  >

<xsl:output
  method="xml"
  encoding="ASCII"
  indent="no"/>

<xsl:strip-space elements="*"/>
<xsl:preserve-space elements="xh:p xh:span xh:li xh:td xh:a"/>

<!--
Transforms headers to nested headers.
Before and after this transformation the Google Docs HTML is no valid HTML anymore!

A treewalk algorithm is used to get nested headers.
How to use treewalk in XSLT: http://www.dpawson.co.uk/xsl/sect2/N4486.html#d5509e1105

Input example:
  <cnhtml:h level="1" titlecontent="Heading1">
    Heading1
  </cnhtml:h>
  <cnhtml:h level="2" titlecontent="Heading2">
    Heading2
  </cnhtml:h>

Output:
  <cnhtml:h titlecontent="Heading1">
    Heading1
    <cnhtml:h titlecontent="Heading2">
      Heading2
    </cnhtml:h>
  </cnhtml:h>
-->

<!-- default copy all -->
<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- At the beginning of body XSLT should walk step by step through the HTML -->
<xsl:template match="x:body">
  <xsl:message>start walking body</xsl:message>
  <xsl:copy>
    <xsl:apply-templates select="@*"/>
    <!-- start walking with first tag in body -->
    <xsl:apply-templates select="node()[1]" mode="walker_pass2">
      <xsl:with-param name="level" select="1"/>
    </xsl:apply-templates>
  </xsl:copy>
</xsl:template>

<!-- At the beginning of exercise/problem XSLT should walk step by step through the HTML -->
<xsl:template match="x:div[@class='exercise']/x:div[@class='problem' or @class='solution']">
  <xsl:message>start walking exercise/problem or exercise/problem</xsl:message>
  <xsl:copy>
    <xsl:apply-templates select="@*"/>
    <!-- start walking with first tag in body -->
    <xsl:apply-templates select="node()[1]" mode="walker_pass2">
      <xsl:with-param name="level" select="1"/>
    </xsl:apply-templates>
  </xsl:copy>
</xsl:template>

<!-- At the beginning of exercise/problem XSLT should walk step by step through the HTML -->
<xsl:template match="x:div[@class='rule']/x:div[@class='statement' or @class='proof']">
  <xsl:message>start walking rule/statement or rule/proof</xsl:message>
  <xsl:copy>
    <xsl:apply-templates select="@*"/>
    <!-- start walking with first tag in body -->
    <xsl:apply-templates select="node()[1]" mode="walker_pass2">
      <xsl:with-param name="level" select="1"/>
    </xsl:apply-templates>
  </xsl:copy>
</xsl:template>

<!-- At the beginning of example XSLT should walk step by step through the HTML -->
<xsl:template match="x:div[@class='example']">
  <xsl:message>start walking example</xsl:message>
  <xsl:copy>
    <xsl:apply-templates select="@*"/>
    <!-- start walking with first tag in body -->
    <xsl:apply-templates select="node()[1]" mode="walker_pass2">
      <xsl:with-param name="level" select="1"/>
    </xsl:apply-templates>
  </xsl:copy>
</xsl:template>

<!-- Convert headers into nested headers -->
<xsl:template match="cnhtml:h" mode="walker_pass2">
  <xsl:param name="level" select="1"/>
  <xsl:variable name="userlevel" select="@level"/>

  <!-- Just for debugging this should NEVER happen -->
  <xsl:if test="$userlevel &lt; $level">
    <!--
    <xsl:message><xsl:text>FAILURE IN EXECUTION! $userlevel is less than $level! This should never happen!</xsl:text></xsl:message>
    <xsl:message><xsl:value-of select="."/></xsl:message>
    -->
  </xsl:if>

  <!-- header found with a level greater or the same as the current level? If yes, create a nested header. -->
  <xsl:if test="$userlevel - $level &gt;= 0">
    <cnhtml:h>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates/>
      <xsl:apply-templates select="following-sibling::node()[1]" mode="walker_pass2">
        <xsl:with-param name="level" select="$level + 1"/>
      </xsl:apply-templates>
    </cnhtml:h>
  </xsl:if>

  <!-- Used for debugging
  <xsl:if test="$userlevel = 6">
    <xsl:message><xsl:value-of select="preceding-sibling::cnhtml:h[@level &lt; $userlevel][1]"/></xsl:message>
    <xsl:message><xsl:value-of select="generate-id(preceding-sibling::cnhtml:h[@level &lt; $userlevel][1])"/></xsl:message>
    <xsl:message><xsl:value-of select="following-sibling::cnhtml:h[@level = $userlevel][1]/preceding-sibling::cnhtml:h[@level &lt; $userlevel][1]"/></xsl:message>
    <xsl:message><xsl:value-of select="generate-id(following-sibling::cnhtml:h[@level = $userlevel][1]/preceding-sibling::cnhtml:h[@level &lt; $userlevel][1])"/></xsl:message>
    <xsl:message>=============================</xsl:message>
  </xsl:if>
   -->

  <!-- Is there a following header in the same level? -->
  <xsl:if test="following-sibling::*[self::cnhtml:h or self::x:section][@level = $userlevel][1]">  
    <!-- This part is very hard to understand:
       It compares if the first preceding header with a lower level is the same as the first preceding header 
       (with a lower level) for the following header with the same level.
       So it keeps sure that there is no lower level header in between the next header with the same level.
       In other words: It keeps sure that the tree is correct and no double tags are created ;)
    -->
    <xsl:if                                                                              test="generate-id(preceding-sibling::*[self::cnhtml:h or self::x:section][@level &lt; $userlevel][1])
             = generate-id(following-sibling::*[self::cnhtml:h or self::x:section][@level = $userlevel][1]/preceding-sibling::*[self::cnhtml:h or self::x:section][@level &lt; $userlevel][1])">
      <xsl:apply-templates select="following-sibling::*[self::cnhtml:h or self::x:section][@level = $userlevel][1]" mode="walker_pass2">
        <xsl:with-param name="level" select="$level"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:if>
</xsl:template>

<!-- Copy & Walk through the HTML -->
<xsl:template match="node()" mode="walker_pass2">
  <xsl:param name="level" select="1"/>
  <xsl:apply-templates select="."/>
  <!-- Do not process headers with lower level. -->
  <xsl:if test="not(following-sibling::node()[1]/self::cnhtml:h[@level &lt; $level]|
                    following-sibling::node()[1]/self::x:section[@level &lt; $level])">  
    <xsl:apply-templates select="following-sibling::node()[1]" mode="walker_pass2">
      <xsl:with-param name="level" select="$level"/>
    </xsl:apply-templates>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>
