<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:akn="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
                xmlns:ris="http://rechtsinformationen.bund.de/schema/ris/0.1"
                exclude-result-prefixes="xs akn ris xsi"
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
	     format-date: ISO YYYY-MM-DD → DD.MM.YYYY
	     "+999999999-12-31" → "unbefristet"
	     Empty string → empty string
	     ================================================================ -->
	<xsl:template name="format-date">
		<xsl:param name="date" select="''"/>
		<xsl:choose>
			<xsl:when test="starts-with($date, '+999999999')">unbefristet</xsl:when>
			<xsl:when test="$date = ''"/>
			<xsl:otherwise>
				<xsl:value-of select="format-date(xs:date($date), '[D01].[M01].[Y0001]')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- ================================================================
	     Root
	     ================================================================ -->
	<xsl:template match="/">
		<xsl:apply-templates select="akn:akomaNtoso/akn:doc/akn:meta"/>
	</xsl:template>

	<xsl:template match="akn:doc/akn:meta">
		<!-- FRBR -->
		<xsl:variable name="frbr"                 select="akn:identification"/>
		<xsl:variable name="doknr"                select="$frbr/akn:FRBRWork/akn:FRBRalias[@name='dokumentnummer']/@value"/>
		<xsl:variable name="titel"                select="$frbr/akn:FRBRWork/akn:FRBRalias[@name='langueberschrift']/@value"/>
		<xsl:variable name="zitierdatum"           select="$frbr/akn:FRBRExpression/akn:FRBRdate[@name='zitierdatum']/@date"/>
		<xsl:variable name="letzteVeroeffentlichung" select="$frbr/akn:FRBRManifestation/akn:FRBRdate[@name='letzteVeroeffentlichung']/@date"/>
		<xsl:variable name="erstveroeffentlichung" select="$frbr/akn:FRBRManifestation/akn:FRBRdate[@name='erstveroeffentlichung']/@date"/>
		<!-- Metadata -->
		<xsl:variable name="risMeta"  select="akn:proprietary/ris:meta"/>
		<!-- References -->
		<xsl:variable name="refs"          select="akn:analysis/akn:otherReferences"/>
		<xsl:variable name="fundstelle"    select="$refs/akn:implicitReference[@ris:domainTerm='Fundstelle']"/>
		<xsl:variable name="normenKette"   select="$refs/akn:implicitReference[@ris:domainTerm='Norm']"/>
		<xsl:variable name="verweisNormen" select="$refs/akn:implicitReference[@ris:domainTerm='Normverweis']"/>
		<xsl:variable name="verweisVwv"    select="$refs/akn:implicitReference[@ris:domainTerm='Verweis Verwaltungsvorschrift']"/>
		<xsl:variable name="rspr"          select="$refs/akn:implicitReference[@ris:domainTerm='Referenz Rechtsprechung']"/>

		<html lang="de">
			<head>
				<meta charset="utf-8"/>
				<xsl:call-template name="render-title-header">
					<xsl:with-param name="titel" select="$titel"/>
				</xsl:call-template>

				<xsl:if test="$show-fundstelle">
					<xsl:call-template name="reference-list">
						<xsl:with-param name="id" select="'fundstelle'"/>
						<xsl:with-param name="references" select="$fundstelle/ris:fundstelle"/>
						<xsl:with-param name="format" select="'fundstelle'"/>
					</xsl:call-template>
				</xsl:if>

				<xsl:if test="$show-aktivverweisung">
					<xsl:call-template name="reference-list">
						<xsl:with-param name="id" select="'verweisNormen'"/>
						<xsl:with-param name="references" select="$verweisNormen/ris:verweisNorm"/>
						<xsl:with-param name="format" select="'verweis'"/>
					</xsl:call-template>
				</xsl:if>

				<xsl:if test="$show-normenkette">
					<xsl:call-template name="reference-list">
						<xsl:with-param name="id" select="'normenKette'"/>
						<xsl:with-param name="references" select="$normenKette/ris:referenzNorm"/>
						<xsl:with-param name="format" select="'normenkette'"/>
					</xsl:call-template>
				</xsl:if>

				<xsl:if test="$show-aktivverweisung">
					<xsl:call-template name="reference-list">
						<xsl:with-param name="id" select="'verweisVwv'"/>
						<xsl:with-param name="references" select="$verweisVwv/ris:verweisVerwaltungsvorschrift"/>
						<xsl:with-param name="format" select="'verweis'"/>
					</xsl:call-template>
				</xsl:if>

				<xsl:if test="$show-aktivzitierung-rechtsprechung">
					<xsl:call-template name="reference-list">
						<xsl:with-param name="id" select="'rspr'"/>
						<xsl:with-param name="references" select="$rspr/ris:referenzRechtsprechung"/>
						<xsl:with-param name="format" select="'rechtsprechung'"/>
					</xsl:call-template>
				</xsl:if>
			</head>
			<body>
				<xsl:call-template name="render-header">
					<xsl:with-param name="titel"                   select="$titel"/>
					<xsl:with-param name="doknr"                   select="$doknr"/>
					<xsl:with-param name="zitierdatum"             select="$zitierdatum"/>
					<xsl:with-param name="letzteVeroeffentlichung" select="$letzteVeroeffentlichung"/>
					<xsl:with-param name="erstveroeffentlichung"   select="$erstveroeffentlichung"/>
					<xsl:with-param name="risMeta"                 select="$risMeta"/>
				</xsl:call-template>

				<xsl:call-template name="render-metadata">
					<xsl:with-param name="risMeta" select="$risMeta"/>
				</xsl:call-template>

				<xsl:call-template name="render-definitionen">
					<xsl:with-param name="risMeta" select="$risMeta"/>
				</xsl:call-template>

				<xsl:call-template name="render-schlagwoerter">
					<xsl:with-param name="risMeta" select="$risMeta"/>
				</xsl:call-template>
			</body>
		</html>
	</xsl:template>

	<!-- ================================================================
	     Header: Langtitel + FRBR date fields
	     ================================================================ -->
	<xsl:template name="render-title-header">
		<xsl:param name="titel"/>
		<xsl:if test="$titel != '' and $show-amtliche-langueberschrift">
			<title>
				<xsl:value-of select="$titel"/>
			</title>
		</xsl:if>
	</xsl:template>


	<xsl:template name="render-header">
		<xsl:param name="titel"/>
		<xsl:param name="doknr"/>
		<xsl:param name="zitierdatum"/>
		<xsl:param name="letzteVeroeffentlichung"/>
		<xsl:param name="erstveroeffentlichung"/>
		<xsl:param name="risMeta"/>

		<xsl:if test="$show-amtliche-langueberschrift or $show-zitierdatum or $show-risAbkuerzung or $show-dokumentnummer">
			<header id="header">
				<xsl:if test="$titel != '' and $show-amtliche-langueberschrift">
					<h1><xsl:value-of select="$titel"/></h1>
				</xsl:if>
				<dl>
					<xsl:if test="$show-dokumentnummer and $doknr != ''">
						<div>
							<dt>Dokumentnummer</dt>
							<dd><xsl:value-of select="$doknr"/></dd>
						</div>
					</xsl:if>

					<xsl:if test="$show-erstveroeffentlichung and $erstveroeffentlichung != ''">
						<div>
							<dt>Erstveröffentlichung</dt>
							<dd><xsl:value-of select="$erstveroeffentlichung"/></dd>
						</div>
					</xsl:if>

					<xsl:if test="$show-letzte-veroeffentlichung and $letzteVeroeffentlichung != ''">
						<div>
							<dt>Letzte Veröffentlichung</dt>
							<dd><xsl:value-of select="$letzteVeroeffentlichung"/></dd>
						</div>
					</xsl:if>

					<xsl:if test="$show-risAbkuerzung and $risMeta/ris:risAbkuerzung != ''">
						<div>
							<dt>RIS-Abkürzung</dt>
							<dd><xsl:value-of select="$risMeta/ris:risAbkuerzung"/></dd>
						</div>
					</xsl:if>

					<xsl:if test="$show-zitierdatum and $zitierdatum != ''">
						<div>
							<dt>Zitierdatum</dt>
							<dd>
						<xsl:call-template name="format-date">
							<xsl:with-param name="date" select="$zitierdatum"/>
						</xsl:call-template>
					</dd>
						</div>
					</xsl:if>
				</dl>
			</header>
		</xsl:if>
	</xsl:template>

	<!-- ================================================================
	     Metadata <dl>
	     ================================================================ -->
	<xsl:template name="render-metadata">
		<xsl:param name="risMeta"/>

		<dl id="metadaten">
			<xsl:if test="$show-aktenzeichen and $risMeta/ris:aktenzeichenListe">
				<div>
					<dt>Aktenzeichen</dt>
					<dd>
						<xsl:for-each select="$risMeta/ris:aktenzeichenListe/ris:aktenzeichen">
							<xsl:if test="position() > 1"><br/></xsl:if>
							<xsl:value-of select="."/>
						</xsl:for-each>
					</dd>
				</div>
			</xsl:if>

			<xsl:if test="$show-normgeber and $risMeta/ris:normgeberListe/ris:normgeber">
				<div>
					<dt>Normgeber</dt>
					<dd>
						<xsl:for-each select="$risMeta/ris:normgeberListe/ris:normgeber">
							<xsl:if test="position() > 1">, </xsl:if>
							<abbr>
								<xsl:if test="normalize-space(ris:langbezeichnung)">
									<xsl:attribute name="title">
										<xsl:value-of select="ris:langbezeichnung"/>
									</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="ris:kurzbezeichnung"/>
							</abbr>
						</xsl:for-each>
					</dd>
				</div>
			</xsl:if>

			<xsl:if test="$show-dokumenttyp and $risMeta/ris:dokumenttypen/ris:dokumenttyp">
				<div>
					<dt>Dokumenttyp</dt>
					<dd>
						<xsl:for-each select="$risMeta/ris:dokumenttypen/ris:dokumenttyp">
							<xsl:if test="position() > 1">, </xsl:if>
							<xsl:value-of select="."/>
						</xsl:for-each>
					</dd>
				</div>
			</xsl:if>

			<xsl:if test="$show-sachgebiete and $risMeta/ris:sachgebiete/ris:sachgebiet">
				<div>
					<dt>Sachgebiete</dt>
					<dd>
						<ul>
							<xsl:for-each select="$risMeta/ris:sachgebiete/ris:sachgebiet">
								<li>
									<xsl:value-of select="."/>
								</li>
							</xsl:for-each>
						</ul>
					</dd>
				</div>
			</xsl:if>

			<xsl:if test="$show-inkrafttretedatum and $risMeta/ris:inkrafttretedatum != ''">
				<div>
					<dt>Inkrafttreten</dt>
					<dd>
					<xsl:call-template name="format-date">
						<xsl:with-param name="date" select="$risMeta/ris:inkrafttretedatum"/>
					</xsl:call-template>
				</dd>
				</div>
			</xsl:if>

			<xsl:if test="$show-ausserkrafttretedatum and $risMeta/ris:ausserkrafttretedatum != ''">
				<div>
					<dt>Außerkrafttreten</dt>
					<dd>
					<xsl:call-template name="format-date">
						<xsl:with-param name="date" select="$risMeta/ris:ausserkrafttretedatum"/>
					</xsl:call-template>
				</dd>
				</div>
			</xsl:if>

			<xsl:if test="$show-anwendungszeitraum and $risMeta/ris:anwendungszeitraum/ris:anwendungsbeginn != ''">
				<div>
					<dt>Anwendungsbeginn</dt>
					<dd><xsl:value-of select="$risMeta/ris:anwendungszeitraum/ris:anwendungsbeginn"/></dd>
				</div>
			</xsl:if>
			<xsl:if test="$show-anwendungszeitraum and $risMeta/ris:anwendungszeitraum/ris:anwendungsende != ''">
				<div>
					<dt>Anwendungsende</dt>
					<dd><xsl:value-of select="$risMeta/ris:anwendungszeitraum/ris:anwendungsende"/></dd>
				</div>
			</xsl:if>
		</dl>
	</xsl:template>

	<!-- ================================================================
	     Definitionen
	     ================================================================ -->
	<xsl:template name="render-definitionen">
		<xsl:param name="risMeta"/>

		<xsl:if test="$show-definitionen and $risMeta/ris:definitionen/ris:definition/ris:definierterBegriff">
			<section id="definitionen">
				<h2>Definitionen</h2>
				<ul>
					<xsl:for-each select="$risMeta/ris:definitionen/ris:definition/ris:definierterBegriff">
						<li><xsl:value-of select="."/></li>
					</xsl:for-each>
				</ul>
			</section>
		</xsl:if>
	</xsl:template>

	<!-- ================================================================
	     Schlagwörter
	     ================================================================ -->
	<xsl:template name="render-schlagwoerter">
		<xsl:param name="risMeta"/>

		<xsl:if test="$show-schlagwoerter and $risMeta/akn:classification/akn:keyword">
			<section id="schlagwoerter">
				<h2>Schlagwörter</h2>
				<ul>
					<xsl:for-each select="$risMeta/akn:classification/akn:keyword">
						<li><xsl:value-of select="@showAs"/></li>
					</xsl:for-each>
				</ul>
			</section>
		</xsl:if>
	</xsl:template>

	<!-- ================================================================
	     AkomaNtoso inline elements — passthrough with semantic HTML
	     ================================================================ -->
	<xsl:template match="akn:p">
		<p><xsl:apply-templates/></p>
	</xsl:template>

	<xsl:template match="akn:div">
		<div><xsl:apply-templates/></div>
	</xsl:template>

	<xsl:template match="akn:heading">
		<h2><xsl:apply-templates/></h2>
	</xsl:template>

	<xsl:template match="akn:subheading">
		<h3><xsl:apply-templates/></h3>
	</xsl:template>

	<xsl:template match="akn:num">
		<span><xsl:apply-templates/></span>
	</xsl:template>

	<xsl:template match="akn:ref">
		<a href="{@href}"><xsl:apply-templates/></a>
	</xsl:template>

	<xsl:template match="akn:i | akn:em">
		<em><xsl:apply-templates/></em>
	</xsl:template>

	<xsl:template match="akn:b | akn:strong">
		<strong><xsl:apply-templates/></strong>
	</xsl:template>

	<!-- Suppress unwanted akn:meta output in body -->
	<xsl:template match="akn:meta"/>

</xsl:stylesheet>
