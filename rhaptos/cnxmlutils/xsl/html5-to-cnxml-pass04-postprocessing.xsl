<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://cnx.rice.edu/cnxml"
  xmlns:cnx="http://cnx.rice.edu/cnxml"
  xmlns:md="http://cnx.rice.edu/mdml"
  xmlns:bib="http://bibtexml.sf.net/"
  xmlns:m="http://www.w3.org/1998/Math/MathML"
  xmlns:q="http://cnx.rice.edu/qml/1.0"
  xmlns:cnxtra="http://cnxtra"
  version="1.0"
  exclude-result-prefixes="cnx cnxtra">

<xsl:output method="xml" encoding="ASCII" indent="no"/>

<xsl:strip-space elements="*"/>

<!--
Post processing of CNXML
- Convert empty paragraphs to paragraphs with newlines
- Convert cnxtra:image to images
- Convert cnxtra:tex from Blahtex to embedded MathML

Deprecated:
- Add @IDs to elements (needs rework!)
-->

<!-- Default: copy everything -->
<xsl:template match="@*|node()">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
  </xsl:copy>
</xsl:template>

<!-- remove all nesting paras -->
<xsl:template match="cnx:para[ancestor::cnx:para]">
  <xsl:apply-templates/>
</xsl:template>

<!-- convert empty paragraphs to paragraphs with newline -->
<xsl:template match="cnx:para[not(child::*|text())]">
  <para>
    <xsl:apply-templates select="@*"/>
    <newline/>
  </para>
</xsl:template>

<!-- add an empty div to empty sections -->
<xsl:template match="cnx:section[not(child::cnx:*[not(self::cnx:title|self::cnx:section)])]">
  <xsl:copy>
    <xsl:apply-templates select="@*|node()"/>
    <div/>
  </xsl:copy>
</xsl:template>

<!-- convert images to CNXML -->
<xsl:template match="cnx:media/cnxtra:image">
  <!-- there still needs to be a cnx:media template that reaches down 
       into this mathc and pulls out the image's @alt -->
        <image>
          <xsl:attribute name="mime-type">
            <xsl:value-of select="@mime-type"/>
          </xsl:attribute>
          <xsl:attribute name="src">
            <xsl:choose>
              <xsl:when test="text()">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@src"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:if test="@height &gt; 0">
            <xsl:attribute name="height">
              <xsl:value-of select="@height"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="@width &gt; 0">
            <xsl:attribute name="width">
              <xsl:value-of select="@width"/>
            </xsl:attribute>
          </xsl:if>
        </image>
</xsl:template>

<xsl:template match="cnxtra:image">
  <!-- just ignore images which cannot be uploaded -->
  <!--
  <xsl:choose>
  -->
    <!-- <xsl:if test="text()"> -->
    <!-- need to wrap any stand alone image element with a media element -->
      <media>
        <xsl:attribute name="alt">
          <xsl:value-of select="@alt"/>
        </xsl:attribute>
        <image>
          <xsl:attribute name="mime-type">
            <xsl:value-of select="@mime-type"/>
          </xsl:attribute>
          <xsl:attribute name="src">
            <!-- TODO!!! -->
            <xsl:choose>
              <xsl:when test="text()">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="@src"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:if test="@height &gt; 0">
            <xsl:attribute name="height">
              <xsl:value-of select="@height"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="@width &gt; 0">
            <xsl:attribute name="width">
              <xsl:value-of select="@width"/>
            </xsl:attribute>
          </xsl:if>
        </image>
      </media>
    <!-- </xsl:if> -->
  <!--
    <xsl:otherwise>
      <xsl:text>[Image (Upload Error)]</xsl:text>
    </xsl:otherwise>
  </xsl:choose>
  -->
</xsl:template>

<!-- remove placeholder media tags.  media tags without @alt are not valid in cnxml -->
<xsl:template match="cnx:media[not(@alt)]">
  <xsl:apply-templates select="@*|node()"/>
</xsl:template>

<xsl:template match="cnx:title[cnx:label]">
  <xsl:apply-templates select="cnx:label"/>
  <title>
    <xsl:apply-templates select="@*|node()[not(self::cnx:label)]"/> 
  </title>
</xsl:template>

</xsl:stylesheet>
