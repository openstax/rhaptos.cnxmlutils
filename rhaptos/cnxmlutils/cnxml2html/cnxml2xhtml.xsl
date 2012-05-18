<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:c="http://cnx.rice.edu/cnxml"
  xmlns:m="http://www.w3.org/1998/Math/MathML"
  xmlns:md="http://cnx.rice.edu/mdml/0.4"
  xmlns:qml="http://cnx.rice.edu/qml/1.0"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:mod="http://cnx.rice.edu/#moduleIds"
  xmlns:bib="http://bibtexml.sf.net/">

<!-- Resort to how we currently handle media and tables -->
<xsl:import href="ident.xsl"/>

<!--
<xsl:import href="dbk2html-media.xsl"/>
<xsl:import href="cnxml2xhtml-tables.xsl"/>
-->

<xsl:template match="c:media|c:table">
  <xsl:comment>TODO: Use plain-jane conversion of <xsl:value-of select="local-name()"/></xsl:comment>
</xsl:template>


<!-- Boilerplate HTML -->
<xsl:template match="c:document">
  <html>
    <head>
      <xsl:apply-templates select="c:metadata"/>
    </head>
    <body>
      <xsl:apply-templates select="c:featured-links"/>
      <xsl:apply-templates select="c:content"/>
      <xsl:apply-templates select="c:glossary"/>
    </body>
  </html>
</xsl:template>

<xsl:template match="c:metadata">
  <head>
    <xsl:apply-templates select="node()"/>
  </head>
</xsl:template>
<xsl:template match="c:content">
  <xsl:apply-templates select="node()"/>
</xsl:template>
<xsl:template match="c:glossary">
  <xsl:call-template name="htmlish"><xsl:with-param name="tag">section</xsl:with-param></xsl:call-template>
</xsl:template>


<!-- class is handled manually -->
<xsl:template match="@class"/>
<!-- type is automatically used as a class -->
<xsl:template match="@type"/>

<xsl:template name="add-class">
  <xsl:attribute name="class">
    <xsl:value-of select="local-name()"/>
    <xsl:if test="@class">
      <xsl:text> </xsl:text>
      <xsl:value-of select="@class"/>
    </xsl:if>
    <!-- Lists allow a custom type and it's used (8899 times) -->
    <xsl:if test="@type">
      <xsl:text> </xsl:text>
      <xsl:value-of select="@type"/>
    </xsl:if>
    
    <!-- list styles are encoded as classes -->
    <xsl:if test="@number-style">
      <xsl:text> number-style-</xsl:text>
      <xsl:value-of select="@number-style"/>
    </xsl:if>
    <xsl:if test="@bullet-style">
      <xsl:text> bullet-style-</xsl:text>
      <xsl:value-of select="@bullet-style"/>
    </xsl:if>

    <!-- TODO: "unlabeled" class should not be in the HTML, it should be auto-added (it's only there to help the CSS) -->
    <xsl:if test="not(c:title or c:label)">
      <xsl:text> unlabeled</xsl:text>
    </xsl:if>
  </xsl:attribute>
</xsl:template>

<xsl:template name="htmlish">
  <xsl:param name="tag"/>
  <xsl:element name="{$tag}">
    <xsl:call-template name="add-class"/>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:element>
</xsl:template>

<xsl:template name="blockish">
  <div>
    <xsl:call-template name="add-class"/>
    <xsl:apply-templates select="@*|c:title|c:label"/>
    <div class="body">
      <xsl:apply-templates select="node()[not(self::c:title or self::c:label)]"/>
    </div>
  </div>
</xsl:template>

<xsl:template name="inlineish">
  <xsl:call-template name="htmlish"><xsl:with-param name="tag">span</xsl:with-param></xsl:call-template>
</xsl:template>

<xsl:template match="c:preformat|c:span|c:cite|c:cite-title|c:term|c:foreign|c:caption">
  <xsl:call-template name="inlineish"/>
</xsl:template>

<xsl:template match="c:section|c:example|c:problem|c:solution|c:statement|c:proof|c:exercise|c:equation|c:rule">
  <xsl:call-template name="blockish"/>
</xsl:template>

<xsl:template match="c:div|c:preformat|c:footnote">
  <xsl:call-template name="blockish"/>
</xsl:template>

<!-- these are sometimes (depending on the context) block-level -->
<xsl:template match="c:quote|c:note|c:commentary">
  <xsl:call-template name="blockish"/>
</xsl:template>

<!-- TODO: Convert glossaries to dl/dt-dd elements -->
<xsl:template match="c:definition">
  <xsl:call-template name="blockish"/>
</xsl:template>
<xsl:template match="c:seealso|c:meaning">
  <xsl:call-template name="inlineish"/>
</xsl:template>


<!-- =============================================
     elements that map to non-span/div elements 
     ============================================= -->

<xsl:template match="c:sub|c:sup|c:div|c:span">
  <xsl:call-template name="htmlish"><xsl:with-param name="tag"><xsl:value-of select="local-name()"/></xsl:with-param></xsl:call-template>
</xsl:template>

<xsl:template match="c:para">
  <xsl:call-template name="htmlish"><xsl:with-param name="tag">p</xsl:with-param></xsl:call-template>
</xsl:template>

<xsl:template match="c:code">
  <xsl:call-template name="htmlish"><xsl:with-param name="tag">pre</xsl:with-param></xsl:call-template>
</xsl:template>

<xsl:template match="c:title|c:label">
  <h2>
    <!-- TODO: "labeled" class should not be in the HTML, it should be auto-added (it's only there to help the CSS) -->
    <xsl:if test="../@id">
      <xsl:attribute name="id">
        <xsl:value-of select="../@id"/>
        <xsl:text>-title</xsl:text>
      </xsl:attribute>
    </xsl:if>

    <xsl:call-template name="add-class"/>
    <xsl:apply-templates select="@*"/>
    <span class="text">
      <xsl:apply-templates select="node()"/>
    </span>
  </h2>
</xsl:template>

<xsl:template match="c:link[@url and starts-with(@url, 'http')]/@url"/>
<xsl:template match="c:link[@url and starts-with(@url, 'http')]">
  <a href="{@url}">
    <xsl:call-template name="add-class"/>
    <xsl:apply-templates select="@*|node()"/>
  </a>
</xsl:template>

<xsl:template match="c:link/@document|c:link/@target-id|c:link/@version"/>
<xsl:template match="c:link[@document or @target-id]">
  <xsl:variable name="href">
    <xsl:if test="@document">
      <xsl:value-of select="@document"/>
    </xsl:if>
    <xsl:if test="@version">
      <xsl:text>@</xsl:text>
      <xsl:value-of select="@version"/>
    </xsl:if>
    <xsl:if test="@target-id">
      <xsl:text>#</xsl:text>
      <xsl:value-of select="@target-id"/>
    </xsl:if>
  </xsl:variable>
  <a href="{$href}">
    <xsl:call-template name="add-class"/>
    <xsl:apply-templates select="@*|node()"/>
  </a>
</xsl:template>

<xsl:template match="c:emphasis[@effect='italics' or @effect='bold']/@effect"/>
<xsl:template match="c:emphasis[@effect='italics']">
  <xsl:call-template name="htmlish"><xsl:with-param name="tag">em</xsl:with-param></xsl:call-template>
</xsl:template>

<xsl:template match="c:emphasis[not(@effect) or @effect='bold']">
  <xsl:call-template name="htmlish"><xsl:with-param name="tag">strong</xsl:with-param></xsl:call-template>
</xsl:template>

<xsl:template match="c:list/@type"/>
<xsl:template match="c:list[@list-type='bulleted' or @list-type='enumerated']/@list-type"/>
<xsl:template match="c:list/@number-style|c:list/@bullet-style"/>
<xsl:template match="c:list[not(@list-type) or @list-type='bulleted']">
  <xsl:call-template name="htmlish"><xsl:with-param name="tag">ul</xsl:with-param></xsl:call-template>
</xsl:template>
<xsl:template match="c:list[@list-type='enumerated']">
  <xsl:call-template name="htmlish"><xsl:with-param name="tag">ol</xsl:with-param></xsl:call-template>
</xsl:template>
<xsl:template match="c:item">
  <xsl:call-template name="htmlish"><xsl:with-param name="tag">li</xsl:with-param></xsl:call-template>
</xsl:template>

<xsl:template match="c:figure[not(c:subfigure)]">
  <xsl:call-template name="htmlish"><xsl:with-param name="tag">figure</xsl:with-param></xsl:call-template>
</xsl:template>

<xsl:template match="c:figure/c:caption|c:table/c:caption">
  <xsl:call-template name="blockish"/>
</xsl:template>

<xsl:template match="c:newline/@count"/>
<xsl:template match="c:newline">
  <br class="newline">
    <xsl:if test="@count > 1">
      <xsl:attribute name="style">
        <xsl:text>height: </xsl:text>
        <xsl:value-of select="@count"/>
        <xsl:text>em;</xsl:text>
      </xsl:attribute>
    </xsl:if>
  </br>
</xsl:template>

<xsl:template match="c:newline[@effect='underline']/@effect"/>
<xsl:template match="c:newline[@effect='underline']" name="cnx.newline">
  <xsl:param name="count" select="@count"/>
  <br class="newline underline"/>
  <xsl:if test="$count > 1">
    <xsl:call-template name="cnx.newline">
      <xsl:with-param name="count" select="$count - 1"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<xsl:template match="c:space/@effect|c:space/@count"/>
<xsl:template match="c:space">
  <xsl:variable name="class">
    <xsl:text>space</xsl:text>
    <xsl:if test="@effect='underline'">
      <xsl:text> underline</xsl:text>
    </xsl:if>
  </xsl:variable>
  <span class="{$class}">
    <xsl:if test="@count > 1">
      <xsl:attribute name="style">
        <xsl:text>width: </xsl:text>
        <xsl:value-of select="@count"/>
        <xsl:text>em;</xsl:text>
      </xsl:attribute>
    </xsl:if>
    <xsl:text> </xsl:text><!-- at least one character -->
  </span>
</xsl:template>


</xsl:stylesheet>
