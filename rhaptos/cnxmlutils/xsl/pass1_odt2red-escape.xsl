<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  
  xmlns="http://cnx.rice.edu/cnxml"
  
  xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0"
  xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" 
  xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0"

  version="1.0">

<!-- This stylesheet outputs LIGHT RED ( #ff0000 ) text in the document
     as raw XML. This step is unsafe and may fail (even 1 unmatched close tag).
     
     There is 1 more bit of cleanup done in the next pass because this outputs
     XML with no namespace.
-->

<xsl:output encoding="ASCII" indent="yes" method="xml"/>

<!-- By default pass everything through. Not xincluded because eggs don't play nice -->
<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>


<!-- Output all RED text regardless if it's in a span, para, heading, etc -->
<xsl:template match="*[text() and translate(@fo:color,'ABCDEF','abcdef') = '#ff0000']">
  <xsl:choose>
    <xsl:when test="count(node()) = 1 and 1 = count(text()) and string-length(normalize-space(text())) = 0">
      <xsl:processing-instruction name="cnx.debug">Silently ignoring red text with nothing in it</xsl:processing-instruction>
    </xsl:when>
<!--
    <xsl:when test="*">
      <xsl:processing-instruction name="cnx.error">RED text is reserved for XML snippets. This text has other things inside it like <xsl:for-each select="*"><xsl:value-of select="name()"/><xsl:text> </xsl:text></xsl:for-each></xsl:processing-instruction>
    </xsl:when>
    <xsl:when test="not(starts-with(normalize-space(text()), '&lt;'))">
      <xsl:processing-instruction name="cnx.error">RED text is reserved for XML snippets. Text: [<xsl:value-of select="substring(normalize-space(text()),1,40)"/>]</xsl:processing-instruction>
    </xsl:when>
-->
  </xsl:choose>

<!--
  <xsl:processing-instruction name="cnx.debug">Start RED escaped text from import</xsl:processing-instruction>
-->
  <!-- Convert "pretty" apostrophes and quotes to simple ones -->
  <xsl:value-of select="translate(., '&#8220;&#8221;&#8217;', '&quot;&quot;&quot;')" disable-output-escaping="yes"/>
<!--
  <xsl:processing-instruction name="cnx.debug">CNX: End RED escaped text from import</xsl:processing-instruction>
-->
</xsl:template>



<!-- Unwrap elements that only contain red text (like a para, or a span around the red text span) OR a para with some whitespace and then red text -->
<xsl:template match="*[count(*) &gt;= 1 and count(*) = count(*[translate(@fo:color,'ABCDEF','abcdef') = '#ff0000']) and normalize-space(text()) = '']
|
*[count(*[@fo:color = '#ff0000']) &gt;= 1 and not(*[not(self::text:span)]) and not(text:span[* or normalize-space(text()) != ''])]

">
<!--
  <xsl:processing-instruction name="cnx.debug">Wrapper element around element with just red XML text: <xsl:value-of select="name()"/></xsl:processing-instruction>
-->
  <xsl:apply-templates select="node()"/>
</xsl:template>


</xsl:stylesheet>
