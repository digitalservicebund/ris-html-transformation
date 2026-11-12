<?xml version="1.0" encoding="UTF-8"?>
<!-- Shared templates for SLI and ULI literature documents in the V1 format (as produced by ris-literature) -->
<xsl:stylesheet version="2.0"
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:akn="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
				xmlns:ris="http://rechtsinformationen.bund.de/schema/ris/0.1"
				exclude-result-prefixes="akn ris">

	<xsl:output method="html" encoding="UTF-8" indent="yes"/>

	<xsl:strip-space elements="*"/>

	<xsl:include href="../references.xslt"/>

	<!-- ================================================================
	     Section visibility parameters shared by SLI and ULI — set to false() to hide a section.
	     ================================================================ -->
	<xsl:param name="show-haupttitel"                                 select="true()"/>
	<xsl:param name="show-zusaetzliche-titel"                         select="true()"/>
	<xsl:param name="show-gliederung"                                 select="true()"/>
	<xsl:param name="show-dokumenttyp"                                select="true()"/>
	<xsl:param name="show-kurzreferat"                                select="true()"/>
	<xsl:param name="show-verfasser"                                  select="true()"/>
	<xsl:param name="show-mitarbeiter"                                select="true()"/>
	<xsl:param name="show-urheber"                                    select="true()"/>
	<xsl:param name="show-veroeffentlichungsjahre"                    select="true()"/>
	<xsl:param name="show-normen"                                     select="true()"/>
	<xsl:param name="show-aktivzitierung-rechtsprechung"              select="true()"/>
	<xsl:param name="show-aktivzitierung-unselbststaendige-literatur" select="true()"/>
	<xsl:param name="show-aktivzitierung-selbststaendige-literatur"   select="true()"/>

	<xsl:variable name="work" select="/akn:akomaNtoso/akn:doc/akn:meta/akn:identification/akn:FRBRWork"/>
	<xsl:variable name="refs" select="/akn:akomaNtoso/akn:doc/akn:meta/akn:analysis/akn:otherReferences"/>
	<xsl:variable name="risMeta" select="/akn:akomaNtoso/akn:doc/akn:meta/akn:proprietary/ris:meta"/>

	<!-- render titles -->
	<xsl:template name="titles">
		<xsl:if test="$show-haupttitel and $titles[1]">
			<h1 id="title">
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

	<!-- Gesamttitel are rendered as "Titel Bandbezeichnung", all other titles as they come. -->
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

	<!-- render the kurzreferat as a section -->
	<xsl:template name="kurzreferat">
		<xsl:variable name="kurzreferat" select="/akn:akomaNtoso/akn:doc/akn:mainBody/akn:div[normalize-space()]"/>
		<xsl:if test="$show-kurzreferat and $kurzreferat">
			<section id="kurzreferat">
				<h2>Kurzreferat</h2>
				<xsl:apply-templates select="$kurzreferat/node()" mode="html"/>
			</section>
		</xsl:if>
	</xsl:template>

	<!-- render dokumenttypen as a <template> block in the html head -->
	<xsl:template name="dokumenttypen">
		<xsl:variable name="dokumenttypen" select="$risMeta/ris:dokumenttypen/ris:dokumenttyp[normalize-space()]"/>
		<xsl:if test="$show-dokumenttyp and $dokumenttypen">
			<template id="dokumenttypen">
				<ul>
					<xsl:for-each select="$dokumenttypen">
						<li><xsl:value-of select="normalize-space(.)"/></li>
					</xsl:for-each>
				</ul>
			</template>
		</xsl:if>
	</xsl:template>

	<!-- render the verfasser as a <template> block in the html head -->
	<xsl:template name="verfasser">
		<xsl:if test="$show-verfasser">
			<xsl:call-template name="person-list">
				<xsl:with-param name="id" select="'verfasserListe'"/>
				<xsl:with-param name="persons" select="$risMeta/ris:verfasserListe/ris:verfasser"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- render the mitarbeiter as a <template> block in the html head -->
	<xsl:template name="mitarbeiter">
		<xsl:if test="$show-mitarbeiter">
			<xsl:call-template name="person-list">
				<xsl:with-param name="id" select="'mitarbeiterListe'"/>
				<xsl:with-param name="persons" select="$risMeta/ris:mitarbeiterListe/ris:mitarbeiter"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- render the urheber (institutions) as a <template> block in the html head.
	  	 they are rendered with their name only, as they come. -->
	<xsl:template name="urheber">
		<xsl:variable name="urheber" select="$risMeta/ris:urheberListe/ris:urheber[normalize-space()]"/>
		<xsl:if test="$show-urheber and $urheber">
			<template id="urheberListe">
				<ul>
					<xsl:for-each select="$urheber">
						<li><xsl:value-of select="normalize-space(.)"/></li>
					</xsl:for-each>
				</ul>
			</template>
		</xsl:if>
	</xsl:template>

	<!-- render the veroeffentlichungsJahre as a <template> block in the html head, as they come -->
	<xsl:template name="veroeffentlichungsjahre">
		<xsl:variable name="jahre" select="$risMeta/ris:veroeffentlichungsJahre/ris:veroeffentlichungsJahr[normalize-space()]"/>
		<xsl:if test="$show-veroeffentlichungsjahre and $jahre">
			<template id="veroeffentlichungsJahre">
				<ul>
					<xsl:for-each select="$jahre">
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

	<!-- Person names come as "Nachname, Vorname" and are rendered as "Vorname Nachname" -->
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

	<!-- render references as <template> blocks in the html head -->
	<xsl:template name="references">
		<xsl:if test="$show-normen">
			<xsl:call-template name="reference-list">
				<xsl:with-param name="id" select="'referenzenNorm'"/>
				<xsl:with-param name="references" select="$risMeta/ris:referenzenNorm/ris:referenzNorm[normalize-space()]"/>
				<xsl:with-param name="format" select="'normenkette'"/>
			</xsl:call-template>
		</xsl:if>
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

	<!-- ================================================================
	     Rich text (e.g. the Kurzreferat in the akn:mainBody), rendered in mode "html".
	     ris-literature only produces akn:p, akn:a, akn:br, akn:span, akn:sub, akn:sup and
	     akn:inline (em, strong, hlf, noindex) here.
	     ================================================================ -->
	<xsl:template match="akn:p|akn:div|akn:span|akn:sub|akn:sup" mode="html">
		<xsl:element name="{local-name()}">
			<xsl:apply-templates mode="html"/>
		</xsl:element>
	</xsl:template>

	<xsl:template match="akn:br" mode="html">
		<br/>
	</xsl:template>

	<xsl:template match="akn:a[@href]" mode="html">
		<a href="{@href}"><xsl:apply-templates mode="html"/></a>
	</xsl:template>

	<xsl:template match="akn:inline[@name='em']" mode="html">
		<em><xsl:apply-templates mode="html"/></em>
	</xsl:template>

	<xsl:template match="akn:inline[@name='strong']" mode="html">
		<strong><xsl:apply-templates mode="html"/></strong>
	</xsl:template>

	<!-- Any other element (e.g. akn:inline hlf or noindex) is unwrapped, keeping its content -->
	<xsl:template match="*" mode="html">
		<xsl:apply-templates mode="html"/>
	</xsl:template>

	<xsl:template match="text()" mode="html">
		<xsl:value-of select="."/>
	</xsl:template>

	<xsl:template match="text()"/>
</xsl:stylesheet>
