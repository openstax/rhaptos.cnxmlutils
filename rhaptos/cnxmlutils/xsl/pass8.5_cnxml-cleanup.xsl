<?xml version="1.0" encoding="ASCII"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xmlns:mml="http://www.w3.org/1998/Math/MathML" xmlns:svg="http://www.w3.org/2000/svg" xmlns:db="http://docbook.org/ns/docbook" xmlns:d="http://docbook.org/ns/docbook" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:ext="http://cnx.org/ns/docbook+" xmlns:c="http://cnx.rice.edu/cnxml" version="1.0">

<xsl:output encoding="ASCII" indent="no" method="xml"/>

<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- Convert Dx to delta x (4) -->
<xsl:template match="mml:*/text()[substring(., 1, 1) = 'D' and string-length(.) >= 2]">
  <xsl:message>  Fixing: Converting Dx to delta x in <xsl:value-of select="local-name()"/> [<xsl:value-of select="text()"/>]</xsl:message>
  <xsl:variable name="fix">
    <xsl:text>&#916;</xsl:text>
    <xsl:value-of select="substring-after(.,'D')"/>
  </xsl:variable>
<xsl:copy-of select="$fix"/></xsl:template>

<!-- Add a space to alpha-numeric text following math and preceding math (1140) -->
<xsl:template match="text()[preceding-sibling::node()[self::mml:math or self::db:token] and string-length(.) > 0
 and substring(.,1,1) != ' '
 and substring(.,1,1) != ':'
 and substring(.,1,1) != ';'
 and substring(.,1,1) != '.'
 and substring(.,1,1) != '?'
 and substring(.,1,1) != '!'
 and substring(.,1,1) != ','
 and substring(.,1,1) != '='
 and substring(.,1,1) != ')'
 and substring(.,1,1) != '('
 and substring(.,1,1) != '/'
 and substring(.,1,1) != '-'
]">
  <xsl:message>  Fixing: Add a space between math and text before: [<xsl:value-of select="normalize-space(.)"/>] ~@id="<xsl:value-of select="ancestor-or-self::*[@id][1]/@id"/>"</xsl:message>
  <xsl:variable name="fix">
    <xsl:text> </xsl:text>
    <xsl:copy/>
  </xsl:variable>
<xsl:copy-of select="$fix"/></xsl:template>

<xsl:template match="text()[following-sibling::node()[self::mml:math or self::db:token] and string-length(.) > 0
 and substring(.,string-length(.),1) != ' '
 and substring(.,string-length(.),1) != '('
]">
    <xsl:message>  Fixing: Add a space between math and text after: [<xsl:value-of select="normalize-space(substring(.,string-length(.),1))"/>] [<xsl:value-of select="normalize-space(.)"/>] ~@id="<xsl:value-of select="ancestor-or-self::*[@id][1]/@id"/>"</xsl:message>
  <xsl:variable name="fix">
    <xsl:copy/>
    <xsl:text> </xsl:text>
  </xsl:variable>
<xsl:copy-of select="$fix"/></xsl:template>


<!-- Convert overbars so they are stretchy (90) -->
<xsl:template match="mml:mo[@stretchy='false' and text() = '&#713;']">
  <xsl:message>  Fixing: Found an overbar. Converting to stretchy=true and just a "-" ~@id="<xsl:value-of select="ancestor-or-self::*[@id][1]/@id"/>"</xsl:message>
  <xsl:variable name="fix">
    <xsl:copy>
      <xsl:apply-templates select="@*[not(local-name() = 'stretchy')]"/>
      <xsl:attribute name="stretchy">
        <xsl:text>true</xsl:text>
      </xsl:attribute>
      <xsl:text>-</xsl:text>
    </xsl:copy>
  </xsl:variable>
<xsl:copy-of select="$fix"/></xsl:template>


<!-- For tables without a header, use the 1st row as a header (13) -->
<!-- TODO: rewrite using cnxml instead of dbk -->
<xsl:template match="c:table/c:tgroup[not(c:thead)]/c:tbody">
  <xsl:message>  Fixing: Found a table with no header. Using the 1st row as header ~@id="<xsl:value-of select="ancestor-or-self::*[@id][1]/@id"/>"</xsl:message>
  <xsl:variable name="fix">
    <c:thead>
      <xsl:apply-templates select="c:row[1]"/>
    </c:thead>
    <xsl:copy>
      <xsl:apply-templates select="c:row[position() != 1]"/>
    </xsl:copy>
  </xsl:variable>
<xsl:copy-of select="$fix"/></xsl:template>


<!-- There are links (and textual references, but I can't find those) that are mislabeled (should be xrefs) -->
<!-- TODO: rewrite using cnxml instead of dbk -->
<!-- TODO: add an XML document-id-mapping lookup to rewrite the @document value -->
<xsl:template match="c:link[@document and node()]">
  <xsl:message>  MANUAL: Found a link to <xsl:value-of select="@document"/> with text: "<xsl:value-of select="text()"/>" ~@id="<xsl:value-of select="ancestor-or-self::*[@id][1]/@id"/>"</xsl:message>
<xsl:variable name="fix">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:variable>
<xsl:copy-of select="$fix"/></xsl:template>

<!-- Find things like "Exercise 1.3" in regular body text -->
<xsl:template match="text()[contains(.,'Example ') and string(number(substring(substring-after(.,'Example '),1,1))) != 'NaN']">
  <xsl:message>  MANUAL: Found a reference to 'Example #' in regular text; this should be a c:link. Text: "Example <xsl:value-of select="substring(substring-after(.,'Example '),1,10)"/>" ~@id="<xsl:value-of select="ancestor-or-self::*[@id][1]/@id"/>"</xsl:message>
<xsl:variable name="fix">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:variable>
<xsl:copy-of select="$fix"/></xsl:template>

<xsl:template match="text()[contains(.,'Table ') and string(number(substring(substring-after(.,'Table '),1,1))) != 'NaN']">
  <xsl:message>  MANUAL: Found a reference to 'Table #' in regular text; this should be a c:link. Text: "Table <xsl:value-of select="substring(substring-after(.,'Table '),1,10)"/>"... ~@id="<xsl:value-of select="ancestor-or-self::*[@id][1]/@id"/>"</xsl:message>
<xsl:variable name="fix">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:variable>
<xsl:copy-of select="$fix"/></xsl:template>

<xsl:template match="text()[contains(.,'Figure ') and string(number(substring(substring-after(.,'Figure '),1,1))) != 'NaN']">
  <xsl:message>  MANUAL: Found a reference to 'Figure #' in regular text; this should be a c:link. Text: "Figure <xsl:value-of select="substring(substring-after(.,'Figure '),1,10)"/>"... ~@id="<xsl:value-of select="ancestor-or-self::*[@id][1]/@id"/>"</xsl:message>
<xsl:variable name="fix">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:variable>
<xsl:copy-of select="$fix"/></xsl:template>

<!-- Remove the fontsize for math (1300) -->
<xsl:template match="mml:mstyle/@fontsize|mml:mstyle/@mathsize">
  <xsl:message>  Fixing: Removing font size from mathml ~@id="<xsl:value-of select="ancestor-or-self::*[@id][1]/@id"/>"</xsl:message>
</xsl:template>

<xsl:template match="mml:mstyle[count(@*) = 1 and @fontsize or @mathsize]">
  <xsl:message>  Fixing: Removing mml:mstyle with just a @fontsize</xsl:message>
  <xsl:variable name="fix">
    <xsl:choose>
      <xsl:when test="count(*) = 1">
        <xsl:apply-templates select="node()"/>
      </xsl:when>
      <xsl:otherwise>
        <mml:mrow>
          <xsl:apply-templates select="node()"/>
        </mml:mrow>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
<xsl:copy-of select="$fix"/></xsl:template>


<!-- mmultiscripts -->
<!-- The format looks something like:
    ...
    <m:mi>x</m:mi>
  </m:mrow>
</m:mrow>
<m:mrow>
  <m:mrow>
    <m:mmultiscripts>
      <m:mtext></m:mtext>
      <m:mprescripts/>
      [1 child]
      <m:none/>
    </m:mmultiscripts>
    ...

and needs to turn into:
    ...
    <m:msub>
      <m:mi>x</m:mi>
      [1 child]
    </m:msub>
  </m:mrow>
</m:mrow>
<m:mrow>
  <m:mrow>
    ...

-->
<xsl:template match="mml:mmultiscripts">
  <xsl:message>  MANUAL: mmultiscripts found ~@id="<xsl:value-of select="ancestor-or-self::*[@id][1]/@id"/>"</xsl:message>
<xsl:variable name="fix">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:variable>
<xsl:copy-of select="$fix"/></xsl:template>


</xsl:stylesheet>
