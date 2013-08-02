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

<xsl:param name="id.prefix">a2h-</xsl:param>

<!--
Transforms headers to HTML5 sections.

Input example:
  <cnhtml:h titlecontent="Heading1" level="1">
    Heading1
    <cnhtml:h titlecontent="Heading2" level="2">
      Heading2
    </cnhtml:h>
  </cnhtml:h>

Output:
  <section>
    <h1>Heading1</h1>
    <section>
      <h2>Heading2</h2>
    </section>
  </section>

-->

<!-- default copy all -->
<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- Convert headers into sections -->
<xsl:template match="cnhtml:h">
  <xsl:element name="section">
    <xsl:if test="@id">
      <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
    </xsl:if>
    <xsl:if test="not(@id)">
      <xsl:attribute name="id">
        <xsl:value-of select="$id.prefix"/>
        <xsl:value-of select="generate-id()"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:attribute name="data-depth"><xsl:value-of select="@level"/></xsl:attribute>
    <xsl:apply-templates mode="section-data-attr" select="@*[starts-with(local-name(), 'data-')]
                                                            [not(starts-with(local-name(), 'data-header'))]"/>
    <xsl:element name="h{@level}">
      <xsl:attribute name="class">title</xsl:attribute>
      <xsl:if test="@data-header-id">
        <xsl:attribute name="id"><xsl:value-of select="@data-header-id"/></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates mode="header-data-attr" select="@*[starts-with(local-name(), 'data-header')]
                                                             [not(local-name()='data-header-id')]"/>
      <xsl:value-of select="@title"/>
    </xsl:element>
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

<xsl:template mode="section-data-attr" match="@*">
  <xsl:attribute name="{local-name()}"><xsl:value-of select="."/></xsl:attribute>
</xsl:template>

<xsl:template mode="header-data-attr" match="@*">
  <xsl:attribute name="data-{substring-after(local-name(), 'data-header-')}"><xsl:value-of select="."/></xsl:attribute>
</xsl:template>

<!-- remove @level which was only needed for section reconstruction -->
<xsl:template match="x:section/@level">
  <xsl:attribute name="data-depth"><xsl:value-of select="."/></xsl:attribute>
</xsl:template>

</xsl:stylesheet>
