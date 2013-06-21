<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:c="http://cnx.rice.edu/cnxml"
  xmlns:m="http://www.w3.org/1998/Math/MathML"
  exclude-result-prefixes="c"
  version="1.0">

<!-- Most of these templates are "SHORTCUTS",
     meant to reduce the amount of RED XML needed in the import doc.
     For example, the text:
      <exercise>
        some text, figures, equations, etc
        <solution>A</solution>
      </exercise>
     
     translates into the following valid cnxml:
      <exercise>
        <problem>
          <para>some text</para>
          <para>figures, equations, etc</para>
        <solution>
          <para>A</para>
        </solution>
      </exercise>
     
-->

<!-- Remove all debug processing instructions -->
<xsl:template match="processing-instruction('cnx.debug')|processing-instruction('cnx.info')"/>

<!-- (Marvin:) Enclose <space> in paragraph if it has no valid parent -->
<xsl:template match="c:space[not(
  parent::c:preformat|parent::c:para|parent::c:title|parent::c:label|parent::c:cite|parent::c:cite-title|parent::c:link|parent::c:emphasis|parent::c:term|parent::c:sub|parent::c:sup|parent::c:quote|parent::c:foreign|parent::c:footnote|parent::c:note|parent::c:item|parent::c:code|parent::c:caption|parent::c:commentary|parent::c:meaning|parent::c:entry
)]">
  <c:para>
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </c:para>
</xsl:template>

<!-- SHORTCUT: allow "<figure>title [] [] caption</figure>" to create subfigures -->
<!-- Figures cannot have para tags in them and images are converted into figures as well (so it'll be a nested figure/para/figure ) -->
<xsl:template match="c:figure">
  <xsl:copy>
    <xsl:apply-templates select="@*"/>
    <xsl:apply-templates select="c:title"/>
    <!-- Images are also converted to figures -->
    <xsl:choose>
      <!-- odt2cnxml converts every draw:frame to a <figure><media/></figure> -->
      <xsl:when test="count(c:para/c:media|c:media) &gt; 1">
        <xsl:for-each select="c:para/c:media|c:media">
          <c:subfigure>
            <xsl:apply-templates select="."/>
          </c:subfigure>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="c:para/c:media|c:media"/>
      </xsl:otherwise>
    </xsl:choose>
    <!-- Captions and such -->
    <xsl:apply-templates select="c:*[not(self::c:para or self::c:title or self::c:media)]"/>
    <xsl:if test="c:para[not(c:media)]">
      <!-- Convert text inside a <figure/> into a caption -->
      <c:caption>
        <xsl:apply-templates select="c:para[not(c:media)]/node()"/>
      </c:caption>
    </xsl:if>
  </xsl:copy>
</xsl:template>

<!-- RED c:caption will have a c:para in it; strip it -->
<xsl:template match="c:caption/c:para">
  <xsl:apply-templates select="node()"/>
</xsl:template>

<!-- SHORTCUT: allow <figure alt='blah'>. "@alt actually belongs on the "media" element -->
<xsl:template match="c:figure/@alt"/>
<xsl:template match="c:figure[ancestor-or-self::c:figure[@alt]]/c:media">
  <c:figure alt="{ancestor::c:figure/@alt}">
    <xsl:apply-templates select="@*|node()"/>
  </c:figure>
</xsl:template>

<xsl:template match="c:media[not(@alt) and not(ancestor::c:figure/@alt)]">
  <c:media alt="">
    <xsl:apply-templates select="@*|node()"/>
  </c:media>
</xsl:template>

<xsl:template match="c:figure//c:figure">
  <xsl:processing-instruction name="cnx.warning">Stripping out nested figure (word import)</xsl:processing-instruction>
  <xsl:apply-templates select="node()"/>
</xsl:template>

<!-- SHORTCUT: Any time there are multiple images in a c:figure wrap them in a c:subfigure -->
<xsl:template match="c:media[not(parent::c:subfigure) and count(ancestor::c:figure//c:media) &gt; 1]">
  <c:subfigure>
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </c:subfigure>
</xsl:template>

<!-- SHORTCUT: allow "<glossary> <term>word</term> meaning \n ... </glossary>" -->
<xsl:template match="c:glossary/c:para">
  <c:definition>
    <xsl:apply-templates select="*[1]"/><!-- should be a term -->
    <c:meaning>
      <xsl:apply-templates select="node()[position() != 1]"/>
    </c:meaning>
  </c:definition>
</xsl:template>
<!-- SHORTCUT: allow "<glossary> <term>word</term> <meaning>meaning</meaning> \n ... </glossary>".
When <term/> and <meaning/> are on the same line they end up wrapped in a <para/> so remove the <para/>.
 -->
<xsl:template match="c:definition/c:para">
    <xsl:apply-templates select="node()"/>
</xsl:template>

<xsl:template match="c:term/text()">
  <xsl:value-of select="normalize-space(.)"/>
</xsl:template>

<!-- SHORTCUT: allow authors to just enter "<problem>a</problem>" (without exercise) -->
<xsl:template match="c:problem[not(ancestor::c:exercise)]">
  <c:exercise>
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </c:exercise>
</xsl:template>

<!-- SHORTCUT: allow authors to just enter "<exercise>a</exercise>" (without problem) -->
<xsl:template match="c:exercise[not(c:problem)]">
  <!-- Assume everything except for c:solution is part of the problem -->
  <c:exercise>
    <xsl:apply-templates select="@*"/>
    <c:problem>
      <xsl:apply-templates select="node()[not(self::c:solution)]"/>
    </c:problem>
    <xsl:apply-templates select="c:solution"/>
  </c:exercise>
</xsl:template>

<!-- SHORTCUT: allow authors to just enter "<solution>a</solution>" (without para)-->
<xsl:template match="c:*[self::c:problem or self::c:solution]/text()[normalize-space() != '']">
  <c:para>
    <xsl:value-of select="."/>
  </c:para>
</xsl:template>

<xsl:template match="c:title//c:figure">
  <xsl:processing-instruction name="cnx.error">Figures in a heading is NOT allowed! Make sure the image is in a normal paragraph</xsl:processing-instruction>
</xsl:template>

<xsl:template match="c:section[count(*) &lt;= 1]">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
    <c:para>
      <xsl:processing-instruction name="cnx.warning">All headings must be followed by some content. Inserting an empty paragraph.</xsl:processing-instruction>
    </c:para>
  </xsl:copy>
</xsl:template>


<xsl:template match="c:equation/c:para">
  <xsl:apply-templates select="node()"/>
</xsl:template>

<!-- Footnotes with just a para can just unwrap the para -->
<xsl:template match="c:footnote[count(*) = 1 and c:para[count(*) = 0]]">
  <xsl:copy>
    <xsl:apply-templates select="@*|c:para/node()"/>
  </xsl:copy>
</xsl:template>

<!-- Sometimes headings contain textboxes.
  These result in <para> tags inside a title; so just unwrap the title.
  See nhphuong__CH2_ANALYSIS_IN_TIME_DOMAIN.doc and ncpea__NCPEA_CONNEXIONS_submission_#87_FINAL.doc in the testbed.
-->
<xsl:template match="c:title/c:para">
  <xsl:apply-templates select="node()"/>
</xsl:template>

<!-- A para that only contains m:math is converted to a c:equation -->
<xsl:template match="c:para[m:math and count(*) = 1 and normalize-space()='']">
  <c:equation>
    <xsl:apply-templates select="@*|node()"/>
  </c:equation>
</xsl:template>

<xsl:template match="m:math[not(@display='block') and not(ancestor::c:para)]">
  <m:math display="block">
    <xsl:apply-templates select="@*|node()"/>
  </m:math>
</xsl:template>

<xsl:template match="c:section/m:math|c:content/m:math">
  <c:para>
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </c:para>
</xsl:template>

<xsl:template match="c:media[not(ancestor-or-self::c:figure[@alt])]">
  <xsl:copy>
    <xsl:attribute name="alt"></xsl:attribute>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- SHORTCUT: "figures" in a title are converted into images -->
<xsl:template match="c:title/c:figure">
  <xsl:if test="*[not(self::c:media)]">
    <xsl:processing-instruction name="cnx.warning">Images in titles can only contain the image (no captions, etc)</xsl:processing-instruction>
  </xsl:if>
  <xsl:apply-templates select="c:media"/>
</xsl:template>

<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>
