<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
  xmlns:c="http://cnx.rice.edu/cnxml"

  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
  xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0">


<!-- OK, this is a messy messy file. Due to how editing a document works RED text (or any other text) can end up in adjacent spans. For example:
<text:p>
  <text:span fo:color="#ff0000">&lt;figure</text:span>
  <text:span fo:color="#ff0000"><text:s/></text:span>
  <text:span fo:color="#ff0000">id="fig3.1"&gt;</text:span>
</text:p>

To handle this, I collapse adjacent span tags into 1.
There are 2 passes that are done linearly through the para's children.

1. Copy nodes until a span is encountered (using following-sibling::node())
2. Make a style hash of the span (and output a text:span)
3. Walk through the rest of nodes copying the contents of styles with the same hash until something other than a matching span is encountered (text, another element, span w/ a diff style)
4. Skip over all of the matched spans (because their contents were inserted into the span made in step 2
5. Continue copying (GOTO Step 1)
-->


  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

<!-- Start up the walker/copier! -->
<xsl:template match="text:p">
  <xsl:copy>
    <xsl:apply-templates select="@*"/>
<!--xsl:comment>PHIL: para</xsl:comment-->
    <xsl:apply-templates mode="copier" select="node()[1]"/>
  </xsl:copy>
</xsl:template>

<!-- When the copier hits a span start the work.
     1. Open a span tag, have the "walker" fill in adjacent spans with the same hash
     2. Stop when a non-empty node is reached (empty text is fine)
     3. Continue with the copier (skipping matched spans)
-->
<xsl:template match="text:p/text:span" mode="copier">
  <xsl:param name="hash" select="'INVALID_HASH'"/>
<!--xsl:comment>PHIL: Span Copier <xsl:value-of select="$hash"/></xsl:comment-->
  <xsl:variable name="myHash">
    <xsl:call-template name="make-hash"/>
  </xsl:variable>

  <xsl:if test="$hash != $myHash">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
      <!-- Include subsequent span text as long as the formatting we care about is the same -->
      <xsl:apply-templates mode="walker" select="following-sibling::node()[1]">
        <xsl:with-param name="hash" select="$myHash"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:if>
  
  <!-- Resume copying but set hash to be myHash (so consumed spans will get skipped) -->
  <xsl:apply-templates mode="copier" select="following-sibling::node()[1]">
    <xsl:with-param name="hash" select="$myHash"/>
  </xsl:apply-templates>

</xsl:template>




<!-- If the walker runs into text after a span stop walking. -->
<xsl:template match="text()[normalize-space(.) != '']|*" mode="walker">
  <xsl:param name="hash" select="'INVALID_HASH'"/>
<!--xsl:comment>PHIL: NOT-Empty Walker</xsl:comment-->
</xsl:template>

<xsl:template match="text()[normalize-space(.) != '']" mode="copier">
  <xsl:param name="hash" select="'INVALID_HASH'"/>
<!--xsl:comment>PHIL: NOT-Empty Copier</xsl:comment-->
  <xsl:copy/>
  <xsl:apply-templates select="following-sibling::node()[1]" mode="copier">
    <xsl:with-param name="hash" select="'INVALID_HASH'"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="node()" mode="copier">
  <xsl:param name="hash" select="'INVALID_HASH'"/>
<!--xsl:comment>PHIL: node Copier</xsl:comment-->
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
  <xsl:apply-templates select="following-sibling::node()[1]" mode="copier">
    <xsl:with-param name="hash" select="$hash"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="*" mode="copier">
  <xsl:param name="hash" select="'INVALID_HASH'"/>
<!--xsl:comment>PHIL: Element Copier</xsl:comment-->
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
  <xsl:apply-templates select="following-sibling::node()[1]" mode="copier">
    <xsl:with-param name="hash" select="'INVALID_HASH'"/>
  </xsl:apply-templates>
</xsl:template>

<!-- Pass-through processing instructions, comments, and white space -->
<xsl:template match="processing-instruction()|comment()" mode="walker">
  <xsl:param name="hash" select="'INVALID_HASH'"/>
<!--xsl:comment>PHIL: node Walker</xsl:comment-->
  <xsl:apply-templates select="following-sibling::node()[1]" mode="walker">
    <xsl:with-param name="hash" select="$hash"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="text()[normalize-space(.) = '']" mode="walker">
  <xsl:param name="hash" select="'INVALID_HASH'"/>
<!--xsl:comment>PHIL: Empty Walker</xsl:comment-->
  <xsl:copy/>
  <xsl:apply-templates select="following-sibling::node()[1]" mode="walker">
    <xsl:with-param name="hash" select="$hash"/>
  </xsl:apply-templates>
</xsl:template>

<xsl:template match="text:p[text:span]/text()[preceding-sibling::text:span]">
<!--xsl:comment>PHIL: text() after a span</xsl:comment-->
</xsl:template>

<xsl:template match="text:p/text:span" mode="walker">
  <xsl:param name="hash" select="'INVALID_HASH'"/>
<!--xsl:comment>PHIL: Span Walker</xsl:comment-->
  <xsl:variable name="myHash">
    <xsl:call-template name="make-hash"/>
  </xsl:variable>
  
  <xsl:if test="$hash = $myHash">
    <xsl:apply-templates select="node()"/>
    <xsl:apply-templates mode="walker" select="following-sibling::node()[1]">
      <xsl:with-param name="hash" select="$hash"/>
    </xsl:apply-templates>
  </xsl:if>
</xsl:template>



<!-- The red property takes precedence over ALL other styles (including CNXML styles) -->
<xsl:template name="make-hash">
  <xsl:choose>
    <xsl:when test="translate(@fo:color,'ABCDEF','abcdef')='#ff0000'">
      <xsl:text>RED</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates mode="hash-maker" select="@*"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template mode="hash-maker" match="@*">
  <xsl:value-of select="name()"/>
  <xsl:text>=</xsl:text>
  <xsl:value-of select="."/>
  <xsl:text> </xsl:text>
</xsl:template>

<xsl:template mode="hash-maker" match="@fo:font-weight[.='normal']|@fo:font-style[.='normal']"/>

</xsl:stylesheet>
