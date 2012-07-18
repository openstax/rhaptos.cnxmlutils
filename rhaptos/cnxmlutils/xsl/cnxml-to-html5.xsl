<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:c="http://cnx.rice.edu/cnxml"
  xmlns:m="http://www.w3.org/1998/Math/MathML"
  xmlns:md="http://cnx.rice.edu/mdml/0.4"
  xmlns:qml="http://cnx.rice.edu/qml/1.0"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:mod="http://cnx.rice.edu/#moduleIds"
  xmlns:bib="http://bibtexml.sf.net/">


<xsl:template match="@*" priority="-1000">
  <xsl:if test="namespace-uri(..) = 'http://cnx.rice.edu/cnxml' and ancestor::c:content">
    <xsl:message>TODO: <xsl:value-of select="local-name(..)"/>/@<xsl:value-of select="local-name()"/></xsl:message>
  </xsl:if>
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- Only consider c:titles in c:content (ignore c:document/c:title) -->
<xsl:template match="c:title[ancestor::c:content]|c:label" priority="0">
  <xsl:message>TODO: <xsl:value-of select="local-name(..)"/>/<xsl:value-of select="local-name(.)"/></xsl:message>
  <xsl:copy>
    <xsl:apply-templates mode="class" select="."/><xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="c:*|m:math" priority="-1">
  <xsl:message>TODO: <xsl:value-of select="local-name(.)"/></xsl:message>
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="node()" priority="-100">
  <xsl:copy>
    <xsl:apply-templates mode="class" select="."/><xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="@id|@class">
  <xsl:copy/>
</xsl:template>

<xsl:template match="c:content">
  <body><xsl:apply-templates mode="class" select="."/><xsl:apply-templates select="@*|node()"/></body>
</xsl:template>

<xsl:template mode="class" match="node()"/>
<xsl:template mode="class" match="*">
  <xsl:param name="newClasses"/>
  <xsl:attribute name="class">
    <xsl:if test="@class">
      <xsl:value-of select="@class"/>
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:if test="$newClasses">
      <xsl:value-of select="$newClasses"/>
      <xsl:text> </xsl:text>
    </xsl:if>
    <xsl:value-of select="local-name()"/>
  </xsl:attribute>
</xsl:template>

<!-- ========================= -->

<xsl:template match="c:title">
  <div><xsl:apply-templates mode="class" select="."/><xsl:apply-templates select="@*|node()"/></div>
</xsl:template>

<xsl:template match="c:para/c:title|c:table/c:title">
  <span><xsl:apply-templates mode="class" select="."/><xsl:apply-templates select="@*|node()"/></span>
</xsl:template>


<!-- ========================= -->

<xsl:template match="c:section[c:title]">
  <xsl:param name="depth" select="1"/>
  <div><xsl:apply-templates mode="class" select="."/>
    <xsl:element name="h{$depth}">
      <xsl:apply-templates mode="class" select="."/>
      <xsl:apply-templates select="@id|c:title/@*|c:title/node()"/>
    </xsl:element>
    <xsl:apply-templates select="node()[not(self::c:title)]">
      <xsl:with-param name="depth" select="$depth + 1"/>
    </xsl:apply-templates>
  </div>
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

<xsl:template match="c:rule[not(@type)]">
  <div><xsl:apply-templates mode="class" select="."/><xsl:apply-templates select="@*|node()"/></div>
</xsl:template>

<xsl:template match="c:quote">
  <q><xsl:apply-templates mode="class" select="."/><xsl:apply-templates select="@*|node()"/></q>
</xsl:template>

<xsl:template match="c:code[not(@type)]">
  <code><xsl:apply-templates mode="class" select="."/><xsl:apply-templates select="@*|node()"/></code>
</xsl:template>

<!-- ========================= -->

<xsl:template match="c:note[not(@type) and not(@display)]">
  <div><xsl:apply-templates mode="class" select="."/><xsl:apply-templates select="@*|node()"/></div>
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
    <xsl:if test="@document">
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
  <a href="{$href}">
    <xsl:apply-templates mode="linkish" select="@*[local-name() != 'id']"/>
    <xsl:apply-templates select="@id|node()"/>
  </a>
</xsl:template>

<xsl:template mode="linkish" match="@*">
  <xsl:attribute name="data-{local-name()}">
    <xsl:value-of select="."/>
  </xsl:attribute>
</xsl:template>

<!-- ========================= -->
<!-- Figures and subfigures    -->
<!-- ========================= -->

<xsl:template match="c:figure[not(@orient or @type)]|c:subfigure[not(@type)]">
  <figure>
    <xsl:apply-templates select="@*"/>
    <xsl:if test="c:caption or c:title">
      <figcaption>
        <xsl:apply-templates select="c:title"/>
        <!-- NOTE: caption loses the optional id -->
        <xsl:apply-templates select="c:caption/node()"/>
      </figcaption>
    </xsl:if>
    <xsl:apply-templates select="node()[not(self::c:title or self::c:caption)]"/>
  </figure>
</xsl:template>


<!-- ========================= -->
<!-- Tables: partial support   -->
<!-- ========================= -->

<xsl:template match="c:table/@summary">
  <xsl:copy/>
</xsl:template>
<xsl:template match="c:table[not(c:label) and count(c:tgroup) = 1]">
  <table>
    <xsl:apply-templates select="@*"/>
    <xsl:if test="c:caption or c:title">
      <caption>
        <xsl:apply-templates select="c:title"/>
        <!-- NOTE: caption loses the optional id -->
        <xsl:appy-templates select="c:caption/node()"/>
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

<xsl:template match="c:media[not(@display or @longdesc or node())]">
  <span class="media">
    <xsl:apply-templates select="@*|node()"/>
  </span>
</xsl:template>

<xsl:template match="c:image/@src|c:image/@mime-type|c:image/@for"/>
<xsl:template match="c:image[not(@print-width or @thumbnail or @longdesc)]">
  <img src="{@src}" data-mime-type="{@mime-type}">
    <xsl:if test="@for">
      <xsl:apply-templates mode="class" select=".">
        <xsl:with-param name="newClasses">
          <xsl:text>for-</xsl:text>
          <xsl:value-of select="@for"/>
        </xsl:with-param>
      </xsl:apply-templates>
    </xsl:if>
    <xsl:apply-templates select="@*|node()"/>
  </img>
</xsl:template>
<xsl:template match="c:image/@width|c:image/@height">
  <xsl:copy/>
</xsl:template>


</xsl:stylesheet>