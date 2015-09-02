<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://cnx.rice.edu/cnxml"
  xmlns:h="http://www.w3.org/1999/xhtml"
  xmlns:m="http://www.w3.org/1998/Math/MathML"
  xmlns:q="http://cnx.rice.edu/qml/1.0"
  xmlns:bib="http://bibtexml.sf.net/"
  xmlns:data="http://www.w3.org/TR/html5/dom.html#custom-data-attribute"
  xmlns:a="http://attributes.list"
  exclude-result-prefixes="h a"
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

<xsl:template match="*/@class">
  <!-- FIXME Drop the choose in favor of a straight copy (in the xsl:otherwise). -->
  <xsl:choose>
    <xsl:when test="parent::*[@data-type='example']
                    |parent::*[@data-type='exercise']
                    |parent::*[@data-type='problem']
                    |parent::*[@data-type='solution']
                    |parent::*[@data-type='commentary']
                    |parent::*[@data-type='note']
                    |parent::*[@data-type='equation']
                    |parent::*[@data-type='title' and parent::*[@data-type='example' or @data-type='note' or @data-type='figure']]">
      <!-- FFF When @data-type is added to the aloha plugins, this will strip the previously used class as type definer from the classes. -->
      <xsl:variable name="classes">
        <xsl:call-template name="string-replace-all">
          <xsl:with-param name="text" select="."/>
          <xsl:with-param name="replace" select="parent::*/@data-type"/>
          <xsl:with-param name="by" select="string('')"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:if test="$classes != ''">
        <xsl:attribute name="class">
          <xsl:value-of select="normalize-space($classes)"/>
        </xsl:attribute>
      </xsl:if>
    </xsl:when>
    <xsl:when test="parent::h:dl">
      <xsl:variable name="classes">
        <xsl:call-template name="string-replace-all">
          <xsl:with-param name="text" select="."/>
          <xsl:with-param name="replace" select="string('definition')"/>
          <xsl:with-param name="by" select="string('')"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:if test="$classes != ''">
        <xsl:attribute name="class">
          <xsl:value-of select="normalize-space($classes)"/>
        </xsl:attribute>
      </xsl:if>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="*/@data-element-type">
  <xsl:attribute name="type">
    <xsl:value-of select="."/>
  </xsl:attribute>
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

<a:attributes>
<a:attrib name='align'/>
<a:attrib name='alt'/>
<a:attrib name='archive'/>
<a:attrib name='author'/>
<a:attrib name='autoplay'/>
<a:attrib name='bgcolor'/>
<a:attrib name='bullet-style'/>
<a:attrib name='char'/>
<a:attrib name='charoff'/>
<a:attrib name='code'/>
<a:attrib name='codebase'/>
<a:attrib name='colname'/>
<a:attrib name='colnum'/>
<a:attrib name='cols'/>
<a:attrib name='colsep'/>
<a:attrib name='colwidth'/>
<a:attrib name='controller'/>
<a:attrib name='count'/>
<a:attrib name='depth'/>
<a:attrib name='display'/>
<a:attrib name='document'/>
<a:attrib name='effect'/>
<a:attrib name='element-type'/>
<a:attrib name='flash-vars'/>
<a:attrib name='for'/>
<a:attrib name='frame'/>
<a:attrib name='has-label'/>
<a:attrib name='height'/>
<a:attrib name='item-sep'/>
<a:attrib name='label'/>
<a:attrib name='labeled-item'/>
<a:attrib name='lang'/>
<a:attrib name='list-type'/>
<a:attrib name='loop'/>
<a:attrib name='longdesc'/>
<a:attrib name='mark-prefix'/>
<a:attrib name='mark-suffix'/>
<a:attrib name='media-type'/>
<a:attrib name='mime-type'/>
<a:attrib name='morerows'/>
<a:attrib name='name'/>
<a:attrib name='nameend'/>
<a:attrib name='namest'/>
<a:attrib name='number-style'/>
<a:attrib name='orient'/>
<a:attrib name='pgwide'/>
<a:attrib name='pluginspage'/>
<a:attrib name='print-placement'/>
<a:attrib name='print-width'/>
<a:attrib name='pub-type'/>
<a:attrib name='quality'/>
<a:attrib name='resource'/>
<a:attrib name='rowsep'/>
<a:attrib name='scale'/>
<a:attrib name='spanname'/>
<a:attrib name='src'/>
<a:attrib name='standby'/>
<a:attrib name='start-value'/>
<a:attrib name='strength'/>
<a:attrib name='summary'/>
<a:attrib name='target-id'/>
<a:attrib name='thumbnail'/>
<a:attrib name='to-term'/>
<a:attrib name='type'/>
<a:attrib name='url'/>
<a:attrib name='valign'/>
<a:attrib name='value'/>
<a:attrib name='version'/>
<a:attrib name='volume'/>
<a:attrib name='width'/>
<a:attrib name='window'/>
<a:attrib name='wmode'/>
</a:attributes>

<xsl:key name='attr' match='a:attrib' use='@name' />
<xsl:variable name='attributes' select='document("")//a:attributes' />

<xsl:template match="@*[starts-with(local-name(), 'data-') and local-name() != 'data-label' and local-name() != 'data-type']">
  <xsl:variable name="name" select="substring-after(local-name(), 'data-')"/>
  <xsl:variable name="value" select="."/>
  <xsl:for-each select="$attributes">
      <xsl:choose>
      <xsl:when test='key("attr",$name)'>
          <xsl:attribute name="{$name}">
            <xsl:value-of select="$value"/>
          </xsl:attribute>
      </xsl:when>
      <xsl:otherwise>
          <xsl:attribute name="data:{$name}">
            <xsl:value-of select="$value"/>
          </xsl:attribute>
      </xsl:otherwise>
      </xsl:choose>
  </xsl:for-each>
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
    <xsl:if test="./h:cnx-pi[@data-type='cnx.flag.introduction']">
      <xsl:attribute name="class">
        <xsl:value-of select="substring-before(substring-after(./h:cnx-pi[@data-type='cnx.flag.introduction']/text(), 'class=&quot;'), '&quot;')"/>
      </xsl:attribute>
    </xsl:if>
    <!-- Unable to utilize @module-id or @id because this information is not in the html. -->
    <title>
      <xsl:apply-templates select="*[@data-type='document-title']/text()" />
    </title>
    <content>
      <xsl:apply-templates select="@*|node()[not(@data-type='glossary' or @data-type='footnote-refs')]"/>
    </content>
    <xsl:if test="*[@data-type='glossary']">
      <glossary>
        <xsl:apply-templates select="*[@data-type='glossary']/@*|*[@data-type='glossary']/node()"/>
      </glossary>
    </xsl:if>
  </document>
</xsl:template>

<!-- @data-type='abstract-wrapper' is an container element that is placed on an abstract just before transformation. -->
<!-- The 'wrapper' tag is used to contain otherwise loose content. It is removed in post-processing. -->
<xsl:template match="*[@data-type='abstract-wrapper']">
  <wrapper>
    <xsl:apply-templates select="node()"/>
  </wrapper>
</xsl:template>

<!-- abstract should not be in content, it's already in the database -->
<xsl:template match="*[@data-type='abstract']"/>

<xsl:template match="h:div[@data-type='description']/@itemprop"/>

<!-- data-type description is in the summary when using the webview editor -->
<!-- FIXME Remove class matching -->
<xsl:template match="h:div[(not(@data-type) or @data-type='description')
                           and not(contains(@class, 'example')
                                   or contains(@class, 'exercise')
                                   or contains(@class, 'problem')
                                   or contains(@class, 'solution')
                                   or contains(@class, 'commentary')
                                   or contains(@class, 'note')
                                   or contains(@class, 'equation')
                                   or contains(@class, 'title'))]">
  <div>
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<xsl:template match="h:span[not(@data-type)]">
  <span>
    <xsl:apply-templates select="@*|node()"/>
  </span>
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

<xsl:template name="string-replace-all">
  <!-- Origin http://stackoverflow.com/questions/1069092/xslt-replace-function-not-found -->
  <xsl:param name="text"/>
  <xsl:param name="replace"/>
  <xsl:param name="by"/>
  <xsl:choose>
    <xsl:when test="contains($text,$replace)">
      <xsl:value-of select="substring-before($text,$replace)"/>
      <xsl:value-of select="$by"/>
      <xsl:call-template name="string-replace-all">
        <xsl:with-param name="text" select="substring-after($text,$replace)"/>
        <xsl:with-param name="replace" select="$replace"/>
        <xsl:with-param name="by" select="$by"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$text"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- ======================================== -->
<!-- Processing instructions -->
<!-- ======================================== -->

<xsl:template match="processing-instruction()">
  <xsl:processing-instruction name="{local-name()}">
    <xsl:value-of select="."/>
  </xsl:processing-instruction>
</xsl:template>

<xsl:template match="h:cnx-pi">
  <xsl:processing-instruction name="{@data-type}">
    <xsl:value-of select="text()"/>
  </xsl:processing-instruction>
</xsl:template>


<!-- ========================= -->
<!-- Generic elements and attribs -->

<xsl:template match="@data-type"/>

<!-- FIXME Remove class matching -->
<xsl:template match="*[@data-type='title']
                     |*[contains(@class, 'title')
                        and (parent::*[contains(@class, 'example') or contains(@class, 'note')]
                             or parent::h:figure)]">
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

<!-- FIXME Remove class matching -->
<xsl:template match="*[@data-type='example']
                     |*[contains(@class, 'example')]">
  <example>
    <xsl:call-template name="labeled-content"/>
  </example>
</xsl:template>

<xsl:template match="*[@data-type='exercise']/@data-print-placement|
                     *[@data-type='solution']/@data-print-placement">
  <xsl:call-template name="data-prefix"/>
</xsl:template>

<!-- FIXME Remove class matching -->
<xsl:template match="*[@data-type='exercise']
                     |*[contains(@class, 'exercise')]">
  <exercise>
    <xsl:call-template name="labeled-content"/>
  </exercise>
</xsl:template>

<!-- FIXME Remove class matching -->
<xsl:template match="*[@data-type='problem']
                     |*[contains(@class, 'problem')]">
  <problem>
    <xsl:call-template name="labeled-content"/>
  </problem>
</xsl:template>

<!-- FIXME Remove class matching -->
<xsl:template match="*[@data-type='solution']
                     |*[contains(@class, 'solution')]">
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

<!-- FIXME Remove class matching -->
<xsl:template match="*[@data-type='commentary']
                     |*[contains(@class, 'commentary')]">
  <commentary>
    <xsl:call-template name="labeled-content"/>
</commentary>
</xsl:template>

<!-- FIXME Remove class matching -->
<xsl:template match="*[@data-type='equation']
                     |*[contains(@class, 'equation')]">
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

<xsl:template match="h:code|h:pre">
  <code><xsl:call-template name="labeled-content"/></code>
</xsl:template>

<xsl:template match="*[@data-type='code']">
  <code>
    <xsl:apply-templates select="@*|h:pre/@*"/>
    <xsl:apply-templates select="h:pre/@data-label" mode="labeled"/>
    <xsl:apply-templates select="node()"/>
  </code>
</xsl:template>

<!-- don't copy whitespace only text node in <div data-type="code"> -->
<xsl:template match="*[@data-type='code']/text()[normalize-space()='']"/>

<xsl:template match="*[@data-type='code']/h:pre/@*">
  <xsl:if test="starts-with(local-name(), 'data-') and local-name()!='data-label'">
    <xsl:call-template name="data-prefix"/>
  </xsl:if>
</xsl:template>

<xsl:template match="*[@data-type='code']/h:pre">
  <!-- unwrap the pre tag in the div -->
  <xsl:apply-templates select="node()"/>
</xsl:template>

<xsl:template match="h:cite/@*">
  <xsl:copy/>
</xsl:template>

<xsl:template match="h:cite">
  <cite>
    <xsl:apply-templates select="@*|node()"/>
  </cite>
</xsl:template>

<xsl:template match="*[@data-type='cite-title']">
  <cite-title>
    <xsl:apply-templates select="@*|node()"/>
  </cite-title>
</xsl:template>


<!-- ========================= -->

<!-- FIXME Remove class matching -->
<xsl:template match="*[@data-type='note']
                     |*[contains(@class, 'note')]">
  <note>
    <xsl:apply-templates select="@*[not(local-name()='data-label' or local-name()='data-has-label')]"/>
    <xsl:apply-templates select="@data-label|node()"/>
  </note>
</xsl:template>

<xsl:template match="*[@data-type='note']/@data-label">
  <xsl:if test="../@data-has-label='true'">
    <xsl:apply-templates select="." mode="labeled"/>
  </xsl:if>
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

<xsl:template match="h:br">
  <newline/>
</xsl:template>

<xsl:template match="h:hr">
  <newline effect="underline"/>
</xsl:template>

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

<!-- The emphasis class is already in the effect -->
<xsl:template match="*[@data-type='emphasis']/@class"/>

<xsl:template match="*[@data-type='emphasis']">
  <emphasis><xsl:apply-templates select="@*|node()"/></emphasis>
</xsl:template>

<!-- ========================= -->

<xsl:template match="*[@data-type='foreign']">
  <foreign><xsl:apply-templates select="@*|node()"/></foreign>
</xsl:template>

<xsl:template match="h:sub">
  <sub><xsl:apply-templates select="@*|node()"/></sub>
</xsl:template>

<xsl:template match="h:sup">
  <sup><xsl:apply-templates select="@*|node()"/></sup>
</xsl:template>

<!-- ======================================== -->
<!-- Link and term and cite -->
<!-- All link data is treated the same way. All @href values are transformed to @url. -->
<!-- We post-process the @url value during the reference resolution procedure. -->
<!-- ======================================== -->

<xsl:template match="*[@data-type='term']">
  <term><xsl:apply-templates select="@*|node()"/></term>
</xsl:template>

<xsl:template match="h:a/*[@data-type='term']">
  <!-- unwrap the term inside the link -->
  <xsl:apply-templates select="node()"/>
</xsl:template>

<xsl:template match="*[@data-type='cite']">
  <cite>
    <xsl:apply-templates select="@*|node()"/>
</cite>
</xsl:template>

<xsl:template match="h:a/*[@data-type='cite']">
  <!-- unwrap the cite inside the link -->
  <xsl:apply-templates select="@*[local-name()!='data-type']|node()"/>
</xsl:template>

<!-- suppress cite data-type, currently only data-type on a -->
<xsl:template match="h:a/@data-type"/>

<xsl:template match="h:a[@href and not(@data-type='footnote-number')]">
  <xsl:variable name="tag_name">
    <xsl:choose>
      <xsl:when test="@data-to-term='true'">term</xsl:when>
      <xsl:when test="@data-type='cite'">cite</xsl:when>
      <xsl:otherwise>link</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:element name="{$tag_name}">
    <xsl:attribute name="url">
      <xsl:value-of select="@href"/>
    </xsl:attribute>
    <xsl:choose>
      <xsl:when test="@class='autogenerated-content'">
        <xsl:apply-templates select="@*[local-name()!='class']"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="@*|*[@data-type='term']/@data-strength"/>
        <xsl:apply-templates select="node()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:element>
</xsl:template>

<xsl:template match="h:a[@data-to-term='true']/@data-to-term"/>

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
  <table>
    <!-- Akin to figure captions -->
    <xsl:apply-templates select="h:caption/*[@data-type='title']|@*"/>
    <xsl:apply-templates select="@data-label" mode="labeled"/>
    <xsl:if test="h:caption/node()[not(self::*[@data-type='title']) and not(normalize-space()='')]">
      <caption>
        <xsl:apply-templates select="h:caption/node()[not(self::*[@data-type='title'])]"/>
      </caption>
    </xsl:if>

    <!-- calculate maximum number of columns -->
    <xsl:variable name="cols">
      <xsl:choose>
        <xsl:when test="h:thead/h:tr[1]/h:th">
          <xsl:value-of select="sum(h:thead/h:tr[1]/*/@colspan) + count(h:thead/h:tr[1]/*[not(@colspan)])"/>
        </xsl:when>
        <xsl:when test="h:tbody/h:tr[1]/h:td">
          <xsl:value-of select="sum(h:tbody/h:tr[1]/*/@colspan) + count(h:tbody/h:tr[1]/*[not(@colspan)])"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <tgroup cols="{$cols}">
      <xsl:call-template name="colspec">
        <xsl:with-param name="colspec.cols" select="$cols"/>
      </xsl:call-template>
      <xsl:apply-templates select="node()[not(self::h:caption) and not(self::h:colgroup)]"/>
    </tgroup>
  </table>
</xsl:template>

<xsl:template match="h:col/@*"/>
<!-- @data-width is copied to colwidth in the colspec template -->
<xsl:template match="h:col/@data-width"/>
<xsl:template match="h:col/@*[starts-with(local-name(),'data-')]">
  <xsl:call-template name="data-prefix"/>
</xsl:template>

<!-- generate colspec
     arguments: colspec.cols - number of colspec to create
     generate <colspec colname="c{$column.number}"/> -->
<xsl:template name="colspec">
  <xsl:param name="colspec.cols"/>
  <xsl:param name="colspec.current" select="1"/>

  <xsl:if test="$colspec.current &lt;= $colspec.cols">
    <colspec colname="c{$colspec.current}">
      <xsl:if test="h:colgroup/h:col[$colspec.current]/@data-width[normalize-space()!='']">
        <xsl:attribute name="colwidth">
          <xsl:value-of select="h:colgroup/h:col[$colspec.current]/@data-width"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="h:colgroup/h:col[$colspec.current]/@*"/>
    </colspec>
    <xsl:call-template name="colspec">
      <xsl:with-param name="colspec.cols" select="$colspec.cols"/>
      <xsl:with-param name="colspec.current" select="$colspec.current + 1"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<xsl:template match="h:table/@summary">
  <xsl:copy/>
</xsl:template>

<xsl:template match="h:thead|h:tbody|h:tfoot">
  <xsl:element name="{local-name()}">
    <xsl:apply-templates select="@*|node()"/>
  </xsl:element>
</xsl:template>

<xsl:template match="h:tr">
  <row><xsl:apply-templates select="@*|node()"/></row>
</xsl:template>

<xsl:template match="h:td|h:th">
  <entry><xsl:apply-templates select="@*|node()"/></entry>
</xsl:template>

<xsl:template match="h:td/@rowspan|h:th/@rowspan">
  <xsl:attribute name="morerows">
    <xsl:value-of select=". - 1"/>
  </xsl:attribute>
</xsl:template>

<xsl:template name="calculate-namest">
  <xsl:value-of select="sum(../preceding-sibling::*/@colspan) + count(../preceding-sibling::*[not(@colspan)])"/>
</xsl:template>

<xsl:template match="h:td/@colspan|h:th/@colspan">
  <xsl:variable name="namest">
    <xsl:call-template name="calculate-namest"/>
  </xsl:variable>
  <xsl:attribute name="namest">
    <xsl:text>c</xsl:text><xsl:value-of select="$namest + 1"/>
  </xsl:attribute>
  <xsl:attribute name="nameend">
    <xsl:text>c</xsl:text><xsl:value-of select="$namest + ."/>
  </xsl:attribute>
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
<xsl:template match="h:img|*[@data-type='image']" mode="normal-image">
  <image mime-type="{@data-media-type}">
    <xsl:if test="contains(@class, 'for-')">
      <xsl:attribute name="for">
        <xsl:value-of select="substring-before(substring-after(@class, 'for-'), ' ')"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </image>
</xsl:template>

<xsl:template match="h:img|*[@data-type='image']">
  <xsl:apply-templates select="." mode="normal-image"/>
</xsl:template>

<xsl:template match="h:img[not(parent::*[@data-type='media'])]">
  <media alt="{@alt}">
    <xsl:apply-templates select="." mode="normal-image"/>
  </media>
</xsl:template>

<xsl:template match="h:img/@width|h:img/@height|h:img/@src|
                     *[@data-type='image']/@width|*[@data-type='image']/@height">
  <xsl:copy/>
</xsl:template>
<xsl:template match="h:img" mode="jar-image">
  <image thumbnail="{@src}" src="{../@href}" mime-type="{@data-media-type}">
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
<xsl:template match="h:object[not(starts-with(@type, 'application/x-labview'))]/h:param">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- create attributes in parent element for some of the params -->
<xsl:template match="h:object[starts-with(@type, 'application/x-labview')]/h:param[@name='version']|
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
<xsl:template match="h:object[starts-with(@type, 'application/x-labview')]">
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

<!-- labview plugins page is only for html -->
<xsl:template match="h:object[starts-with(@type, 'application/x-labview')]/@data-pluginspage"/>

<xsl:template match="h:object[starts-with(@type, 'application/x-labview')]/h:param[@name='lvfppviname']">
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
<!-- Glossary -->
<!-- ========================= -->

<!-- A header is placed on the glossary during cnxml->html5. -->
<xsl:template match="*[@data-type='glossary-title']"/>

<xsl:template match="h:dl">
  <definition>
    <xsl:call-template name="labeled-content"/>
  </definition>
</xsl:template>

<xsl:template match="h:dt">
  <term>
    <xsl:apply-templates select="@*|node()"/>
  </term>
</xsl:template>

<xsl:template match="h:dd">
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
<!-- Footnote -->
<!-- This works by pulling the footnotes content out of the footnote section to place it inside the content. -->
<!-- ========================= -->

<xsl:template name="get-footnote">
  <xsl:param name="name"/>
  <xsl:apply-templates select="//h:li[h:a[@data-type='footnote-ref' and @name=$name]]" mode="footnote"/>
</xsl:template>

<xsl:template match="h:li" mode="footnote">
  <xsl:apply-templates select="h:a[@data-type='footnote-ref']" mode="footnote"/>
  <xsl:apply-templates select="node()[not(@data-type='footnote-ref')]"/>
</xsl:template>
<xsl:template match="h:a[@data-type='footnote-ref']" mode="footnote"/>

<xsl:template match="*[@data-type='footnote-number']">
  <footnote id="{substring(@href, 2)}">
    <xsl:call-template name="get-footnote">
      <xsl:with-param name="name" select="substring(@href, 2)"/>
    </xsl:call-template>
  </footnote>
</xsl:template>
<!-- A header is placed on the footnotes section during cnxml->html5. -->
<xsl:template match="*[@data-type='footnote-title']"/>

<xsl:template match="*[@date-type='footnote-refs']"/>

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
