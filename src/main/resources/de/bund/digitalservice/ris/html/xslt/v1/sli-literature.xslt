<?xml version="1.0" encoding="UTF-8"?>
<!-- SLI literature documents in the V1 format (as produced by ris-literature).
     Renders the titles, the Gliederung, the Dokumenttypen, the Bearbeiter, the Mitarbeiter, the Begründer, the
     Herausgeber (Personen and Institutionen), the Urheber, the Hochschulschriftenvermerke, the Bestellnummern (ISBN, ISSN, …), the Kongressvermerke, the Kurzreferat, the Teilbände, the Ausgabe, the Gesamtfußnoten, the Normen and the Aktivzitierungen
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
	<xsl:param name="show-hochschulschriftenvermerke"                 select="true()"/>
	<xsl:param name="show-bestellnummer"                              select="true()"/>
	<xsl:param name="show-kongressvermerke"                           select="true()"/>
	<xsl:param name="show-teilbaende"                                 select="true()"/>
	<xsl:param name="show-fussnoten"                                  select="true()"/>

	<!-- Organisations (Hochschulen, Verlage, Institutionen) referenced from the role lists via refersTo -->
	<xsl:key name="organisation" match="ris:organisationen/ris:organisation" use="concat('#', @eId)"/>
	<!-- Kongresse referenced from the Kongressvermerke via refersTo -->
	<xsl:key name="kongress" match="ris:kongresse/ris:kongress" use="concat('#', @eId)"/>

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
				<xsl:call-template name="kurzreferat"/>
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
		<xsl:call-template name="mitarbeiter"/>
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
		<xsl:call-template name="urheber"/>
		<!-- Hochschulschriftenvermerke are rendered as "Name, Jahr". The Jahr is taken from the
		     referenced organisation; without it (or without the organisation) only the name is rendered. -->
		<xsl:variable name="hochschulschriftenvermerke" select="$risMeta/ris:hochschulschriftenvermerke/ris:hochschulschriftenvermerk[normalize-space()]"/>
		<xsl:if test="$show-hochschulschriftenvermerke and $hochschulschriftenvermerke">
			<template id="hochschulschriftenvermerke">
				<ul>
					<xsl:for-each select="$hochschulschriftenvermerke">
						<xsl:variable name="hochschule" select="key('organisation', @refersTo)[1]"/>
						<li><xsl:value-of select="string-join((normalize-space(.), normalize-space($hochschule/ris:jahr))[. != ''], ', ')"/></li>
					</xsl:for-each>
				</ul>
			</template>
		</xsl:if>
		<!-- Bestellnummern (ISBN, ISSN, …) are the FRBRaliases of the FRBRManifestation. Their value
		     already contains the type prefix (e.g. "ISBN 3-920645-41-3"), so it is rendered as it comes. -->
		<xsl:variable name="bestellnummern" select="/akn:akomaNtoso/akn:doc/akn:meta/akn:identification/akn:FRBRManifestation/akn:FRBRalias[normalize-space(@value)]"/>
		<xsl:if test="$show-bestellnummer and $bestellnummern">
			<template id="bestellnummern">
				<ul>
					<xsl:for-each select="$bestellnummern">
						<li><xsl:value-of select="normalize-space(@value)"/></li>
					</xsl:for-each>
				</ul>
			</template>
		</xsl:if>
		<!-- Teilbände come as ready-made strings (e.g. "Bd 1. Allgemeiner Teil, 2019, 512 S") and are rendered as they are -->
		<xsl:variable name="teilbaende" select="$risMeta/ris:teilbaende/ris:teilband[normalize-space()]"/>
		<xsl:if test="$show-teilbaende and $teilbaende">
			<template id="teilbaende">
				<ul>
					<xsl:for-each select="$teilbaende">
						<li><xsl:value-of select="normalize-space(.)"/></li>
					</xsl:for-each>
				</ul>
			</template>
		</xsl:if>
		<!-- Kongressvermerke are rendered as "Name, Jahr, Ort, Land" from the referenced Kongress,
		     leaving out the parts that are missing. Without a referenced Kongress only the name is rendered. -->
		<xsl:variable name="kongressvermerke" select="$risMeta/ris:kongressvermerke/ris:kongressvermerk[normalize-space()]"/>
		<xsl:if test="$show-kongressvermerke and $kongressvermerke">
			<template id="kongressvermerke">
				<ul>
					<xsl:for-each select="$kongressvermerke">
						<xsl:variable name="kongress" select="key('kongress', @refersTo)[1]"/>
						<li><xsl:value-of select="string-join((normalize-space(.), $kongress/(ris:jahr, ris:ort, ris:land)/normalize-space())[. != ''], ', ')"/></li>
					</xsl:for-each>
				</ul>
			</template>
		</xsl:if>
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
