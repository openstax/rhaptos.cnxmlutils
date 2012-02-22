<?xml version="1.0"?>
<xsl:stylesheet version="1.0"
  xmlns="http://cnx.rice.edu/cnxml"
  xmlns:c="http://cnx.rice.edu/cnxml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  
 xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0" xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0" xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0" xmlns:number="urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0" xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0" xmlns:chart="urn:oasis:names:tc:opendocument:xmlns:chart:1.0" xmlns:dr3d="urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:form="urn:oasis:names:tc:opendocument:xmlns:form:1.0" xmlns:script="urn:oasis:names:tc:opendocument:xmlns:script:1.0" xmlns:ooo="http://openoffice.org/2004/office" xmlns:ooow="http://openoffice.org/2004/writer" xmlns:oooc="http://openoffice.org/2004/calc" xmlns:dom="http://www.w3.org/2001/xml-events" xmlns:xforms="http://www.w3.org/2002/xforms" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:rpt="http://openoffice.org/2005/report" xmlns:of="urn:oasis:names:tc:opendocument:xmlns:of:1.2" xmlns:rdfa="http://docs.oasis-open.org/opendocument/meta/rdfa#"  xmlns:m="http://www.w3.org/1998/Math/MathML"
  office:class="text" office:version="1.0"
  exclude-result-prefixes="office style text table draw fo xlink number svg chart dr3d math form script c"
  >


  <!-- This is a nasty pile of mess. Most of the styles code resides here
       and I didn't want to yank it from this version.
       Most of my edits can be found by searching for "xsl:processing-instruction"
  -->

  <xsl:output omit-xml-declaration="no" indent="yes" method="xml" />

  <!-- augmented input xml with /office:document-content/office:styles in oo2oo.xsl  -->
  <xsl:variable name="bold"/>

  <xsl:key name="bookmark" match="//text:bookmark" use="@text:name"/>

  <xsl:key name="bookmark-start" match="//text:bookmark-start" use="@text:name"/>
  
  <!-- We no longer need the list styles -->
  <xsl:template match="text:list-style"/>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*">
    <xsl:processing-instruction name="cnx.warning">Could not match Open Office Element <xsl:value-of select="name()"/>. Converting children.</xsl:processing-instruction>
    <xsl:apply-templates select="node()"/>
  </xsl:template>

  <xsl:template match="draw:line|draw:g|draw:rectangle|draw:custom-shape|draw:enhanced-geometry">
    <xsl:processing-instruction name="cnx.warning">This importer does not support importing lines, rectangles, or other shapes</xsl:processing-instruction>
  </xsl:template>
<!-- Discard any ODT attributes -->
<xsl:template match="@text:*|@style:*"/>

<xsl:template match="text:note[text:note-citation]">
  <c:footnote id="import-auto-footnote-{text:note-citation/text()}">
    <xsl:apply-templates select="@*|node()"/>
  </c:footnote>
</xsl:template>
<xsl:template match="text:note/text:note-citation"/>
<xsl:template match="text:note/text:note-body">
  <xsl:apply-templates select="node()"/>
</xsl:template>

  <!-- Discard the :para element when it only contains non-inline c: elements -->
  <xsl:template match="text:p[normalize-space(text()) = '' and
      count(*) = count(c:*) and count(*) &gt;= 1 and not(
        c:text-extras or c:span or c:term or c:cite or c:cite-title or
        c:foreign or c:emphasis or c:sub or c:sup or c:inline-code or
        c:inline-preformat or c:inline-quote or c:inline-note or
        c:inline-list or c:inline-media or c:footnote or c:link or
        c:newline or c:space
      )]">
    <xsl:processing-instruction name="cnx.debug">Unwrapping a para around RED elements <xsl:for-each select="*"><xsl:value-of select="name()"/></xsl:for-each></xsl:processing-instruction>
    <xsl:apply-templates select="node()"/>
  </xsl:template>

  <!-- Preserve the @class="cnx.red-text" on a para that contains only 1 span with red text -->
  <xsl:template match="text:p[count(*[@class='cnx.red-text']) &gt; 0 and count(*[not(@class='cnx.red-text')]) = 0]">
    <para>
      <xsl:apply-templates select="*/@*"/>
      <xsl:apply-templates select="node()"/>
    </para>
  </xsl:template>
  
  <xsl:template match="text:span[@class='cnx.red-text']">
    <span>
      <xsl:apply-templates select="@*|node()"/>
    </span>
  </xsl:template>

  <xsl:template match="c:*">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="office:document-content|office:body">
    <xsl:apply-templates select="node()"/>
  </xsl:template>
  
  <xsl:template match="office:scripts|office:font-face-decls|style:*"/>

  <xsl:template match="office:text">

    <document module-id="imported-from-openoffice" id="imported-from-openoffice" cnxml-version="0.7">
      <title>
        <xsl:text>Untitled Document</xsl:text>
      </title>

      <content>
        <xsl:apply-templates select="@*|node()"/>
      </content>
      <xsl:apply-templates select=".//c:glossary">
        <xsl:with-param name="render" select="1"/>
      </xsl:apply-templates>
    </document>
  </xsl:template>

  <!-- The Glossary section is moved out of c:content (it's in normal text) and into a separate area -->
  <xsl:template match="c:glossary">
    <xsl:param name="render" select="false()"/>
    <xsl:if test="$render">
      <xsl:copy>
        <xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*" mode="GlossarySec">
    <xsl:for-each select="preceding-sibling::*[not(self::name)]">
      <xsl:apply-templates select="." />
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="text:section">
    <section>
      <xsl:if test="child::text:h[position()=1]">
        <title>
          <xsl:value-of select="child::text:h"/>
        </title>
      </xsl:if>

      <xsl:choose>
        <xsl:when test="count(child::*[not(self::text:h[position()=1])])>0">
          <xsl:apply-templates select="node()"/>
        </xsl:when>
        <xsl:otherwise>
          <para>
            <xsl:processing-instruction name="cnx.warning"><xsl:value-of select="count(child::*[not(self::text:h[position()=1])])"/> Empty sections are illegal in CNXML 0.5.  This empty paragraph is a place holder that was added as a byproduct of the word importer.</xsl:processing-instruction>
          </para>
        </xsl:otherwise>
      </xsl:choose>
    </section>
  </xsl:template>

  <xsl:template match="text:section[not(normalize-space(.)) and not(descendant::draw:image)]">
    <!-- ignore white space sections that do not have images -->
  </xsl:template>

  <xsl:template match="section[name[m:math]]">
    <para>
        <xsl:if test="*[not(self::name)]">
          <xsl:apply-templates select="node()"/>
        </xsl:if>
    </para>
  </xsl:template>

  <xsl:template match="section">
      <section>
        <xsl:if test="name">
          <title>
            <xsl:value-of select="name"/>
          </title>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="count(child::*[not(self::name)])>0">
            <xsl:choose>
              <xsl:when test="text:p[@text:style-name='CNXML_20_Glossary_20_Section'][1]">
                <xsl:apply-templates select="text:p[@text:style-name='CNXML_20_Glossary_20_Section'][1]" mode="GlossarySec"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates select="*[not(self::name)]"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <para>
              <xsl:comment>Empty sections are illegal in CNXML 0.5.  This empty paragraph is a place holder that was added as a byproduct of the word importer.</xsl:comment>
            </para>
          </xsl:otherwise>
        </xsl:choose>
      </section>
  </xsl:template>


  <!-- Para, Quote(block) -->
  <xsl:template match="text:p">
    <xsl:variable name="Para-Style">
      <xsl:value-of select="substring-before(@text:style-name, '_20_Char')"/>
    </xsl:variable>
    <xsl:if test="count(node())=0">
        <xsl:if test="preceding-sibling::*[1]/text:span/@text:style-name='CNXML_20_Code_20__28_Block_29_' and following-sibling::*[1]/text:span/@text:style-name='CNXML_20_Code_20__28_Block_29_'">
          <para>
            <xsl:text>
            </xsl:text>
          </para>
        </xsl:if>
    </xsl:if>
    <xsl:if test="count(text()|child::*[not(self::text:s)])">
      <xsl:choose>
        <xsl:when test="@text:level='1'">
          <para>
            <title>
              <xsl:value-of select="."/>
            </title>
          </para>
        </xsl:when>
        <xsl:when test="@fo:font-style='italic' and @fo:font-weight='bold'">
           <para>
                <emphasis effect='bold'><emphasis effect='italics'><xsl:apply-templates select="node()"/></emphasis></emphasis>
            </para>
        </xsl:when>
        <xsl:when test="@fo:font-style='italic'">
            <para>
                <emphasis effect='italics'><xsl:apply-templates select="node()"/></emphasis>
            </para>
        </xsl:when>
        <xsl:when test="@fo:font-weight='bold'">
            <para>
                <emphasis effect='bold'><xsl:apply-templates select="node()"/></emphasis>
            </para>
        </xsl:when>
        <xsl:when test="@style:text-underline-style='solid'">
            <para>
                <emphasis effect='underline'><xsl:apply-templates select="node()"/></emphasis>
            </para>
        </xsl:when>
        <xsl:when test="$Para-Style='CNXML_20_Example'">
          <xsl:choose>
            <xsl:when test="not(normalize-space(.)) and descendant::draw:image">
              <xsl:apply-templates select="node()"/>
            </xsl:when>
            <xsl:when test="preceding-sibling::*[1]/@text:style-name='CNXML_20_Example' and not(descendant::draw:image)">
            </xsl:when>
            <xsl:otherwise>
              <example>
                <xsl:apply-templates select="." mode="exHelper" />
              </example>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$Para-Style='CNXML_20_Equation'">
          <equation>
            <xsl:apply-templates select="node()"/>
          </equation>
        </xsl:when>
        <xsl:when test="$Para-Style='CNXML_20_Definition_20__28_Term_29_'">
          <xsl:if test="following-sibling::text:p[position()=1]/@text:style-name='CNXML_20_Definition_20__28_Meaning_29_'">
          <!-- definition must have both a term and meaning child. -->
            <definition>
              <xsl:attribute name="id" >
                <xsl:value-of select="generate-id()" />
              </xsl:attribute>
              <term>
                <xsl:apply-templates select="node()"/>
              </term>
              <meaning>
                <xsl:if test="following-sibling::*[1]/text:bookmark or following-sibling::*[1]/text:bookmark-start">
                  <xsl:attribute name="id">
                    <xsl:value-of select="generate-id(following-sibling::*[1])"/>
                  </xsl:attribute>
                </xsl:if>
                <xsl:apply-templates select="following-sibling::*[1]" mode="meaningHelper" />
              </meaning>
            </definition>
          </xsl:if>
        </xsl:when>
        <xsl:when test="$Para-Style='CNXML_20_Definition_20__28_Meaning_29_'">
        </xsl:when>
        <xsl:when test="$Para-Style='CNXML_20_Theorem_20__28_Statement_29_'">
          <xsl:if test="not(following-sibling::*[1]/@text:style-name='CNXML_20_Theorem_20__28_Statement_29_')" >
            <xsl:variable name="ruleid" select="."/>
            <rule type="theorem">
              <statement>
                <xsl:apply-templates select="." mode="statementHelper"/>
              </statement>
              <xsl:if test="following-sibling::text:p[position()=1]/@text:style-name='CNXML_20_Theorem_20__28_Proof_29_'">
              <proof>
                <xsl:apply-templates select="following-sibling::*[1]" mode="proofHelper"/>
              </proof>
              </xsl:if>
            </rule>
          </xsl:if>
        </xsl:when>
        <xsl:when test="$Para-Style='CNXML_20_Theorem_20__28_Proof_29_'">
        </xsl:when>
        <xsl:when test="$Para-Style='CNXML_20_Exercise_20__28_Problem_29_'">
          <exercise>
            <problem>
                <para>
                <xsl:apply-templates select="node()"/>
                </para>
            </problem>
            <xsl:if test="following-sibling::text:p[position()=1]/@text:style-name='CNXML_20_Exercise_20__28_Solution_29_'">
              <solution>
                <xsl:apply-templates select="following-sibling::*[1]" mode="solHelper"/>
              </solution>
            </xsl:if>
          </exercise>
        </xsl:when>
        <xsl:when test="$Para-Style='CNXML_20_Quote' or $Para-Style='CNXML_20_Quote_20__28_Block_29_'">
            <xsl:choose>
              <xsl:when test="not(normalize-space(.)) and descendant::draw:image">
                <xsl:apply-templates select="node()"/>
              </xsl:when>
              <xsl:when test="not(normalize-space(.)) and not(descendant::draw:image)">
              </xsl:when>
              <xsl:when test="not(descendant::draw:image) and (preceding-sibling::*[1]/@text:style-name='CNXML_20_Quote_20__28_Block_29_' or preceding-sibling::*[1]/@text:style-name='CNXML_20_Quote')">
              </xsl:when>
              <xsl:otherwise>
              <para>
                <xsl:apply-templates select="." mode="quoteBlockHelper"/>
              </para>
              </xsl:otherwise>
            </xsl:choose>
        </xsl:when>
        <xsl:when test="$Para-Style='CNXML_20_Code_20__28_Block_29_'">
          <xsl:if test="preceding-sibling::*[1]/@text:style-name='CNXML_20_Code_20__28_Block_29_'">
          </xsl:if>
          <xsl:if test="not(preceding-sibling::*[1]/@text:style-name='CNXML_20_Code_20__28_Block_29_')">
            <code display="block">
              <xsl:apply-templates select="." mode="codeHelper"/>
            </code>
          </xsl:if>
        </xsl:when>
        <xsl:when test="$Para-Style='CNXML_20_Exercise_20__28_Solution_29_'">
        </xsl:when>
        <xsl:when test="$Para-Style='CNXML_20_Figure_20_Title'">
        </xsl:when>
        <xsl:when test="//office:document-content/office:automatic-styles/style:style[@style:name=$Para-Style]/@style:parent-style-name='CNXML_20_Figure_20_Title'">
        </xsl:when>
        <xsl:when test="$Para-Style='CNXML_20_Figure_20_Caption'">
        </xsl:when>
        <xsl:when test="$Para-Style='CNXML_20_Glossary_20_Section'">
        </xsl:when>
        <xsl:when test="count(child::*)=1 and normalize-space(text())='' and text:span/@text:style-name='CNXML_20_Note'">
          <note type="Note">
            <xsl:value-of select="text:span"/>
          </note>
        </xsl:when>
        <xsl:when test="count(child::*)=2 and text:bookmark-start and text:bookmark-end and not(normalize-space())">
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="parent::text:footnote-body or parent::text:endnote-body or parent::text:list-item or parent::table:table-cell or (count(child::*)=1 and not(child::text()) and child::draw:image)">
              <xsl:apply-templates select="node()"/>
            </xsl:when>
            <xsl:otherwise>
              <para>
                <xsl:apply-templates select="@*|node()"/>
              </para>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*" mode="quoteBlockHelper">
    <xsl:choose>
      <xsl:when test="not(normalize-space(.)) and descendant::draw:image">
        <xsl:apply-templates select="node()"/>
      </xsl:when>
      <xsl:when test="not(normalize-space(.)) and not(descendant::draw:image)">
      </xsl:when>
      <xsl:otherwise>
        <quote display="block">
          <xsl:apply-templates select="node()"/>
        </quote>
        <xsl:if test="following-sibling::*[1]/@text:style-name='CNXML_20_Quote_20__28_Block_29_' or following-sibling::*[1]/@text:style-name='CNXML_20_Quote'">
          <xsl:apply-templates select="following-sibling::*[1]" mode="quoteBlockHelper" />
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template match="*" mode="meaningHelper">
      <xsl:apply-templates select="node()"/>
      <xsl:text>
      </xsl:text>
    <xsl:if test="following-sibling::text:p[1]/@text:style-name='CNXML_20_Definition_20__28_Meaning_29_'">
      <xsl:apply-templates select="following-sibling::text:p[1]" mode="meaningHelper"/>
    </xsl:if>
  </xsl:template>


  <xsl:template match="*" mode="proofHelper">
    <para>
      <xsl:apply-templates select="node()"/>
    </para>
    <xsl:if test="following-sibling::text:p[1]/@text:style-name='CNXML_20_Theorem_20__28_Proof_29_'">
      <xsl:apply-templates select="following-sibling::text:p[1]" mode="proofHelper"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*" mode="statementHelper">
    <xsl:variable name="idh" select="following-sibling::*[1]"/>
    <xsl:if test="preceding-sibling::text:p[1]/@text:style-name='CNXML_20_Theorem_20__28_Statement_29_'">
      <xsl:apply-templates select="preceding-sibling::text:p[1]" mode="statementHelper"/>
    </xsl:if>
    <para>
      <xsl:apply-templates select="node()"/>
    </para>
  </xsl:template>


  <xsl:template match="*" mode="solHelper">
    <para>
      <xsl:apply-templates select="node()"/>
    </para>
    <xsl:if test="following-sibling::text:p[1]/@text:style-name='CNXML_20_Exercise_20__28_Solution_29_'">
      <xsl:apply-templates select="following-sibling::text:p[1]" mode="solHelper"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*" mode="codeHelper">
    <xsl:value-of select="."/><xsl:text>
    </xsl:text>
    <xsl:if test="following-sibling::*[1]/@text:style-name='CNXML_20_Code_20__28_Block_29_'">
      <xsl:apply-templates select="following-sibling::*[1]" mode="codeHelper"/>
    </xsl:if>
  </xsl:template>


  <xsl:template match="*" mode="exHelper">
    <xsl:if test="not(descendant::draw:image) and normalize-space()">
    <para>
      <xsl:apply-templates select="node()"/>
    </para>
    </xsl:if>
    <xsl:if test="following-sibling::*[1]/@text:style-name='CNXML_20_Example'">
      <xsl:apply-templates select="following-sibling::*[1]" mode="exHelper" />
    </xsl:if>
  </xsl:template>


  <!-- Para/Para -->
  <xsl:template match="text:p//text:p[not(parent::table:table-cell or parent::text:footnote-body or parent::text:endnote-body)]">
    <xsl:choose>
      <xsl:when test="parent::draw:text-box">
        <xsl:apply-templates select="node()"/>  <!--avoid nested para's generated by text-box-->
      </xsl:when>
      <xsl:otherwise>
        <para>
        <xsl:apply-templates select="node()"/>
        </para>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- List and list items -->
  <xsl:template match="text:ordered-list[normalize-space(.)]|text:list">
    <xsl:variable name="list-type" select="@list-type"/>
    <xsl:variable name="number-style" select="@number-style"/>
    <xsl:variable name="before" select="@mark-prefix"/>
    <xsl:variable name="after" select="@mark-suffix"/>

    <xsl:choose>
      <xsl:when test="@text:continue-numbering='true' and preceding-sibling::*[1][self::text:ordered-list]">
        <!-- do nothing. already processed this node. -->
      </xsl:when>

      <xsl:otherwise>
        <list list-type="{$list-type}">
          <xsl:if test="string-length($number-style)>0">
            <xsl:attribute name="number-style">
              <xsl:value-of select="$number-style" />
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="string-length($before)>0">
            <xsl:attribute name="mark-prefix">
              <xsl:value-of select="$before" />
            </xsl:attribute>
          </xsl:if>
          <!--
            TODO: mark-suffix produces sometimes unreadable (low/high-ansi?) text,
            it needs to be checked if the content of mark-suffix is readable.
            Ignore it now. (Marvin Reimer)
          -->
          <!--
          <xsl:if test="string-length($after)>0">
            <xsl:attribute name="mark-suffix">
              <xsl:value-of select="$after" />
            </xsl:attribute>
          </xsl:if>
          -->
          <xsl:apply-templates select="node()"/>
          <xsl:call-template name="check.for.continued.numbering">
            <xsl:with-param name="current.list" select="." />
          </xsl:call-template>
        </list>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="text:ordered-list[not(normalize-space(.))]">
    <!-- ignore white space lists -->
  </xsl:template>

  <xsl:template name="check.for.continued.numbering">
    <xsl:param name="current.list" />
    <xsl:choose>
      <xsl:when test="$current.list/following-sibling::*[1][self::text:ordered-list[@text:continue-numbering='true']]">
        <xsl:apply-templates select="$current.list/following-sibling::*[1]/text:list-item" />
        <xsl:call-template name="check.for.continued.numbering">
          <xsl:with-param name="current.list" select="$current.list/following-sibling::*[1]" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise />
    </xsl:choose>
  </xsl:template>

  <xsl:template match="text:unordered-list[normalize-space(.)]">
    <xsl:choose>
      <xsl:when test="@text:style-name='Var List'">
        <list>
          <xsl:apply-templates select="node()"/>
        </list>
      </xsl:when>
      <xsl:when test="@text:style-name='UnOrdered List'">
        <list list-type="bulleted">
          <xsl:apply-templates select="node()"/>
        </list>
      </xsl:when>
      <xsl:otherwise>
        <list list-type="bulleted">
          <xsl:apply-templates select="node()"/>
        </list>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="text:list-item">
    <xsl:choose>
      <xsl:when test="parent::text:unordered-list/@text:style-name='Var List'">
        <item>
          <xsl:for-each select="text:p[@text:style-name='VarList Term']">
            <xsl:if test="descendant::text:bookmark-start">
            </xsl:if>
            <xsl:apply-templates select="."/>
          </xsl:for-each>
        </item>
      </xsl:when>
      <xsl:otherwise>
        <item>
          <xsl:if test="descendant::text:bookmark-start">
            <xsl:attribute name="id">
              <xsl:value-of select="generate-id()"/>
            </xsl:attribute>
          </xsl:if> 
          <xsl:apply-templates select="node()"/>
        </item>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="text:p[@text:style-name='List Contents']">
    <item>
      <xsl:if test="descendant::text:bookmark-start">
        <xsl:attribute name="id">
          <xsl:value-of select="generate-id()"/>
        </xsl:attribute>
      </xsl:if> 
      <xsl:apply-templates select="node()"/>
    </item>
  </xsl:template>


  <!-- Notes -->
  <xsl:template match="office:annotation/text:p">
    <note type='Note'>
      <xsl:apply-templates select="node()"/>
    </note>
  </xsl:template>

  <xsl:template match="text:footnote">
    <footnote>
      <xsl:choose>
        <xsl:when test="count(descendant::text:footnote-body/child::*)=0">
          <xsl:value-of select="descendant::text:footnote-body/*"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="descendant::text:footnote-body"/>
        </xsl:otherwise>
      </xsl:choose>
    </footnote>
  </xsl:template>


  <xsl:template match="text:endnote">
    <footnote> <!--endnote should function exactly the same as footnote -->
      <xsl:if test="descendant::text:endnote-body//text:bookmark or descendant::text:endnote-body//text:bookmark-start">
        <xsl:attribute name="id">
          <xsl:value-of select="generate-id(descendant::text:endnote-body)"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="count(descendant::text:endnote-body/child::*)=0">
          <xsl:value-of select="descendant::text:endnote-body/*"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="descendant::text:endnote-body"/>
        </xsl:otherwise>
      </xsl:choose>
    </footnote>
  </xsl:template>

  <!-- OOo XML has an explicit footnote number which we need to ignore -->
  <xsl:template match="text:footnote-citation" />


  <xsl:template match="draw:frame[math:math]">
    <xsl:apply-templates select="math:math"/>
  </xsl:template>
  <xsl:template match="draw:frame[draw:object or draw:object-ole]">
    <xsl:processing-instruction name="cnx.error">Complex object not supported (maybe OLE/Plugin)</xsl:processing-instruction>
  </xsl:template>
    
  <xsl:template match="draw:frame[draw:text-box]">
    <xsl:processing-instruction name="cnx.warning">Don't use text boxes.</xsl:processing-instruction>
    <xsl:apply-templates select="draw:text-box/node()"/>
  </xsl:template>
  

  <!-- Any heading inside an exercise, example, block-level element, turn it into a c:title -->
  <xsl:template match="c:*[self::c:section
                            or self::c:example
                            or self::c:list
                            or self::c:equation
                            or self::c:code
                            or self::c:figure
                            or self::c:note
                            or self::c:subfigure
                            or self::c:exercise
                            or self::c:commentary
                            or self::c:rule
                          ]/text:h">
    <c:title>
      <xsl:apply-templates select="node()"/>
    </c:title>
  </xsl:template>

  <!-- Notes can't have a c:title but they can have a c:label -->
  <xsl:template match="c:solution[not(c:label)]/text:h">
    <c:label>
      <xsl:apply-templates select="node()"/>
    </c:label>
  </xsl:template>

  <!-- Any text:head that haven't been converted into sections are in another element
      (like a list, figure, table, etc)
      Just convert them to an emphasis
  -->
  <xsl:template match="text:h">
    <xsl:processing-instruction name="cnx.error">Converting a non-navigational heading into an emphasis.</xsl:processing-instruction>
    <c:emphasis effect="bold">
      <xsl:apply-templates select="node()"/>
    </c:emphasis>
  </xsl:template>
  
  <!-- Figure -->
  <xsl:template match="draw:frame[draw:image and count(*) = 1]">
    <xsl:param name='type'>
      <xsl:value-of select="substring-after(draw:image/@xlink:href,'.')"/>
    </xsl:param> 

    <xsl:choose>
      <xsl:when test="self::draw:object-ole">
        <xsl:processing-instruction name="cnx.warning">OLE Objects are not supported (this might be math)</xsl:processing-instruction>
        ***SORRY, THIS MEDIA TYPE IS NOT SUPPORTED.***
      </xsl:when>
      <xsl:when test="($type='svm')">
        <xsl:processing-instruction name="cnx.warning">SVM Objects are not supported (this might be math)</xsl:processing-instruction>
        <xsl:comment>Sorry, this media type is not supported.</xsl:comment>
      </xsl:when>
      <xsl:when test="ancestor-or-self::c:figure">
        <!-- Skip creating the figure (shortcut) -->
        <xsl:call-template name="cnx.media">
          <xsl:with-param name="type" select="$type"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="parent::text:span">
        <!-- BNW: was inline media and is now figure??? -->
        <figure>
          <xsl:if test="../../preceding-sibling::text:p[position()=1]/@text:style-name='CNXML_20_Figure_20_Title'">
            <title>
              <xsl:value-of select="../../preceding-sibling::text:p[position()=1]"/>
            </title>
          </xsl:if>
          <xsl:call-template name="cnx.media">
            <xsl:with-param name="type" select="$type"/>
          </xsl:call-template>
          <xsl:if test="../../following-sibling::text:p[position()=1]/@text:style-name='CNXML_20_Figure_20_Caption'">
            <caption>
              <xsl:value-of select="../../following-sibling::text:p[position()=1]"/>
            </caption>
          </xsl:if>
        </figure>
      </xsl:when>
      <xsl:otherwise>
        <figure>
          <xsl:call-template name="cnx.media-and-caption">
            <xsl:with-param name="type" select="$type"/>
          </xsl:call-template>
        </figure>
      </xsl:otherwise>
    </xsl:choose>  
  </xsl:template>

<xsl:template name="cnx.media-and-caption">
  <xsl:param name="type"/>
  <xsl:call-template name="cnx.media">
    <xsl:with-param name="type" select="$type"/>
  </xsl:call-template>
  
  <xsl:if test="../following-sibling::text:p[1]/@text:style-name='CNXML_20_Figure_20_Caption'">
    <caption>
      <xsl:choose>
        <xsl:when test="count(../following-sibling::text:p[1]/child::*)=0">
          <xsl:value-of select="../following-sibling::text:p[1]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="../following-sibling::text:p[1]/*"/>
        </xsl:otherwise>
      </xsl:choose>
    </caption>
  </xsl:if>
</xsl:template>

<xsl:template name="cnx.media">
  <xsl:param name='type'>
    <xsl:value-of select="substring-after(draw:image/@xlink:href,'.')"/>
  </xsl:param> 
  <!-- add extension (from $type) if it doesn't already exist. see also 'helpers.parseContent'.
  see also below "Image in a table" -->
  <xsl:variable name='beforeext'>
    <xsl:value-of select="substring-before(@draw:name, concat('.',$type))"/>
  </xsl:variable>
  <xsl:variable name='name'>
    <xsl:if test="not(string-length($beforeext))">
      <xsl:value-of select="@draw:name" />
    </xsl:if>
    <xsl:if test="boolean(string-length($beforeext))">
      <xsl:value-of select="$beforeext" />
    </xsl:if>
  </xsl:variable>
  <xsl:variable name='height'>
    <xsl:choose>
      <xsl:when test="@svg:height">
        <xsl:call-template name="cnx.2px">
          <xsl:with-param name="dist" select="@svg:height" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="0" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name='width'>
    <xsl:choose>
      <xsl:when test="@svg:width">
        <xsl:call-template name="cnx.2px">
          <xsl:with-param name="dist" select="@svg:width" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="0" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:if test="../preceding-sibling::text:p[position()=1]">
    <xsl:variable name="Style">
      <xsl:value-of select="../preceding-sibling::text:p[position()=1]/@text:style-name"/>
    </xsl:variable>
    <xsl:if test="$Style='CNXML_20_Figure_20_Title' or
                  ../preceding-sibling::text:p[position()=1]/@style:parent-style-name='CNXML_20_Figure_20_Title'">
      <title>
        <xsl:if test="../preceding-sibling::text:p[1]/text:bookmark or
                      ../preceding-sibling::text:p[1]/text:bookmark-start">
          <xsl:attribute name="id">
            <xsl:value-of select="generate-id(../preceding-sibling::text:p[1])"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:value-of select="../preceding-sibling::text:p[1]"/>
      </title>
    </xsl:if>
  </xsl:if>
  <media>
    <image mime-type='image/{$type}' src='{$name}.{$type}'>
      <xsl:if test="$height > 0">
        <xsl:attribute name="height"><xsl:value-of select="$height"/></xsl:attribute>
      </xsl:if>
      <xsl:if test="$width > 0">
        <xsl:attribute name="width"><xsl:value-of select="$width"/></xsl:attribute>
      </xsl:if>
    </image>
  </media>
</xsl:template>

  <!-- Convert other measurements to pixels. Images for example are stored in "in" -->
  <xsl:template name="cnx.2px">
    <xsl:param name="dist"/>
    <xsl:choose>
      <xsl:when test="contains($dist, 'in')">
        <xsl:variable name="inches" select="number(substring-before($dist, 'in'))"/>
        <xsl:variable name="points" select="$inches * 72.0"/>
        <xsl:variable name="px" select="$points * 96.0 div 72.0"/>
        <xsl:value-of select="round($px)"/>
      </xsl:when>
      <xsl:when test="contains($dist, 'cm')">
        <xsl:variable name="cm" select="number(substring-before($dist, 'cm'))"/>
        <xsl:variable name="inches" select="$cm div 2.54"/>
        <xsl:variable name="points" select="$inches * 72.0"/>
        <xsl:variable name="px" select="$points * 96.0 div 72.0"/>
        <xsl:value-of select="round($px)"/>
      </xsl:when>
      <xsl:when test="contains($dist, 'pt')">
        <xsl:variable name="points" select="number(substring-before($dist, 'pt'))"/>
        <xsl:variable name="px" select="$points * 96.0 div 72.0"/>
        <xsl:value-of select="round($px)"/>
      </xsl:when>
      <xsl:when test="contains($dist, 'px')">
        <xsl:variable name="px" select="number(substring-before($dist, 'px'))"/>
        <xsl:value-of select="round($px)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$dist"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Image in a table -->
  <!-- FIXME: Should this be a subfigure instead of a table? -->
  <xsl:template match="table:table//draw:image">
    <xsl:param name='type'>
      <xsl:value-of select="substring-after(@xlink:href,'.')"/>
    </xsl:param> 
    <!-- add extension (from $type) if it doesn't already exist. see also 'helpers.parseContent'.
    see also above "Figure" -->
    <xsl:variable name='beforeext'>
      <xsl:value-of select="substring-before(@draw:name, concat('.',$type))"/>
    </xsl:variable>
    <xsl:variable name='name'>
      <xsl:if test="not(string-length($beforeext))">
        <xsl:value-of select="@draw:name" />
      </xsl:if>
      <xsl:if test="boolean(string-length($beforeext))">
        <xsl:value-of select="$beforeext" />
      </xsl:if>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="(self::draw:object-ole or $type='svm')">
        <xsl:processing-instruction name="cnx.warning">This media type is not supported (this might be math)</xsl:processing-instruction>
        <xsl:comment>Sorry, this media type is not supported.</xsl:comment>
      </xsl:when>
      <xsl:otherwise>
        <media>
          <image mime-type='image/{$type}' src='{@draw:name}.{$type}'/>
        </media>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*[@ooo_drawing]">
    <media alt="Drawing">
      <image mime-type="image/png"> <!-- use png now because svg export is not working good in OOo -->
        <xsl:attribute name="src">
          <xsl:value-of select="@ooo_drawing"/>
        </xsl:attribute>
      </image>
    </media>
  </xsl:template>

  <!-- Emphasis, Quote, Code, Foreign, Term-->
  <xsl:template match="text:span">
    <xsl:param name="Style">
      <xsl:value-of select="@text:style-name"/>
    </xsl:param>
    <xsl:choose>
      <xsl:when test="@fo:font-style='italic' and count(child::*)=1 and child::*[1]=draw:image">
        <xsl:apply-templates select="node()"/>
      </xsl:when>
      <xsl:when test="@fo:font-style='italic' and @fo:font-weight='bold'">
        <emphasis effect="bold"><emphasis effect='italics'><xsl:apply-templates select="node()"/></emphasis></emphasis>
      </xsl:when>
      <xsl:when test="@fo:font-style='italic'">
        <emphasis effect='italics'><xsl:apply-templates select="node()"/></emphasis>
      </xsl:when>
      <xsl:when test="@fo:font-weight='bold'">
        <emphasis effect='bold'><xsl:apply-templates select="node()"/></emphasis>
      </xsl:when>
      <xsl:when test="@style:text-underline-style='solid'">
        <emphasis effect='underline'><xsl:apply-templates select="node()"/></emphasis>
      </xsl:when>
      <xsl:when test="starts-with(@style:text-position, 'sub ')">
        <sub><xsl:apply-templates select="node()"/></sub>
      </xsl:when>
      <xsl:when test="starts-with(@style:text-position, 'super ')">
        <sup><xsl:apply-templates select="node()"/></sup>
      </xsl:when>
      <xsl:when test="//office:document-content/office:automatic-styles/style:style[@style:name=$Style and @style:parent-style-name]">
        <xsl:choose>
          <xsl:when test="//office:document-content/office:automatic-styles/style:style[@style:name=$Style]/@style:parent-style-name='CNXML_20_Term'">
            <xsl:choose>
              <xsl:when test="not(normalize-space(.)) and descendant::draw:image">
                <!-- term with no text but image(s) -->
                <xsl:apply-templates select="node()"/>
              </xsl:when>
              <xsl:when test="not(normalize-space(.)) and not(descendant::draw:image)">
                 <!-- term with no text; do nothing -->
              </xsl:when>
              <xsl:otherwise>
                <term>
                  <xsl:apply-templates select="node()"/>
                </term>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="//office:document-content/office:automatic-styles/style:style[@style:name=$Style]/@style:parent-style-name='CNXML_20_Quote_20__28_Inline_29_'">
            <quote display="inline">
              <xsl:apply-templates select="node()"/>
            </quote>
          </xsl:when>
          <xsl:when test="//office:document-content/office:automatic-styles/style:style[@style:name=$Style]/@style:parent-style-name='CNXML_20_Emphasis'">
            <xsl:choose>
              <xsl:when test="not(normalize-space(.)) and descendant::draw:image">
                <!-- emphasis with no text but image(s) -->
                <xsl:apply-templates select="node()"/>
              </xsl:when>
              <xsl:when test="not(normalize-space(.)) and not(descendant::draw:image)">
                 <!-- emphasis with no text; do nothing -->
              </xsl:when>
              <xsl:otherwise>
                <emphasis>
                  <xsl:apply-templates select="node()"/>
                </emphasis>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="//office:document-content/office:automatic-styles/style:style[@style:name=$Style]/@style:parent-style-name='CNXML_20_Code_20__28_Inline_29_' or //office:document-content/office:automatic-styles/style:style[@style:name=$Style]/@style:parent-style-name='CNXML_20_Code'">
            <xsl:choose>
              <xsl:when test="not(normalize-space(.)) and descendant::draw:image">
                <!-- code with no text but image(s) -->
                <xsl:apply-templates select="node()"/>
              </xsl:when>
              <xsl:when test="not(normalize-space(.)) and not(descendant::draw:image)">
                 <!-- code with no text; do nothing -->
              </xsl:when>
              <xsl:otherwise>
                <code display="inline">
                  <xsl:apply-templates select="node()"/>
                </code>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="//office:document-content/office:automatic-styles/style:style[@style:name=$Style]/@style:parent-style-name='CNXML_20_Foreign'">
            <foreign>
              <xsl:apply-templates select="node()"/>
            </foreign>
          </xsl:when>
          <xsl:when test="//office:document-content/office:automatic-styles/style:style[@style:name=$Style]/@style:parent-style-name='CNXML_20_Cite'">
            <xsl:choose>
              <xsl:when test="not(normalize-space(.)) and descendant::draw:image">
                <!--  with no text but image(s) -->
                <xsl:apply-templates select="node()"/>
              </xsl:when>
              <xsl:when test="not(normalize-space(.)) and not(descendant::draw:image)">
                 <!-- cite with no text; do nothing -->
              </xsl:when>
              <xsl:otherwise>
                <cite>
                  <xsl:apply-templates select="node()"/>
                </cite>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="//office:document-content/office:automatic-styles/style:style[@style:name=$Style]/@style:parent-style-name='CNXML_20_Note'">
            <xsl:choose>
              <xsl:when test="not(normalize-space(.)) and descendant::draw:image">
                <!-- note with no text but image(s) -->
                <xsl:apply-templates select="node()"/>
              </xsl:when>
              <xsl:when test="not(normalize-space(.)) and not(descendant::draw:image)">
                 <!-- note with no text; do nothing -->
              </xsl:when>
              <xsl:otherwise>
                <note type='Note'>
                  <xsl:apply-templates select="node()"/>
                </note>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="node()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose><!--try an if statement -->
          <xsl:when test="$Style='Emphasis'">
            <emphasis>
              <xsl:apply-templates select="node()"/>
            </emphasis>
          </xsl:when>
          <xsl:when test="$Style='CNXML_20_Emphasis'">
            <xsl:choose>
              <xsl:when test="not(normalize-space(.)) and descendant::draw:image">
                <!-- emphasis with no text but image(s) -->
                <xsl:apply-templates select="node()"/>
              </xsl:when>
              <xsl:when test="not(normalize-space(.)) and not(descendant::draw:image)">
                 <!-- emphasis with no text; do nothing -->
              </xsl:when>
              <xsl:otherwise>
                <emphasis>
                  <xsl:apply-templates select="node()"/>
                </emphasis>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="$Style='q'">
            <quote display="inline">
              <xsl:apply-templates select="node()"/>
            </quote>
          </xsl:when>
          <xsl:when test="$Style='Code'">
            <code display="inline">
              <xsl:apply-templates select="node()"/>
            </code>
          </xsl:when>
          <xsl:when test="$Style='CNXML_20_Code_20__28_Inline_29_' or $Style='CNXML_20_Code'">
            <xsl:choose>
              <xsl:when test="not(normalize-space(.)) and descendant::draw:image">
                <!-- code with no text but image(s) -->
                <xsl:apply-templates select="node()"/>
              </xsl:when>
              <xsl:when test="not(normalize-space(.)) and not(descendant::draw:image)">
                 <!-- code with no text; do nothing -->
              </xsl:when>
              <xsl:otherwise>
                <code display="inline">
                  <xsl:apply-templates select="node()"/>
                </code>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="$Style='CNXML_20_Term'">
            <xsl:choose>
              <xsl:when test="not(normalize-space(.)) and descendant::draw:image">
                <!-- term with no text but image(s) -->
                <xsl:apply-templates select="node()"/>
              </xsl:when>
              <xsl:when test="not(normalize-space(.)) and not(descendant::draw:image)">
                 <!-- term with no text; do nothing -->
              </xsl:when>
              <xsl:otherwise>
                <term>
                  <xsl:apply-templates select="node()"/>
                </term>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="$Style='CNXML_20_Cite'">
            <xsl:choose>
              <xsl:when test="not(normalize-space(.)) and descendant::draw:image">
                <!-- cite with no text but image(s) -->
                <xsl:apply-templates select="node()"/>
              </xsl:when>
              <xsl:when test="not(normalize-space(.)) and not(descendant::draw:image)">
                 <!-- cite with no text; do nothing -->
              </xsl:when>
              <xsl:otherwise>
                <cite>
                  <xsl:apply-templates select="node()"/>
                </cite>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="$Style='CNXML_20_Quote_20__28_Inline_29_'">
            <xsl:choose>
              <xsl:when test="not(normalize-space(.)) and descendant::draw:image">
                <!-- quote with no text but image(s) -->
                <xsl:apply-templates select="node()"/>
              </xsl:when>
              <xsl:when test="not(normalize-space(.)) and not(descendant::draw:image)">
                 <!-- quote with no text; do nothing -->
              </xsl:when>
              <xsl:otherwise>
                <quote display="inline">
                  <xsl:apply-templates select="node()"/>
                </quote>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="$Style='CNXML_20_Foreign'">
            <foreign>
              <xsl:apply-templates select="node()"/>
            </foreign>
          </xsl:when>
          <xsl:when test="$Style='CNXML_20_Note'">
            <xsl:choose>
              <xsl:when test="not(normalize-space(.)) and descendant::draw:image">
                <!-- note with no text but image(s) -->
                <xsl:apply-templates select="node()"/>
              </xsl:when>
              <xsl:when test="not(normalize-space(.)) and not(descendant::draw:image)">
                 <!-- note with no text; do nothing -->
              </xsl:when>
              <xsl:otherwise>
                <note type='Note'>
                  <xsl:apply-templates select="node()"/>
                </note>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="node()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  

  <xsl:template match="table:table">
    <table summary="">
      <xsl:if test="following-sibling::text:p[@text:style-name='Table']">
        <title>
          <xsl:value-of select="following-sibling::text:p[@text:style-name='Table']"/>
        </title>
      </xsl:if>
      <xsl:call-template name="generictable"/>
    </table>
  </xsl:template>

  <xsl:template match="table:table[count(./table:table-row/table:table-cell)=1]">
    <para>
    <!-- We have found a one entry table. -->
      <xsl:apply-templates select="./table:table-row/table:table-cell/*" />
    </para>
  </xsl:template>

  <xsl:template name="generictable">
    <tgroup>
      <!-- Determine the number of columns the table has -->
      <xsl:attribute name='cols'>
        <xsl:call-template name="count.columns" />
      </xsl:attribute>
      <!-- Put in colspecs so that entries can span correctly -->
      <xsl:call-template name="colspec.maker">
        <xsl:with-param name="numcols">
          <xsl:call-template name="count.columns" />
        </xsl:with-param>
      </xsl:call-template>
      <tbody>
        <xsl:apply-templates select="node()"/>
      </tbody>
    </tgroup>
  </xsl:template>

  <xsl:template name="count.columns">
    <xsl:param name="iteration" select="1" />
    <xsl:param name="numcols" select="0" />
    <xsl:param name="location" select="." />
    <xsl:choose>
      <xsl:when test="not($location/table:table-column[$iteration])">
        <xsl:value-of select="$numcols" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$location/table:table-column[$iteration]/@table:number-columns-repeated">
            <xsl:call-template name="count.columns">
              <xsl:with-param name="numcols" select="$numcols + $location/table:table-column[$iteration]/@table:number-columns-repeated" />
              <xsl:with-param name="iteration" select="$iteration + 1" />
              <xsl:with-param name="location" select="$location" />
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="count.columns">
              <xsl:with-param name="numcols" select="$numcols + 1" />
              <xsl:with-param name="iteration" select="$iteration + 1" />
              <xsl:with-param name="location" select="$location" />
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>        
  </xsl:template>
  
  <xsl:template name="colspec.maker">
    <xsl:param name="iteration" select="1" />
    <xsl:param name="numcols" select="0" />
    <xsl:choose>
      <xsl:when test="$iteration &gt; $numcols" />
      <xsl:otherwise>
        <xsl:element name="colspec">
          <xsl:attribute name="colnum">
            <xsl:value-of select="$iteration" />
          </xsl:attribute>
          <xsl:attribute name="colname">
            <xsl:text>c</xsl:text>
            <xsl:value-of select="$iteration" />
          </xsl:attribute>
        </xsl:element>
        <xsl:call-template name="colspec.maker">
          <xsl:with-param name="iteration" select="$iteration + 1" />
          <xsl:with-param name="numcols" select="$numcols" />
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="table:table-column|table:table-header-rows|table:table-cell/table:sub-table|table:table-cell//table:table">
      <!-- Skip me but do my children. -->
    <xsl:apply-templates select="node()"/>
  </xsl:template>

  <xsl:template match="table:table-row">
    <row>
      <xsl:apply-templates select="node()"/>
    </row>
  </xsl:template>

  <xsl:template match="table:table-cell|table:covered-table-cell">
    <xsl:param name="entry.colnum">
      <xsl:call-template name="entry.colnum.determiner" />
    </xsl:param>
    <xsl:variable name="entry.or.entrytbl">
      <xsl:choose>
        <xsl:when test="table:sub-table">
          <xsl:text>entrytbl.sub-table</xsl:text>
        </xsl:when>
        <xsl:when test="descendant::table:table">
          <xsl:text>entrytbl.table</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>entry.normal</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="{substring-before($entry.or.entrytbl,'.')}">
      <xsl:if test="@table:number-columns-spanned &gt; 1">
        <xsl:attribute name="namest">
          <xsl:text>c</xsl:text>
          <xsl:value-of select="$entry.colnum" />
        </xsl:attribute>
        <xsl:attribute name="nameend">
          <xsl:text>c</xsl:text>
          <xsl:value-of select="$entry.colnum + @table:number-columns-spanned - 1" />
        </xsl:attribute>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="$entry.or.entrytbl='entrytbl.sub-table'">
          <xsl:attribute name="cols">
            <xsl:call-template name="count.columns">
              <xsl:with-param name="location" select="table:sub-table"/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:call-template name="colspec.maker">
            <xsl:with-param name="numcols">
              <xsl:call-template name="count.columns">
                <xsl:with-param name="location" select="table:sub-table"/>
              </xsl:call-template>
            </xsl:with-param>
          </xsl:call-template>
          <tbody>
            <xsl:apply-templates select="node()"/>
          </tbody>
        </xsl:when>
        <xsl:when test="$entry.or.entrytbl='entrytbl.table'">
          <xsl:attribute name="cols">
            <xsl:call-template name="count.columns">
              <xsl:with-param name="location" select="descendant::table:table[1]"/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:call-template name="colspec.maker">
            <xsl:with-param name="numcols">
              <xsl:call-template name="count.columns">
                <xsl:with-param name="location" select="descendant::table:table[1]"/>
              </xsl:call-template>
            </xsl:with-param>
          </xsl:call-template>
          <tbody>
            <xsl:apply-templates select="node()"/>
          </tbody>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="node()"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="self::table:covered-table-cell">
        <xsl:processing-instruction name="cnx.warning">This cell was added but was originally covered by text in the original file. Consider fixing this by making the CALS table span the correct number of rows/columns</xsl:processing-instruction>
      </xsl:if>
    </xsl:element>
  </xsl:template>

  <xsl:template name="entry.colnum.determiner">
    <xsl:param name="iteration" select="1" />
    <xsl:param name="entry.colnum" select="1" />
    <xsl:choose>
      <xsl:when test="not(preceding-sibling::table:table-cell[$iteration])">
        <xsl:value-of select="$entry.colnum" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="preceding-sibling::table:table-cell[$iteration]/@table:number-columns-spanned">
            <xsl:call-template name="entry.colnum.determiner">
              <xsl:with-param name="entry.colnum" select="$entry.colnum + preceding-sibling::table:table-cell[$iteration]/@table:number-columns-spanned" />
              <xsl:with-param name="iteration" select="$iteration + 1" />
            </xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="entry.colnum.determiner">
              <xsl:with-param name="entry.colnum" select="$entry.colnum + 1" />
              <xsl:with-param name="iteration" select="$iteration + 1" />
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="math:math">
    <m:math>
      <xsl:apply-templates select="@*|node()"/>
    </m:math>
  </xsl:template>

  <xsl:template match="math:*">
    <xsl:element name="m:{local-name()}">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="math:*/@*">
    <xsl:attribute name="{local-name()}">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>

  <xsl:template
    match="text:p[count(*)=1 and
                  not(ancestor::table:table-cell) and
                  draw:object[math:math and
                              string-length(normalize-space(preceding-sibling::text())) = 0 and
                              string-length(normalize-space(following-sibling::text())) = 0
                             ]
                 ]
                 ">
    <equation>
      <xsl:apply-templates select="node()"/>
    </equation>
  </xsl:template>

<!-- Link -->

  <xsl:template match="text:a">
    <xsl:choose>
      <xsl:when test="text:span/@text:style-name='CNXML_20_Cite'">
        <cite>
          <xsl:attribute name="url">
            <xsl:value-of select="@xlink:href"/>
          </xsl:attribute>
          <xsl:value-of select="child::*"/>
        </cite>
      </xsl:when>
      <xsl:when test="text:span/@text:style-name='CNXML_20_Term'">
        <term>
          <xsl:attribute name="url">
            <xsl:value-of select="@xlink:href"/>
          </xsl:attribute>
           <xsl:value-of select="child::*"/>
        </term>
      </xsl:when>
      <xsl:when test="text:span/@text:style-name='CNXML_20_Foreign'">
        <foreign>
          <xsl:attribute name="url">
            <xsl:value-of select="@xlink:href"/>
          </xsl:attribute>
           <xsl:value-of select="child::*"/>
        </foreign>
      </xsl:when>
      <xsl:when test="text:span/@text:style-name='CNXML_20_Quote_20__28_Inline_29_'">
        <quote display="inline">
          <xsl:attribute name="url">
            <xsl:value-of select="@xlink:href"/>
          </xsl:attribute>
           <xsl:value-of select="child::*"/>
        </quote>
      </xsl:when>
      <xsl:when test="starts-with(@xlink:href,'#')">
        <xsl:variable name="markName" select="normalize-space(translate(@xlink:href,'#',' '))"/>
        <link>
          <xsl:attribute name="target-id">
              <xsl:choose>
                <xsl:when test="ancestor::office:body//text:bookmark-start/@text:name=$markName">
                  <xsl:choose>
                    <xsl:when test="key('bookmark-start',$markName)/parent::name">
                      <xsl:value-of select="generate-id(key('bookmark-start',$markName)/ancestor::section[1])"/>
                    </xsl:when>
                    <xsl:when test="key('bookmark-start',$markName)/ancestor::text:list-item">
                      <xsl:value-of select="generate-id(key('bookmark-start',$markName)/ancestor::text:list-item[1])"/>
                    </xsl:when>
                    <xsl:when test="count(key('bookmark-start',$markName)/../child::*)=2 and not(normalize-space(key('bookmark-start',$markName)/..))">
                      <xsl:value-of select="generate-id(key('bookmark-start',$markName)/../following-sibling::*[1])"/>
                    </xsl:when>
                    <xsl:when test="key('bookmark-start',$markName)/ancestor::text:footnote-body">
                      <xsl:value-of select="generate-id(key('bookmarkstart',$markName)/ancestor::text:footnote-body[1])"/>
                    </xsl:when>
                    <xsl:when test="key('bookmark-start',$markName)/ancestor::table:table">
                      <xsl:value-of select="generate-id(key('bookmark',$markName)/ancestor::table:table[1])"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="generate-id(key('bookmark-start',$markName)/parent::*)"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
                <xsl:when test="ancestor::office:body//text:bookmark/@text:name=$markName">
                  <xsl:choose>
                    <xsl:when test="key('bookmark',$markName)/parent::name">
                      <xsl:value-of select="generate-id(key('bookmark',$markName)/ancestor::section[1])"/>
                    </xsl:when>
                    <xsl:when test="key('bookmark',$markName)/ancestor::text:list-item">
                      <xsl:value-of select="generate-id(key('bookmark',$markName)/ancestor::text:list-item[1])"/>
                    </xsl:when>
                    <xsl:when test="count(key('bookmark',$markName)/../child::*)=2 and not(normalize-space(key('bookmark',$markName)/..))">
                      <xsl:value-of select="generate-id(key('bookmark',$markName)/../following-sibling::*[1])"/>
                    </xsl:when>
                    <xsl:when test="key('bookmark',$markName)/ancestor::text:footnote-body">
                      <xsl:value-of select="generate-id(key('bookmark',$markName)/ancestor::text:footnote-body[1])"/>
                    </xsl:when>
                    <xsl:when test="key('bookmark',$markName)/ancestor::table:table">
                      <xsl:value-of select="generate-id(key('bookmark',$markName)/ancestor::table:table[1])"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="generate-id(key('bookmark',$markName)/parent::*)"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>
              </xsl:choose>
          </xsl:attribute>
          <xsl:apply-templates select="node()"/>
        </link>
      </xsl:when>
      <xsl:when test="contains(@xlink:href,'cnx.org/content/') or contains(@xlink:href,'cnx.rice.edu/content/')">
        <xsl:variable name="cnxURL" select="substring-after(@xlink:href,'content/')"/>
        <xsl:variable name="cnxnDoc" select="substring-before($cnxURL,'/')" />
        <xsl:variable name="cnxnVer">
          <xsl:choose>
            <xsl:when test="contains(substring-after($cnxURL,concat($cnxnDoc,'/')),'/')">
              <xsl:value-of select="substring-before(substring-after($cnxURL,concat($cnxnDoc,'/')),'/')" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="substring-after($cnxURL,concat($cnxnDoc,'/'))" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="cnxnTar">
          <xsl:if test="normalize-space($cnxnVer)">
            <xsl:value-of select="normalize-space(translate(substring-after($cnxURL,$cnxnVer),'/#','  '))"/>
          </xsl:if>
        </xsl:variable>
        <link>
          <xsl:attribute name='document'>
            <xsl:value-of select="$cnxnDoc" />
          </xsl:attribute>
          <xsl:if test="normalize-space($cnxnVer) and not($cnxnVer='latest')">
            <xsl:attribute name='version'>
              <xsl:value-of select="$cnxnVer" />
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="normalize-space($cnxnTar)">
            <xsl:attribute name='target-id'>
              <xsl:value-of select="$cnxnTar" />            
            </xsl:attribute>
          </xsl:if>
          <xsl:apply-templates select="node()"/>
        </link>
      </xsl:when>
      <xsl:otherwise>
        <link>
          <xsl:attribute name='url'>
                <xsl:value-of select="@xlink:href"/>
          </xsl:attribute>
          <xsl:apply-templates select="node()"/>
        </link>
     </xsl:otherwise>
   </xsl:choose>
  </xsl:template>

  <xsl:template match="text:tab-stop">
    <xsl:text> </xsl:text>
  </xsl:template>

  <!-- S -->
  <xsl:template match="text:s"/>

  <!-- Squash Everything Else -->

  <xsl:template match="*"/>

  <xsl:template match="text:deletion" />

  <xsl:template match="form:property-value" />

  <xsl:template match="text:index-title-template" />

  <xsl:template match="text:bibliography-entry-template" />

  <xsl:template match="number:date-style" />

  <xsl:template match="office:styles"/>
  
  <xsl:template match="text:bookmark|text:line-break">
    <xsl:processing-instruction name="cnx.info">Ignoring <xsl:value-of select="name()"/></xsl:processing-instruction>
  </xsl:template>


<!-- When a paragraph only has an image, unwrap it because images can be block-level -->
<xsl:template match="text:p[draw:frame and count(*)=1 and normalize-space()='']">
  <xsl:apply-templates select="node()"/>
</xsl:template>

</xsl:stylesheet>

