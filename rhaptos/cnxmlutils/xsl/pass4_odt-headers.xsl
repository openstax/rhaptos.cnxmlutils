<?xml version="1.0"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:c="http://cnx.rice.edu/cnxml"

  xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0"
  xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
  exclude-result-prefixes="c office text"
  version="1.0">

  <!-- Convert the RED escaped text to fit in the CNXML namespace
       See previous pass
    -->
  <xsl:template match="*[namespace-uri()='']">
    <xsl:element name="c:{local-name()}">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:element>
  </xsl:template>

<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- At the beginning of body XSLT should walk step by step through the HTML -->
<xsl:template match="office:text|c:section">
  <xsl:copy>
    <xsl:apply-templates select="@*"/>
    <!-- start walking with first tag in body -->
    <xsl:apply-templates select="node()[1]" mode="walker">
    </xsl:apply-templates>
  </xsl:copy>
</xsl:template>

<!-- Convert headers into nested headers -->
<xsl:template match="text:h" mode="walker">
  <xsl:param name="level" select="@text:outline-level"/>
  <xsl:variable name="userlevel" select="@text:outline-level"/>

  <!-- Just for debugging this should NEVER happen -->
  <xsl:if test="$userlevel &lt; $level">
    <xsl:processing-instruction name="cnx.warning">Document contains a lower-level heading (<xsl:value-of select="$level"/>) before a higher-level heading (<xsl:value-of select="$userlevel"/>). Title: <xsl:value-of select="."/></xsl:processing-instruction>
  </xsl:if>

  <!-- header found with a level greater or the same as the current level? If yes, create a nested header. -->
  <xsl:if test="$userlevel - $level &gt;= 0">
    <c:section>
      <!-- Don't apply the @text:outline attributes
          <xsl:apply-templates select="@*"/>
      -->
      <c:title>
        <xsl:apply-templates select="node()"/>
      </c:title>
      <xsl:apply-templates select="following-sibling::node()[1]" mode="walker">
        <xsl:with-param name="level" select="$level + 1"/>
      </xsl:apply-templates>
    </c:section>
  </xsl:if>

  <!-- Used for debugging
  <xsl:if test="$userlevel = 6">
    <xsl:message><xsl:value-of select="preceding-sibling::text:h[@text:outline-level &lt; $userlevel][1]"/></xsl:processing-instruction>
    <xsl:message><xsl:value-of select="generate-id(preceding-sibling::text:h[@text:outline-level &lt; $userlevel][1])"/></xsl:processing-instruction>
    <xsl:message><xsl:value-of select="following-sibling::text:h[@text:outline-level = $userlevel][1]/preceding-sibling::text:h[@text:outline-level &lt; $userlevel][1]"/></xsl:processing-instruction>
    <xsl:message><xsl:value-of select="generate-id(following-sibling::text:h[@text:outline-level = $userlevel][1]/preceding-sibling::text:h[@text:outline-level &lt; $userlevel][1])"/></xsl:processing-instruction>
    <xsl:message>=============================</xsl:processing-instruction>
  </xsl:if>
   -->

  <xsl:if test="following-sibling::text:h[@text:outline-level = $userlevel][1]">           <!-- Is there a following header in the same level? -->
    <!-- This part is very hard to understand:
       It compares if the first preceding header with a lower level is the same as the first preceding header (with a lower level) for the following header with the same level.
       So it keeps sure that there is no lower level header in between the next header with the same level.
       In other words: It keeps sure that the tree is correct and no double tags are created ;)
    -->
     <xsl:if test="generate-id(preceding-sibling::text:h[@text:outline-level &lt; $userlevel][1])
             = generate-id(following-sibling::text:h[@text:outline-level = $userlevel][1]/preceding-sibling::text:h[@text:outline-level &lt; $userlevel][1])">
       <xsl:apply-templates select="following-sibling::text:h[@text:outline-level = $userlevel][1]" mode="walker">
        <xsl:with-param name="level" select="$level"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:if>
</xsl:template>

<!-- Do not copy level attribute from Pass1 -->
<!-- TODO: Currently it is copied for debugging -->
<!-- <xsl:template match="@text:outline-level"/> -->

<!-- Copy & Walk through the HTML -->
<xsl:template match="node()" mode="walker">
  <xsl:param name="level" select="../text:h[1]/@text:outline-level"/>
  <xsl:apply-templates select="." />
  <xsl:if test="not(following-sibling::node()[1]/self::text:h[@text:outline-level &lt; $level])">  <!-- Do not process headers with lower level. -->
    <xsl:apply-templates select="following-sibling::node()[1]" mode="walker">
      <xsl:with-param name="level" select="$level"/>
    </xsl:apply-templates>
  </xsl:if>
</xsl:template>

</xsl:stylesheet>