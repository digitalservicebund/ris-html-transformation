<?xml version="1.0" encoding="UTF-8"?>
<!-- ULI literature documents in the V1 format (as produced by ris-literature).
     Renders the titles, the Gliederung, the Dokumenttypen, the Fundstellen, the Fundstellen in
     selbstständiger Literatur and the Aktivzitierungen Rechtsprechung, unselbstständige and
     selbstständige Literatur for now. -->
<xsl:stylesheet version="2.0"
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:akn="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
				xmlns:ris="http://rechtsinformationen.bund.de/schema/ris/0.1"
				exclude-result-prefixes="akn ris">

	<xsl:output method="html" encoding="UTF-8" indent="yes"/>

	<xsl:strip-space elements="*"/>

	<xsl:include href="../references.xslt"/>

	<!-- ================================================================
	     Section visibility parameters — set to false() to hide a section.
	     ================================================================ -->
	<xsl:param name="show-haupttitel"                                 select="true()"/>
	<xsl:param name="show-zusaetzliche-titel"                         select="true()"/>
	<xsl:param name="show-gliederung"                                 select="true()"/>
	<xsl:param name="show-dokumenttyp"                                select="true()"/>
	<xsl:param name="show-fundstelle"                                 select="true()"/>
	<xsl:param name="show-fundstelle-selbststaendig"                  select="true()"/>
	<xsl:param name="show-aktivzitierung-rechtsprechung"              select="true()"/>
	<xsl:param name="show-aktivzitierung-unselbststaendige-literatur" select="true()"/>
	<xsl:param name="show-aktivzitierung-selbststaendige-literatur"   select="true()"/>

	<xsl:variable name="work" select="/akn:akomaNtoso/akn:doc/akn:meta/akn:identification/akn:FRBRWork"/>
	<xsl:variable name="refs" select="/akn:akomaNtoso/akn:doc/akn:meta/akn:analysis/akn:otherReferences"/>
	<xsl:variable name="risMeta" select="/akn:akomaNtoso/akn:doc/akn:meta/akn:proprietary/ris:meta"/>

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
			</body>
		</html>
	</xsl:template>

	<!-- render titles -->
	<xsl:template name="titles">
		<xsl:if test="$show-haupttitel and $titles[1]">
			<h1><xsl:value-of select="$titles[1]"/></h1>
		</xsl:if>
		<xsl:if test="$show-zusaetzliche-titel and $titles[2]">
			<section id="zusaetzliche-titel">
				<h2>Zusätzliche Titel</h2>
				<xsl:for-each select="$titles[position() > 1]">
					<p><xsl:value-of select="."/></p>
				</xsl:for-each>
			</section>
		</xsl:if>
	</xsl:template>

	<!-- render gliederung (outline) as a section, one li per non-blank gliederungseintrag -->
	<xsl:template name="gliederung">
		<xsl:variable name="eintraege" select="$risMeta/ris:gliederung/ris:gliederungseintrag[normalize-space()]"/>
		<xsl:if test="$show-gliederung and $eintraege">
			<section id="gliederung">
				<h2>Gliederung</h2>
				<ul>
					<xsl:for-each select="$eintraege">
						<li><xsl:value-of select="normalize-space(.)"/></li>
					</xsl:for-each>
				</ul>
			</section>
		</xsl:if>
	</xsl:template>

	<!-- render metadata lists as <template> blocks in the html head -->
	<xsl:template name="metadata">
		<xsl:if test="$show-dokumenttyp and $risMeta/ris:dokumenttypen/ris:dokumenttyp[normalize-space()]">
			<template id="dokumenttypen">
				<ul>
					<xsl:for-each select="$risMeta/ris:dokumenttypen/ris:dokumenttyp[normalize-space()]">
						<li><xsl:value-of select="normalize-space(.)"/></li>
					</xsl:for-each>
				</ul>
			</template>
		</xsl:if>
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

	<!-- render references as <template> blocks in the html head -->
	<xsl:template name="references">
		<xsl:if test="$show-aktivzitierung-rechtsprechung">
			<xsl:call-template name="reference-list">
				<xsl:with-param name="id" select="'referenzRechtsprechungAktiv'"/>
				<xsl:with-param name="references" select="$refs/akn:implicitReference/ris:referenzRechtsprechung[ris:richtung = 'aktiv']"/>
				<xsl:with-param name="linkBasePath" select="'/gerichtsentscheidungen/'"/>
				<xsl:with-param name="format" select="'rechtsprechung'"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="$show-aktivzitierung-unselbststaendige-literatur">
			<xsl:call-template name="reference-list">
				<xsl:with-param name="id" select="'referenzUnselbststaendigeLiteraturAktiv'"/>
				<xsl:with-param name="references" select="$refs/akn:implicitReference/ris:referenzUnselbststaendigeLiteratur[ris:richtung = 'aktiv']"/>
				<xsl:with-param name="linkBasePath" select="'/literaturnachweise/'"/>
				<xsl:with-param name="format" select="'uli'"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="$show-aktivzitierung-selbststaendige-literatur">
			<xsl:call-template name="reference-list">
				<xsl:with-param name="id" select="'referenzSelbststaendigeLiteraturAktiv'"/>
				<xsl:with-param name="references" select="$refs/akn:implicitReference/ris:referenzSelbststaendigeLiteratur[ris:richtung = 'aktiv']"/>
				<xsl:with-param name="linkBasePath" select="'/literaturnachweise/'"/>
				<xsl:with-param name="format" select="'sli'"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<xsl:template match="text()"/>
</xsl:stylesheet>
