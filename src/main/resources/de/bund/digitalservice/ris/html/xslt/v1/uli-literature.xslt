<?xml version="1.0" encoding="UTF-8"?>
<!-- ULI literature documents in the V1 format (as produced by ris-literature). -->
<xsl:stylesheet version="2.0"
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:akn="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
				xmlns:ris="http://rechtsinformationen.bund.de/schema/ris/0.1"
				exclude-result-prefixes="akn ris">

	<xsl:include href="literature.xslt"/>

	<!-- Titles in order of priority: the first one is the main title, the others are
	     rendered as additional titles. -->
	<xsl:variable name="titles" as="node()*" select="(
		$work/akn:FRBRalias[@name='haupttitel']/@value,
		$work/akn:FRBRalias[@name='dokumentarischerTitel']/@value,
		$work/akn:FRBRalias[@name='haupttitelzusatz']/@value)"/>

	<xsl:template match="akn:doc">
		<html lang="de">
			<head>
				<meta charset="utf-8"/>
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
		<xsl:call-template name="verfasser"/>
		<xsl:call-template name="mitarbeiter"/>
		<xsl:call-template name="urheber"/>
		<xsl:call-template name="veroeffentlichungsjahre"/>
		<xsl:call-template name="reference-list">
			<xsl:with-param name="id" select="'fundstelle'"/>
			<xsl:with-param name="references" select="$refs/akn:implicitReference/ris:fundstelle"/>
			<xsl:with-param name="format" select="'fundstelle'"/>
		</xsl:call-template>
		<xsl:variable name="fundstellenSelbststaendig" select="$refs/akn:implicitReference/ris:fundstelleSelbststaendig[normalize-space()]"/>
		<xsl:if test="$fundstellenSelbststaendig">
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
