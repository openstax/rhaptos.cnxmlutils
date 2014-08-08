<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:c="http://cnx.rice.edu/cnxml"
  xmlns:m="http://www.w3.org/1998/Math/MathML"
  xmlns:qml="http://cnx.rice.edu/qml/1.0"
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

<!-- Ignore title, it is handled explicitly below. -->
<xsl:template match="/body/*[@data-type='title']" />

<xsl:template match="m:*/@class">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="body">
  <c:document xmlns="http://cnx.rice.edu/cnxml"
              xmlns:md="http://cnx.rice.edu/mdml"
              xmlns:bib="http://bibtexml.sf.net/"
              xmlns:m="http://www.w3.org/1998/Math/MathML"
              xmlns:q="http://cnx.rice.edu/qml/1.0"
              cnxml-version="0.7" module-id="new" id="_root">
      <c:title>
        <xsl:apply-templates select="*[@data-type='title']/text()" />
      </c:title>
      <c:content><xsl:apply-templates select="@*|node()"/></c:content>
  </c:document>
</xsl:template>


<!-- ========================= -->
<!-- Generic elements and attribs -->

<xsl:template match="@data-type"/>

<xsl:template match="*[@data-type='title']">
  <c:title><xsl:apply-templates select="@*|node()"/></c:title>
</xsl:template>

<!-- ========================= -->

<xsl:template match="section/@data-depth"/>


<xsl:template match="section">
  <c:section>
    <xsl:apply-templates select="@*"/>
    <xsl:apply-templates select="*[self::h1 or self::h2 or self::h3 or self::h4 or self::h5 or self::h6]/@id"/>
    <xsl:apply-templates select="node()"/>
  </c:section>
</xsl:template>

<xsl:template match="section/*[self::h1 or self::h2 or self::h3 or self::h4 or self::h5 or self::h6]">
  <c:title><xsl:apply-templates select="@*[not(local-name()='id')]|node()"/></c:title>
</xsl:template>


<xsl:template match="p">
  <c:para><xsl:apply-templates select="@*|node()"/></c:para>
</xsl:template>

<xsl:template match="*[@data-type='example']">
  <c:example><xsl:apply-templates select="@*|node()"/></c:example>
</xsl:template>

<xsl:template match="*[@data-type='exercise']">
  <c:exercise><xsl:apply-templates select="@*|node()"/></c:exercise>
</xsl:template>

<xsl:template match="*[@data-type='problem']">
  <c:problem><xsl:apply-templates select="@*|node()"/></c:problem>
</xsl:template>

<xsl:template match="*[@data-type='solution']">
  <c:solution><xsl:apply-templates select="@*|node()"/></c:solution>
</xsl:template>

<xsl:template match="*[@data-type='commentary']">
  <c:commentary><xsl:apply-templates select="@*|node()"/></c:commentary>
</xsl:template>

<xsl:template match="*[@data-type='equation']">
  <c:equation><xsl:apply-templates select="@*|node()"/></c:equation>
</xsl:template>

<xsl:template match="*[@data-type='rule']">
  <c:rule><xsl:apply-templates select="@*|node()"/></c:rule>
</xsl:template>

<xsl:template match="q">
  <c:quote><xsl:apply-templates select="@*|node()"/></c:quote>
</xsl:template>

<xsl:template match="code">
  <c:code><xsl:apply-templates select="@*|node()"/></c:code>
</xsl:template>

<xsl:template match="pre">
  <c:code><xsl:apply-templates select="@*|node()"/></c:code>
</xsl:template>

<xsl:template match="*[@data-type='code']">
  <c:code><xsl:apply-templates select="@*|node()"/></c:code>
</xsl:template>

<xsl:template match="*[@data-type='code']/pre">
  <!-- unwrap the pre tag in the div -->
  <xsl:apply-templates select="node()"/>
</xsl:template>


<!-- ========================= -->

<xsl:template match="*[@data-type='note']">
  <c:note><xsl:apply-templates select="@*|node()"/></c:note>
</xsl:template>

<!-- Brittle HACK to get notes with headings to create valid CNXML -->
<!-- Use "2" because the 1st child is a title -->
<xsl:template match="*[@data-type='note']//section[*[2][self::p]]">
  <xsl:apply-templates select="node()[not(self::*[@data-type='title'])]"/>
</xsl:template>

<xsl:template match="*[@data-type='note']//section/*[2][self::p]">
  <c:para>
    <xsl:apply-templates select="@*"/>
    <xsl:apply-templates select="../@*|../*[@data-type='title']"/>
    <xsl:apply-templates select="node()"/>
  </c:para>
</xsl:template>

<!-- ========================= -->

<xsl:template match="ol">
  <c:list list-type="enumerated">
    <xsl:apply-templates select="@*|node()"/>
  </c:list>
</xsl:template>

<xsl:template match="ul">
  <c:list><xsl:apply-templates select="@*|node()"/></c:list>
</xsl:template>

<xsl:template match="li">
  <c:item><xsl:apply-templates select="@*|node()"/></c:item>
</xsl:template>

<xsl:template match="ol/@start">
  <xsl:attribute name="start-value"><xsl:value-of select="."/></xsl:attribute>
</xsl:template>

<xsl:template match="ul/@*[local-name()!='id']|ol/@*[local-name()!='id']"/>
<xsl:template match="@*[starts-with(local-name(), 'data-')]">
  <xsl:attribute name="{substring-after(local-name(), 'data-')}">
    <xsl:value-of select="."/>
  </xsl:attribute>
</xsl:template>


<xsl:template match="*[@data-type='list']">
  <c:list>
    <xsl:if test="ol">
      <xsl:attribute name="list-type">enumerated</xsl:attribute>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </c:list>
</xsl:template>

<xsl:template match="*[@data-type='list']/ul|*[@data-type='list']/ol">
  <xsl:apply-templates select="node()"/>
</xsl:template>

<!-- ========================= -->

<xsl:template match="strong|b">
  <c:emphasis><xsl:apply-templates select="@*|node()"/></c:emphasis>
</xsl:template>

<xsl:template match="em|i">
  <c:emphasis effect="italics"><xsl:apply-templates select="@*|node()"/></c:emphasis>
</xsl:template>

<xsl:template match="u">
  <c:emphasis effect="underline"><xsl:apply-templates select="@*|node()"/></c:emphasis>
</xsl:template>

<xsl:template match="*[@data-type='smallcaps']">
  <c:emphasis effect="smallcaps"><xsl:apply-templates select="@*|node()"/></c:emphasis>
</xsl:template>

<xsl:template match="*[@data-type='normal']">
  <c:emphasis effect="normal"><xsl:apply-templates select="@*|node()"/></c:emphasis>
</xsl:template>

<!-- ========================= -->

<xsl:template match="*[@data-type='term']">
  <c:term><xsl:apply-templates select="@*|node()"/></c:term>
</xsl:template>

<xsl:template match="*[@data-type='foreign']">
  <c:foreign><xsl:apply-templates select="@*|node()"/></c:foreign>
</xsl:template>

<xsl:template match="*[@data-type='footnote']">
  <c:footnote><xsl:apply-templates select="@*|node()"/></c:footnote>
</xsl:template>

<xsl:template match="sub">
  <c:sub><xsl:apply-templates select="@*|node()"/></c:sub>
</xsl:template>

<xsl:template match="sup">
  <c:sup><xsl:apply-templates select="@*|node()"/></c:sup>
</xsl:template>

<!-- ========================= -->
<!-- Links: encode in @data-*  -->
<!-- ========================= -->

<xsl:template match="a[@href and starts-with(@href, 'http')]">
  <c:link url="{@href}"><xsl:apply-templates select="@id|node()"/></c:link>
</xsl:template>

<xsl:template match="a[@href]">
  <c:link>
    <xsl:apply-templates select="@*"/>
    <xsl:apply-templates select="@id|node()"/>
  </c:link>
</xsl:template>

<xsl:template match="a/@*[local-name()!='id']"/>
<xsl:template match="@*[starts-with(local-name(), 'data-')]">
  <xsl:if test="local-name() != 'data-type'">
    <xsl:attribute name="{substring-after(local-name(), 'data-')}">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:if>
</xsl:template>

<!-- ========================= -->
<!-- Figures and subfigures    -->
<!-- ========================= -->

<!-- A subfigure -->
<xsl:template match="figure//figure">
  <c:subfigure>
    <xsl:call-template name="figure-body"/>
  </c:subfigure>
</xsl:template>
<xsl:template match="figure">
  <c:figure>
    <xsl:call-template name="figure-body"/>
  </c:figure>
</xsl:template>

<xsl:template name="figure-body">
  <xsl:apply-templates select="@*"/>
  <!-- pull the title out of the caption -->
  <xsl:apply-templates select="node()[not(self::figcaption)]"/>
  <!-- only generate the caption tag if there is something other than the title in it -->
  <!-- According to the spec, the caption must come at the end of a figure -->
  <xsl:apply-templates select="figcaption"/>
</xsl:template>

<xsl:template match="figcaption">
  <c:caption>
    <xsl:apply-templates select="@*|node()"/>
  </c:caption>
</xsl:template>


<!-- ========================= -->
<!-- Tables: partial support   -->
<!-- ========================= -->

<xsl:template match="table">
  <c:table summary="{@summary}">
    <!-- Akin to figure captions -->
    <xsl:apply-templates select="caption/*[@data-type='title']"/>
    <xsl:if test="caption/node()[not(self::*[@data-type='title'])]">
      <c:caption>
        <xsl:apply-templates select="caption/node()[not(self::*[@data-type='title'])]"/>
      </c:caption>
    </xsl:if>

    <c:tgroup>
      <xsl:apply-templates select="node()[not(self::caption)]"/>
    </c:tgroup>
  </c:table>
</xsl:template>

<xsl:template match="thead|tbody|tfoot">
  <xsl:element name="c:{local-name()}">
    <xsl:apply-templates select="@*|node()"/>
  </xsl:element>
</xsl:template>

<xsl:template match="tr">
  <c:row><xsl:apply-templates select="@*|node()"/></c:row>
</xsl:template>

<xsl:template match="td">
  <c:entry><xsl:apply-templates select="@*|node()"/></c:entry>
</xsl:template>


<!-- ========================= -->
<!-- Media: Partial Support    -->
<!-- ========================= -->

<xsl:template match="*[@data-type='media']">
  <c:media>
    <xsl:apply-templates select="@*|node()"/>
  </c:media>
</xsl:template>

<xsl:template match="img">
  <c:image src="{@src}" mime-type="{@data-media-type}">
    <xsl:if test="contains(@class, 'for-')">
      <xsl:attribute name="for">
        <xsl:value-of select="substring-before(substring-after(@class, 'for-'), ' ')"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </c:image>
</xsl:template>
<xsl:template match="img/@width|img/@height">
  <xsl:copy/>
</xsl:template>

<!-- ========================= -->
<!-- Glossary: Partial Support -->
<!-- ========================= -->

<xsl:template match="*[@data-type='definition']">
  <c:definition>
    <xsl:apply-templates select="@*|node()"/>
  </c:definition>
</xsl:template>

<xsl:template match="*[@data-type='meaning']">
  <c:meaning>
    <xsl:apply-templates select="@*|node()"/>
  </c:meaning>
</xsl:template>

<xsl:template match="*[@data-type='seealso']">
  <c:seealso>
    <xsl:apply-templates select="@*|node()"/>
  </c:seealso>
</xsl:template>

</xsl:stylesheet>
