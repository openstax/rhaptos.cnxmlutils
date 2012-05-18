<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:col="http://cnx.rice.edu/collxml"
  xmlns:md="http://cnx.rice.edu/mdml"
  xmlns:xi='http://www.w3.org/2001/XInclude'
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="col md"
  >
<xsl:include href="cnxml2xhtml.xsl"/>

<xsl:param name="cnx.cover.image">cover.png</xsl:param>
<xsl:param name="cnx.cover.format">image/png</xsl:param>

<xsl:output indent="yes"/>

<xsl:template match="col:*/@*">
	<xsl:copy/>
</xsl:template>

<xsl:template match="col:collection">
	<xsl:variable name="url">
		<xsl:value-of select="col:metadata/md:content-url/text()"/>
	</xsl:variable>
	<xsl:variable name="id">
		<xsl:value-of select="col:metadata/md:content-id/text()"/>
	</xsl:variable>
	<html>
  <head><link rel="stylesheet" href="css/ccap-physics-xhtml.css"/></head>
	<body data-url="{col:metadata/md:content-url/text()}" data-id="{col:metadata/md:content-id/text()}" data-repository="{col:metadata/md:repository/text()}">
		<xsl:apply-templates select="@*|node()"/>
	</body>
	</html>
</xsl:template>

<xsl:template match="col:*">
  <xsl:comment>TODO: "col:<xsl:value-of select="local-name()"/>" not implemented yet</xsl:comment>
</xsl:template>

<xsl:template match="col:metadata">
	<header>
		<!-- Add in the cover page image. Used by dbk2epub.xsl -->
		<img class="cover" src="{$cnx.cover.image}" data-mime-type="{$cnx.cover.format}" />
    <xsl:comment>TODO: "col:<xsl:value-of select="local-name()"/>" not implemented yet</xsl:comment>
	</header>
</xsl:template>

<!-- Modules before the first subcollection are preface frontmatter -->
<xsl:template match="col:collection/col:content[col:subcollection and col:module]/col:module[not(preceding-sibling::col:subcollection)]" priority="100">
	<section class="preface">
    <xsl:apply-templates select="@*"/>
    <header>
      <xsl:apply-templates select="node()"/>
    </header>
		<xsl:call-template name="cnx.xinclude.module"/>
	</section>
</xsl:template>

<!-- Modules after the last subcollection are appendices -->
<xsl:template match="col:collection/col:content[col:subcollection and col:module]/col:module[not(following-sibling::col:subcollection)]" priority="100">
  <section class="appendix">
    <xsl:apply-templates select="@*"/>
    <header>
      <xsl:apply-templates select="node()"/>
    </header>
      <xsl:call-template name="cnx.xinclude.module"/>
  </section>
</xsl:template>


<!-- Free-floating Modules in a col:collection should be treated as Chapters -->
<xsl:template match="col:collection/col:content/col:module"> 
	<!-- TODO: Convert the db:section root of the module to a chapter. Can't now because we create xinclude refs to it -->
	<section class="chapter">
    <xsl:apply-templates select="@*"/>
    <header>
      <xsl:apply-templates select="node()"/>
    </header>
		<xsl:call-template name="cnx.xinclude.module"/>
	</section>
</xsl:template>

<xsl:template match="col:collection/col:content/col:subcollection">
	<section class="chapter"><xsl:apply-templates select="@*|node()"/></section>
</xsl:template>

<!-- Subcollections in a chapter should be treated as a section -->
<xsl:template match="col:subcollection/col:content/col:subcollection">
	<section><xsl:apply-templates select="@*|node()"/></section>
</xsl:template>

<xsl:template match="col:content">
	<xsl:apply-templates/>
</xsl:template>

<xsl:template match="col:module">
    <section>
        <xsl:apply-templates select="@*"/>
        <header>
          <xsl:apply-templates select="node()"/>
        </header>
        <xsl:call-template name="cnx.xinclude.module"/>
    </section>
</xsl:template>


<xsl:template match="md:title">
	<h2 class="title"><xsl:apply-templates/></h2>
</xsl:template>



<xsl:template match="@id|@xml:id|comment()|processing-instruction()">
    <xsl:copy/>
</xsl:template>

<xsl:template name="cnx.xinclude.module">
  <xsl:variable name="href">
    <xsl:value-of select="@document"/>
    <xsl:if test="@version != 'latest'">
      <xsl:text>@</xsl:text>
      <xsl:value-of select="@version"/>
    </xsl:if>
  </xsl:variable>
  <a class="include" href="{@document}">xinclude "<xsl:value-of select="@document"/>"</a>
</xsl:template>


</xsl:stylesheet>
