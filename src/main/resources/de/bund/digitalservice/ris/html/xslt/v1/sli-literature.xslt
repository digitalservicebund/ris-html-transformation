<?xml version="1.0" encoding="UTF-8"?>
<!-- SLI literature documents in the V1 format (as produced by ris-literature) -->
<xsl:stylesheet version="2.0"
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:akn="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
				xmlns:ris="http://rechtsinformationen.bund.de/schema/ris/0.1"
				exclude-result-prefixes="akn ris">

	<xsl:include href="literature.xslt"/>

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
				<meta charset="utf-8"/>
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
				<xsl:call-template name="fussnoten"/>
			</body>
		</html>
	</xsl:template>

	<!-- render metadata lists as <template> blocks in the html head -->
	<xsl:template name="metadata">
		<!-- Ausgabe is a single plain value, rendered as a <meta> -->
		<xsl:if test="normalize-space($risMeta/ris:ausgabe)">
			<meta name="ausgabe" content="{normalize-space($risMeta/ris:ausgabe)}"/>
		</xsl:if>
		<xsl:call-template name="dokumenttypen"/>
		<xsl:call-template name="verfasser"/>
		<xsl:call-template name="person-list">
			<xsl:with-param name="id" select="'bearbeiterListe'"/>
			<xsl:with-param name="persons" select="$risMeta/ris:bearbeiterListe/ris:bearbeiter"/>
		</xsl:call-template>
		<xsl:call-template name="mitarbeiter"/>
		<xsl:call-template name="person-list">
			<xsl:with-param name="id" select="'begruenderListe'"/>
			<xsl:with-param name="persons" select="$risMeta/ris:begruenderListe/ris:begruender"/>
		</xsl:call-template>
		<!-- Herausgebende Personen are rendered as "Vorname Nachname", herausgebende Institutionen
		     with their name only, as they come. -->
		<xsl:call-template name="person-list">
			<xsl:with-param name="id" select="'herausgeberPersonen'"/>
			<xsl:with-param name="persons" select="$risMeta/ris:herausgeberPersonen/ris:herausgeberPerson"/>
		</xsl:call-template>
		<xsl:variable name="herausgeberInstitutionen" select="$risMeta/ris:herausgeberInstitutionen/ris:herausgeberInstitution[normalize-space()]"/>
		<xsl:if test="$herausgeberInstitutionen">
			<template id="herausgeberInstitutionen">
				<ul>
					<xsl:for-each select="$herausgeberInstitutionen">
						<li><xsl:value-of select="normalize-space(.)"/></li>
					</xsl:for-each>
				</ul>
			</template>
		</xsl:if>
		<xsl:call-template name="urheber"/>
		<!-- Verlagsangaben are rendered as "Name, Ort". -->
		<xsl:variable name="verlagsangaben" select="$risMeta/ris:verlagsangaben/ris:verlagsangabe[normalize-space()]"/>
		<xsl:if test="$verlagsangaben">
			<template id="verlagsangaben">
				<ul>
					<xsl:for-each select="$verlagsangaben">
						<xsl:variable name="verlag" select="key('organisation', @refersTo)[1]"/>
						<li><xsl:value-of select="string-join((normalize-space(.), normalize-space($verlag/ris:ort))[. != ''], ', ')"/></li>
					</xsl:for-each>
				</ul>
			</template>
		</xsl:if>
		<xsl:call-template name="veroeffentlichungsjahre"/>
		<!-- Hochschulschriftenvermerke are rendered as "Name, Jahr". -->
		<xsl:variable name="hochschulschriftenvermerke" select="$risMeta/ris:hochschulschriftenvermerke/ris:hochschulschriftenvermerk[normalize-space()]"/>
		<xsl:if test="$hochschulschriftenvermerke">
			<template id="hochschulschriftenvermerke">
				<ul>
					<xsl:for-each select="$hochschulschriftenvermerke">
						<xsl:variable name="hochschule" select="key('organisation', @refersTo)[1]"/>
						<li><xsl:value-of select="string-join((normalize-space(.), normalize-space($hochschule/ris:jahr))[. != ''], ', ')"/></li>
					</xsl:for-each>
				</ul>
			</template>
		</xsl:if>
		<!-- Bestellnummern (ISBN, ISSN, …) are the FRBRaliases of the FRBRManifestation. -->
		<xsl:variable name="bestellnummern" select="/akn:akomaNtoso/akn:doc/akn:meta/akn:identification/akn:FRBRManifestation/akn:FRBRalias[normalize-space(@value)]"/>
		<xsl:if test="$bestellnummern">
			<template id="bestellnummern">
				<ul>
					<xsl:for-each select="$bestellnummern">
						<li><xsl:value-of select="normalize-space(@value)"/></li>
					</xsl:for-each>
				</ul>
			</template>
		</xsl:if>
		<!-- Teilbände come as ready-made strings and are rendered as they are -->
		<xsl:variable name="teilbaende" select="$risMeta/ris:teilbaende/ris:teilband[normalize-space()]"/>
		<xsl:if test="$teilbaende">
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
		<xsl:if test="$kongressvermerke">
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

	<!-- render gesamtfussnoten as a dedicated section at the end of the document.
	  Gesamtfussnoten have no marker in the text, so each one is rendered as a plain paragraph. -->
	<xsl:template name="fussnoten">
		<xsl:variable name="fussnoten" select="$risMeta/ris:gesamtfussnoten/ris:gesamtfussnote[normalize-space()]"/>
		<xsl:if test="$fussnoten">
			<section id="gesamtfussnoten">
				<h2>Fußnoten</h2>
				<xsl:for-each select="$fussnoten">
					<p><xsl:value-of select="normalize-space(.)"/></p>
				</xsl:for-each>
			</section>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
