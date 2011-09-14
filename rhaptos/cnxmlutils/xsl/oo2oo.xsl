<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
  xmlns:c="http://cnx.rice.edu/cnxml"

  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
 xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0" xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0" xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0" xmlns:number="urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0" xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0" xmlns:chart="urn:oasis:names:tc:opendocument:xmlns:chart:1.0" xmlns:dr3d="urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:form="urn:oasis:names:tc:opendocument:xmlns:form:1.0" xmlns:script="urn:oasis:names:tc:opendocument:xmlns:script:1.0" xmlns:ooo="http://openoffice.org/2004/office" xmlns:ooow="http://openoffice.org/2004/writer" xmlns:oooc="http://openoffice.org/2004/calc" xmlns:dom="http://www.w3.org/2001/xml-events" xmlns:xforms="http://www.w3.org/2002/xforms" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:rpt="http://openoffice.org/2005/report" xmlns:of="urn:oasis:names:tc:opendocument:xmlns:of:1.2" xmlns:rdfa="http://docs.oasis-open.org/opendocument/meta/rdfa#"  xmlns:m="http://www.w3.org/1998/Math/MathML"
  office:class="text" office:version="1.0"
  exclude-result-prefixes="office style text table draw fo xlink number svg chart dr3d math form script c"

  >

  <xsl:param name="stylesPath"/>
  <xsl:variable name="office-styles" select="document($stylesPath)/office:document-styles"/>


  <!-- Convert the RED escaped text to fit in the CNXML namespace -->
  <xsl:template match="*[namespace-uri()='']">
    <xsl:element name="c:{local-name()}">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:element>
  </xsl:template>

<!-- single entry tables are used for presentation purposes only, we hope. -->
  <xsl:template match="table:table[count(./table:table-row/table:table-cell)=1]">
    <xsl:variable name="one.entry" select="./table:table-row/table:table-cell[position()=1]" />

    <xsl:if test='count($one.entry/text:h)=1'>
      <xsl:comment>found a single entry table with a single header.</xsl:comment>
      <text:section>
        <xsl:attribute name='id'>
          <xsl:value-of select="generate-id()"/>
        </xsl:attribute>
        <xsl:apply-templates select='$one.entry/*'/>
      </text:section>
    </xsl:if>
    <xsl:if test='count($one.entry/text:h)=0'>
      <xsl:comment>found a single entry table without any header.</xsl:comment>
      <xsl:apply-templates select='$one.entry/*'/>
    </xsl:if>
    <xsl:if test='count($one.entry/text:h)>1'>
      <xsl:comment>found a single entry table with many headers.</xsl:comment>
      <text:section>
        <xsl:attribute name='id'>
          <xsl:value-of select="generate-id()"/>
        </xsl:attribute>
        <xsl:apply-templates select='$one.entry/*'/>
      </text:section>
    </xsl:if>

  </xsl:template>

<!-- single entry ordered lists are used for presentation purposes only, we hope. -->

  <xsl:template match="text:ordered-list[count(child::*)=1 and ./text:list-item/text:ordered-list]">
      <xsl:apply-templates select="./text:list-item/*" />
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
      <xsl:apply-templates/>
    </text:h>
  </xsl:template>

  <xsl:template match="text:p[@text:style-name='Heading 2']">
    <text:h text:style-name="Heading 2" text:level="2">
      <xsl:apply-templates/>
    </text:h>
  </xsl:template>

  <xsl:template match="text:p[@text:style-name='Heading 3']">
    <text:h text:style-name="Heading 3" text:level="3">
      <xsl:apply-templates/>
    </text:h>
  </xsl:template>

<!--  remove header if it only contains an image. -->

  <xsl:template match="text:h[count(child::*)=1 and (
                              draw:object or draw:object-ole or draw:image)]">
      <xsl:apply-templates/>
  </xsl:template>

<!-- Eliminate Headings After the Last Glossary -->

  <xsl:template match="text:h[preceding-sibling::text:p[@text:style-name='CNXML Glossary Section']]">
  </xsl:template>

<!-- convert header to paragraph if it contains an image and other stuff. -->

  <xsl:template match="text:h[draw:object or draw:object-ole or draw:image]">
    <text:p>
      <xsl:attribute name='id'>
        <xsl:value-of select="generate-id()"/>
      </xsl:attribute>
      <xsl:apply-templates/>
    </text:p>
  </xsl:template>

<!-- remove ordered list with only a header but leave the header's children. -->

  <xsl:template match="text:ordered-list[count(child::*)=1 and child::text:list-header]">
      <xsl:apply-templates select="./text:list-header/*"/>
  </xsl:template>

<!-- productions make sure the unmodified input is written to output -->

  <xsl:template match="text:p[count(text() | child::*[not(self::text:s)]) &lt; 1]"/>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

<!-- remove empty para, headers, and spans. -->

  <xsl:template match="
      office:forms|
      office:automatic-styles|
      text:sequence-decls|
      text:sequence-decl|
      text:tracked-changes|
      text:s|
      text:tab|
      text:soft-page-break|
      text:p/text:line-break
      ">
    <xsl:apply-templates select="node()"/>
  </xsl:template>

  <xsl:template match="text:h[count(node())=0]" />

  <xsl:template match="text:span[count(node())=0]" />

  <xsl:template match="text:p[count(node())=0]">
    <xsl:if test="@text:style-name='CNXML Code (Block)' and preceding-sibling::*[1]/@text:style-name='CNXML Code (Block)'">
      <xsl:copy-of select="."/>
    </xsl:if>
  </xsl:template>
  
  </xsl:stylesheet>

