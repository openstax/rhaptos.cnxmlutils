<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:saxon="http://saxon.sf.net/"
  xmlns:tr="http://transpect.io"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="saxon tr fn mml xs">

  <xsl:import href="mml2tex/xsl/mml2tex.xsl"/>

  <xsl:output method="xml" encoding="UTF-8"/>

  <xsl:preserve-space elements="mml:mn mml:mi mml:mtext mml:mo mml:ms"/>

  <xsl:param name="debug" select="'no'"/>
  <xsl:param name="debug-dir-uri" select="'debug'"/>

  <xsl:template match="mml:math[@display='block']">
    <xsl:element name="div">
      <xsl:attribute name="data-math">true</xsl:attribute>
      <xsl:apply-templates select="." mode="mathml2tex"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="mml:math">
    <xsl:element name="span">
      <xsl:attribute name="data-math">true</xsl:attribute>
      <xsl:apply-templates select="." mode="mathml2tex"/>
    </xsl:element>
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

  <xsl:template match="mml:annotation-xml[@encoding='MathML-Content']" mode="mathml2tex">
    <xsl:message terminate="no" select="'[WARNING]: ignoring content mathml', name()"/>
  </xsl:template>

</xsl:stylesheet>
