<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
  xmlns:c="http://cnx.rice.edu/cnxml"

  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0" xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0" xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0" xmlns:number="urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0" xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0" xmlns:chart="urn:oasis:names:tc:opendocument:xmlns:chart:1.0" xmlns:dr3d="urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:form="urn:oasis:names:tc:opendocument:xmlns:form:1.0" xmlns:script="urn:oasis:names:tc:opendocument:xmlns:script:1.0" xmlns:ooo="http://openoffice.org/2004/office" xmlns:ooow="http://openoffice.org/2004/writer" xmlns:oooc="http://openoffice.org/2004/calc" xmlns:dom="http://www.w3.org/2001/xml-events" xmlns:xforms="http://www.w3.org/2002/xforms" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:rpt="http://openoffice.org/2005/report" xmlns:of="urn:oasis:names:tc:opendocument:xmlns:of:1.2" xmlns:rdfa="http://docs.oasis-open.org/opendocument/meta/rdfa#"  xmlns:m="http://www.w3.org/1998/Math/MathML"
  office:class="text" office:version="1.0"
  exclude-result-prefixes="office style text table draw fo xlink number svg chart dr3d math form script c"

  >

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- Some draw objects don't have a @draw:name but the importer uses the name
        to uniquely create a filename so add one
  -->
  <xsl:template match="draw:flow[not(@draw:name)]">
    <draw:flow draw:name="import-auto-{generate-id()}">
      <xsl:apply-templates select="@*|node()"/>
    </draw:flow>
  </xsl:template>

<!-- single entry tables are used for presentation purposes only, we hope. -->
  <xsl:template match="table:table[count(./table:table-row/table:table-cell)=1]">
    <xsl:variable name="one.entry" select="./table:table-row/table:table-cell[position()=1]" />

    <xsl:if test='count($one.entry/text:h)=1'>
      <xsl:processing-instruction name="cnx.info">found a single entry table with a single header.</xsl:processing-instruction>
      <c:section>
        <c:title>
          <xsl:apply-templates select="$one.entry/text:h"/>
        </c:title>
        <xsl:apply-templates select='$one.entry/node()[not(self::text:h)]'/>
      </c:section>
    </xsl:if>
    <xsl:if test='count($one.entry/text:h)=0'>
      <xsl:processing-instruction name="cnx.info">found a single entry table without any header.</xsl:processing-instruction>
      <xsl:apply-templates select='$one.entry/node()'/>
    </xsl:if>
    <xsl:if test='count($one.entry/text:h)>1'>
      <xsl:processing-instruction name="cnx.warning">found a single entry table with many headers.</xsl:processing-instruction>
      <c:section>
        <xsl:apply-templates select='$one.entry/node()'/>
      </c:section>
    </xsl:if>

  </xsl:template>

<!-- single entry ordered lists are used for presentation purposes only, we hope. -->

  <xsl:template match="text:*[(self::text:ordered-list or self::text:list) and count(child::*)=1 and ./text:list-item/text:*[(self::text:ordered-list or self::text:list)]]">
    <xsl:processing-instruction name="cnx.warning">Unwrapping a list with only 1 item, another list</xsl:processing-instruction>
      <xsl:apply-templates select="./text:list-item/*" />
  </xsl:template>

  <xsl:template match="text:list[not(text:list-item or text:list-header)]">
    <xsl:processing-instruction name="cnx.warning">Empty lists are not allowed. Removing</xsl:processing-instruction>
  </xsl:template>

<!-- header children in draw:text-box need to be converted to paragraphs. -->

  <xsl:template match="draw:text-box/text:h">
    <text:p>
      <xsl:apply-templates select="@*|node()"/>
    </text:p>
  </xsl:template>

<!-- convert Heading 1/2/3 paragraphs into headers. -->

  <xsl:template match="text:p[@text:style-name='Heading 1']">
    <text:h text:style-name="Heading 1" text:level="1">
      <xsl:apply-templates select="node()"/>
    </text:h>
  </xsl:template>

  <xsl:template match="text:p[@text:style-name='Heading 2']">
    <text:h text:style-name="Heading 2" text:level="2">
      <xsl:apply-templates select="node()"/>
    </text:h>
  </xsl:template>

  <xsl:template match="text:p[@text:style-name='Heading 3']">
    <text:h text:style-name="Heading 3" text:level="3">
      <xsl:apply-templates select="node()"/>
    </text:h>
  </xsl:template>

<!--  remove header if it only contains an image. -->

  <xsl:template match="text:h[count(child::*)=1 and (
                              draw:object or draw:object-ole or draw:image)]">
      <xsl:apply-templates select="node()"/>
  </xsl:template>

<!-- Eliminate Headings After the Last Glossary -->

  <xsl:template match="text:h[preceding-sibling::text:p[@text:style-name='CNXML_20_Glossary_20_Section']]">
  </xsl:template>

<!-- convert header to paragraph if it contains an image and other stuff. -->

  <xsl:template match="text:h[draw:object or draw:object-ole or draw:image]">
    <text:p>
      <xsl:attribute name='id'>
        <xsl:value-of select="generate-id()"/>
      </xsl:attribute>
      <xsl:apply-templates select="node()"/>
    </text:p>
  </xsl:template>

<!-- remove ordered list with only a header but leave the header's children. -->

  <xsl:template match="text:*[(self::text:ordered-list or self::text:list) and count(child::*)=1 and child::text:list-header]">
    <c:para>
      <xsl:processing-instruction name="cnx.warning">Unwrapping a list with only a header. Consider not using a list to only store paragraphs</xsl:processing-instruction>
      <xsl:apply-templates select="./text:list-header/*"/>
    </c:para>
  </xsl:template>

<!-- productions make sure the unmodified input is written to output -->

  <xsl:template match="text:p[count(text() | child::*[not(self::text:s)]) &lt; 1][not(@ooo_drawing)]"/>

<!-- remove empty para, headers, and spans. -->

  <xsl:template match="
      office:forms|
      office:automatic-styles|
      office:event-listeners|
      text:sequence-decls|
      text:sequence-decl|
      text:tracked-changes|
      text:tab|
      text:soft-page-break|
      text:p/text:line-break
      ">
    <xsl:apply-templates select="node()"/>
  </xsl:template>
  
  <xsl:template match="text:s">
    <xsl:text> </xsl:text>
  </xsl:template>
  
  <xsl:template match="text:h[count(node())=0][not(@ooo_drawing)]" />

  <xsl:template match="text:span[count(node())=0][not(@ooo_drawing)]" />

  <xsl:template match="text:p[count(node())=0][not(@ooo_drawing)]">
    <xsl:if test="@text:style-name='CNXML_20_Code_20__28_Block_29_' and preceding-sibling::*[1]/@text:style-name='CNXML_20_Code_20__28_Block_29_'">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="text:table-of-content">
    <xsl:processing-instruction name="cnx.warning">Table of Contents are not used during import. Discarding</xsl:processing-instruction>
  </xsl:template>

  <xsl:template match="text:list-header">
    <title>
      <xsl:apply-templates select="@*|node()"/>
    </title>
  </xsl:template>
  <!-- Sometimes headers can have a Para -->
  <xsl:template match="text:list-header/text:p">
    <xsl:processing-instruction name="cnx.warning">List headers cannot contain paragraphs. Removing paragraph</xsl:processing-instruction>
    <xsl:apply-templates select="node()"/>
  </xsl:template>


<xsl:template match="text:changed-region|text:change-start|text:change-end|text:change">
  <xsl:processing-instruction name="cnx.info">This document contains a history of changes. These will be discarded upon import</xsl:processing-instruction>
</xsl:template>


<xsl:template match="text:bookmark-start|text:bookmark-end">
  <xsl:processing-instruction name="cnx.info">This document contained a bookmark. It will be discarded upon import</xsl:processing-instruction>
</xsl:template>

<xsl:template match="text:execute-macro|script:*">
  <xsl:processing-instruction name="cnx.warning">This document contained a macro/script. It will be discarded upon import</xsl:processing-instruction>
</xsl:template>

<xsl:template match="text:h/@text:outline-level"/>

<!--
    Sometimes there is a gap between the userlevel and level
    (for example, a H4 immediately following an H2, ie no H3).
    This causes subsequent H4's to be duplicated as children of
    both the H2 _and_ the H4 (since the $level is 3)
    See cburrus__LF00.doc (in testbed folder) for an example
-->
<xsl:template match="text:h">
  <xsl:variable name="level" select="@text:outline-level"/>
  <xsl:variable name="prevs" select="preceding-sibling::text:h[@text:outline-level &lt; $level]"/>
  <xsl:variable name="newlevel">
    <xsl:choose>
      <xsl:when test="$prevs">
        <xsl:variable name="prevlevel" select="$prevs[position()=last()]/@text:outline-level"/>
        <xsl:choose>
          <xsl:when test="$prevlevel != $level - 1">
            <xsl:value-of select="$prevlevel + 1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$level"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>1</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <text:h text:outline-level="{$newlevel}">
    <xsl:apply-templates select="@*"/>
    <xsl:if test="$level != $newlevel">
      <!-- Sometimes Headings can be inside lists, tables, and other things; don't warn -->
      <xsl:if test="parent::office:text">
        <xsl:processing-instruction name="cnx.warning">The document's heading levels mismatch. This one is <xsl:value-of select="$level"/> but should be <xsl:value-of select="$newlevel"/> to be imported properly</xsl:processing-instruction>
      </xsl:if>
    </xsl:if>

    <xsl:apply-templates select="node()"/>
  </text:h>
</xsl:template>

<!-- Some headings are in "Outline" or "WWNum1" format.
    Only the heading is in the list and they look like this:
    <list style-name="Outline">
      <list-item>
        <list>
          <list-item>
            ...
            <h>Title</h>
          </list-item>
        </list>
      </list-item>
    </list>
    <p>Body</p>
  -->
<xsl:template match="text:*[self::text:list or self::text:list-item][ancestor-or-self::*[@text:style-name='Outline' or @text:style-name='WWNum1']]">
  <xsl:apply-templates select="node()"/>
</xsl:template>

<!-- See space64__Chuong_02-NgonNguJava.doc -->
<xsl:template match="text:section">
  <c:section>
    <xsl:if test="*[1][self::text:h]">
      <c:title>
        <xsl:apply-templates select="*[1]/node()"/>
      </c:title>
    </xsl:if>
    <xsl:apply-templates select="*[not(position()=1 and self::text:h)]|text()|comment()|processing-instruction()"/>
  </c:section>
</xsl:template>


<!-- Attach all style info (bold, underline, list numbering, RED, etc)
      directly onto the element so we don't need to pass around the huge style:style
      and text:list-style elements that clutter up intermediate XML -->

<!-- Attach the style:style attributes so we don't have to look them up later -->
<xsl:key name="style-properties" match="//style:style/style:text-properties" use="../@style:name"/>

<!-- This attribute can be found on para/span/list ... -->
<xsl:template match="@text:style-name">
  <xsl:variable name="props" select="key('style-properties', .)"/>
  <xsl:apply-templates select="$props[1]/../@style:parent-style-name" mode="stylizer"/>
  <xsl:apply-templates select="$props/@*" mode="stylizer"/>
</xsl:template>

<!-- Notes are RED and we don't want them being treated as escaped XML
      so don't pass on the fo:color attribute
-->
<xsl:template match="@text:style-name[starts-with(.,'CNXML_')]">
  <xsl:copy/>
</xsl:template>

<!-- These are the attributes we care about (used in subsequent XSLT passes) -->
<xsl:template match="@ooo_drawing|@fo:font-style|@fo:font-weight|@style:text-underline|@style:text-underline-style|@style:text-position|@style:parent-style-name|@fo:color[translate(.,'ABCDEF','abcdef') = '#ff0000']" mode="stylizer">
  <xsl:attribute name="{name()}">
    <xsl:value-of select="."/>
  </xsl:attribute>
</xsl:template>

<!-- The rest don't get transferred -->
<xsl:template match="@*" mode="stylizer"/>


<!-- Normalize lists. Look up the numbering info and attach it to the text:list
      The odt2cnxml pass will use these attributes later.
-->
<xsl:key name="list-styles" match="//text:list-style" use="@style:name"/>
<!--xsl:key 
        name="list-automatic-styles"
        match="/office:document-content/office:automatic-styles/text:list-style"
        use="@style:name"/>
    xsl:key name="list-styles"
       match="/office:document-content/office:styles/text:list-style"
       use="@style:name"/>
-->

<xsl:template match="text:ordered-list|text:list">
  <xsl:variable name="name" select="ancestor-or-self::*[self::text:ordered-list or self::text:list][@text:style-name][1]/@text:style-name"/>
  <xsl:variable name="props" select="key('style-properties', $name)"/>
  <xsl:variable name="level" select="count(ancestor::text:ordered-list) + 1"/>
  <xsl:variable name="style" select="key('list-styles', $name)[position() = last()]"/>
  <xsl:variable name="typeEl" select="$style/*[@text:level = $level]"/>

  <xsl:variable name="type">
    <xsl:choose>
      <xsl:when test="$typeEl[self::text:list-level-style-number]">enumerated</xsl:when>
<!--  <xsl:when test="$typeEl[self::text:list-level-style-bullet]">bulleted</xsl:when> -->
      <xsl:otherwise>bulleted</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:variable name="numFormat" select="$typeEl/@style:num-format"/>
  <xsl:variable name="format">
    <xsl:choose>
      <xsl:when test="$numFormat='1'">arabic</xsl:when>
      <xsl:when test="$numFormat='A'">upper-alpha</xsl:when>
      <xsl:when test="$numFormat='a'">lower-alpha</xsl:when>
      <xsl:when test="$numFormat='I'">upper-roman</xsl:when>
      <xsl:when test="$numFormat='i'">lower-roman</xsl:when>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="before" select="$typeEl/@style:num-prefix"/>
  <!-- Ignore the default suffix of "." -->
  <xsl:variable name="after" select="$typeEl[@style:num-suffix != '.']/@style:num-suffix"/>

  <text:list list-type="{$type}" number-style="{$format}" mark-prefix="{$before}" mark-suffix="{$after}">
    <xsl:apply-templates select="@*|node()"/>
  </text:list>

</xsl:template>

<xsl:template match="office:automatic-styles|office:styles|text:list-style|office:scripts|office:font-face-decls|style:style"/>

<!-- Collapse nested text:span tags -->
<xsl:template match="text:span[text:span and count(*)=1]">
  <xsl:copy>
    <xsl:apply-templates select="@*|text:span/@*|text:span/node()"/>
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>

