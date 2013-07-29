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
<xsl:preserve-space elements="xh:p xh:span xh:li xh:td xh:a xh:h1 xh:h2 xh:h3 xh:h4 xh:h5 xh:h6"/> <!-- TODO: Is this really all content? Many HTML5 tags are not covered now -->

<!--
This XSLT transforms headers and lists of XHTML.

It transforms all tags: <h1>,<h2>,<h3>,<h4>,<h5>,<h6> to <cnhtml:h level="n">
e.g. <h1></h1> to <cnhtml:h level="1"></cnhtml:h>

It also transforms <section data-depth="n' class="complex-section"> to <section level="n' class="complex-section">
section.complex-section noeds are needed for sections which can not be represented as headers and then reconstructed 
back into section containers.

The level attribute is the driver in the section reconstruction transform.
-->

<!-- default copy all -->
<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- Change header to <h level="x"> -->
<xsl:template match="x:h1|x:h2|x:h3|x:h4|x:h5|x:h6"> 
  <xsl:variable name="title_nodeset">
    <xsl:apply-templates mode="cleantitle"/>
  </xsl:variable>
  <xsl:variable name="title_content">
    <xsl:value-of select="normalize-space(exsl:node-set($title_nodeset))"/>
  </xsl:variable>
  <xsl:variable name="level" >
    <xsl:choose>
    <xsl:when test="self::x:h1">1</xsl:when>
    <xsl:when test="self::x:h2">2</xsl:when>
    <xsl:when test="self::x:h3">3</xsl:when>
    <xsl:when test="self::x:h4">4</xsl:when>
    <xsl:when test="self::x:h5">5</xsl:when>
    <xsl:when test="self::x:h6">6</xsl:when>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:choose>
      <!-- convert empty headers to empty paragraphs -->
      <xsl:when test="string-length($title_content) &lt;= 0">
          <p>
            <xsl:apply-templates/>
          </p>
      </xsl:when>
      <!-- convert headings inside lists to paragraphs -->
      <xsl:when test="ancestor::x:li">
          <p>
              <xsl:apply-templates/>
          </p>
      </xsl:when>
      <xsl:otherwise>
        <cnhtml:h>
            <xsl:message>INFO: Renaming HTML header to leveled header</xsl:message>
            <!-- insert level attribute -->
            <xsl:attribute name="level"><xsl:value-of select="$level"/></xsl:attribute>

            <!-- copy header text and also remove all stylings of a header -->
            <xsl:attribute name="title">
              <xsl:value-of select="$title_content"/>
            </xsl:attribute>

            <!-- copy all remaining attributes -->
            <xsl:apply-templates select="@*[not(local-name() = 'data-depth')]"/>

            <!-- copy all children which do not have any content -->
            <xsl:apply-templates/>
        </cnhtml:h>
      </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="x:section[@class='complex-section']">
  <xsl:element name="section">
    <xsl:attribute name="level"><xsl:value-of select="@data-depth"/></xsl:attribute>
    <xsl:apply-templates select="@*[not(local-name() = 'data-depth')]"/>
    
    <xsl:apply-templates mode="complex" select="x:h1|x:h2|x:h3|x:h4|x:h5|x:h6"/>
    <xsl:apply-templates select="node()[not(self::x:h1|self::x:h2|self::x:h3|self::x:h4|self::x:h5|self::x:h6)]"/>
  </xsl:element>
</xsl:template>

<xsl:template mode="complex" match="x:h1|x:h2|x:h3|x:h4|x:h5|x:h6">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>
