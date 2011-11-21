<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">

  <!-- During one of the earlier XSLT passes RED text is converted into XML.
        If this conversion fails, RED text is left as normal escaped text
        until this pass where it is unescaped again (but this time with CNXML)
    -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="text()[ancestor::*[@class='red-text']]
                      |text()[parent::*[starts-with(text(),'&lt;')]]">
    <xsl:value-of select="normalize-space(.)" disable-output-escaping="yes"/>
  </xsl:template>
</xsl:stylesheet>

