<?xml version="1.0" encoding="UTF-8"?>
<!-- SLI literature documents in the V1 format (as produced by ris-literature).
     Renders only the titles for now. -->
<xsl:stylesheet version="2.0"
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:akn="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
				xmlns:ris="http://rechtsinformationen.bund.de/schema/ris/0.1"
				exclude-result-prefixes="akn ris">

	<xsl:output method="html" encoding="UTF-8" indent="yes"/>

	<xsl:strip-space elements="*"/>

	<xsl:variable name="work" select="/akn:akomaNtoso/akn:doc/akn:meta/akn:identification/akn:FRBRWork"/>

	<!-- Titles in order of priority: the first one is the main title, the others are
	     rendered as additional titles. -->
	<xsl:variable name="titles" as="node()*" select="(
		$work/akn:FRBRalias[@name='haupttitel']/@value,
		$work/akn:FRBRalias[@name='dokumentarischerTitel']/@value,
		$work/akn:FRBRalias[@name='haupttitelzusatz']/@value,
		//ris:titelkurzformen/ris:titelkurzform,
		//ris:gesamttitelangaben/ris:gesamttitel,
		//ris:sonstigerSachtitelListe/ris:sonstigerSachtitel)"/>

	<xsl:template match="akn:doc">
		<html lang="de">
			<head>
				<title>
					<xsl:call-template name="render-title">
						<xsl:with-param name="node" select="$titles[1]"/>
					</xsl:call-template>
				</title>
			</head>
			<body>
				<xsl:call-template name="titles"/>
			</body>
		</html>
	</xsl:template>

	<!-- render titles -->
	<xsl:template name="titles">
		<xsl:if test="$titles[1]">
			<h1>
				<xsl:call-template name="render-title">
					<xsl:with-param name="node" select="$titles[1]"/>
				</xsl:call-template>
			</h1>
		</xsl:if>
		<xsl:if test="$titles[2]">
			<section id="zusaetzliche-titel">
				<h2>Zusätzliche Titel</h2>
				<xsl:for-each select="$titles[position() > 1]">
					<p>
						<xsl:call-template name="render-title">
							<xsl:with-param name="node" select="."/>
						</xsl:call-template>
					</p>
				</xsl:for-each>
			</section>
		</xsl:if>
	</xsl:template>

	<xsl:template name="render-title">
		<xsl:param name="node"/>
		<xsl:choose>
			<xsl:when test="$node[self::ris:gesamttitel]">
				<xsl:value-of select="string-join(($node/ris:titel, $node/ris:bandbezeichnung)[normalize-space()], ' ')"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$node"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="text()"/>
</xsl:stylesheet>
