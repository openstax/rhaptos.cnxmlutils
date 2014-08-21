<?xml version="1.0"?>

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:col="http://cnx.rice.edu/collxml"
  xmlns="http://cnx.rice.edu/cnxml"
  xmlns:cnxml="http://cnx.rice.edu/cnxml"
  xmlns:cnxorg="http://cnx.rice.edu/system-info"
  xmlns:m="http://www.w3.org/1998/Math/MathML"
  xmlns:md4="http://cnx.rice.edu/mdml/0.4"
  xmlns:md="http://cnx.rice.edu/mdml"
  xmlns:q="http://cnx.rice.edu/qml/1.0"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:bib="http://bibtexml.sf.net/"
  xmlns:cc="http://web.resource.org/cc/"
  xmlns:cnx="http://cnx.rice.edu/contexts#"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:exsl="http://exslt.org/common"
  xmlns:str="http://exslt.org/strings"
  extension-element-prefixes="exsl str"
>

  <xsl:output encoding="UTF-8" method="xml" omit-xml-declaration="yes" />
  <xsl:preserve-space elements="md:abstract cnxml:code cnxml:preformat"/>

  <xsl:template match="node()|@*">
    <xsl:copy>
      <xsl:apply-templates select="node()|@*"/>
    </xsl:copy>
  </xsl:template>

<xsl:template match="cnxml:link">
    <xsl:choose>
      <xsl:when  test="contains(@url,'http://cnx.org/content/')">
          <link>
          <xsl:attribute name="url"><xsl:value-of select="substring-after(@url,'http://cnx.org/content')"/></xsl:attribute>
          <xsl:apply-templates select="node()|@id|@window|@strength"/>
          </link>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
</xsl:template>

</xsl:stylesheet>
