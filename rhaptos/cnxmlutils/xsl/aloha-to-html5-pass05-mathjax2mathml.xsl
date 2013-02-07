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
Requires that MathML is unescaped with python!
- Removes unnecessary Mathjax spans
- Removes scripts surrounding math
- Fix math namespace
- Remove Firefox specific math

Input example:
  <span class="math-element">
    <math>
      <semantics>
        <mroot>
          <mrow>
          ...
  </span>

Output:
    <math>
      <semantics>
        <mroot>
          <mrow>
          ...
-->

<!-- default copy all -->
<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- math namespace fix -->
<xsl:template match="@*|node()" mode="math">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- math namespace fix -->
<xsl:template match="*" mode="math">
  <xsl:element name="{local-name()}" namespace="http://www.w3.org/1998/Math/MathML">
     <xsl:apply-templates select="@*"/>
     <xsl:apply-templates select="node()" mode="math"/>
   </xsl:element>
</xsl:template>

<!-- remove Firefox math attribute -->
<xsl:template match="@_moz-math-font-style"/>

<!-- remove MathJax' script -->
<xsl:template match="x:script[contains(@type, 'math')]"/>

<!-- remove <span class="math-element"> surrounding Mathjax' MathML content -->
<xsl:template match="x:span[@class='math-element']">
  <xsl:apply-templates />
</xsl:template>

<!-- math namespace fix -->
<xsl:template match="math">
  <xsl:element name="{local-name()}" namespace="http://www.w3.org/1998/Math/MathML">
     <xsl:apply-templates select="@*"/>
     <xsl:apply-templates select="node()" mode="math"/>
   </xsl:element>  
</xsl:template>

</xsl:stylesheet>
