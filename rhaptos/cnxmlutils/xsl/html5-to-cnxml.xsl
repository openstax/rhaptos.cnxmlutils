<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://cnx.rice.edu/cnxml"
  xmlns:h="http://www.w3.org/1999/xhtml"
  xmlns:m="http://www.w3.org/1998/Math/MathML"
  xmlns:q="http://cnx.rice.edu/qml/1.0"
  xmlns:bib="http://bibtexml.sf.net/"
  exclude-result-prefixes="h"
  >

<xsl:output method="xml" omit-xml-declaration="no" indent="no" encoding="utf-8"/>


<!-- DEBUG catchalls -->
<xsl:template match="@*" priority="-1000">
    <xsl:message>TODO: <xsl:value-of select="local-name(..)"/>/@<xsl:value-of select="local-name()"/></xsl:message>
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="*" priority="-1">
  <xsl:message>TODO: <xsl:value-of select="local-name(.)"/></xsl:message>
  <para class="not-converted-yet">NOT_CONVERTED_YET: <xsl:value-of select="local-name(.)"/></para>
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>
<!-- /DEBUG -->






<!-- <xsl:template match="@*|node()"> -->
  <!-- Match any attribute or node and copy it. -->
<!--   <xsl:copy> -->
<!--     <xsl:apply-templates select="@*|node()"/> -->
<!--   </xsl:copy> -->
<!-- </xsl:template> -->

<!-- ======================================== -->
<!-- Global Attribute Handlers -->
<!-- ======================================== -->

<xsl:template match="@id">
  <xsl:copy/>
</xsl:template>

<!-- FIXME: Don't ignore @class -->
<xsl:template match="@class"/>

<!-- Ignore document-title, it is handled explicitly. -->
<xsl:template match="/h:body/*[@data-type='document-title']"/>

<!-- <xsl:template match="@data-label"> -->
<!--   <label><xsl:value-of select="."/></label> -->
<!-- </xsl:template> -->

<xsl:template name="data-prefix">
  <!-- Places data-{name} attributes on parent tag as name without the 'data-' prefix. -->
  <xsl:param name="name" select="local-name()"/>
  <xsl:param name="value" select="."/>
  <xsl:attribute name="{substring-after($name, 'data-')}">
    <xsl:value-of select="$value"/>
  </xsl:attribute>
</xsl:template>

<xsl:template match="@*[starts-with(local-name(), 'data-') and (local-name() != 'data-label')]">
  <xsl:if test="local-name() != 'data-type'">
    <xsl:attribute name="{substring-after(local-name(), 'data-')}">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:if>
</xsl:template>


<!-- ======================================== -->
<!-- Document -->
<!-- Main document handler, everything outside of body is (or should be) ignored by this template -->
<!-- ======================================== -->

<xsl:template match="h:body">
  <document xmlns="http://cnx.rice.edu/cnxml"
            xmlns:md="http://cnx.rice.edu/mdml/0.4"
            xmlns:md1='http://cnx.rice.edu/mdml'
            xmlns:bib="http://bibtexml.sf.net/"
            xmlns:m="http://www.w3.org/1998/Math/MathML"
            xmlns:q="http://cnx.rice.edu/qml/1.0"
            cnxml-version="0.7">
    <!-- Unable to utilize @module-id or @id because this information is not in the html. -->
    <title>
      <xsl:apply-templates select="*[@data-type='document-title']/text()" />
    </title>
    <content><xsl:apply-templates select="@*|node()"/></content>
  </document>
</xsl:template>

<!-- @data-type='abstract-wrapper' is an container element that is placed on an abstract just before transformation. -->
<!-- The 'wrapper' tag is used to contain otherwise loose content. It is removed in post-processing. -->
<xsl:template match="*[@data-type='abstract-wrapper']">
  <wrapper>
    <xsl:apply-templates select="node()"/>
  </wrapper>
</xsl:template>


<!-- ====== -->
<!-- MathML -->
<!-- ====== -->

<xsl:template match="m:*/@class">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>


<!-- ========================= -->
<!-- Generic elements and attribs -->

<xsl:template match="@data-type"/>

<xsl:template match="*[@data-type='title']">
  <title><xsl:apply-templates select="@*|node()"/></title>
</xsl:template>

<!-- ========================= -->

<xsl:template match="h:section/@data-depth"/>


<xsl:template match="h:section">
  <section>
    <xsl:apply-templates select="@*"/>
    <xsl:apply-templates select="*[self::h:h1 or self::h:h2 or self::h:h3 or self::h:h4 or self::h:h5 or self::h:h6]/@id"/>
    <xsl:apply-templates select="node()"/>
  </section>
</xsl:template>

<xsl:template match="h:section/*[self::h:h1 or self::h:h2 or self::h:h3 or self::h:h4 or self::h:h5 or self::h:h6]">
  <title><xsl:apply-templates select="@*[not(local-name()='id')]|node()"/></title>
</xsl:template>


<xsl:template match="h:p">
  <para><xsl:apply-templates select="@*|node()"/></para>
</xsl:template>

<xsl:template match="*[@data-type='example']">
  <example><xsl:apply-templates select="@*|node()"/></example>
</xsl:template>

<xsl:template match="*[@data-type='exercise']">
  <exercise><xsl:apply-templates select="@*|node()"/></exercise>
</xsl:template>

<xsl:template match="*[@data-type='problem']">
  <problem><xsl:apply-templates select="@*|node()"/></problem>
</xsl:template>

<xsl:template match="*[@data-type='solution']">
  <solution><xsl:apply-templates select="@*|node()"/></solution>
</xsl:template>

<xsl:template match="*[@data-type='proof']">
  <proof><xsl:apply-templates select="@*|node()"/></proof>
</xsl:template>

<xsl:template match="*[@data-type='statement']">
  <statement><xsl:apply-templates select="@*|node()"/></statement>
</xsl:template>

<xsl:template match="*[@data-type='commentary']">
  <commentary><xsl:apply-templates select="@*|node()"/></commentary>
</xsl:template>

<xsl:template match="*[@data-type='equation']">
  <equation><xsl:apply-templates select="@*|node()"/></equation>
</xsl:template>

<xsl:template match="*[@data-type='rule']">
  <rule><xsl:apply-templates select="@*|node()"/></rule>
</xsl:template>

<xsl:template match="h:q">
  <quote><xsl:apply-templates select="@*|node()"/></quote>
</xsl:template>

<xsl:template match="h:blockquote">
  <quote><xsl:apply-templates select="@*|node()"/></quote>
</xsl:template>

<xsl:template match="h:code">
  <code><xsl:apply-templates select="@*|node()"/></code>
</xsl:template>

<xsl:template match="h:pre">
  <code><xsl:apply-templates select="@*|node()"/></code>
</xsl:template>

<xsl:template match="*[@data-type='code']">
  <code><xsl:apply-templates select="@*|node()"/></code>
</xsl:template>

<xsl:template match="*[@data-type='code']/h:pre">
  <!-- unwrap the pre tag in the div -->
  <xsl:apply-templates select="node()"/>
</xsl:template>


<!-- ========================= -->

<xsl:template match="*[@data-type='note']">
  <note><xsl:apply-templates select="@*|node()"/></note>
</xsl:template>

<!-- Brittle HACK to get notes with headings to create valid CNXML -->
<!-- Use "2" because the 1st child is a title -->
<xsl:template match="*[@data-type='note']//h:section[*[2][self::h:p]]">
  <xsl:apply-templates select="node()[not(self::*[@data-type='title'])]"/>
</xsl:template>

<xsl:template match="*[@data-type='note']//h:section/*[2][self::h:p]">
  <para>
    <xsl:apply-templates select="@*"/>
    <xsl:apply-templates select="../@*|../*[@data-type='title']"/>
    <xsl:apply-templates select="node()"/>
  </para>
</xsl:template>


<!-- ======================================== -->
<!-- Lists -->
<!-- ======================================== -->

<xsl:template match="h:ol">
  <list list-type="enumerated">
    <xsl:apply-templates select="@*|node()"/>
  </list>
</xsl:template>

<xsl:template match="h:ul">
  <list list-type="bulleted">
    <xsl:apply-templates select="@*|node()"/>
  </list>
</xsl:template>

<xsl:template match="h:li">
  <item><xsl:apply-templates select="@*|node()"/></item>
</xsl:template>

<xsl:template match="h:ol/@start">
  <xsl:attribute name="start-value"><xsl:value-of select="."/></xsl:attribute>
</xsl:template>

<xsl:template match="h:ul/@*[local-name()!='id']|ol/@*[local-name()!='id']"/>
<!-- <xsl:template match="@*[starts-with(local-name(), 'data-')]"> -->
<!--   <xsl:attribute name="{substring-after(local-name(), 'data-')}"> -->
<!--     <xsl:value-of select="."/> -->
<!--   </xsl:attribute> -->
<!-- </xsl:template> -->


<xsl:template match="*[@data-type='list']">
  <list>
    <!-- Attach any attributes on the html list element to the cnxml list tag. -->
    <xsl:for-each select="h:ul/@*|h:ol/@*">
      <xsl:call-template name="data-prefix"/>
    </xsl:for-each>
    <!-- Specifiy the list-type based on the html list element. -->
    <xsl:choose>
      <xsl:when test="h:ol">
        <xsl:attribute name="list-type">enumerated</xsl:attribute>
      </xsl:when>
      <xsl:when test="h:ul">
        <xsl:attribute name="list-type">bulleted</xsl:attribute>
      </xsl:when>
    </xsl:choose>

    <xsl:apply-templates select="@*|node()"/>
  </list>
</xsl:template>

<xsl:template match="*[@data-type='list']/h:ul|*[@data-type='list']/h:ol">
  <xsl:apply-templates select="node()"/>
</xsl:template>

<!-- ======================================== -->

<xsl:template match="h:strong|h:b">
  <emphasis><xsl:apply-templates select="@*|node()"/></emphasis>
</xsl:template>

<xsl:template match="h:em|h:i">
  <emphasis effect="italics"><xsl:apply-templates select="@*|node()"/></emphasis>
</xsl:template>

<xsl:template match="h:u">
  <emphasis effect="underline"><xsl:apply-templates select="@*|node()"/></emphasis>
</xsl:template>

<xsl:template match="*[@data-type='smallcaps']">
  <emphasis effect="smallcaps"><xsl:apply-templates select="@*|node()"/></emphasis>
</xsl:template>

<xsl:template match="*[@data-type='normal']">
  <emphasis effect="normal"><xsl:apply-templates select="@*|node()"/></emphasis>
</xsl:template>

<!-- ========================= -->

<xsl:template match="*[@data-type='term']">
  <term><xsl:apply-templates select="@*|node()"/></term>
</xsl:template>

<xsl:template match="*[@data-type='foreign']">
  <foreign><xsl:apply-templates select="@*|node()"/></foreign>
</xsl:template>

<xsl:template match="*[@data-type='footnote']">
  <footnote><xsl:apply-templates select="@*|node()"/></footnote>
</xsl:template>

<xsl:template match="h:sub">
  <sub><xsl:apply-templates select="@*|node()"/></sub>
</xsl:template>

<xsl:template match="h:sup">
  <sup><xsl:apply-templates select="@*|node()"/></sup>
</xsl:template>

<!-- ======================================== -->
<!-- Link -->
<!-- All link data is treated the same way. All @href values are transformed to @url. -->
<!-- We post-process the @url value during the reference resolution procedure. -->
<!-- ======================================== -->

<xsl:template match="h:a[@href]">
  <link url="{@href}">
    <xsl:apply-templates select="@*|node()"/>
  </link>
</xsl:template>

<xsl:template match="h:a/@*[local-name()!='id']"/>

<!-- ========================= -->
<!-- Figures and subfigures    -->
<!-- ========================= -->

<!-- A subfigure -->
<xsl:template match="h:figure//h:figure">
  <subfigure>
    <xsl:call-template name="figure-body"/>
  </subfigure>
</xsl:template>
<xsl:template match="h:figure">
  <figure>
    <xsl:call-template name="figure-body"/>
  </figure>
</xsl:template>

<xsl:template name="figure-body">
  <xsl:apply-templates select="@*"/>
  <!-- pull the title out of the caption -->
  <xsl:apply-templates select="node()[not(self::h:figcaption)]"/>
  <!-- only generate the caption tag if there is something other than the title in it -->
  <!-- According to the spec, the caption must come at the end of a figure -->
  <xsl:apply-templates select="h:figcaption"/>
</xsl:template>

<xsl:template match="h:figcaption">
  <caption>
    <xsl:apply-templates select="@*|node()"/>
  </caption>
</xsl:template>


<!-- ========================= -->
<!-- Tables: partial support   -->
<!-- ========================= -->

<xsl:template match="h:table">
  <table summary="{@summary}">
    <!-- Akin to figure captions -->
    <xsl:apply-templates select="h:caption/*[@data-type='title']"/>
    <xsl:if test="h:caption/node()[not(self::*[@data-type='title'])]">
      <caption>
        <xsl:apply-templates select="h:caption/node()[not(self::*[@data-type='title'])]"/>
      </caption>
    </xsl:if>

    <tgroup>
      <xsl:apply-templates select="node()[not(self::h:caption)]"/>
    </tgroup>
  </table>
</xsl:template>

<xsl:template match="h:thead|h:tbody|h:tfoot">
  <xsl:element name="{local-name()}">
    <xsl:apply-templates select="@*|node()"/>
  </xsl:element>
</xsl:template>

<xsl:template match="h:tr">
  <row><xsl:apply-templates select="@*|node()"/></row>
</xsl:template>

<xsl:template match="h:td">
  <entry><xsl:apply-templates select="@*|node()"/></entry>
</xsl:template>


<!-- ========================= -->
<!-- Media: Partial Support    -->
<!-- ========================= -->

<xsl:template match="*[@data-type='media']">
  <media>
    <xsl:apply-templates select="@*|node()"/>
  </media>
</xsl:template>

<xsl:template match="h:img">
  <image src="{@src}" mime-type="{@data-media-type}">
    <xsl:if test="contains(@class, 'for-')">
      <xsl:attribute name="for">
        <xsl:value-of select="substring-before(substring-after(@class, 'for-'), ' ')"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </image>
</xsl:template>
<xsl:template match="h:img/@width|h:img/@height">
  <xsl:copy/>
</xsl:template>

<xsl:template match="h:video">
  <video src="{h:source/@src}" mime-type="{h:source/@type}">
    <xsl:if test="@muted">
      <xsl:attribute name="volume">0</xsl:attribute>
    </xsl:if>
    <xsl:apply-templates select="@*"/>
  </video>
</xsl:template>
<!-- remove source tag, @src and @type should be in video tag -->
<xsl:template match="h:video/h:source"/>

<xsl:template match="h:video/@autoplay">
  <xsl:attribute name="autoplay">true</xsl:attribute>
</xsl:template>

<!-- embedded objects -->
<xsl:template match="h:object">
  <video src="{h:embed/@src}">
    <xsl:apply-templates select="@*|node()"/>
  </video>
</xsl:template>
<!-- copy object/@data-media-type to mime-type -->
<xsl:template match="h:object/@data-media-type">
  <xsl:attribute name="mime-type">
    <xsl:value-of select="."/>
  </xsl:attribute>
</xsl:template>
<!-- remove embed tags, attributes copied to video tag -->
<xsl:template match="h:object/h:embed"/>

<!-- ========================= -->
<!-- Iframe                    -->
<!-- ========================= -->

<xsl:template match="h:iframe">
  <iframe>
    <xsl:apply-templates select="@*|node()"/>
  </iframe>
</xsl:template>

<!-- ========================= -->
<!-- Glossary: Partial Support -->
<!-- ========================= -->

<xsl:template match="*[@data-type='definition']">
  <definition>
    <xsl:apply-templates select="@*|node()"/>
  </definition>
</xsl:template>

<xsl:template match="*[@data-type='meaning']">
  <meaning>
    <xsl:apply-templates select="@*|node()"/>
  </meaning>
</xsl:template>

<xsl:template match="*[@data-type='seealso']">
  <seealso>
    <xsl:apply-templates select="@*|node()"/>
  </seealso>
</xsl:template>

</xsl:stylesheet>
