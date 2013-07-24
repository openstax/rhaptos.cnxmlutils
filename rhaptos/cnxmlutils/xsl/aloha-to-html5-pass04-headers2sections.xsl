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
  <section>
    <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
    <xsl:attribute name="data-class"><xsl:value-of select="@data-class"/></xsl:attribute>
    <xsl:attribute name="data-type"><xsl:value-of select="@data-type"/></xsl:attribute>
    <xsl:element name="h{@level}">
      <xsl:attribute name="id"><xsl:value-of select="@data-header-id"/></xsl:attribute>
      <xsl:attribute name="data-class"><xsl:value-of select="@data-header-class"/></xsl:attribute>
      <xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
      <xsl:value-of select="@title"/>
    </xsl:element>
    <xsl:apply-templates/>
  </section>
</xsl:template>

</xsl:stylesheet>
