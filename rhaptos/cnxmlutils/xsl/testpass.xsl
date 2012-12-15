<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:x="http://www.w3.org/1999/xhtml"
  >

<xsl:output omit-xml-declaration="yes" encoding="ASCII"/>

<!-- default copy all -->
<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- Change header to <h level="x"> -->
<xsl:template match="x:h1|x:h2|x:h3|x:h4|x:h5|x:h6"> 
  <xsl:message>it matches</xsl:message>
</xsl:template>

</xsl:stylesheet>
