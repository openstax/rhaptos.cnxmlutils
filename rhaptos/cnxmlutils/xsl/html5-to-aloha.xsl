<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:c="http://cnx.rice.edu/cnxml"
  xmlns:m="http://www.w3.org/1998/Math/MathML"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:md="http://cnx.rice.edu/mdml/0.4"
  xmlns:qml="http://cnx.rice.edu/qml/1.0"
  xmlns:mod="http://cnx.rice.edu/#moduleIds"
  xmlns:bib="http://bibtexml.sf.net/"
  
  xmlns:data="http://dev.w3.org/html5/spec/#custom"
  exclude-result-prefixes="m mml"
  >

<xsl:output omit-xml-declaration="yes" encoding="ASCII"/>

<!--
Converts HTML5 (from CNXML to HTML5) to Aloha simplified HTML5.
This simplified Aloha HTML5 fits more the Aloha structure and editing.

Log:
2013-07-19: Remove sections
-->

<!-- default copy all -->
<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- remove classes from strong and emphasis -->
<xsl:template match="strong|em|table|body">
  <xsl:element name="{local-name()}">
    <xsl:apply-templates/>
  </xsl:element>
</xsl:template>

<!-- turn sections into headers -->

<!-- section with no header is complex -->
<xsl:template match="section[not(h1|h2|h3|h4|h5|h6)]">
  <xsl:apply-templates mode="complex" select="." />
</xsl:template>

<!-- section with a following nonsection sibling is complex -->
<xsl:template match="section[following-sibling::*][not(following-sibling::section)]">
  <xsl:apply-templates mode="complex" select="." />
</xsl:template>

<xsl:template mode="complex" match="section">
  <section class="complex-section">
    <xsl:apply-templates select="@*"/>
    <xsl:apply-templates mode="complex" select="h1|h2|h3|h4|h5|h6" />
    <xsl:apply-templates select="node()[not(self::h1|self::h2|self::h3|
                                            self::h4|self::h5|self::h6)]"/>
  </section>
</xsl:template>

<xsl:template mode="complex" match="h1|h2|h3|h4|h5|h6">
  <xsl:variable name="h" select="name(.)"/>  
  <xsl:element name="{$h}">
    <xsl:apply-templates select="@*|node()"/>
  </xsl:element>
</xsl:template>

<xsl:template match="section">
  <!-- children will take care of section/@* -->
  <xsl:apply-templates mode="headers" select="h1|h2|h3|h4|h5|h6" />
  <xsl:apply-templates select="node()[not(self::h1|self::h2|self::h3|
                                          self::h4|self::h5|self::h6)]"/>
</xsl:template>

<!--
<xsl:template match="section[section[following-sibling::*][not(following-sibling::section)]]">
  <xsl:comment>found a non-section child node that has a section preceding sibling</xsl:comment>
  <xsl:apply-templates mode="complex" select="." />
</xsl:template>
-->

<xsl:template match="h1|h2|h3|h4|h5|h6" />

<xsl:template mode="headers" match="section/h1|section/h2|section/h3|
                                    section/h4|section/h5|section/h6">
  <xsl:variable name="h" select="name(.)"/>  
  <xsl:element name="{$h}">
    <!-- place section attributes onto the h* node -->
    <xsl:apply-templates select="../@*" />
    <!-- handle h* attributes -->
    <xsl:if test="@id">
      <xsl:attribute name="data-header-id">
        <xsl:value-of select="@id"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="@data-class">
      <xsl:attribute name="data-header-class">
        <xsl:value-of select="@data-class"/>
      </xsl:attribute>
    </xsl:if>
    <!--handle h* children nodes -->
    <xsl:apply-templates select="node()"/>
  </xsl:element>
</xsl:template>

</xsl:stylesheet>
