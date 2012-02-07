<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0"
  xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
  version="1.0">

<xsl:output encoding="ASCII"/>

<!-- This XSL only runs if the odt2red pass failed.
     It inserts a message saying conversion failed -->

<xsl:param name="message">No Default Message</xsl:param>

<!-- By default pass everything through. Not xincluded because eggs don't play nice -->
<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- If unescaping the red text failed, insert an error message so it shows up in EIP -->
<xsl:template match="office:text">
  <xsl:copy>
    <xsl:apply-templates select="@*"/>
    <xsl:processing-instruction name="cnx.error">Converting Red text to XML failed. Message: <xsl:value-of select="$message"/></xsl:processing-instruction>
    <xsl:apply-templates select="node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="@fo:color[translate(.,'ABCDEF','abcdef') = '#ff0000']">
  <xsl:attribute name="class">cnx.red-text</xsl:attribute>
</xsl:template>

</xsl:stylesheet>