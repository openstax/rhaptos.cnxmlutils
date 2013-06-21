<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:c="http://cnx.rice.edu/cnxml"
  xmlns:m="http://www.w3.org/1998/Math/MathML"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:md="http://cnx.rice.edu/mdml/0.4"
  xmlns:qml="http://cnx.rice.edu/qml/1.0"
  xmlns:mod="http://cnx.rice.edu/#moduleIds"
  xmlns:bib="http://bibtexml.sf.net/"
  
  xmlns:data="http://dev.w3.org/html5/spec/#custom"
  exclude-result-prefixes="m mml"
  >

<xsl:output omit-xml-declaration="yes" encoding="ASCII"/>

<!--
Converts HTML5 (from CNXML to HTML5) to Aloha simplified HTML5.
This simplified Aloha HTML5 fits more the Aloha structure and editing.
-->

<!-- default copy all -->
<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- remove div sections -->
<xsl:template match="div[@class='section']">
  <xsl:apply-templates/>
</xsl:template>

<!-- remove classes from strong and emphasis -->
<xsl:template match="strong|em|table|body">
  <xsl:element name="{local-name()}">
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

<xsl:template match="span[@class='media']">
  <xsl:apply-templates/>
</xsl:template>

</xsl:stylesheet>
