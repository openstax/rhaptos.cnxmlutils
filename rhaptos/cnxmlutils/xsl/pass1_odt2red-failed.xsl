<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  
  xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
  version="1.0">

<xsl:output encoding="ASCII"/>

<xsl:template match="office:text">
  <xsl:copy>
    <xsl:apply-templates select="@*"/>
    <xsl:processing-instruction name="cnx.error">Converting Red text to XML failed.</xsl:processing-instruction>
    <xsl:apply-templates select="node()"/>
  </xsl:copy>
</xsl:template>


<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>