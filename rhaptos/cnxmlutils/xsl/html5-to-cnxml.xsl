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






<!-- ======================================== -->
<!-- Global Attribute Handlers -->
<!-- ======================================== -->

<xsl:template match="@id">
  <xsl:copy/>
</xsl:template>

<xsl:template match="@class"/>
<xsl:template match="h:a/@class">
  <xsl:copy/>
</xsl:template>

<!-- Ignore document-title, it is handled explicitly. -->
<xsl:template match="/h:body/*[@data-type='document-title']"/>

<xsl:template match="@data-label" mode="labeled">
  <!-- FIXME labels can have child elements. However, the cnxml->html doesn't address this either. -->
  <label><xsl:value-of select="."/></label>
</xsl:template>
<!-- drop label from the attribute list -->
<xsl:template match="@data-label"/>

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


<!-- ======================================== -->
<!-- Callables -->
<!-- ======================================== -->

<xsl:template name="labeled-content">
  <!-- Essentially does the same as:  <xsl:apply-templates select="@*|node()"/> -->
  <!-- ... Except it interjects the label after calls to the the other attributes have been made. -->
  <!-- If not called in this order, the created element will prevent the other attributes from applying themselves to the parent element. -->
  <xsl:apply-templates select="@*"/>
  <xsl:apply-templates select="@data-label" mode="labeled"/>
  <xsl:apply-templates select="node()"/>
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
    <xsl:apply-templates select="@data-label" mode="labeled"/>
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
  <example>
    <xsl:call-template name="labeled-content"/>
  </example>
</xsl:template>

<xsl:template match="*[@data-type='exercise']">
  <exercise>
    <xsl:call-template name="labeled-content"/>
  </exercise>
</xsl:template>

<xsl:template match="*[@data-type='problem']">
  <problem>
    <xsl:call-template name="labeled-content"/>
  </problem>
</xsl:template>

<xsl:template match="*[@data-type='solution']">
  <solution>
    <xsl:call-template name="labeled-content"/>
  </solution>
</xsl:template>

<xsl:template match="*[@data-type='proof']">
  <proof>
    <xsl:call-template name="labeled-content"/>
  </proof>
</xsl:template>

<xsl:template match="*[@data-type='statement']">
  <statement>
    <xsl:call-template name="labeled-content"/>
  </statement>
</xsl:template>

<xsl:template match="*[@data-type='commentary']">
  <commentary>
    <xsl:call-template name="labeled-content"/>
</commentary>
</xsl:template>

<xsl:template match="*[@data-type='equation']">
  <equation>
    <xsl:call-template name="labeled-content"/>
  </equation>
</xsl:template>

<xsl:template match="*[@data-type='rule']">
  <rule>
    <xsl:call-template name="labeled-content"/>
  </rule>
</xsl:template>

<xsl:template match="h:q">
  <quote>
    <xsl:call-template name="labeled-content"/>
  </quote>
</xsl:template>

<xsl:template match="h:blockquote">
  <quote>
    <xsl:call-template name="labeled-content"/>
  </quote>
</xsl:template>

<xsl:template match="h:code">
  <code>
    <xsl:call-template name="labeled-content"/>
  </code>
</xsl:template>

<xsl:template match="h:pre">
  <code>
    <xsl:call-template name="labeled-content"/>
  </code>
</xsl:template>

<xsl:template match="*[@data-type='code']">
  <code>
    <xsl:call-template name="labeled-content"/>
  </code>
</xsl:template>

<xsl:template match="*[@data-type='code']/h:pre">
  <!-- unwrap the pre tag in the div -->
  <xsl:apply-templates select="node()"/>
</xsl:template>


<!-- ========================= -->

<xsl:template match="*[@data-type='note']">
  <note>
    <xsl:call-template name="labeled-content"/>
  </note>
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
<!-- Newlines & Spaces -->
<!-- ======================================== -->

<xsl:template match="*[@data-type='newline']">
  <newline>
    <xsl:apply-templates select="@*"/>
  </newline>
</xsl:template>

<xsl:template match="*[@data-type='newline']/@*|*[@data-type='space']/@*">
  <xsl:if test="local-name()='data-effect' or local-name()='data-count'">
    <xsl:call-template name="data-prefix"/>
  </xsl:if>
  <xsl:if test="local-name()='id'">
    <xsl:copy/>
  </xsl:if>
</xsl:template>

<xsl:template match="*[@data-type='space']">
  <space>
    <xsl:apply-templates select="@*"/>
  </space>
</xsl:template>


<!-- ======================================== -->
<!-- Lists -->
<!-- ======================================== -->

<xsl:template match="h:ol">
  <list list-type="enumerated">
    <xsl:call-template name="labeled-content"/>
  </list>
</xsl:template>

<xsl:template match="h:ul">
  <list list-type="bulleted">
    <xsl:call-template name="labeled-content"/>
  </list>
</xsl:template>

<xsl:template match="h:li|*[@data-type='item']">
  <item>
    <xsl:call-template name="labeled-content"/>
  </item>
</xsl:template>

<xsl:template match="*[@data-type='list']">
  <list>
    <!-- Specifiy the list-type based on the html list element. -->
    <xsl:choose>
      <xsl:when test="h:ol">
        <xsl:attribute name="list-type">enumerated</xsl:attribute>
      </xsl:when>
      <xsl:when test="h:ul">
        <xsl:attribute name="list-type">bulleted</xsl:attribute>
      </xsl:when>
    </xsl:choose>

    <!-- Attach any attributes on the html list element to the cnxml list tag. -->
    <xsl:apply-templates select="@*"/>
    <!-- do something with the attributes of my child list
         (this happens when it's a list with title)
         <div data-type='list' id='id4'>
           <div data-type='title'>
             list with all attributes and title
           </div>
           <div data-type='list'>
             <div data-type='item'>and item</div>
           </div>
         </div> -->
    <xsl:apply-templates select="*[@data-type='list']/@*|h:ul/@*|h:ol/@*"/>
    <!-- finally go through all the nodes -->
    <xsl:apply-templates select="node()"/>
  </list>
</xsl:template>

<xsl:template match="*[@data-type='list' and
                       preceding-sibling::*/@data-type='title' and
                       parent::*/@data-type='list']/@*">
  <xsl:apply-templates select="."/>
</xsl:template>

<xsl:template match="h:ul/@*|h:ol/@*|*[@data-type='list']/@*">
  <xsl:if test="starts-with(local-name(), 'data-')">
    <xsl:call-template name="data-prefix"/>
  </xsl:if>
</xsl:template>

<xsl:template match="h:ol/@start|*[@data-type='list']/@start">
  <xsl:attribute name="start-value">
    <xsl:value-of select="."/>
  </xsl:attribute>
</xsl:template>

<xsl:template match="h:ul/@id|
                     h:ol/@id|
                     *[@data-type='list']/@id">
  <xsl:copy/>
</xsl:template>

<xsl:template match="h:ul/@data-labeled-item|
                     h:ol/@data-labeled-item|
                     *[@data-type='list']/@data-labeled-item">
  <xsl:attribute name="list-type">labeled-item</xsl:attribute>
</xsl:template>

<xsl:template match="h:ul/@data-element-type|
                     h:ol/@data-element-type|
                     *[@data-type='list']/@data-element-type">
  <xsl:attribute name="type">
    <xsl:value-of select="."/>
  </xsl:attribute>
</xsl:template>

<!-- no need to copy data-type as it's already in the tag name -->
<xsl:template match="*[@data-type='list']/@data-type"/>

<xsl:template match="*[@data-type='list' and preceding-sibling::*/@data-type='title' and parent::*/@data-type='list']">
  <xsl:apply-templates select="node()"/>
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
    <xsl:choose>
      <xsl:when test="@class='autogenerated-content'">
        <xsl:apply-templates select="@*[local-name()!='class']"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="@*|node()"/>
      </xsl:otherwise>
    </xsl:choose>
  </link>
</xsl:template>

<xsl:template match="h:a[@data-type='image']">
  <xsl:apply-templates select="node()" mode="jar-image"/>
</xsl:template>

<xsl:template match="h:a/@*[local-name()!='id']"/>
<xsl:template match="h:a/@*[starts-with(local-name(), 'data-')]">
  <xsl:call-template name="data-prefix"/>
</xsl:template>
<xsl:template match="h:a[@target='_window']/@target">
  <xsl:attribute name="window">new</xsl:attribute>
</xsl:template>

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
  <xsl:apply-templates select="@data-label" mode="labeled"/>
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
    <xsl:apply-templates select="@data-label" mode="labeled"/>
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
<!-- Media -->
<!-- ========================= -->

<xsl:template match="*[@data-type='media']">
  <media>
    <xsl:apply-templates select="@*|node()"/>
  </media>
</xsl:template>

<xsl:template match="h:img/@alt|*[@data-type='image']/@alt"/>
<xsl:template match="h:img|*[@data-type='image']">
  <image mime-type="{@data-media-type}">
    <xsl:if test="contains(@class, 'for-')">
      <xsl:attribute name="for">
        <xsl:value-of select="substring-before(substring-after(@class, 'for-'), ' ')"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </image>
</xsl:template>
<xsl:template match="h:img/@width|h:img/@height|h:img/@src|
                     *[@data-type='image']/@width|*[@data-type='image']/@height">
  <xsl:copy/>
</xsl:template>
<xsl:template match="h:img" mode="jar-image">
  <image thumbnail="{@src}" src="{../@href}">
    <xsl:apply-templates select="@*[local-name()!='src']|node()"/>
  </image>
</xsl:template>
<!-- already in image@mime-type -->
<xsl:template match="h:img/@data-media-type|*[@data-type='image']/@data-media-type"/>

<xsl:template match="h:video/@*|h:audio/@*">
  <xsl:if test="starts-with(local-name(), 'data-')">
    <xsl:call-template name="data-prefix"/>
  </xsl:if>
</xsl:template>

<xsl:template match="h:video|h:audio">
  <xsl:element name="{name(.)}">
    <xsl:attribute name="src"><xsl:value-of select="h:source/@src"/></xsl:attribute>
    <xsl:attribute name="mime-type"><xsl:value-of select="h:source/@type"/></xsl:attribute>
    <xsl:if test="@muted">
      <xsl:attribute name="volume">0</xsl:attribute>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
    <xsl:if test="@data-author">
      <param name="author" value="{@data-author}"/>
    </xsl:if>
  </xsl:element>
</xsl:template>

<!-- remove source tag, @src and @type should be in video/audio tag -->
<xsl:template match="h:video/h:source|h:audio/h:source"/>

<xsl:template match="h:video/@autoplay|h:audio/@autoplay">
  <xsl:attribute name="autoplay">true</xsl:attribute>
</xsl:template>

<xsl:template match="h:video/@loop|h:video/@controller|h:video/@height|h:video/@width|
                     h:audio/@loop|h:audio/@controller|h:audio/@height|h:audio/@width">
  <xsl:copy/>
</xsl:template>

<!-- media type is already in mime-type -->
<xsl:template match="h:video/@data-media-type|h:audio/@data-media-type"/>

<xsl:template match="h:video/@controls|h:audio/@controls"/>

<!-- already added to as a param tag -->
<xsl:template match="h:video/@data-author|h:audio/@data-author"/>

<xsl:template match="*[@data-print='true']/@data-print">
  <xsl:attribute name="for">pdf</xsl:attribute>
</xsl:template>

<xsl:template match="*[@data-print='false']/@data-print">
  <xsl:attribute name="for">online</xsl:attribute>
</xsl:template>

<xsl:template match="h:object/h:param"/>

<xsl:template match="h:object/h:param/@*">
  <xsl:copy/>
</xsl:template>
<xsl:template match="h:object[not(@type='application/x-labview-vi')]/h:param">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- create attributes in parent element for some of the params -->
<xsl:template match="h:object[@type='application/x-labview-vi']/h:param[@name='version']|
                     h:object[@type='application/x-java-applet']/h:param[@name='code' or @name='codebase' or @name='archive' or @name='name' or @name='src']">
  <xsl:attribute name="{@name}">
    <xsl:value-of select="@value"/>
  </xsl:attribute>
</xsl:template>

<xsl:template match="h:object/@height|h:object/@width">
  <xsl:copy/>
</xsl:template>
<xsl:template match="h:object">
  <video mime-type="{@data-media-type}" src="{h:embed/@src}">
    <xsl:apply-templates select="@*"/>
  </video>
</xsl:template>
<xsl:template match="h:object[@type='application/x-shockwave-flash']">
  <flash src="{h:embed/@src}">
    <xsl:if test="h:embed/@wmode">
      <xsl:attribute name="wmode">
        <xsl:value-of select="h:embed/@wmode"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:apply-templates select="@*[local-name() != 'data']|h:param|node()[not(self::h:param)]"/>
  </flash>
</xsl:template>
<xsl:template match="h:object[@type='application/x-labview-vi']">
  <labview src="{@data}">
    <xsl:apply-templates select="@*[local-name() != 'data']|h:param"/>
  </labview>
</xsl:template>
<xsl:template match="h:object[@type='application/x-java-applet']">
  <java-applet src="{h:embed/@src}">
    <xsl:apply-templates select="@*"/>
    <xsl:apply-templates select="h:param[@name='code' or @name='codebase' or @name='archive' or @name='name' or @name='src']"/>
    <xsl:apply-templates select="h:param[not(@name='code' or @name='codebase' or @name='archive' or @name='name' or @name='src')]|node()[not(self::h:param) and not(self::h:span)]"/>
  </java-applet>
</xsl:template>
<!-- copy object/@type to mime-type -->
<xsl:template match="h:object/@type">
  <xsl:attribute name="mime-type">
    <xsl:value-of select="."/>
  </xsl:attribute>
</xsl:template>
<!-- remove embed tags, attributes copied to parent tag -->
<xsl:template match="h:object/h:embed"/>

<xsl:template match="h:object[@type='application/x-labview-vi']/h:param[@name='lvfppviname']">
  <xsl:attribute name="viname">
    <xsl:value-of select="@value"/>
  </xsl:attribute>
</xsl:template>

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
    <xsl:call-template name="labeled-content"/>
  </definition>
</xsl:template>

<xsl:template match="*[@data-type='meaning']">
  <meaning>
    <xsl:apply-templates select="@*|node()"/>
  </meaning>
</xsl:template>

<xsl:template match="*[@data-type='seealso']">
  <seealso>
    <xsl:call-template name="labeled-content"/>
  </seealso>
</xsl:template>

<!-- ========================= -->
<!-- MathML -->
<!-- ========================= -->

<xsl:template match="m:*">
  <xsl:element name="m:{name()}">
    <xsl:apply-templates select="@*|node()"/>
  </xsl:element>
</xsl:template>

<xsl:template match="m:*/@*">
  <xsl:copy/>
</xsl:template>

</xsl:stylesheet>
