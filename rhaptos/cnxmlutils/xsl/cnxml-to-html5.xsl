<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
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

<xsl:template match="c:span">
  <span><xsl:apply-templates select="@*|node()"/></span>
</xsl:template>

<xsl:template match="c:document">
  <body>
    <xsl:apply-templates select="c:title"/>
    <xsl:apply-templates select="c:metadata/md:abstract"/>
    <xsl:apply-templates select="c:content"/>
  </body>
</xsl:template>

<xsl:template match="md:abstract">
  <!-- Only render the abstract if it contains text/elements -->
  <xsl:if test="node()">
    <div class="abstract">
      <xsl:apply-templates select="@*|node()"/>
    </div>
  </xsl:if>
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
  <xsl:copy>
    <xsl:apply-templates mode="class" select="."/><xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="c:*" priority="-1">
  <xsl:message>TODO: <xsl:value-of select="local-name(.)"/></xsl:message>
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
    <xsl:apply-templates mode="class" select="."/><xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="@id">
  <xsl:copy/>
</xsl:template>

<xsl:template match="@type|@class|@alt|@url|@display|@document|@target-id|@window|@version|@resource|@effect|@pub-type|c:figure/@orient|c:table/@frame|c:table/@colsep|c:table/@rowsep">
  <xsl:attribute name="data-{local-name()}">
    <xsl:value-of select="."/>
  </xsl:attribute>
</xsl:template>

<xsl:template match="c:content">
  <xsl:apply-templates select="node()"/>
</xsl:template>

<xsl:template mode="class" match="node()"/>
<xsl:template mode="class" match="*">
  <xsl:param name="newClasses"/>
  <xsl:attribute name="class">
    <xsl:if test="$newClasses">
      <xsl:value-of select="$newClasses"/>
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:value-of select="local-name()"/>
  </xsl:attribute>
</xsl:template>

<!-- ========================= -->

<!-- c:label elements are converted to a data-label attribute in HTML -->

<!-- Ignore spaces before the label and title elements
     (so we can match rules that convert them to attributes) -->
<xsl:template match="text()[following-sibling::*[1][self::c:label or self::c:title]]">
</xsl:template>


<xsl:template match="c:label[node()]|c:label[not(node())]">
  <!--xsl:message>Applying label to <xsl:value-of select="../@id"/></xsl:message-->
  <xsl:attribute name="data-label"><xsl:value-of select="node()"/></xsl:attribute>
</xsl:template>

<xsl:template match="c:label[*]">
  <xsl:message>TODO: Support label with element children</xsl:message>
</xsl:template>

<!-- ========================= -->

<xsl:template match="c:title">
  <div>
    <xsl:apply-templates mode="class" select="."/>
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<xsl:template match="c:para/c:title|c:table/c:title">
  <span><xsl:apply-templates mode="class" select="."/><xsl:apply-templates select="@*|node()"/></span>
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
  <p><xsl:apply-templates mode="class" select="."/><xsl:apply-templates select="@*|node()"/></p>
</xsl:template>

<xsl:template match="c:example">
  <div><xsl:apply-templates mode="class" select="."/><xsl:apply-templates select="@*|node()"/></div>
</xsl:template>

<xsl:template match="c:exercise">
  <div><xsl:apply-templates mode="class" select="."/><xsl:apply-templates select="@*|node()"/></div>
</xsl:template>

<xsl:template match="c:problem">
  <div><xsl:apply-templates mode="class" select="."/><xsl:apply-templates select="@*|node()"/></div>
</xsl:template>

<xsl:template match="c:solution">
  <div><xsl:apply-templates mode="class" select="."/><xsl:apply-templates select="@*|node()"/></div>
</xsl:template>

<xsl:template match="c:commentary">
  <div><xsl:apply-templates mode="class" select="."/><xsl:apply-templates select="@*|node()"/></div>
</xsl:template>

<xsl:template match="c:equation">
  <div><xsl:apply-templates mode="class" select="."/><xsl:apply-templates select="@*|node()"/></div>
</xsl:template>

<xsl:template match="c:rule">
  <div><xsl:apply-templates mode="class" select="."/><xsl:apply-templates select="@*|node()"/></div>
</xsl:template>

<xsl:template match="c:statement">
  <div><xsl:apply-templates mode="class" select="."/><xsl:apply-templates select="@*|node()"/></div>
</xsl:template>

<xsl:template match="c:proof">
  <div><xsl:apply-templates mode="class" select="."/><xsl:apply-templates select="@*|node()"/></div>
</xsl:template>

<xsl:template match="c:code">
  <code><xsl:apply-templates mode="class" select="."/><xsl:apply-templates select="@*|node()"/></code>
</xsl:template>

<!-- ========================= -->

<xsl:template match="c:quote/@url">
  <xsl:attribute name="cite">
    <xsl:value-of select="."/>
  </xsl:attribute>
</xsl:template>

<xsl:template match="c:quote[@display='inline']">
  <q><xsl:apply-templates mode="class" select="."/><xsl:apply-templates select="@*|node()"/></q>
</xsl:template>

<xsl:template match="c:quote">
  <blockquote>
    <xsl:apply-templates mode="class" select="."/>
    <xsl:apply-templates select="@*|node()"/>
  </blockquote>
</xsl:template>

<!-- ========================= -->

<xsl:template match="c:note">
  <div>
    <xsl:apply-templates mode="class" select="."/>
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<!-- ========================= -->

<xsl:template match="c:cite-title">
  <span><xsl:apply-templates mode="class" select="."/><xsl:apply-templates select="@*|node()"/></span>
</xsl:template>

<xsl:template match="c:cite">
  <cite><xsl:apply-templates select="@*|node()"/></cite>
</xsl:template>

<!-- ========================= -->

<xsl:template match="c:list[@list-type='enumerated']">
  <ol>
    <xsl:apply-templates mode="class" select="."/><xsl:apply-templates select="@*|node()"/>
  </ol>
</xsl:template>

<xsl:template match="c:list[not(@list-type) or @list-type='bulleted']">
  <ul>
    <xsl:apply-templates mode="class" select="."/><xsl:apply-templates select="@*|node()"/>
  </ul>
</xsl:template>

<xsl:template match="c:item">
  <li><xsl:apply-templates mode="class" select="."/><xsl:apply-templates select="@*|node()"/></li>
</xsl:template>

<xsl:template match="c:list/@start-value">
  <xsl:attribute name="start"><xsl:value-of select="."/></xsl:attribute>
</xsl:template>

<xsl:template match="c:list/@*[not(local-name()='id' and local-name()='list-type')]">
  <xsl:attribute name="data-{local-name()}"><xsl:value-of select="."/></xsl:attribute>
</xsl:template>


<!-- ========================= -->

<xsl:template match="c:emphasis[not(@effect) or @effect='bold']">
  <strong><xsl:apply-templates mode="class" select="."/><xsl:apply-templates select="@*|node()"/></strong>
</xsl:template>

<xsl:template match="c:emphasis[@effect='italics']">
  <em><xsl:apply-templates mode="class" select="."/><xsl:apply-templates select="@*|node()"/></em>
</xsl:template>

<xsl:template match="c:emphasis[@effect='underline']">
  <u><xsl:apply-templates mode="class" select="."/><xsl:apply-templates select="@*|node()"/></u>
</xsl:template>

<xsl:template match="c:emphasis[@effect='smallcaps']">
  <span class="smallcaps"><xsl:apply-templates mode="class" select="."/><xsl:apply-templates select="@*|node()"/></span>
</xsl:template>

<xsl:template match="c:emphasis[@effect='normal']">
  <span class="normal"><xsl:apply-templates mode="class" select="."/><xsl:apply-templates select="@*|node()"/></span>
</xsl:template>

<!-- ========================= -->

<xsl:template match="c:term[not(@url or @document or @target-id or @resource or @version)]">
  <span><xsl:apply-templates mode="class" select="."/><xsl:apply-templates select="@*|node()"/></span>
</xsl:template>

<xsl:template match="c:foreign[not(@url or @document or @target-id or @resource or @version)]">
  <span><xsl:apply-templates mode="class" select="."/><xsl:apply-templates select="@*|node()"/></span>
</xsl:template>

<xsl:template match="c:footnote">
  <div><xsl:apply-templates mode="class" select="."/><xsl:apply-templates select="@*|node()"/></div>
</xsl:template>


<xsl:template match="c:sub">
  <sub><xsl:apply-templates mode="class" select="."/><xsl:apply-templates select="@*|node()"/></sub>
</xsl:template>

<xsl:template match="c:sup">
  <sup><xsl:apply-templates mode="class" select="."/><xsl:apply-templates select="@*|node()"/></sup>
</xsl:template>


<!-- ========================= -->
<!-- Links: encode in @data-*  -->
<!-- ========================= -->

<xsl:template match="c:link">
  <xsl:variable name="href">
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
  </xsl:variable>
  <!-- Anchor tags in HTML should not be self-closing. If the contents of the link will be autogenerated then annotate it -->
  <a href="{$href}">
    <xsl:apply-templates mode="linkish" select="@*[local-name() != 'id']"/>
    <xsl:apply-templates select="@id"/>
    <xsl:choose>
      <xsl:when test="node()">
        <xsl:apply-templates select="node()"/>
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

<xsl:template mode="linkish" match="@*"/>

<!-- ========================= -->
<!-- Figures and subfigures    -->
<!-- ========================= -->

<xsl:template match="c:figure|c:subfigure">
  <figure>
    <xsl:apply-templates select="@*|c:label"/>
    <xsl:if test="c:caption or c:title">
      <figcaption>
        <xsl:apply-templates select="c:title"/>
        <!-- NOTE: caption loses the optional id -->
        <xsl:apply-templates select="c:caption/node()"/>
      </figcaption>
    </xsl:if>
    <xsl:apply-templates select="node()[not(self::c:title or self::c:caption or self::c:label)]"/>
  </figure>
</xsl:template>


<!-- ========================= -->
<!-- Tables: partial support   -->
<!-- ========================= -->

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

<xsl:template match="c:entry">
  <td><xsl:apply-templates select="@*|node()"/></td>
</xsl:template>

<xsl:template match="c:colspec/@*|c:spanspec/@*|c:entry/@*"/>

<!-- ========================= -->
<!-- Media: Partial Support    -->
<!-- ========================= -->

<xsl:template match="c:media[not(@display or @longdesc)]">
  <span class="media">
    <xsl:apply-templates select="@*|node()"/>
  </span>
</xsl:template>

<xsl:template match="c:media[child::c:iframe]">
  <div class="media">
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<xsl:template match="c:image/@src|c:image/@mime-type|c:image/@for"/>
<xsl:template match="c:image[not(@print-width or @thumbnail or @longdesc or @for='pdf')]">
  <img src="{@src}" data-media-type="{@mime-type}">
    <xsl:if test="parent::c:media[@alt]">
      <xsl:attribute name="alt">
        <xsl:value-of select="parent::c:media/@alt"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </img>
</xsl:template>
<xsl:template match="c:image[not(@print-width or @thumbnail or @longdesc) and @for='pdf']">
  <span data-media-type="{@mime-type}" data-print="true" data-src="{@src}">
    <xsl:apply-templates select="@*|node()"/>
    <xsl:comment> </xsl:comment> <!-- do not make span self closing when no children -->
  </span>
</xsl:template>
<xsl:template match="c:image/@width|c:image/@height">
  <xsl:copy/>
</xsl:template>

<xsl:template match="c:iframe">
  <iframe><xsl:apply-templates select="@*|node()"/></iframe>
</xsl:template>

<!-- ========================= -->
<!-- Glossary: Partial Support -->
<!-- ========================= -->

<xsl:template match="c:definition">
  <div class="definition">
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<xsl:template match="c:meaning[not(c:title)]">
  <div class="meaning">
    <xsl:apply-templates select="@*|node()"/>
  </div>
</xsl:template>

<xsl:template match="c:seealso">
  <span class="seealso">
    <xsl:apply-templates select="@*|node()"/>
  </span>
</xsl:template>

<!-- not covered elements (Marvin) -->

<xsl:template match="c:newline">
  <br/>
</xsl:template>

</xsl:stylesheet>
