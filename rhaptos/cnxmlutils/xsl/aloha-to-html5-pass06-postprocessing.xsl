<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:c="http://cnx.rice.edu/cnxml"
  xmlns:m="http://www.w3.org/1998/Math/MathML"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:md="http://cnx.rice.edu/mdml/0.4"
  xmlns:qml="http://cnx.rice.edu/qml/1.0"
  xmlns:mod="http://cnx.rice.edu/#moduleIds"
  xmlns:bib="http://bibtexml.sf.net/"
  
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:x="http://www.w3.org/1999/xhtml"
  
  xmlns:data="http://dev.w3.org/html5/spec/#custom"
  exclude-result-prefixes="x m mml"
  >

<xsl:output
  method="xml"
  encoding="ASCII"
  indent="no"/>

<xsl:strip-space elements="*"/>
<xsl:preserve-space elements="xh:p xh:span xh:li xh:td xh:a"/>

<!--
Postprocessing
- Remove title div and move it into title in head
-->

<!-- default copy all -->
<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- get right title from title div -->
<xsl:template match="//x:title[1]">
  <xsl:copy>
    <xsl:value-of select="//x:div[@class='title'][1]"/>
  </xsl:copy>
</xsl:template>

<!-- remove first div title which is doubled -->
<xsl:template match="//x:div[@class='title'][not(preceding::x:div[@class='title'])]"/>

<!-- <img> should not have empty string alt attribute (do not expect "decorative" images) 
     if the image alt is not empty, use it
     if the image alt is empty or does not exist, use the media/@alt if possible -->
<xsl:template match="x:img">
  <img>
    <xsl:choose>
      <xsl:when test="string-length(@alt)>0">
        <xsl:apply-templates select="@alt" />
      </xsl:when>
      <xsl:when test="parent::*/@class='media' and string-length(parent::*/@data-alt)>0">
        <xsl:attribute name="alt">
          <xsl:value-of select="parent::*/@data-alt" />
        </xsl:attribute>
      </xsl:when>
    </xsl:choose>
    <xsl:apply-templates select="@*[not(local-name()='alt')]"/>
    <xsl:apply-templates select="node()"/>
  </img>
</xsl:template>

</xsl:stylesheet>
