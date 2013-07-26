<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xh="http://www.w3.org/1999/xhtml"
  xmlns:cnhtml="http://cnxhtml"
  exclude-result-prefixes="xh">

<xsl:output
  method="xml"
  encoding="ASCII"
  indent="no"/>

<xsl:strip-space elements="*"/>
<xsl:preserve-space elements="xh:p xh:span xh:li xh:td xh:a"/>

<!--
- Merges DIVs
- Remove not needed header content
- Remove scripts, comments

Example input:
<body><div>Hello<div> this <div> is </div>some </div>text</div></body>

Output
<body>Hello this is some text</body>
-->

<!-- Default: copy everything -->
<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- remove everything from header except title and metadata -->
<xsl:template match="xh:head/xh:*[not(self::xh:title or self::xh:meta)]"/>

<!-- remove comments -->
<xsl:template match="comment()"/>

<!-- remove scripts -->
<xsl:template match="xh:script"/>

<!-- remove section/@data-depth which was needed for section reconstruction -->
<xsl:template match="xh:section/@data-depth"/>

</xsl:stylesheet>
