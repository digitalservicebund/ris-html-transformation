<?xml version="1.0" encoding="UTF-8"?>
<!-- SLI literature documents in the V1 format (as produced by ris-literature).
     Renders the titles, the Gliederung, the Dokumenttypen, the Bearbeiter, the Begründer, the
     Herausgeber (Institutionen), the Ausgabe, the Gesamtfußnoten and the Aktivzitierungen
     Rechtsprechung, unselbstständige and selbstständige Literatur for now. -->
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
	<xsl:param name="show-ausgabe"                                    select="true()"/>
	<xsl:param name="show-bearbeiter"                                 select="true()"/>
	<xsl:param name="show-begruender"                                 select="true()"/>
	<xsl:param name="show-herausgeber"                                select="true()"/>
	<xsl:param name="show-fussnoten"                                  select="true()"/>
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
				<xsl:call-template name="metadata"/>
				<xsl:call-template name="references"/>
			</head>
			<body>
				<xsl:call-template name="titles"/>
				<xsl:call-template name="gliederung"/>
				<xsl:call-template name="ausgabe"/>
				<xsl:call-template name="fussnoten"/>
			</body>
		</html>
	</xsl:template>

	<!-- render titles -->
	<xsl:template name="titles">
		<xsl:if test="$show-haupttitel and $titles[1]">
			<h1>
				<xsl:call-template name="render-title">
					<xsl:with-param name="node" select="$titles[1]"/>
				</xsl:call-template>
			</h1>
		</xsl:if>
		<xsl:if test="$show-zusaetzliche-titel and $titles[2]">
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
		<xsl:if test="$show-bearbeiter">
			<xsl:call-template name="person-list">
				<xsl:with-param name="id" select="'bearbeiter'"/>
				<xsl:with-param name="persons" select="$risMeta/ris:bearbeiterListe/ris:bearbeiter"/>
			</xsl:call-template>
		</xsl:if>
		<xsl:if test="$show-begruender">
			<xsl:call-template name="person-list">
				<xsl:with-param name="id" select="'begruender'"/>
				<xsl:with-param name="persons" select="$risMeta/ris:begruenderListe/ris:begruender"/>
			</xsl:call-template>
		</xsl:if>
		<!-- Herausgeber are rendered with their name only -->
		<xsl:variable name="herausgeberInstitutionen" select="$risMeta/ris:herausgeberInstitutionen/ris:herausgeberInstitution[normalize-space()]"/>
		<xsl:if test="$show-herausgeber and $herausgeberInstitutionen">
			<template id="herausgeberInstitutionen">
				<ul>
					<xsl:for-each select="$herausgeberInstitutionen">
						<li><xsl:value-of select="normalize-space(.)"/></li>
					</xsl:for-each>
				</ul>
			</template>
		</xsl:if>
	</xsl:template>

	<!-- Builds a template block (identified by $id) containing one ul of the given persons, with
	     each non-blank person name rendered as a li. -->
	<xsl:template name="person-list">
		<xsl:param name="id"/>
		<xsl:param name="persons"/>
		<xsl:if test="$persons[normalize-space()]">
			<template id="{$id}">
				<ul>
					<xsl:for-each select="$persons[normalize-space()]">
						<li><xsl:call-template name="render-person-name"/></li>
					</xsl:for-each>
				</ul>
			</template>
		</xsl:if>
	</xsl:template>

	<!-- Person names come as "Nachname, Vorname" and are rendered as "Vorname Nachname".
	     Names without a comma are rendered as they are. -->
	<xsl:template name="render-person-name">
		<xsl:choose>
			<xsl:when test="contains(., ',')">
				<xsl:value-of select="normalize-space(concat(substring-after(., ','), ' ', substring-before(., ',')))"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="normalize-space(.)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- render ausgabe -->
	<xsl:template name="ausgabe">
		<xsl:if test="$show-ausgabe and normalize-space($risMeta/ris:ausgabe)">
			<section id="ausgabe">
				<h2>Ausgabe</h2>
				<p><xsl:value-of select="$risMeta/ris:ausgabe"/></p>
			</section>
		</xsl:if>
	</xsl:template>

	<!-- render gesamtfussnoten as a dedicated section at the end of the document.
	  Gesamtfussnoten have no marker in the text, so each one is rendered as a plain paragraph. -->
	<xsl:template name="fussnoten">
		<xsl:variable name="fussnoten" select="$risMeta/ris:gesamtfussnoten/ris:gesamtfussnote[normalize-space()]"/>
		<xsl:if test="$show-fussnoten and $fussnoten">
			<section id="fussnoten">
				<h2>Fußnoten</h2>
				<xsl:for-each select="$fussnoten">
					<p><xsl:value-of select="normalize-space(.)"/></p>
				</xsl:for-each>
			</section>
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
