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


<xsl:template name="build-doc-link">
  <xsl:param name="contents" select="''"/>
  <xsl:param name="docstring" select="''"/>
  <xsl:param name="docid" select="''"/>
  <xsl:param name="version" select="''"/>
  <xsl:param name="filename" select="''"/>
  <xsl:param name="targetid" select="''"/>

<!--  <xsl:message>
  docstring: <xsl:value-of select="$docstring" />
  docid: <xsl:value-of select="$docid" />
  version: <xsl:value-of select="$version" />
  filename: <xsl:value-of select="$filename" />
  targetid: <xsl:value-of select="$targetid" />
  </xsl:message> -->

  <xsl:choose>
    <xsl:when test="$docstring!=''">
      <xsl:choose>
        <xsl:when test="contains($docstring,'#')">
          <xsl:call-template name="build-doc-link">
            <xsl:with-param name="targetid" select="substring-after($docstring,'#')"/>
            <xsl:with-param name="docstring" select="substring-before($docstring,'#')"/>
            <xsl:with-param name="contents" select="$contents"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$docid=''">
            <xsl:choose>
            <xsl:when test="contains($docstring,'/')">
              <xsl:call-template name="build-doc-link">
                <xsl:with-param name="docid" select="substring-before($docstring,'/')"/>
                <xsl:with-param name="docstring" select="substring-after($docstring,'/')"/>
                <xsl:with-param name="contents" select="$contents"/>
                <xsl:with-param name="targetid" select="$targetid"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="build-doc-link">
                <xsl:with-param name="docid" select="$docstring"/>
                <xsl:with-param name="contents" select="$contents"/>
                <xsl:with-param name="targetid" select="$targetid"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise> <!-- have docid -->
            <xsl:choose>
            <xsl:when test="contains($docstring,'/')">
              <xsl:call-template name="build-doc-link">
                <xsl:with-param name="docid" select="$docid"/>
                <xsl:with-param name="version" select="substring-before($docstring,'/')"/>
                <xsl:with-param name="filename" select="substring-after($docstring,'/')"/>
                <xsl:with-param name="contents" select="$contents"/>
                <xsl:with-param name="targetid" select="$targetid"/>
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="build-doc-link">
                <xsl:with-param name="docid" select="$docid"/>
                <xsl:with-param name="version" select="$docstring"/>
                <xsl:with-param name="contents" select="$contents"/>
                <xsl:with-param name="targetid" select="$targetid"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:when>
    <xsl:otherwise>
      <link>
        <xsl:if test="$docid!=''">
          <xsl:attribute name="document"><xsl:value-of select="$docid"/></xsl:attribute>
        </xsl:if>
        <xsl:if test="$version!=''">
        <xsl:attribute name="version"><xsl:value-of select="$version"/></xsl:attribute>
        </xsl:if>
        <xsl:if test="$filename!=''">
        <xsl:attribute name="resource"><xsl:value-of select="$filename"/></xsl:attribute>
        </xsl:if>
        <xsl:if test="$targetid!=''">
        <xsl:attribute name="target-id"><xsl:value-of select="$targetid"/></xsl:attribute>
        </xsl:if>
        <xsl:apply-templates select="@id|@window|@strength"/>
        <xsl:apply-templates select="$contents"/>
      </link>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


<xsl:template match="cnxml:link">
    <xsl:choose>
      <xsl:when  test="contains(@url,'http://cnx.org/content/')">
        <xsl:call-template name="build-doc-link">
          <xsl:with-param name="docstring" select="substring-after(@url,'http://cnx.org/content/')"/>
          <xsl:with-param name="contents" select="node()"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="node()|@*"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
</xsl:template>

</xsl:stylesheet>
