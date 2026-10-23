<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:akn="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
                xmlns:ris="http://rechtsinformationen.bund.de/schema/ris/0.1"
                xmlns:local="http://rechtsinformationen.bund.de/schema/ris/0.1"
                exclude-result-prefixes="xs akn ris local xsi"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xsi:schemaLocation="http://docs.oasis-open.org/legaldocml/ns/akn/3.0 https://docs.oasis-open.org/legaldocml/akn-core/v2.0/cs01/part2-specs/schemas/akomantoso30.xsd">

	<xsl:output method="html" encoding="UTF-8" indent="yes" />

	<xsl:include href="references.xslt" />

	<xsl:param name="ressourcenpfad" as="xs:string" select="''"/>

	<!-- ================================================================
	     Section visibility parameters — set to false() to hide a section.
	     ================================================================ -->
	<xsl:param name="show-aktenzeichen"                  select="true()"/>
	<xsl:param name="show-aktivverweisung"               select="true()"/>
	<xsl:param name="show-aktivzitierung-rechtsprechung" select="true()"/>
	<xsl:param name="show-anwendungszeitraum"            select="true()"/>
	<xsl:param name="show-amtliche-langueberschrift"     select="true()"/>
	<xsl:param name="show-ausserkrafttretedatum"         select="true()"/>
	<xsl:param name="show-definitionen"                  select="false()"/>
	<xsl:param name="show-dokumentnummer"                select="false()"/>
	<xsl:param name="show-dokumenttyp"                   select="true()"/>
	<xsl:param name="show-erstveroeffentlichung"         select="false()"/>
	<xsl:param name="show-fundstelle"                    select="true()"/>
	<xsl:param name="show-inkrafttretedatum"             select="true()"/>
	<xsl:param name="show-letzte-veroeffentlichung"      select="false()"/>
	<xsl:param name="show-normgeber"                     select="true()"/>
	<xsl:param name="show-normenkette"                   select="true()"/>
	<xsl:param name="show-risAbkuerzung"                 select="false()"/>
	<xsl:param name="show-sachgebiete"                   select="false()"/>
	<xsl:param name="show-schlagwoerter"                 select="false()"/>
	<xsl:param name="show-zitierdatum"                   select="true()"/>

	<!-- ================================================================
	     Root
	     ================================================================ -->
	<xsl:template match="akn:doc">
		<!-- FRBR -->
		<xsl:variable name="frbr"                 select="akn:meta/akn:identification"/>
		<xsl:variable name="doknr"                select="$frbr/akn:FRBRWork/akn:FRBRalias[@name='dokumentnummer']/@value"/>
		<xsl:variable name="titel"                select="$frbr/akn:FRBRWork/akn:FRBRalias[@name='langueberschrift']/@value"/>
		<xsl:variable name="zitierdatum"           select="$frbr/akn:FRBRExpression/akn:FRBRdate[@name='zitierdatum']/@date"/>
		<xsl:variable name="letzteVeroeffentlichung" select="$frbr/akn:FRBRManifestation/akn:FRBRdate[@name='letzteVeroeffentlichung']/@date"/>
		<xsl:variable name="erstveroeffentlichung" select="$frbr/akn:FRBRManifestation/akn:FRBRdate[@name='erstveroeffentlichung']/@date"/>
		<!-- Metadata -->
		<xsl:variable name="risMeta"  select="akn:meta/akn:proprietary/ris:meta"/>
		<!-- References -->
		<xsl:variable name="refs" select="akn:meta/akn:analysis/akn:otherReferences"/>

		<html lang="de">
			<head>
				<meta charset="utf-8"/>

				<!-- Title -->
				<xsl:if test="$titel != '' and $show-amtliche-langueberschrift">
					<title>
						<xsl:value-of select="$titel"/>
					</title>
					<meta name="amtliche-langueberschrift" content="{$titel}"/>
				</xsl:if>

				<!-- Scalar FRBR fields -->
				<xsl:if test="$show-dokumentnummer and $doknr != ''">
					<meta name="dokumentnummer" content="{$doknr}"/>
				</xsl:if>

				<xsl:if test="$show-erstveroeffentlichung and $erstveroeffentlichung != ''">
					<meta name="erstveroeffentlichung" content="{$erstveroeffentlichung}"/>
				</xsl:if>

				<xsl:if test="$show-letzte-veroeffentlichung and $letzteVeroeffentlichung != ''">
					<meta name="letzte-veroeffentlichung" content="{$letzteVeroeffentlichung}"/>
				</xsl:if>

				<xsl:if test="$show-risAbkuerzung and $risMeta/ris:risAbkuerzung != ''">
					<meta name="ris-abkuerzung" content="{$risMeta/ris:risAbkuerzung}"/>
				</xsl:if>

				<xsl:if test="$show-zitierdatum and $zitierdatum != ''">
					<meta name="zitierdatum" content="{local:format-date-short($zitierdatum)}"/>
				</xsl:if>

				<!-- Scalar risMeta fields -->
				<xsl:if test="$show-inkrafttretedatum and $risMeta/ris:inkrafttretedatum != ''">
					<meta name="inkrafttretedatum" content="{local:format-date-short($risMeta/ris:inkrafttretedatum)}"/>
				</xsl:if>

				<xsl:if test="$show-ausserkrafttretedatum and $risMeta/ris:ausserkrafttretedatum != ''">
					<meta name="ausserkrafttretedatum" content="{local:format-date-short($risMeta/ris:ausserkrafttretedatum)}"/>
				</xsl:if>

				<xsl:if test="$show-anwendungszeitraum and $risMeta/ris:anwendungszeitraum/ris:anwendungsbeginn != ''">
					<meta name="anwendungsbeginn" content="{$risMeta/ris:anwendungszeitraum/ris:anwendungsbeginn}"/>
				</xsl:if>

				<xsl:if test="$show-anwendungszeitraum and $risMeta/ris:anwendungszeitraum/ris:anwendungsende != ''">
					<meta name="anwendungsende" content="{$risMeta/ris:anwendungszeitraum/ris:anwendungsende}"/>
				</xsl:if>

				<!-- List fields as <template> blocks -->
				<xsl:if test="$show-aktenzeichen and $risMeta/ris:aktenzeichenListe">
					<template id="aktenzeichen">
						<ul>
							<xsl:for-each select="$risMeta/ris:aktenzeichenListe/ris:aktenzeichen">
								<li><xsl:value-of select="."/></li>
							</xsl:for-each>
						</ul>
					</template>
				</xsl:if>

				<xsl:if test="$show-normgeber and $risMeta/ris:normgeberListe/ris:normgeber">
					<template id="normgeber">
						<ul>
							<xsl:for-each select="$risMeta/ris:normgeberListe/ris:normgeber">
								<li>
									<abbr>
										<xsl:if test="normalize-space(ris:langbezeichnung)">
											<xsl:attribute name="title">
												<xsl:value-of select="ris:langbezeichnung"/>
											</xsl:attribute>
										</xsl:if>
										<xsl:value-of select="ris:kurzbezeichnung"/>
									</abbr>
								</li>
							</xsl:for-each>
						</ul>
					</template>
				</xsl:if>

				<xsl:if test="$show-dokumenttyp and $risMeta/ris:dokumenttypen/ris:dokumenttyp">
					<template id="dokumenttypen">
						<ul>
							<xsl:for-each select="$risMeta/ris:dokumenttypen/ris:dokumenttyp">
								<li><xsl:value-of select="."/></li>
							</xsl:for-each>
						</ul>
					</template>
				</xsl:if>

				<xsl:if test="$show-sachgebiete and $risMeta/ris:sachgebiete/ris:sachgebiet">
					<template id="sachgebiete">
						<ul>
							<xsl:for-each select="$risMeta/ris:sachgebiete/ris:sachgebiet">
								<li><xsl:value-of select="."/></li>
							</xsl:for-each>
						</ul>
					</template>
				</xsl:if>

				<xsl:if test="$show-definitionen and $risMeta/ris:definitionen/ris:definition/ris:definierterBegriff">
					<template id="definierteBegriffe">
						<ul>
							<xsl:for-each select="$risMeta/ris:definitionen/ris:definition/ris:definierterBegriff">
								<li><xsl:value-of select="."/></li>
							</xsl:for-each>
						</ul>
					</template>
				</xsl:if>

				<xsl:if test="$show-schlagwoerter and $risMeta/akn:classification/akn:keyword">
					<template id="schlagwoerter">
						<ul>
							<xsl:for-each select="$risMeta/akn:classification/akn:keyword">
								<li><xsl:value-of select="@showAs"/></li>
							</xsl:for-each>
						</ul>
					</template>
				</xsl:if>

				<!-- Reference lists -->
				<xsl:if test="$show-fundstelle">
					<xsl:call-template name="reference-list">
						<xsl:with-param name="id" select="'fundstellen'"/>
						<xsl:with-param name="references" select="$refs/akn:implicitReference[@ris:domainTerm='Fundstelle']/ris:fundstelle"/>
						<xsl:with-param name="format" select="'fundstelle'"/>
					</xsl:call-template>
				</xsl:if>

				<xsl:if test="$show-aktivverweisung">
					<xsl:call-template name="reference-list">
						<xsl:with-param name="id" select="'verweisNormen'"/>
						<xsl:with-param name="references" select="$refs/akn:implicitReference[@ris:domainTerm='Normverweis']/ris:verweisNorm"/>
						<xsl:with-param name="format" select="'verweis'"/>
					</xsl:call-template>
				</xsl:if>

				<xsl:if test="$show-normenkette">
					<xsl:call-template name="reference-list">
						<xsl:with-param name="id" select="'referenzNormen'"/>
						<xsl:with-param name="references" select="$refs/akn:implicitReference[@ris:domainTerm='Norm']/ris:referenzNorm"/>
						<xsl:with-param name="format" select="'normenkette'"/>
					</xsl:call-template>
				</xsl:if>

				<xsl:if test="$show-aktivverweisung">
					<xsl:call-template name="reference-list">
						<xsl:with-param name="id" select="'verweisVerwaltungsvorschriften'"/>
						<xsl:with-param name="references" select="$refs/akn:implicitReference[@ris:domainTerm='Verweis Verwaltungsvorschrift']/ris:verweisVerwaltungsvorschrift"/>
						<xsl:with-param name="format" select="'verweis'"/>
					</xsl:call-template>
				</xsl:if>

				<xsl:if test="$show-aktivzitierung-rechtsprechung">
					<xsl:call-template name="reference-list">
						<xsl:with-param name="id" select="'referenzRechtsprechungen'"/>
						<xsl:with-param name="references" select="$refs/akn:implicitReference[@ris:domainTerm='Referenz Rechtsprechung']/ris:referenzRechtsprechung"/>
						<xsl:with-param name="format" select="'rechtsprechung'"/>
					</xsl:call-template>
				</xsl:if>
			</head>
			<body/>
		</html>
	</xsl:template>

	<!-- Suppress unwanted akn:meta output in body -->
	<xsl:template match="akn:meta"/>

</xsl:stylesheet>
