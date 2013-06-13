<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output
  method="xml"
  encoding="ASCII"
  indent="yes"/>

<!-- copy all and sort attributes by name -->
<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*">
      <xsl:sort select="name()"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="@*">
  <xsl:copy />     
</xsl:template>

</xsl:stylesheet>
