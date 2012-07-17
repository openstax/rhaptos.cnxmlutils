<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:c="http://cnx.rice.edu/cnxml"
  xmlns:m="http://www.w3.org/1998/Math/MathML"
  xmlns:md="http://cnx.rice.edu/mdml/0.4"
  xmlns:qml="http://cnx.rice.edu/qml/1.0"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:x="http://www.w3.org/1999/xhtml"
  xmlns:mod="http://cnx.rice.edu/#moduleIds"
  xmlns:bib="http://bibtexml.sf.net/"
  exclude-result-prefixes="c"
  >

<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="@id">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- TODO: Don't ignore @class -->
<xsl:template match="@class"/>

<xsl:template match="m:*/@class">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="x:body">
  <c:content><xsl:apply-templates select="@*|node()"/></c:content>
</xsl:template>

<!-- ========================= -->

<xsl:template match="x:div[@class='title']">
  <c:title><xsl:apply-templates select="@*|node()"/></c:title>
</xsl:template>

<xsl:template match="x:span[@class='title']">
  <c:title><xsl:apply-templates select="@*|node()"/></c:title>
</xsl:template>

<!-- ========================= -->

<xsl:template match="x:div[@class='section']">
  <c:section>
    <xsl:apply-templates select="@*"/>
    <xsl:apply-templates select="*[self::x:h1 or self::x:h2 or self::x:h3 or self::x:h4 or self::x:h5 or self::x:h6]/@id"/>
    <xsl:apply-templates select="node()"/>
  </c:section>
</xsl:template>

<xsl:template match="x:div[@class='section']/*[self::x:h1 or self::x:h2 or self::x:h3 or self::x:h4 or self::x:h5 or self::x:h6]">
  <c:title><xsl:apply-templates select="@*[not(local-name()='id')]|node()"/></c:title>
</xsl:template>


<xsl:template match="x:p">
  <c:para><xsl:apply-templates select="@*|node()"/></c:para>
</xsl:template>

<xsl:template match="x:div[@class='example']">
  <c:example><xsl:apply-templates select="@*|node()"/></c:example>
</xsl:template>

<xsl:template match="x:div[@class='exercise']">
  <c:exercise><xsl:apply-templates select="@*|node()"/></c:exercise>
</xsl:template>

<xsl:template match="x:div[@class='problem']">
  <c:problem><xsl:apply-templates select="@*|node()"/></c:problem>
</xsl:template>

<xsl:template match="x:div[@class='solution']">
  <c:solution><xsl:apply-templates select="@*|node()"/></c:solution>
</xsl:template>

<xsl:template match="x:div[@class='commentary']">
  <c:commentary><xsl:apply-templates select="@*|node()"/></c:commentary>
</xsl:template>

<xsl:template match="x:div[@class='equation']">
  <c:equation><xsl:apply-templates select="@*|node()"/></c:equation>
</xsl:template>

<xsl:template match="x:div[@class='rule']">
  <c:rule><xsl:apply-templates select="@*|node()"/></c:rule>
</xsl:template>

<xsl:template match="x:q">
  <c:quote><xsl:apply-templates select="@*|node()"/></c:quote>
</xsl:template>

<xsl:template match="x:code">
  <c:code><xsl:apply-templates select="@*|node()"/></c:code>
</xsl:template>

<!-- ========================= -->

<xsl:template match="x:div[@class='note']">
  <c:note><xsl:apply-templates select="@*|node()"/></c:note>
</xsl:template>

<!-- ========================= -->

<xsl:template match="x:ol">
  <c:list list-type="enumerated">
    <xsl:apply-templates select="@*|node()"/>
  </c:list>
</xsl:template>

<xsl:template match="x:ul">
  <c:list><xsl:apply-templates select="@*|node()"/></c:list>
</xsl:template>

<xsl:template match="x:li">
  <c:item><xsl:apply-templates select="@*|node()"/></c:item>
</xsl:template>

<xsl:template match="x:ol/@start">
  <xsl:attribute name="start-value"><xsl:value-of select="."/></xsl:attribute>
</xsl:template>

<xsl:template match="x:ul/@*[local-name()!='id']|x:ol/@*[local-name()!='id']"/>
<xsl:template match="@*[starts-with(local-name(), 'data-')]">
  <xsl:attribute name="{substring-after(local-name(), 'data-')}">
    <xsl:value-of select="."/>
  </xsl:attribute>
</xsl:template>


<!-- ========================= -->

<xsl:template match="x:figure">
  <c:figure><xsl:apply-templates select="@*|node()"/></c:figure>
</xsl:template>

<xsl:template match="x:caption">
  <c:caption><xsl:apply-templates select="@*|node()"/></c:caption>
</xsl:template>

<!-- ========================= -->

<xsl:template match="x:strong|x:b">
  <c:emphasis><xsl:apply-templates select="@*|node()"/></c:emphasis>
</xsl:template>

<xsl:template match="x:em|x:i">
  <c:emphasis effect="italics"><xsl:apply-templates select="@*|node()"/></c:emphasis>
</xsl:template>

<xsl:template match="x:u">
  <c:emphasis effect="underline"><xsl:apply-templates select="@*|node()"/></c:emphasis>
</xsl:template>

<xsl:template match="x:span[@class='smallcaps']">
  <c:emphasis effect="smallcaps"><xsl:apply-templates select="@*|node()"/></c:emphasis>
</xsl:template>

<xsl:template match="x:span[@class='normal']">
  <c:emphasis effect="normal"><xsl:apply-templates select="@*|node()"/></c:emphasis>
</xsl:template>

<!-- ========================= -->

<xsl:template match="x:span[@class='term']">
  <c:term><xsl:apply-templates select="@*|node()"/></c:term>
</xsl:template>

<xsl:template match="x:sub">
  <c:sub><xsl:apply-templates select="@*|node()"/></c:sub>
</xsl:template>

<xsl:template match="x:sup">
  <c:sup><xsl:apply-templates select="@*|node()"/></c:sup>
</xsl:template>

<!-- ========================= -->
<!-- Links: encode in @data-*  -->
<!-- ========================= -->

<xsl:template match="x:a[@href and starts-with(@href, 'http')]">
  <c:link url="{@href}"><xsl:apply-templates select="@id|node()"/></c:link>
</xsl:template>

<xsl:template match="x:a[@href]">
  <c:link>
    <xsl:apply-templates select="@*"/>
    <xsl:apply-templates select="@id|node()"/>
  </c:link>
</xsl:template>

<xsl:template match="x:a/@*[local-name()!='id']"/>
<xsl:template match="@*[starts-with(local-name(), 'data-')]">
  <xsl:attribute name="{substring-after(local-name(), 'data-')}">
    <xsl:value-of select="."/>
  </xsl:attribute>
</xsl:template>

<!-- ========================= -->
<!-- Tables: partial support   -->
<!-- ========================= -->

<xsl:template match="x:table">
  <c:table summary="{@summary}">
    <xsl:if test="x:caption">
      <xsl:apply-templates select="x:span[@class='title']"/>
      <c:caption>
        <xsl:apply-templates select="node()[not(self::x:span[@class='title'])]"/>
      </c:caption>
    </xsl:if>
    
    <c:tgroup>
      <xsl:apply-templates select="node()[not(self::x:caption)]"/>
    </c:tgroup>
  </c:table>
</xsl:template>

<xsl:template match="x:thead|x:tbody|x:tfoot">
  <xsl:element name="c:{local-name()}">
    <xsl:apply-templates select="@*|node()"/>
  </xsl:element>
</xsl:template>

<xsl:template match="x:tr">
  <c:row><xsl:apply-templates select="@*|node()"/></c:row>
</xsl:template>

<xsl:template match="x:td">
  <c:entry><xsl:apply-templates select="@*|node()"/></c:entry>
</xsl:template>

</xsl:stylesheet>