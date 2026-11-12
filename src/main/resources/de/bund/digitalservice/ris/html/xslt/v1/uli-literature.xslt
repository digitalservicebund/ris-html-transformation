<?xml version="1.0" encoding="UTF-8"?>
<!-- ULI literature documents in the V1 format (as produced by ris-literature).
     Renders the titles, the Gliederung, the Dokumenttypen, the Mitarbeiter, the Fundstellen, the Fundstellen in
     selbstständiger Literatur, the Kurzreferat, the Normen and the Aktivzitierungen Rechtsprechung, unselbstständige and
     selbstständige Literatur for now. -->
<xsl:stylesheet version="2.0"
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:akn="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
				xmlns:ris="http://rechtsinformationen.bund.de/schema/ris/0.1"
				exclude-result-prefixes="akn ris">

	<xsl:include href="literature.xslt"/>

	<!-- ================================================================
	     ULI-specific section visibility parameters — set to false() to hide a section.
	     The shared ones are defined in literature.xslt.
	     ================================================================ -->
	<xsl:param name="show-fundstelle"                                 select="true()"/>
	<xsl:param name="show-fundstelle-selbststaendig"                  select="true()"/>

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
				<xsl:call-template name="metadata"/>
				<xsl:call-template name="references"/>
			</head>
			<body>
				<xsl:call-template name="titles"/>
				<xsl:call-template name="gliederung"/>
				<xsl:call-template name="kurzreferat"/>
			</body>
		</html>
	</xsl:template>

	<!-- render metadata lists as <template> blocks in the html head -->
	<xsl:template name="metadata">
		<xsl:call-template name="dokumenttypen"/>
		<xsl:call-template name="mitarbeiter"/>
		<xsl:if test="$show-fundstelle">
			<xsl:call-template name="reference-list">
				<xsl:with-param name="id" select="'fundstelle'"/>
				<xsl:with-param name="references" select="$refs/akn:implicitReference/ris:fundstelle"/>
				<xsl:with-param name="format" select="'fundstelle'"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:variable name="fundstellenSelbststaendig" select="$refs/akn:implicitReference/ris:fundstelleSelbststaendig[normalize-space()]"/>
		<xsl:if test="$show-fundstelle-selbststaendig and $fundstellenSelbststaendig">
			<template id="fundstelleSelbststaendig">
				<ul>
					<xsl:for-each select="$fundstellenSelbststaendig">
						<li><xsl:value-of select="string-join((ris:titel, ris:zitatstelle)[normalize-space()], ' ')"/></li>
					</xsl:for-each>
				</ul>
			</template>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
