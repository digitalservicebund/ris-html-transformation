<?xml version="1.0" encoding="UTF-8"?>
<!-- SLI literature documents in the V1 format (as produced by ris-literature).
     Renders the titles, the Gliederung, the Dokumenttypen, the Bearbeiter, the Begründer, the
     Herausgeber (Personen and Institutionen), the Ausgabe, the Gesamtfußnoten and the Aktivzitierungen
     Rechtsprechung, unselbstständige and selbstständige Literatur for now. -->
<xsl:stylesheet version="2.0"
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:akn="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
				xmlns:ris="http://rechtsinformationen.bund.de/schema/ris/0.1"
				exclude-result-prefixes="akn ris">

	<xsl:include href="literature.xslt"/>

	<!-- ================================================================
	     SLI-specific section visibility parameters — set to false() to hide a section.
	     The shared ones are defined in literature.xslt.
	     ================================================================ -->
	<xsl:param name="show-ausgabe"                                    select="true()"/>
	<xsl:param name="show-bearbeiter"                                 select="true()"/>
	<xsl:param name="show-begruender"                                 select="true()"/>
	<xsl:param name="show-herausgeber"                                select="true()"/>
	<xsl:param name="show-fussnoten"                                  select="true()"/>

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

	<!-- render metadata lists as <template> blocks in the html head -->
	<xsl:template name="metadata">
		<xsl:call-template name="dokumenttypen"/>
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
		<!-- Herausgeber combine the herausgebende Personen and Institutionen in one list, persons
		     first. Both are rendered with their name only: persons as "Vorname Nachname",
		     institutions as they come. -->
		<xsl:variable name="herausgeberPersonen" select="$risMeta/ris:herausgeberPersonen/ris:herausgeberPerson[normalize-space()]"/>
		<xsl:variable name="herausgeberInstitutionen" select="$risMeta/ris:herausgeberInstitutionen/ris:herausgeberInstitution[normalize-space()]"/>
		<xsl:if test="$show-herausgeber and ($herausgeberPersonen or $herausgeberInstitutionen)">
			<template id="herausgeber">
				<ul>
					<xsl:for-each select="$herausgeberPersonen">
						<li><xsl:call-template name="render-person-name"/></li>
					</xsl:for-each>
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
</xsl:stylesheet>
