<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">

  <xsl:output indent="yes"/>

  <!-- During one of the earlier XSLT passes RED text is converted into XML.
        If this conversion fails, RED text is left as normal escaped text
        until this pass where it is unescaped again (but this time with CNXML)
    -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  <!-- Discard the @class -->
  <xsl:template match="@class[. = 'cnx.red-text']"/>
  <!-- And print out the text -->
  <xsl:template match="text()[ancestor::*[@class='cnx.red-text']]">
    <!-- Convert "pretty" apostrophes and quotes to simple ones -->
    <xsl:value-of select="translate(normalize-space(.), '&#8220;&#8221;&#8217;', '&quot;&quot;&quot;')" disable-output-escaping="yes"/>
  </xsl:template>
  <!-- (but don't output the wrapped para) -->
  <xsl:template match="*[@class='cnx.red-text']">
<xsl:text>
</xsl:text>
    <xsl:apply-templates select="node()"/>
  </xsl:template>
</xsl:stylesheet>

