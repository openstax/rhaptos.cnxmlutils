<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:c="http://cnx.rice.edu/cnxml"
  exclude-result-prefixes="c"
  version="1.0">

<!-- Generates a message that is consumable by python (via json) -->

<xsl:template match="processing-instruction('cnx.error')">
  <xsl:call-template name="message">
    <xsl:with-param name="type">ERROR</xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="processing-instruction('cnx.warning')">
  <xsl:call-template name="message">
    <xsl:with-param name="type">WARNING</xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="processing-instruction('cnx.info')">
  <xsl:call-template name="message">
    <xsl:with-param name="type">INFO</xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template match="processing-instruction('cnx.debug')">
  <xsl:call-template name="message">
    <xsl:with-param name="type">DEBUG</xsl:with-param>
  </xsl:call-template>
</xsl:template>

<xsl:template name="message">
  <xsl:param name="type"/>
  <!-- TODO: Could also provide an xpath to the nearest element -->
  <xsl:message>{"level":"<xsl:value-of select="$type"/>", "id":"<xsl:value-of select="ancestor::*[@id][1]/@id"/>", "msg":"<xsl:value-of select="."/>"}</xsl:message>
  
  <!-- TODO: Don't propagate the processing-instruction -->
  <xsl:copy />
</xsl:template>


<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>