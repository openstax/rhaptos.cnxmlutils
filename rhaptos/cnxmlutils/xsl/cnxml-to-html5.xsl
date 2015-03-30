<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:c="http://cnx.rice.edu/cnxml"
  xmlns:m="http://www.w3.org/1998/Math/MathML"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:md="http://cnx.rice.edu/mdml"
  xmlns:qml="http://cnx.rice.edu/qml/1.0"
  xmlns:mod="http://cnx.rice.edu/#moduleIds"
  xmlns:bib="http://bibtexml.sf.net/"

  xmlns:data="http://dev.w3.org/html5/spec/#custom"
  exclude-result-prefixes="m mml"

  >

<xsl:output omit-xml-declaration="yes" encoding="ASCII"/>

<!-- ========================= -->
<!-- One-way conversions       -->
<!-- ========================= -->

<!-- Pass through attributes with the data: prefix as HTML5 data-* attributes -->
<xsl:template match="@data:*">
  <xsl:attribute name="data-{local-name()}"><xsl:value-of select="." /></xsl:attribute>
</xsl:template>

<xsl:template match="c:div">
  <div><xsl:apply-templates select="@*|node()"/></div>
</xsl:template>

<xsl:template match="c:span">
  <span><xsl:apply-templates select="@*|node()"/></span>
</xsl:template>

<xsl:template match="c:document">
  <body xmlns="http://www.w3.org/1999/xhtml">
    <xsl:apply-templates select="c:title"/>
    <xsl:apply-templates select="c:metadata/md:abstract"/>
    <xsl:apply-templates select="c:content"/>
    <xsl:if test="c:content//c:footnote">
      <div data-type="footnote-refs">
        <h2 data-type="footnote-title">Footnotes</h2>
        <ol>
          <xsl:apply-templates select="//c:footnote" mode="footnote"/>
        </ol>
      </div>
    </xsl:if>
    <xsl:apply-templates select="c:glossary"/>
  </body>
</xsl:template>

<xsl:template match="md:abstract">
  <!-- Only render the abstract if it contains text/elements -->
  <xsl:if test="node()">
    <div data-type="abstract">
      <xsl:apply-templates select="@*|node()"/>
    </div>
  </xsl:if>
</xsl:template>


<!-- ========================= -->
<!-- Processing instructions   -->
<!-- ========================= -->

<xsl:template match="processing-instruction()">
  <cnx-pi data-type="{local-name()}">
    <xsl:value-of select="."/>
  </cnx-pi>
</xsl:template>


<!-- ========================= -->
<!-- Generic Util Tempaltes    -->
<!-- ========================= -->


<xsl:template match="@*" priority="-1000">
  <xsl:if test="namespace-uri(..) = 'http://cnx.rice.edu/cnxml' and ancestor::c:content">
    <xsl:message>TODO: <xsl:value-of select="local-name(..)"/>/@<xsl:value-of select="local-name()"/></xsl:message>
  </xsl:if>
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- Only consider c:titles in c:content (ignore c:document/c:title) -->
<xsl:template match="c:title[ancestor::c:content]" priority="0">
  <xsl:message>TODO: <xsl:value-of select="local-name(..)"/>/<xsl:value-of select="local-name(.)"/></xsl:message>
  <div class="not-converted-yet">NOT_CONVERTED_YET: <xsl:value-of select="local-name(..)"/>/<xsl:value-of select="local-name(.)"/></div>
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="c:*" priority="-1">
  <xsl:message>TODO: <xsl:value-of select="local-name(.)"/></xsl:message>
  <div class="not-converted-yet">NOT_CONVERTED_YET: <xsl:value-of select="local-name(.)"/></div>
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- MathJax doesn't like MathML with a prefix -->
<xsl:template match="m:math">
  <math xmlns="http://www.w3.org/1998/Math/MathML">
    <xsl:apply-templates select="@*|node()"/>
  </math>
</xsl:template>

<xsl:template match="m:*">
  <xsl:element name="{local-name()}" namespace="http://www.w3.org/1998/Math/MathML">
    <xsl:apply-templates select="@*|node()"/>
  </xsl:element>
</xsl:template>

<xsl:template match="node()[not(self::*)]" priority="-100">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="@id">
  <xsl:copy/>
</xsl:template>

<xsl:template name="data-prefix">
  <xsl:param name="name" select="local-name()"/>
  <xsl:param name="value" select="."/>
  <xsl:attribute name="data-{$name}">
    <xsl:value-of select="$value"/>
  </xsl:attribute>
</xsl:template>

<xsl:template match="@effect|@pub-type">
  <xsl:call-template name="data-prefix"/>
</xsl:template>

<xsl:template match="c:*/@type">
  <xsl:attribute name="data-element-type">
    <xsl:value-of select="."/>
  </xsl:attribute>
</xsl:template>

<xsl:template match="@class">
  <!-- FIXME Drop the choose in favor of a straight copy (in the xsl:otherwise). -->
  <xsl:choose>
    <xsl:when test="parent::c:example
                    |parent::c:exercise
                    |parent::c:problem
                    |parent::c:solution
                    |parent::c:commentary
                    |parent::c:note
                    |parent::c:equation
                    |parent::c:definition">
      <xsl:attribute name="class">
        <!-- Prepend the node name for as a **TEMPORARY** type definer. -->
        <xsl:value-of select="concat(concat(name(parent::*), ' '), .)"/>
      </xsl:attribute>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template match="c:content">
  <xsl:apply-templates select="node()"/>
</xsl:template>

<xsl:template mode="class" match="node()"/>
<xsl:template mode="class" match="*">
  <xsl:param name="newClasses"/>
  <xsl:attribute name="data-type">
    <xsl:value-of select="local-name()"/>
  </xsl:attribute>
  <xsl:if test="$newClasses">
    <xsl:attribute name="class">
      <xsl:value-of select="$newClasses"/>
    </xsl:attribute>
  </xsl:if>
</xsl:template>

<!-- ========================= -->

<!-- c:label elements are converted to a data-label attribute in HTML -->

<!-- Ignore spaces before the label and title elements
     (so we can match rules that convert them to attributes) -->
<xsl:template match="text()[following-sibling::*[1][self::c:label or self::c:title]]|comment()[following-sibling::*[1][self::c:label or self::c:title]]">
</xsl:template>


<xsl:template match="c:label[node()]|c:label[not(node())]">
  <!--xsl:message>Applying label to <xsl:value-of select="../@id"/></xsl:message-->
  <xsl:attribute name="data-label"><xsl:value-of select="node()"/></xsl:attribute>
</xsl:template>

<!-- TODO: revisit whether labels should contain markup or if the markup can be "pushed" out; some contain emphasis and math -->
<xsl:template match="c:label[*]">
  <xsl:message>TODO: Support label with element children</xsl:message>
  <xsl:attribute name="data-label">
    <xsl:apply-templates select="text()|.//c:*/text()"/> <!-- do not include MathML text nodes -->
  </xsl:attribute>
</xsl:template>

<!-- ========================= -->

<xsl:template match="/c:document/c:title">
  <div data-type="document-title">
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<xsl:template match="c:title|c:para//c:list[not(@display)]/c:title|c:para//c:list[@display='block']/c:title">
  <div data-type="title">
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<xsl:template match="c:para/c:title|c:table/c:title|c:para//c:title[not(parent::c:list)]|c:para//c:list[@display='inline']/c:title">
  <span data-type="title"><xsl:apply-templates select="@*|node()"/></span>
</xsl:template>

<!-- ========================= -->

<xsl:template match="c:section[c:title]">
  <xsl:param name="depth" select="1"/>
  <section>
    <xsl:attribute name="data-depth"><xsl:value-of select="$depth"/></xsl:attribute>
    <xsl:apply-templates select="@*|c:label"/>
    <xsl:element name="h{$depth}">
      <xsl:apply-templates mode="class" select="c:title"/>
      <xsl:apply-templates select="c:title/@*|c:title/node()"/>
    </xsl:element>
    <xsl:apply-templates select="node()[not(self::c:title or self::c:label)]">
      <xsl:with-param name="depth" select="$depth + 1"/>
    </xsl:apply-templates>
  </section>
</xsl:template>

<xsl:template match="c:section[not(c:title)]">
  <xsl:param name="depth" select="1"/>
  <section>
    <xsl:attribute name="data-depth"><xsl:value-of select="$depth"/></xsl:attribute>
    <xsl:apply-templates select="@*|node()">
      <xsl:with-param name="depth" select="$depth + 1"/>
    </xsl:apply-templates>
  </section>
</xsl:template>

<xsl:template match="c:para">
  <p><xsl:apply-templates select="@*|node()"/></p>
</xsl:template>

<xsl:template match="c:example">
  <!-- FIXME Drop @class as type definer. -->
  <div data-type="{local-name()}">
    <xsl:if test="not(@class)">
      <xsl:attribute name="class">
        <xsl:value-of select="local-name()"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<xsl:template match="c:exercise/@print-placement|c:solution/@print-placement">
  <xsl:call-template name="data-prefix"/>
</xsl:template>

<xsl:template match="c:exercise">
  <!-- FIXME Drop @class as type definer. -->
  <div data-type="{local-name()}">
    <xsl:if test="not(@class)">
      <xsl:attribute name="class">
        <xsl:value-of select="local-name()"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<xsl:template match="c:problem">
  <!-- FIXME Drop @class as type definer. -->
  <div data-type="{local-name()}">
    <xsl:if test="not(@class)">
      <xsl:attribute name="class">
        <xsl:value-of select="local-name()"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<xsl:template match="c:solution">
  <!-- FIXME Drop @class as type definer. -->
  <div data-type="{local-name()}">
    <xsl:if test="not(@class)">
      <xsl:attribute name="class">
        <xsl:value-of select="local-name()"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<xsl:template match="c:commentary">
  <!-- FIXME Drop @class as type definer. -->
  <div data-type="{local-name()}">
    <xsl:if test="not(@class)">
      <xsl:attribute name="class">
        <xsl:value-of select="local-name()"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<xsl:template match="c:equation">
  <!-- FIXME Drop @class as type definer. -->
  <div data-type="{local-name()}">
    <xsl:if test="not(@class)">
      <xsl:attribute name="class">
        <xsl:value-of select="local-name()"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<xsl:template match="c:rule">
  <div data-type="{local-name()}"><xsl:apply-templates select="@*|node()"/></div>
</xsl:template>

<xsl:template match="c:statement">
  <div data-type="{local-name()}"><xsl:apply-templates select="@*|node()"/></div>
</xsl:template>

<xsl:template match="c:proof">
  <div data-type="{local-name()}"><xsl:apply-templates select="@*|node()"/></div>
</xsl:template>

<!-- ========================= -->
<!-- Code alternatives -->
<!-- ========================= -->

<!-- Prefix these attributes with a "data-" -->
<xsl:template match="
   c:code/@lang
  |c:code/@display
  |c:preformat">
  <xsl:call-template name="data-prefix"/>
</xsl:template>

<!-- TODO: do we need to handle the case of "c:para//c:code[c:title]"? -->
<xsl:template match="c:code[not(c:title)]|c:preformat[not(c:title) and not(display='inline')]">
  <pre><xsl:apply-templates select="@*|node()"/></pre>
</xsl:template>

<xsl:template match="c:para//c:code[not(c:title)]|c:list//c:code[not(c:title)]|c:code[not(c:title)][@display='inline']">
  <code><xsl:apply-templates select="@*|node()"/></code>
</xsl:template>

<xsl:template match="c:code[c:title]|c:preformat[c:title and not(display='inline')]">
  <div data-type="code">
    <xsl:apply-templates select="@id"/>
    <xsl:apply-templates select="c:title"/>
    <pre><xsl:apply-templates select="@*['id'!=local-name()]|node()[not(self::c:title)]"/></pre>
  </div>
</xsl:template>

<!-- ========================= -->

<xsl:template match="c:quote/@url">
  <xsl:attribute name="cite">
    <xsl:value-of select="."/>
  </xsl:attribute>
</xsl:template>

<xsl:template match="c:quote[@display='inline']">
  <q><xsl:apply-templates select="@*|node()"/></q>
</xsl:template>

<xsl:template match="c:quote">
  <blockquote>
    <xsl:apply-templates select="@*|node()"/>
  </blockquote>
</xsl:template>

<!-- ========================= -->

<!-- Convert c:note/@type to @data-label so things like "Point of Interest" and "Tip" are visually labeled as such -->
<xsl:template match="c:note/@type">
  <xsl:attribute name="data-label">
    <xsl:value-of select="."/>
  </xsl:attribute>
  <!-- also store it as a separate attribute so we can transform back from html to cnxml -->
  <xsl:attribute name="data-element-type">
    <xsl:value-of select="."/>
  </xsl:attribute>
</xsl:template>

<xsl:template match="c:note">
  <!-- FIXME Drop @class as type definer. -->
  <div data-type="{local-name()}">
    <xsl:if test="not(@class)">
      <xsl:attribute name="class">
        <xsl:value-of select="local-name()"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="c:label">
      <xsl:attribute name="data-has-label">true</xsl:attribute>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- Brittle HACK to get notes with headings to create valid CNXML -->
<!-- Special cases for notes that get converted to sections for the editor -->
<xsl:template match="c:note[count(c:para[c:title]) = 1 and count(c:para) = 1]">
  <xsl:param name="depth" select="1"/>
  <!-- FIXME Drop @class as type definer. -->
  <div data-type="{local-name()}">
    <xsl:if test="not(@class)">
      <xsl:attribute name="class">
        <xsl:value-of select="local-name()"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="c:label">
      <xsl:attribute name="data-has-label">true</xsl:attribute>
    </xsl:if>
    <xsl:apply-templates select="@*|c:title|c:label"/>
    <section>
      <xsl:attribute name="data-depth"><xsl:value-of select="$depth"/></xsl:attribute>
      <xsl:element name="h{$depth}">
        <xsl:apply-templates mode="class" select="c:para/c:title"/>
        <xsl:apply-templates select="c:para/c:title/@*|c:para/c:title/node()"/>
      </xsl:element>
      <xsl:apply-templates select="node()[not(self::c:title or self::c:label)]">
        <xsl:with-param name="depth" select="$depth + 1"/>
      </xsl:apply-templates>
    </section>
  </div>
</xsl:template>

<xsl:template match="c:note[count(c:para[c:title]) = 1 and count(c:para) = 1]/c:para/c:title"/>

<!-- ========================= -->

<xsl:template match="c:cite-title">
  <span data-type="{local-name()}"><xsl:apply-templates select="@*|node()"/></span>
</xsl:template>

<xsl:template match="c:cite">
  <cite><xsl:apply-templates select="@*|node()"/></cite>
</xsl:template>

<!-- ========================= -->
<!-- Lists -->
<!-- ========================= -->

<!-- Prefix these attributes with "data-" -->
<xsl:template match="
     c:list/@bullet-style
    |c:list/@number-style
    |c:list/@mark-prefix
    |c:list/@mark-suffix
    |c:list/@item-sep
    |c:list/@display">
  <xsl:call-template name="data-prefix"/>
</xsl:template>

<xsl:template match="c:list/@start-value">
  <xsl:attribute name="start"><xsl:value-of select="."/></xsl:attribute>
</xsl:template>

<!-- Discard these attributes because they are converted in some other way or deprecated -->
<xsl:template match="c:list/@list-type"/>

<xsl:template match="c:list[c:title]">
  <div data-type="{local-name()}">
    <!-- list-id-and-class will give it the class "list" at least -->
    <xsl:call-template name="list-id-and-class"/>

    <xsl:apply-templates select="c:title"/>
    <xsl:apply-templates mode="list-mode" select=".">
      <xsl:with-param name="convert-id-and-class" select="0"/>
    </xsl:apply-templates>
  </div>
</xsl:template>

<xsl:template match="c:para//c:list[c:title][@display='inline']">
  <span data-type="{local-name()}"><!-- list-id-and-class will give it the class "list" at least -->
    <xsl:call-template name="list-id-and-class"/>
    <xsl:apply-templates select="c:title"/>
    <xsl:apply-templates mode="list-mode" select=".">
      <xsl:with-param name="convert-id-and-class" select="0"/>
    </xsl:apply-templates>
  </span>
</xsl:template>

<xsl:template match="c:list[not(c:title)]">
  <xsl:apply-templates mode="list-mode" select=".">
    <xsl:with-param name="convert-id-and-class" select="1"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template name="list-id-and-class">
  <xsl:apply-templates select="@id"/>
</xsl:template>

<!-- ================= -->
<!-- Block-level lists -->
<!-- ================= -->

<xsl:template mode="list-mode" match="c:list[@list-type='enumerated']">
  <xsl:param name="convert-id-and-class"/>
  <ol>
    <xsl:if test="$convert-id-and-class">
      <xsl:call-template name="list-id-and-class"/>
    </xsl:if>
    <xsl:apply-templates select="@*['id' != local-name()]|node()[not(self::c:title)]"/>
  </ol>
</xsl:template>

<!-- lists marked as having labeled items have a boolean attribute so the CSS can have `list-style-type:none` -->
<xsl:template mode="list-mode" match="c:list[@list-type='labeled-item']">
  <xsl:param name="convert-id-and-class"/>
  <ul data-labeled-item="true">
    <xsl:if test="$convert-id-and-class">
      <xsl:call-template name="list-id-and-class"/>
    </xsl:if>
    <xsl:apply-templates select="@*['id' != local-name()]|node()[not(self::c:title)]"/>
  </ul>
</xsl:template>

<xsl:template mode="list-mode" match="c:list[not(@list-type) or @list-type='bulleted']">
  <xsl:param name="convert-id-and-class"/>
  <ul>
    <xsl:if test="$convert-id-and-class">
      <xsl:call-template name="list-id-and-class"/>
    </xsl:if>
    <xsl:apply-templates select="@*['id' != local-name()]|node()[not(self::c:title)]"/>
  </ul>
</xsl:template>

<xsl:template match="c:item">
  <li><xsl:apply-templates select="@*|node()"/></li>
</xsl:template>


<!-- ================= -->
<!-- Inline-level lists -->
<!-- ================= -->

<xsl:template mode="list-mode" match="c:para//c:list[not(@display)]|c:para//c:list[@display='block']">
  <xsl:param name="convert-id-and-class"/>
  <xsl:variable name="list-type">
    <xsl:choose>
      <xsl:when test="not(@list-type)">bulleted</xsl:when>
      <xsl:otherwise><xsl:value-of select="@list-type"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <div data-type="list" data-list-type="{$list-type}">
    <xsl:if test="$convert-id-and-class">
      <xsl:call-template name="list-id-and-class"/>
    </xsl:if>
    <xsl:apply-templates select="@*['id' != local-name()]|node()[not(self::c:title)]"/>
  </div>
</xsl:template>

<xsl:template mode="list-mode" match="c:list[@display='inline']">
  <xsl:param name="convert-id-and-class"/>
  <xsl:variable name="list-type">
    <xsl:choose>
      <xsl:when test="not(@list-type)">bulleted</xsl:when>
      <xsl:otherwise><xsl:value-of select="@list-type"/></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <span data-type="list" data-list-type="{$list-type}">
    <xsl:if test="$convert-id-and-class">
      <xsl:call-template name="list-id-and-class"/>
    </xsl:if>
    <xsl:apply-templates select="@*['id' != local-name()]|node()[not(self::c:title)]"/>
  </span>
</xsl:template>

<xsl:template match="c:list[@display='inline']/c:item">
  <span data-type="item"><xsl:apply-templates select="@*|node()"/></span>
</xsl:template>

<xsl:template match="c:para//c:list[@display='block']/c:item|c:para//c:list[not(@display)]/c:item">
  <div data-type="item"><xsl:apply-templates select="@*|node()"/></div>
</xsl:template>


<!-- ========================= -->

<xsl:template match="c:emphasis">
  <strong><xsl:apply-templates select="@*[not(local-name()='effect')]|node()"/></strong>
</xsl:template>

<xsl:template match="c:emphasis[not(@effect) or @effect='bold' or @effect='Bold']">
  <strong><xsl:apply-templates select="@*|node()"/></strong>
</xsl:template>

<xsl:template match="c:emphasis[@effect='italics' or @effect='italic']">
  <em><xsl:apply-templates select="@*|node()"/></em>
</xsl:template>

<!-- Fix emphasis effect typo "italic" -->
<xsl:template match="c:emphasis[@effect='italic']/@effect">
  <xsl:attribute name="data-effect">italics</xsl:attribute>
</xsl:template>

<xsl:template match="c:emphasis[@effect='underline']">
  <u><xsl:apply-templates select="@*|node()"/></u>
</xsl:template>

<xsl:template match="c:emphasis[@effect='smallcaps']">
  <span data-type="emphasis" class="smallcaps"><xsl:apply-templates select="@*|node()"/></span>
</xsl:template>

<xsl:template match="c:emphasis[@effect='normal']">
  <span data-type="emphasis" class="normal"><xsl:apply-templates select="@*|node()"/></span>
</xsl:template>

<!-- ========================= -->
<!-- Inline Terms -->
<!-- ========================= -->

<!-- Prefix these attributes with "data-" -->
<xsl:template match="c:term/@strength">
  <xsl:call-template name="data-prefix"/>
</xsl:template>

<!-- Attributes that are converted in some other way -->
<xsl:template match="
   c:term/@url
  |c:term/@document
  |c:term/@target-id
  |c:term/@resource
  |c:term/@version
  |c:term/@window"/>

<xsl:template match="c:term[not(@url or @document or @target-id or @resource or @version)]" name="build-term">
  <span data-type="term"><xsl:apply-templates select="@*|node()"/></span>
</xsl:template>

<xsl:template match="c:term[@url or @document or @target-id or @resource or @version]">
  <xsl:variable name="href">
    <xsl:call-template name="build-href"/>
  </xsl:variable>
  <a href="{$href}" data-to-term="true">
    <xsl:if test="@window='new'">
      <xsl:attribute name="target">_window</xsl:attribute>
    </xsl:if>
    <xsl:call-template name="build-term"/>
  </a>
</xsl:template>

<!-- ========================= -->
<!-- Misc -->
<!-- ========================= -->

<xsl:template match="c:foreign[not(@url or @document or @target-id or @resource or @version)]">
  <span data-type="{local-name()}"><xsl:apply-templates select="@*|node()"/></span>
</xsl:template>

<xsl:template match="c:footnote">
  <a data-type="{local-name()}-number">
    <xsl:attribute name="name">
      <xsl:text>footnote-ref</xsl:text><xsl:number level="any" count="c:footnote" format="1"/>
    </xsl:attribute>
    <xsl:attribute name="href">
      <xsl:text>#footnote</xsl:text><xsl:number level="any" count="c:footnote" format="1"/>
    </xsl:attribute>
    <sup><xsl:number level="any" count="c:footnote" format="1"/></sup>
  </a>
</xsl:template>

<xsl:template match="c:footnote" mode="footnote">
    <li>
      <a data-type="{local-name()}-ref">
        <xsl:attribute name="name">
          <xsl:text>footnote</xsl:text><xsl:number level="any" count="c:footnote" format="1"/>
        </xsl:attribute>
        <xsl:attribute name="href">
          <xsl:text>#footnote-ref</xsl:text><xsl:number level="any" count="c:footnote" format="1"/>
        </xsl:attribute>
        <xsl:number level="any" count="c:footnote" format="1"/>
      </a>
      <xsl:text> </xsl:text><xsl:apply-templates/>
    </li>
</xsl:template>

<xsl:template match="c:sub">
  <sub><xsl:apply-templates select="@*|node()"/></sub>
</xsl:template>

<xsl:template match="c:sup">
  <sup><xsl:apply-templates select="@*|node()"/></sup>
</xsl:template>


<!-- ========================= -->
<!-- Links: encode in @data-*  -->
<!-- ========================= -->

<!-- Helper template used by c:link and c:term -->
<xsl:template name="build-href">
  <xsl:if test="@url"><xsl:value-of select="@url"/></xsl:if>
  <xsl:if test="@document != ''">
    <xsl:text>/</xsl:text>
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
  <xsl:if test="@resource">
    <xsl:if test="@document">
      <xsl:text>/</xsl:text>
    </xsl:if>
    <xsl:value-of select="@resource"/>
  </xsl:if>
</xsl:template>


<!-- Prefix these attributes with "data-" -->
<xsl:template match="c:link/@strength">
  <xsl:call-template name="data-prefix"/>
</xsl:template>

<!-- Attributes that are converted in some other way -->
<xsl:template match="
   c:link/@url
  |c:link/@document
  |c:link/@target-id
  |c:link/@resource
  |c:link/@version
  |c:link/@window"/>


<xsl:template match="c:link">
  <xsl:param name="contents" select="node()"/>
  <xsl:variable name="href">
    <xsl:call-template name="build-href"/>
  </xsl:variable>
  <!-- Anchor tags in HTML should not be self-closing. If the contents of the link will be autogenerated then annotate it -->
  <a href="{$href}">
    <xsl:apply-templates select="@*[local-name() != 'id']"/>
    <xsl:apply-templates select="@id"/>
    <xsl:if test="@window='new'">
      <xsl:attribute name="target">_window</xsl:attribute>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="count($contents) > 0">
        <xsl:apply-templates select="$contents"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:attribute name="class">
          <xsl:text>autogenerated-content</xsl:text>
        </xsl:attribute>
        <xsl:text>[link]</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </a>
</xsl:template>

<!-- ========================= -->
<!-- Figures and subfigures    -->
<!-- ========================= -->

<!-- Attributes that get a "data-" prefix when converted -->
<xsl:template match="c:figure/@orient">
  <xsl:call-template name="data-prefix"/>
</xsl:template>

<xsl:template match="c:figure/c:caption|c:subfigure/c:caption">
  <figcaption>
    <xsl:apply-templates select="@*|node()"/>
  </figcaption>
</xsl:template>

<xsl:template match="c:figure|c:subfigure">
  <figure>
    <xsl:apply-templates select="@*|c:label"/>
    <xsl:apply-templates select="c:title"/>
    <xsl:apply-templates select="c:caption"/>
    <xsl:apply-templates select="node()[not(self::c:title or self::c:caption or self::c:label)]"/>
  </figure>
</xsl:template>

<!-- ========================= -->
<!-- Media:                    -->
<!-- ========================= -->

<!-- Prefix the following attributes with "data-" -->
<xsl:template match="
   c:media/@alt
  |c:media/@display
  |c:media/@longdesc
  |c:media/c:*/@longdesc">
  <xsl:call-template name="data-prefix"/>
</xsl:template>

<xsl:template match="c:media">
  <span data-type="{local-name()}">
    <!-- Apply c:media optional attributes -->
    <xsl:apply-templates select="@*|node()"/>
  </span>
</xsl:template>

<!-- General attribute reassignment -->
<xsl:template match="c:media/*[@for='pdf']/@for|c:media/*[@for='Pdf']/@for">
  <xsl:attribute name="data-print">
    <xsl:text>true</xsl:text>
  </xsl:attribute>
</xsl:template>
<xsl:template match="c:media/*[@for='default' or @for='online']/@for">
  <xsl:attribute name="data-print">
    <xsl:text>false</xsl:text>
  </xsl:attribute>
</xsl:template>

<!-- Reassign all c:param as @name=@value -->
<xsl:template match="
   c:audio/c:param
  |c:flash/c:param
  |c:java-applet/c:param
  |c:image/c:param
  |c:labview/c:param
  |c:download/c:param">
  <xsl:attribute name="{@name}">
    <xsl:value-of select="@value"/>
  </xsl:attribute>
</xsl:template>

<xsl:template name="param-pass-through">
  <xsl:for-each select="c:param">
    <param name="{@name}" value="{@value}"/>
  </xsl:for-each>
</xsl:template>

<!-- Ensure when applying templates within c:media/* that you use the
     following sequence for audio, flash, video, java-applet, image,
     labview, and download:
     <xsl:apply-templates select="@*|c:param"/>
     <xsl:apply-templates select="node()[not(self::c:param)]"/>
 -->

<!-- ===================== -->
<!-- c:download            -->
<!-- ===================== -->

<!-- These attributes are handled elsewhere -->
<xsl:template match="c:download/@src|c:download/@mime-type"/>

<xsl:template match="c:download">
  <a href="{@src}" data-media-type="{@mime-type}" data-type="{local-name()}">

    <xsl:apply-templates select="@*|c:param"/>
    <xsl:apply-templates select="node()[not(self::c:param)]"/>
    <!-- Link text -->
    <xsl:value-of select="@src"/>
  </a>
</xsl:template>


<!-- ===================== -->
<!-- c:audio and c:video   -->
<!-- ===================== -->

<!-- Copy these attributes without any changes -->
<xsl:template match="
   c:audio/@src
  |c:audio/@loop
  |c:audio/@controller
  |c:video/@src
  |c:video/@loop
  |c:video/@controller

  |c:video/@height
  |c:video/@width
  ">
  <xsl:copy/>
</xsl:template>

<xsl:template match="c:audio/@autoplay|c:video/@autoplay">
  <xsl:choose>
    <xsl:when test=". = 'true'">
      <xsl:attribute name="autoplay">autoplay</xsl:attribute>
    </xsl:when>
    <xsl:otherwise>
      <!-- discard autoplay attribute -->
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Discard src attribute in audio and video, use source tag instead -->
<xsl:template match="c:audio/@src|c:video/@src">
</xsl:template>

<!-- change @mime-type to @data-media-type -->
<xsl:template match="c:audio/@mime-type|c:video/@mime-type">
  <xsl:attribute name="data-media-type">
    <xsl:value-of select="."/>
  </xsl:attribute>
</xsl:template>

<!-- add either a @volume or @muted -->
<xsl:template match="c:audio/@volume|c:video/@volume">
  <xsl:choose>
    <xsl:when test=". = '0'">
      <xsl:attribute name="muted">true</xsl:attribute>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="data-prefix"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- Prefix the following attributes with "data-" -->
<xsl:template match="
   c:audio/@standby
  |c:video/@standby">
  <xsl:call-template name="data-prefix"/>
</xsl:template>


<!-- Prefix c:param for c:audio and c:video with "data-" -->
<xsl:template match="c:audio/c:param|c:video/c:param">
  <xsl:attribute name="data-{@name}">
    <xsl:value-of select="@value"/>
  </xsl:attribute>
</xsl:template>

<xsl:template match="c:audio">
  <audio controls="controls">
    <xsl:apply-templates select="@*|c:param"/>
    <source src="{@src}" type="{@mime-type}"/>
    <xsl:apply-templates select="node()[not(self::c:param)]"/>
  </audio>
</xsl:template>

<xsl:template match="c:video[contains(@src, 'youtube')]">
  <iframe type="text/html" frameborder="0" src="{@src}" width="640" height="390">
    <xsl:apply-templates select="@width|@height"/>
  </iframe>
</xsl:template>

<xsl:template match="c:video[@mime-type='video/mp4' or @mimetype='video/ogg' or @mimetype='video/webm']">
  <video controls="controls">
    <xsl:apply-templates select="@*|c:param"/>
    <source src="{@src}" type="{@mime-type}"/>
    <xsl:apply-templates select="node()[not(self::c:param)]"/>
  </video>
</xsl:template>

<xsl:template match="c:video">
  <object width="640" height="400">
    <xsl:apply-templates select="@*|c:param"/>
    <param name="src" value="{@src}"/>
    <xsl:apply-templates select="node()[not(self::c:param)]"/>
    <embed src="{@src}" type="{@mime-type}" width="640" height="400">
      <xsl:apply-templates select="@width|@height"/>
    </embed>
  </object>
</xsl:template>

<!-- ===================== -->
<!-- c:java-applet         -->
<!-- ===================== -->

<!-- Copied over without changes -->
<xsl:template match="
   c:java-applet/@height
  |c:java-applet/@width">
  <xsl:copy/>
</xsl:template>

<!-- Discard because these attributes are converted elsewhere -->
<xsl:template match="
   c:java-applet/@mime-type
  |c:java-applet/@code
  |c:java-applet/@codebase
  |c:java-applet/@archive
  |c:java-applet/@name
  |c:java-applet/@src
  "/>

<xsl:template match="c:java-applet">
  <object type="application/x-java-applet">
    <xsl:apply-templates select="@*"/>
    <xsl:call-template name="param-pass-through"/>
    <xsl:apply-templates select="node()[not(self::c:param)]"/>

    <param name="code" value="{@code}"/>
    <xsl:if test="@codebase"><param name="codebase" value="{@codebase}"/></xsl:if>
    <xsl:if test="@archive"><param name="archive" value="{@archive}"/></xsl:if>
    <xsl:if test="@name"><param name="name" value="{@name}"/></xsl:if>
    <xsl:if test="@src"><param name="src" value="{@src}"/></xsl:if>
    <span>Applet failed to run. No Java plug-in was found.</span>
  </object>
</xsl:template>

<xsl:template match="c:object">
  <object type="{@mime-type}" data="{@src}"
	  width="{@width}" height="{@height}">
    <xsl:call-template name="param-pass-through"/>
    <xsl:apply-templates select="node()[not(self::c:param)]"/>
  </object>
</xsl:template>


<!-- =============== -->
<!-- Labview Object  -->
<!-- =============== -->

<!-- Copied over without changes -->
<xsl:template match="
   c:labview/@height
  |c:labview/@width">
  <xsl:copy/>
</xsl:template>

<!-- Discard because these attributes are converted elsewhere -->
<xsl:template match="
   c:labview/@src
  |c:labview/@mime-type
  |c:labview/@version
  |c:labview/@viname
  "/>

<xsl:template match="c:labview">
  <object type="{@mime-type}"
	  data-pluginspage="http://digital.ni.com/express.nsf/bycode/exwgjq"
	  data="{@src}">
    <!-- the type is already defined in the @type attribute:  -->
    <xsl:apply-templates select="@*"/>
    <xsl:call-template name="param-pass-through"/>
    <param name="lvfppviname" value="{@viname}"/>
    <param name="version" value="{@version}"/>
    <param name="reqctrl" value="true"/>
    <param name="runlocally" value="true"/>
    <xsl:apply-templates select="node()[not(self::c:param)]"/>
  </object>
</xsl:template>

<!-- ============= -->
<!-- Flash object  -->
<!-- ============= -->

<!-- Copied over without changes -->
<xsl:template match="
   c:flash/@height
  |c:flash/@width
  |c:flash/@wmode">
  <xsl:copy/>
</xsl:template>

<!-- Discarded because they are handled elsewhere -->
<xsl:template match="
   c:flash/@mime-type
  |c:flash/@src"/>

<xsl:template match="c:flash/@flash-vars">
  <xsl:attribute name="flashvars">
    <xsl:value-of select="."/>
  </xsl:attribute>
</xsl:template>

<xsl:template match="c:flash">
  <object type="{@mime-type}" data="{@src}">
    <xsl:apply-templates select="@id|@longdesc|@height|@width"/>
    <xsl:call-template name="param-pass-through"/>
    <embed src="{@src}" type="{@mime-type}">
      <xsl:apply-templates select="@height|@width|@wmode|@flash-vars"/>
    </embed>
  </object>
</xsl:template>

<xsl:template match="c:media[c:iframe]">
  <div data-type="{local-name()}">
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>


<!-- ===================== -->
<!-- Images                -->
<!-- ===================== -->

<!-- Prefix these attributes with "data-" -->
<xsl:template match="
   c:image/@longdesc
  |c:image/@thumbnail
  |c:image/@print-width">
  <xsl:call-template name="data-prefix"/>
</xsl:template>

<xsl:template match="
   c:image/c:param[@name='longdesc']
  |c:image/c:param[@name='thumbnail']
  |c:image/c:param[@name='print-width']">
  <xsl:attribute name="data-{@name}">
    <xsl:value-of select="@value"/>
  </xsl:attribute>
</xsl:template>

<!-- discard these attributes because they are being handled elsewhere -->
<xsl:template match="c:image/@src|c:image/@mime-type|c:image/@for"/>

<xsl:template match="c:image/@width|c:image/@height">
  <xsl:copy/>
</xsl:template>

<xsl:template match="c:image[not(@for='pdf' or @for='Pdf')]">
  <img src="{@src}" data-media-type="{@mime-type}" alt="{parent::c:media/@alt}">
    <xsl:apply-templates select="@*|c:param"/>
    <xsl:apply-templates select="node()[not(self::c:param)]"/>
  </img>
</xsl:template>

<xsl:template match="c:image[@for='online']/@for">
  <xsl:attribute name="data-print">false</xsl:attribute>
</xsl:template>

<xsl:template match="c:image[@for='pdf' or @for='Pdf']">
  <span data-media-type="{@mime-type}" data-print="true" data-src="{@src}" data-type="{local-name()}">
    <xsl:apply-templates select="@*|node()"/>
    <xsl:comment> </xsl:comment> <!-- do not make span self closing when no children -->
  </span>
</xsl:template>


<!-- HACK: PHeT simulations in Physics were marked up to make a clickable link as
     <image mime-type="image/png"
            for="online"
            src="equation-grapher_en.jar"
            thumbnail="PhET_Icon.png"
            width="450"/>

    This creates a link with the thumbnail image.
    NOTE: This needs to occur **after** the other templates for some reason.
-->
<!-- Discard the thumbnail attribute because it is handled elsewhere -->
<xsl:template match="c:image[@thumbnail and not(@for='pdf' or @for='Pdf')]/@thumbnail"/>
<xsl:template match="c:image[@thumbnail and not(@for='pdf' or @for='Pdf')]">
  <a href="{@src}" data-type="{local-name()}">
    <img src="{@thumbnail}" data-media-type="{@mime-type}" alt="{parent::c:media/@alt}">
      <xsl:apply-templates select="@*|node()"/>
    </img>
  </a>
</xsl:template>


<xsl:template match="c:iframe">
  <iframe><xsl:apply-templates select="@*|node()"/></iframe>
</xsl:template>

<!-- ========================= -->
<!-- Glossary -->
<!-- ========================= -->

<xsl:template match="c:glossary">
  <div data-type="{local-name()}">
    <xsl:apply-templates select="@*"/>
    <h2 data-type="glossary-title">Glossary</h2>
    <xsl:apply-templates select="node()"/>
  </div>
</xsl:template>

<xsl:template match="c:content//c:definition">
  <!-- FIXME Drop @class as type definer. -->
  <dl>
    <xsl:apply-templates select="@*|c:label"/>
    <xsl:if test="not(@class)">
      <xsl:attribute name="class">
        <xsl:value-of select="local-name()"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:apply-templates select="node()[not(self::c:label)]"/>
  </dl>
</xsl:template>

<xsl:template match="c:glossary//c:definition">
  <!-- FIXME Drop @class as type definer. -->
  <dl>
    <xsl:if test="not(@class)">
      <xsl:attribute name="class">
        <xsl:value-of select="local-name()"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </dl>
</xsl:template>

<xsl:template match="c:definition//c:term">
  <dt><xsl:apply-templates select="@*|node()"/></dt>
</xsl:template>

<xsl:template match="c:meaning[not(c:title)]">
  <dd>
    <xsl:apply-templates select="@*|node()"/>
  </dd>
</xsl:template>

<xsl:template match="c:seealso">
  <span data-type="{local-name()}">
    <xsl:apply-templates select="@*|node()"/>
  </span>
</xsl:template>

<!-- not covered elements (Marvin) -->

<!-- ========================= -->
<!-- Newline and Space -->
<!-- ========================= -->

<!-- Prefix these attributes with "data-" -->
<xsl:template match="
     c:newline/@effect
    |c:newline/@count
    |c:space/@effect
    |c:space/@count">
  <xsl:call-template name="data-prefix"/>
</xsl:template>

<xsl:template name="count-helper">
  <xsl:param name="count"/>
  <xsl:param name="string"/>

  <xsl:value-of select="$string" disable-output-escaping="yes"/>

  <xsl:if test="$count &gt; 1">
    <xsl:call-template name="count-helper">
      <xsl:with-param name="count" select="$count - 1"/>
      <xsl:with-param name="string" select="$string"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>


<xsl:template match="c:newline[not(parent::c:list)]
                              [not(ancestor::c:para and @effect = 'underline')]
                              [not(@effect) or @effect = 'underline' or @effect = 'normal']">
  <div data-type="{local-name()}">

    <xsl:apply-templates select="@*"/>

    <xsl:variable name="string">
      <xsl:choose>
        <xsl:when test="@effect = 'underline'">
          <xsl:text>&lt;hr/&gt;</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>&lt;br/&gt;</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:call-template name="count-helper">
      <xsl:with-param name="count" select="@count" />
      <xsl:with-param name="string" select="$string"/>
    </xsl:call-template>
  </div>
</xsl:template>



<xsl:template match="c:space[not(@effect) or @effect = 'underline' or @effect = 'normal']">
  <span data-type="{local-name()}">

    <xsl:apply-templates select="@*"/>

    <xsl:call-template name="count-helper">
      <xsl:with-param name="count" select="@count"/>
      <xsl:with-param name="string" select="' '"/>
    </xsl:call-template>
  </span>
</xsl:template>



<!-- ====== -->
<!-- Tables -->
<!-- ====== -->

<!-- Attributes that get a "data-" prefix when converted -->
<xsl:template match="
     c:table/@frame
    |c:table/@colsep
    |c:table/@rowsep
    |c:entrytbl/@colsep
    |c:entrytbl/@rowsep
    |c:entrytbl/@align
    |c:entrytbl/@char
    |c:entrytbl/@charoff
    ">
  <xsl:call-template name="data-prefix"/>
</xsl:template>

<!-- Copy the summary attribute over unchanged -->
<xsl:template match="c:table/@summary">
  <xsl:copy/>
</xsl:template>

<xsl:template match="c:table[count(c:tgroup) = 1]">
  <table>
    <xsl:apply-templates select="@*|c:label"/>
    <xsl:if test="c:caption or c:title">
      <caption>
        <xsl:apply-templates select="c:title"/>
        <!-- NOTE: caption loses the optional id -->
        <xsl:apply-templates select="c:caption/node()"/>
      </caption>
    </xsl:if>
    <xsl:apply-templates select="c:tgroup"/>
  </table>
</xsl:template>

<xsl:template match="c:tgroup">
  <xsl:if test="c:colspec/@colwidth or c:colspec/@align">
    <colgroup>
      <xsl:call-template name="column-maker"/>
    </colgroup>
  </xsl:if>
  <xsl:apply-templates select="c:thead|c:tbody|c:tfoot"/>
</xsl:template>

<xsl:template match="c:thead|c:tbody|c:tfoot">
  <xsl:element name="{local-name()}">
    <xsl:apply-templates select="@*|node()"/>
  </xsl:element>
</xsl:template>

<xsl:template match="c:row">
  <tr><xsl:apply-templates select="@*|node()"/></tr>
</xsl:template>

<!-- c:entry handling -->
<xsl:template match="c:entry[ancestor::c:thead]">
  <th>
    <xsl:if test="@morerows">
      <xsl:attribute name="rowspan">
        <xsl:value-of select="@morerows + 1"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="(@namest and @nameend) or @spanname">
      <!-- Reference to colspec or spanspec for @colspan calculation. -->
      <xsl:attribute name="colspan">
        <xsl:call-template name="calculate-colspan"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </th>
</xsl:template>
<xsl:template match="c:entry">
  <td>
    <xsl:if test="@morerows">
      <xsl:attribute name="rowspan">
        <xsl:value-of select="@morerows + 1"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="(@namest and @nameend) or @spanname">
      <!-- Reference to colspec or spanspec for @colspan calculation. -->
      <xsl:attribute name="colspan">
        <xsl:call-template name="calculate-colspan"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </td>
</xsl:template>
<!-- Discarded c:entry attributes -->
<xsl:template match="c:entry/@*"/>
<xsl:template match="c:entry/@align|c:entry/@valign">
  <xsl:call-template name="data-prefix"/>
</xsl:template>

<xsl:template match="c:entrytbl">
  <td colspan="{@cols}">

    <!-- FIXME @cols is required, but may be incorrect? -->
    <!-- <xsl:if test="(@namest and @nameend) or @spanname"> -->
    <!--   <xsl:attribute name="colspan"> -->
    <!--     <xsl:call-template name="calculate-colspan"/> -->
    <!--   </xsl:attribute> -->
    <!-- </xsl:if> -->
    <table>
      <xsl:if test="c:colspec/@colwidth or child::*/c:colspec/@colwidth">
        <colgroup>
          <xsl:call-template name="column-maker"/>
        </colgroup>
      </xsl:if>
      <xsl:apply-templates select="@*|node()"/>
    </table>
  </td>
</xsl:template>
<!-- Discard c:entrytbl attributes -->
<xsl:template match="c:entrytbl/@*"/>

<!-- Discard colspec and spanspec nodes -->
<xsl:template match="c:colspec|c:spanspec"/>


<!-- ======================== -->
<!-- Table template callables -->
<!-- ======================== -->

<!-- Get colspec column number -->
<xsl:template name="get-colspec-colnum">
  <!-- Returns a column number for the colspec. Used in variable definition. -->
  <xsl:param name="colspec" select="."/>
  <xsl:choose>
    <xsl:when test="$colspec/@colnum">
      <xsl:value-of select="$colspec/@colnum"/>
    </xsl:when>
    <xsl:when test="$colspec/preceding-sibling::c:colspec">
      <xsl:variable name="preceding-colspec-colnum">
        <xsl:call-template name="get-colspec-colnum">
          <xsl:with-param name="colspec" select="$colspec/preceding-sibling::c:colspec[1]"/>
        </xsl:call-template>
      </xsl:variable>
      <xsl:value-of select="$preceding-colspec-colnum + 1"/>
    </xsl:when>
    <xsl:otherwise>1</xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="calculate-colspan">
  <!-- Returns the value for a @colspan. Used in variable or value assignement. -->
  <xsl:param name="entry" select="."/>
  <xsl:variable name="spanname" select="$entry/@spanname"/>
  <xsl:variable name="namest">
    <xsl:choose>
      <xsl:when test="$entry/@spanname and not($entry/ancestor::*[2]/c:colspec)">
        <xsl:value-of select="$entry/ancestor::*[3]/c:spanspec[@spanname=$spanname]/@namest"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$entry/@namest"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="nameend">
    <xsl:choose>
      <xsl:when test="$entry/@spanname and not($entry/ancestor::*[2]/c:colspec)">
        <xsl:value-of select="$entry/ancestor::*[3]/c:spanspec[@spanname=$spanname]/@nameend"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$entry/@nameend"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="startcolnum">
    <xsl:choose>
      <xsl:when test="$entry/ancestor::*[2]/c:colspec">
        <xsl:call-template name="get-colspec-colnum">
          <xsl:with-param name="colspec" select="$entry/ancestor::*[2]/c:colspec[@colname=$namest]"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="get-colspec-colnum">
          <xsl:with-param name="colspec" select="$entry/ancestor::*[3]/c:colspec[@colname=$namest]"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="endcolnum">
    <xsl:choose>
      <xsl:when test="$entry/ancestor::*[2]/c:colspec">
        <xsl:call-template name="get-colspec-colnum">
          <xsl:with-param name="colspec" select="$entry/ancestor::*[2]/c:colspec[@colname=$nameend]"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="get-colspec-colnum">
          <xsl:with-param name="colspec" select="$entry/ancestor::*[3]/c:colspec[@colname=$nameend]"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:value-of select="$endcolnum - $startcolnum + 1"/>
</xsl:template>

<!-- Table column maker -->
<xsl:template name="column-maker">
  <!-- Param prefixe is cm.{variable-name} for column-maker (cm). -->
  <xsl:param name="cm.iteration" select="'1'"/>
  <xsl:param name="colwidth">
    <!-- If thead or tfoot has a colspec with a @colwidth, it takes
         precedence over a @colwidth directly under a tgroup or entrytbl.
         Set this @colwidth as a param.
    -->
    <xsl:choose>
      <xsl:when test="child::*/c:colspec[(@colnum=$cm.iteration)
                      or (position()=$cm.iteration and not(@colnum))]/@colwidth">
        <xsl:value-of select="child::*/c:colspec[(@colnum=$cm.iteration)
                              or (position()=$cm.iteration and not(@colnum))]/@colwidth"/>
      </xsl:when>
      <xsl:when test="c:colspec[(@colnum=$cm.iteration)
                      or (position()=$cm.iteration and not(@colnum))]/@colwidth">
        <xsl:value-of select="c:colspec[(@colnum=$cm.iteration)
                              or (position()=$cm.iteration and not(@colnum))]/@colwidth"/>
      </xsl:when>
    </xsl:choose>
  </xsl:param>
  <xsl:param name="colalign">
    <!-- copied from colwidth -->
    <xsl:choose>
      <xsl:when test="child::*/c:colspec[(@colnum=$cm.iteration)
                      or (position()=$cm.iteration and not(@colnum))]/@align">
        <xsl:value-of select="child::*/c:colspec[(@colnum=$cm.iteration)
                              or (position()=$cm.iteration and not(@colnum))]/@align"/>
      </xsl:when>
      <xsl:when test="c:colspec[(@colnum=$cm.iteration)
                      or (position()=$cm.iteration and not(@colnum))]/@align">
        <xsl:value-of select="c:colspec[(@colnum=$cm.iteration)
                              or (position()=$cm.iteration and not(@colnum))]/@align"/>
      </xsl:when>
    </xsl:choose>
  </xsl:param>

  <xsl:choose>
    <xsl:when test="$cm.iteration &gt; @cols"/>
    <xsl:otherwise>
      <col>
        <xsl:if test="not($colwidth='')">
          <xsl:attribute name="data-width">
            <xsl:value-of select="$colwidth"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:if test="not($colalign='')">
          <xsl:attribute name="data-align">
            <xsl:value-of select="$colalign"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="c:colspec[(@colnum=$cm.iteration)
                          or (position()=$cm.iteration and not(@colnum))][@colwidth!='']
                          or child::*/c:colspec[(@colnum=$cm.iteration)
                          or (position()=$cm.iteration and not(@colnum))][@colwidth!='']">
          </xsl:when>
        </xsl:choose>
      </col>
      <!-- Go to the next column and make a col element for it, if it exists. -->
      <xsl:call-template name="column-maker">
        <xsl:with-param name="cm.iteration" select="$cm.iteration + 1"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>
