<?xml version="1.0" encoding="UTF-8"?>
<!-- ULI literature documents in the V1 format (as produced by ris-literature).
     Renders only the titles for now. -->
<xsl:stylesheet version="2.0"
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:akn="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
				exclude-result-prefixes="akn">

	<xsl:output method="html" encoding="UTF-8" indent="yes"/>

	<xsl:strip-space elements="*"/>

	<xsl:variable name="work" select="/akn:akomaNtoso/akn:doc/akn:meta/akn:identification/akn:FRBRWork"/>

	<!-- Titles in order of priority: the first one is the main title, the others are
	     rendered as additional titles. -->
	<xsl:variable name="titles" as="node()*" select="(
		$work/akn:FRBRalias[@name='haupttitel']/@value,
		$work/akn:FRBRalias[@name='dokumentarischerTitel']/@value,
		$work/akn:FRBRalias[@name='haupttitelzusatz']/@value)"/>

	<xsl:template match="akn:doc">
		<html lang="de">
			<head>
				<title><xsl:value-of select="$titles[1]"/></title>
			</head>
			<body>
				<xsl:call-template name="titles"/>
			</body>
		</html>
	</xsl:template>

	<!-- render titles -->
	<xsl:template name="titles">
		<xsl:if test="$titles[1]">
			<h1><xsl:value-of select="$titles[1]"/></h1>
		</xsl:if>
		<xsl:if test="$titles[2]">
			<section id="zusaetzliche-titel">
				<h2>Zusätzliche Titel</h2>
				<xsl:for-each select="$titles[position() > 1]">
					<p><xsl:value-of select="."/></p>
				</xsl:for-each>
			</section>
		</xsl:if>
	</xsl:template>

	<xsl:template match="text()"/>
</xsl:stylesheet>
