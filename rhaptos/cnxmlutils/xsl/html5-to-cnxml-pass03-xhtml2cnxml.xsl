<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://cnx.rice.edu/cnxml"
  xmlns:md="http://cnx.rice.edu/mdml"
  xmlns:bib="http://bibtexml.sf.net/"
  xmlns:m="http://www.w3.org/1998/Math/MathML"
  xmlns:q="http://cnx.rice.edu/qml/1.0"
  xmlns:xh="http://www.w3.org/1999/xhtml"
  xmlns:cnhtml="http://cnxhtml"
  xmlns:cnxtra="http://cnxtra"
  version="1.0"
  exclude-result-prefixes="xh cnhtml cnxtra">

<xsl:output method="xml" encoding="ASCII" indent="no"/>

<xsl:strip-space elements="*"/>

<xsl:param name="id.prefix">h2c-</xsl:param>

<!--
Main XHTML to CNXML transformation.

XHTML gets converted to their CNXML equivalent.

After this transformation ID attributes are still missing and internal links point
to a <cnxtra:bookmark> placeholder which is not a valid CNML tag!
-->

<xsl:template match="/">
  <document>
    <xsl:attribute name="cnxml-version">0.7</xsl:attribute>
    <xsl:attribute name="module-id">new</xsl:attribute>
     <xsl:apply-templates select="xh:html"/>
  </document>
</xsl:template>

<!--
  IMPORTANT!!!!
  Instead of applying templates on "@*|node()" call this template.

  It will make sure the data-label attribute is converted to an element
-->
<xsl:template name="apply-all">
  <xsl:call-template name="apply-attributes"/>
  <xsl:call-template name="apply-nodes"/>
</xsl:template>

<xsl:template name="apply-attributes">
  <xsl:apply-templates select="@*[local-name()!='data-label']"/>
  <xsl:apply-templates select="@data-label"/>
</xsl:template>

<xsl:template name="apply-nodes">
  <xsl:apply-templates select="node()"/>
</xsl:template>

<!-- HTML -->
<xsl:template match="xh:html">
  <xsl:apply-templates select="xh:head"/>
  <content>
    <!-- create section if not first element is a header -->
    <xsl:apply-templates select="xh:body"/>
    <!--
    <xsl:choose>
      <xsl:when test="xh:body[1][cnhtml:h]">
        <xsl:apply-templates select="xh:body"/>
      </xsl:when>
      <xsl:otherwise>
        <section>
          <xsl:apply-templates select="xh:body"/>
        </section>
      </xsl:otherwise>
    </xsl:choose>
    -->
  </content>
</xsl:template>

<!-- Get the title out of the header -->
<xsl:template match="xh:head">
  <!-- if document title is missing, Rhaptos creates error in metadata! -->
  <title>
    <xsl:variable name="document_title">
      <xsl:value-of select="normalize-space(xh:title)"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="string-length($document_title) &gt; 0">
        <xsl:value-of select="$document_title"/>
      </xsl:when>
      <xsl:otherwise> <!-- create "untitled" as title text -->
        <xsl:text>Untitled</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </title>
</xsl:template>

<!-- HTML body -->
<xsl:template match="xh:body">
  <xsl:call-template name="apply-all"/>
</xsl:template>

<!-- div -->
<xsl:template match="xh:div">
  <xsl:choose>
    <xsl:when test="./text()">
      <para>
        <xsl:call-template name="apply-all"/>
      </para>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="apply-all"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- div copy classes to new tags -->
<xsl:template match="xh:div[@class]">
  <xsl:element name="{@class}">
    <xsl:if test="@id">
      <xsl:if test="string(number(substring(@id,1,1))) = 'NaN'"> <!-- check if first character is number -->
        <xsl:attribute name="id">
          <xsl:value-of select="@id"/>
        </xsl:attribute>
      </xsl:if>
    </xsl:if>
    <xsl:call-template name="apply-all"/>
  </xsl:element>
</xsl:template>

<!-- paragraphs -->
<xsl:template match="xh:p">
  <para>
    <xsl:call-template name="apply-all"/>
  </para>
</xsl:template>

<!-- em (italics) -->
<xsl:template match="xh:em">
  <emphasis effect="italics">
    <xsl:call-template name="apply-all"/>
  </emphasis>
</xsl:template>

<!-- strong (bold) -->
<xsl:template match="xh:strong">
  <emphasis effect="bold">
    <xsl:call-template name="apply-all"/>
  </emphasis>
</xsl:template>

<!-- underline (first part is a tidy workaround) -->
<xsl:template match="@class[contains(., 'c1')]|xh:u">
  <emphasis effect="underline">
    <xsl:call-template name="apply-all"/>
  </emphasis>
</xsl:template>

<xsl:template match="xh:sub">
  <sub>
    <xsl:call-template name="apply-all"/>
  </sub>
</xsl:template>

<xsl:template match="xh:sup">
  <sup>
    <xsl:call-template name="apply-all"/>
  </sup>
</xsl:template>

<!-- br -->
<xsl:template match="xh:p/xh:br">
  <newline/>
</xsl:template>

<!-- span -->
<xsl:template match="xh:span">
  <xsl:choose>
    <!-- Do we have a header? Then do not apply any emphasis to the <title> -->
     <xsl:when test="parent::cnhtml:h">
      <xsl:call-template name="apply-all"/>
    </xsl:when>
    <!-- First super- and supformat text -->
    <xsl:when test="contains(@style, 'vertical-align:super')">
      <sup>
        <xsl:call-template name="apply-all"/>
      </sup>
    </xsl:when>
    <xsl:when test="contains(@style, 'vertical-align:sub')">
      <sub>
        <xsl:call-template name="apply-all"/>
      </sub>
    </xsl:when>
    <xsl:when test="contains(@style, 'font-style:italic')">
      <emphasis effect='italics'>
        <xsl:call-template name="apply-all"/>
      </emphasis>
    </xsl:when>
    <xsl:when test="contains(@style, 'font-weight:bold')">
      <emphasis effect='bold'>
        <xsl:call-template name="apply-all"/>
      </emphasis>
    </xsl:when>
    <xsl:when test="contains(@style, 'text-decoration:underline')">
      <!-- when we have no text, e.g. just links, do not generate emphasis -->
      <xsl:choose>
        <xsl:when test="text()">
          <emphasis effect='underline'>
            <xsl:call-template name="apply-all"/>
          </emphasis>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="apply-all"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="apply-all"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- span copy classes to cnxml tags -->
<xsl:template match="xh:span[@class]">
  <xsl:element name="{@class}">
    <xsl:if test="@id">
      <xsl:if test="string(number(substring(@id,1,1))) = 'NaN'">
        <xsl:attribute name="id">
          <xsl:value-of select="@id"/>
        </xsl:attribute>
      </xsl:if>
    </xsl:if>
    <xsl:call-template name="apply-all"/>
  </xsl:element>
</xsl:template>

<!-- quotes -->
<xsl:template match="xh:q[@class]/@cite|xh:blockquote[@class]/@cite">
  <xsl:attribute name="url">
    <xsl:value-of select="."/>
  </xsl:attribute>
</xsl:template>

<!-- cites -->
<xsl:template match="xh:cite">
  <cite>
    <xsl:if test="@id">
      <xsl:if test="string(number(substring(@id,1,1))) = 'NaN'">
        <xsl:attribute name="id">
          <xsl:value-of select="@id"/>
        </xsl:attribute>
      </xsl:if>
    </xsl:if>
    <xsl:call-template name="apply-all"/>
  </cite>
</xsl:template>

<xsl:template match="xh:q[@class]|xh:blockquote[@class]">
  <xsl:element name="{@class}">
    <xsl:if test="@id">
      <xsl:if test="string(number(substring(@id,1,1))) = 'NaN'">
        <xsl:attribute name="id">
          <xsl:value-of select="@id"/>
        </xsl:attribute>
      </xsl:if>
    </xsl:if>
    <xsl:call-template name="apply-all"/>
  </xsl:element>
</xsl:template>

<xsl:template match="xh:div/text()">
  <xsl:value-of select="."/>
</xsl:template>

<!-- copy text from specific text-nodes -->
<xsl:template match="xh:p/text()|xh:span/text()|xh:li/text()|xh:th/text()|xh:td/text()|xh:a/text()">
  <xsl:value-of select="."/>
</xsl:template>

<!-- sections -->
<xsl:template match="xh:section">
  <section>
    <xsl:call-template name="apply-attributes"/>
    <!-- TODO! -->
    <!--
    <xsl:if test="not(child::xh:p)">
      <para>
        <newline/>
      </para>
    </xsl:if>
    -->
     <xsl:call-template name="apply-nodes"/>
  </section>
</xsl:template>

<xsl:template match="xh:h1|xh:h2|xh:h3|xh:h4|xh:h5|xh:h6">
  <title>
    <xsl:call-template name="apply-attributes"/>
     <xsl:call-template name="apply-nodes"/>
  </title>
</xsl:template>


<!-- unordered listings -->
<xsl:template match="xh:ul">
    <list>
        <xsl:call-template name="apply-all"/>
    </list>
</xsl:template>

<!-- ordered listings -->
<xsl:template match="xh:ol">
    <list list-type="enumerated">
        <xsl:call-template name="apply-all"/>
    </list>
</xsl:template>

<!-- listings content -->
<xsl:template match="xh:li">
    <item>
        <xsl:call-template name="apply-all"/>
    </item>
</xsl:template>

<!-- table -->
<xsl:template match="xh:table">
  <table>
    <xsl:attribute name="summary" select=""/>
    <xsl:attribute name="pgwide">1</xsl:attribute>
    <xsl:apply-templates select="xh:tbody"/>
  </table>
</xsl:template>

<!-- table body -->
<xsl:template match="xh:tbody">
  <tgroup>
    <xsl:choose>

      <!-- Do we have table headers in first row? -->
      <xsl:when test="xh:tr[1]/xh:th and xh:tr[2]">
        <xsl:attribute name="cols">
          <!-- get number of column from the first row -->
          <xsl:value-of select="count(xh:tr[1]/xh:th)"/>
        </xsl:attribute>
        <!-- get column width -->
        <xsl:for-each select="xh:tr[1]/xh:th">
          <colspec>
            <xsl:attribute name="colnum">
              <xsl:value-of select="position()"/>
            </xsl:attribute>
            <xsl:attribute name="colwidth">
              <xsl:value-of select="@width"/>
            </xsl:attribute>
          </colspec>
        </xsl:for-each>
        <thead>
          <row>
            <xsl:for-each select="xh:tr[1]/xh:th">
              <entry>
                <xsl:apply-templates select="node()"/>
              </entry>
            </xsl:for-each>
          </row>
        </thead>
        <tbody>
          <xsl:variable name="first_tr">
            <xsl:value-of select="generate-id(xh:tr[1])"/>
          </xsl:variable>
          <xsl:for-each select="xh:tr[generate-id(.) != $first_tr]"> <!--ignore first tr with headers -->
            <row>
              <xsl:for-each select="xh:td">
                <entry>
                  <xsl:apply-templates select="node()"/>
                </entry>
              </xsl:for-each>
            </row>
          </xsl:for-each>
        </tbody>
      </xsl:when>

      <!-- No table headers or just tables with headers -->
      <xsl:otherwise>
        <xsl:attribute name="cols">
          <!-- get number of column from the first row -->
          <xsl:value-of select="count(xh:tr[1]/xh:td|xh:tr[1]/xh:th)"/>
        </xsl:attribute>
        <!-- get column width -->
        <xsl:for-each select="xh:tr[1]/xh:td|xh:tr[1]/xh:th">
          <colspec>
            <xsl:attribute name="colnum">
              <xsl:value-of select="position()"/>
            </xsl:attribute>
            <xsl:attribute name="colwidth">
              <xsl:value-of select="@width"/>
            </xsl:attribute>
          </colspec>
        </xsl:for-each>
        <tbody>
          <xsl:for-each select="xh:tr">
            <row>
              <xsl:for-each select="xh:td|xh:th">
                <entry>
                  <xsl:apply-templates select="node()"/>
                </entry>
              </xsl:for-each>
            </row>
          </xsl:for-each>
        </tbody>
      </xsl:otherwise>
    </xsl:choose>
  </tgroup>
</xsl:template>

<!-- links -->
<xsl:template match="xh:a">
  <xsl:if test="@href">
    <xsl:choose>
      <!-- internal link -->
      <xsl:when test="substring(@href, 1, 1) = '#'">
        <link>
	        <xsl:attribute name="bookmark">
	          <xsl:value-of select="@href"/>
	        </xsl:attribute>
          <xsl:attribute name="target-id">
            <xsl:value-of select="substring-after(@href, '#')"/>
          </xsl:attribute>
	        <xsl:call-template name="apply-all"/>
	      </link>
      </xsl:when>
      <!-- external link -->
      <xsl:otherwise>
		    <link>
		      <xsl:attribute name="url">
		        <xsl:value-of select="@href"/> <!-- link url -->
 		      </xsl:attribute>
		      <!-- open external links default in new window if they are no emails-->
		      <xsl:if test="not(starts-with(@href, 'mailto'))">
		        <xsl:attribute name="window">new</xsl:attribute>
		      </xsl:if>
		      <xsl:call-template name="apply-all"/>
		    </link>
	    </xsl:otherwise>
    </xsl:choose>
  </xsl:if>
  <!-- create a "bookmark" for internal links -->
  <xsl:if test="@name">
  	<cnxtra:bookmark>
  		<xsl:attribute name="name">
  			<xsl:value-of select="@name"/>
  		</xsl:attribute>
  		<xsl:call-template name="apply-all"/>
  	</cnxtra:bookmark>
	</xsl:if>
</xsl:template>

<!-- images -->
<xsl:template match="xh:img">
  <cnxtra:image>
    <xsl:copy-of select="@src|@height|@width|@alt"/>
  </cnxtra:image>
</xsl:template>

<!-- remove empty images -->
<xsl:template match="xh:img[not(@src)]"/>

<!-- remove unsupported now -->

<!-- TODO! -->
<xsl:template match="xh:p[cnxtra:tex]"/>

<xsl:template match="xh:pre|xh:code">
  <code display="block">
    <xsl:for-each select="node()">
      <xsl:value-of select="."/>
      <xsl:text>&#xa;</xsl:text>
    </xsl:for-each>
  </code>
</xsl:template>

<xsl:template match="xh:iframe">
  <figure>
    <media alt="">
      <iframe>
        <xsl:attribute name="width">
          <xsl:value-of select="@width"/>
        </xsl:attribute>
        <xsl:attribute name="height">
          <xsl:value-of select="@height"/>
        </xsl:attribute>
        <xsl:attribute name="src">
          <xsl:value-of select="@src"/>
        </xsl:attribute>
      </iframe>
    </media>
  </figure>
</xsl:template>

<xsl:template match="xh:div[@class='media']/xh:iframe">
  <iframe>
    <xsl:attribute name="width">
      <xsl:value-of select="@width"/>
    </xsl:attribute>
    <xsl:attribute name="height">
      <xsl:value-of select="@height"/>
    </xsl:attribute>
    <xsl:attribute name="src">
      <xsl:value-of select="@src"/>
    </xsl:attribute>
  </iframe>
</xsl:template>

<xsl:template match="xh:figure">
  <figure>
    <xsl:call-template name="apply-attributes"/>
    
    <!-- title -->
    <xsl:apply-templates select="xh:figcaption/xh:div[@class='title']"/>

    <xsl:apply-templates select="node()[not(self::xh:figcaption)]"/>
    
    <!-- caption -->
    <xsl:if test="xh:figcaption[string-length(normalize-space(node()[not(self::xh:div[@class='title'])])) > 0]">
      <xsl:apply-templates select="xh:figcaption"/>
    </xsl:if>
  </figure>
</xsl:template>

<xsl:template match="xh:figcaption">
  <caption>
    <xsl:call-template name="apply-attributes"/>
    <xsl:apply-templates select="node()[not(self::xh:div[@class='title'])]"/>
  </caption>
</xsl:template>

<!-- TODO! ignore tags -->
<xsl:template match="
	xh:abbr
	|xh:acronym
	|xh:address
	|xh:applet
	|xh:area
	|xh:base
	|xh:basefont
	|xh:bdo
	|xh:button
	|xh:caption
	|xh:center
	|xh:col
	|xh:colgroup
	|xh:dd
	|xh:del
	|xh:dfn
	|xh:dir
	|xh:fieldset
	|xh:form
	|xh:frame
	|xh:frameset
	|xh:hr
	|xh:i
	|xh:input
	|xh:ins
	|xh:isindex
	|xh:kbd
	|xh:legend
	|xh:map
	|xh:menu
	|xh:meta
	|xh:noframes
	|xh:noscript
	|xh:object
	|xh:optgroup
	|xh:option
	|xh:param
	|xh:s
	|xh:samp
	|xh:script
	|xh:select
	|xh:style
	|xh:textarea
	|xh:thead
	|xh:tfoot
	|xh:tt
	|xh:var
  "/>

<!-- TODO: ignore tags, but keep content -->
<xsl:template match="
	xh:dl
	|xh:dt
	|xh:small
	|xh:strike
	|xh:title
	|xh:b
	|xh:label
	|xh:link
	|xh:font
	|xh:big
  ">
<!--  <xsl:call-template name="apply-all"/> -->
</xsl:template>

<!-- handle attributes -->
<xsl:template match="@id">
  <xsl:if test="string(number(substring(.,1,1))) = 'NaN'">
    <xsl:copy/>
  </xsl:if>
</xsl:template>

<!-- convert data-attribute names to normal attributes -->
<xsl:template match="@*[starts-with(name(), 'data-') and 'data-label' != name()]">
  <xsl:attribute name="{substring(name(), 6)}">
    <xsl:value-of select="."/>
  </xsl:attribute>
</xsl:template>

<!-- convert data-label to a c:label. See template name="apply-all" -->
<xsl:template match="@data-label">
  <label><xsl:value-of select="."/></label>
</xsl:template>

<xsl:template match="@*">
  <xsl:message>TODO: <xsl:value-of select="local-name(..)"/>/@<xsl:value-of select="local-name()"/></xsl:message>
</xsl:template>

<!-- handle math -->
<xsl:template match="m:math">
  <xsl:copy-of select="."/>
</xsl:template>

<!-- handle generic block -->
<xsl:template match="xh:div[@data-unknown]">
  <div>
    <xsl:if test="not(@id)">
      <xsl:attribute name="id">
        <xsl:value-of select="$id.prefix"/>
        <xsl:value-of select="generate-id()"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="@class">
       <xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
    </xsl:if>
    <xsl:apply-templates select="@*[not(local-name() = 'data-unknown')]"/>
    <xsl:apply-templates select="node()"/>
  </div>
</xsl:template>

</xsl:stylesheet>
