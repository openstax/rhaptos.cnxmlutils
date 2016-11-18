<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:saxon="http://saxon.sf.net/"
  xmlns:tr="http://transpect.io"
  xmlns:m="http://www.w3.org/1998/Math/MathML"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="saxon tr fn m xs">

  <xsl:import href="mml2tex/xsl/mml2tex.xsl"/>

  <xsl:output method="xml" encoding="UTF-8"/>

  <xsl:preserve-space elements="m:mn m:mi m:mtext m:mo m:ms"/>

  <xsl:param name="debug" select="'no'"/>
  <xsl:param name="debug-dir-uri" select="'debug'"/>

  <xsl:template match="m:annotation[@encoding='application/x-tex']">
    <xsl:message select="'[mmlcopy]: ignoring existing application/x-tex annotation', name()"/>
  </xsl:template>

  <xsl:template match="m:annotation" mode="mathml2tex">
    <xsl:message select="'[mml2tex]: skipping annotation', name()"/>
  </xsl:template>

  <xsl:template match="m:annotation-xml" mode="mathml2tex">
    <xsl:message select="'[mml2tex]: skipping annotation-xml', name()"/>
  </xsl:template>

  <xsl:template match="m:semantics[parent::m:math]">
    <xsl:copy>
      <xsl:apply-templates select="node()"/>

      <xsl:element name="m:annotation">
        <xsl:attribute name="encoding">application/x-tex</xsl:attribute>
        <xsl:apply-templates select=".." mode="mathml2tex"/>
      </xsl:element>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="m:math[m:semantics]">
    <xsl:copy>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="m:math">
    <xsl:copy>
      <xsl:element name="m:semantics">
        <xsl:apply-templates select="node()"/>

        <xsl:element name="m:annotation">
          <xsl:attribute name="encoding">application/x-tex</xsl:attribute>
          <xsl:apply-templates select="." mode="mathml2tex"/>
        </xsl:element>
      </xsl:element>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*|@*|processing-instruction()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/">
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
