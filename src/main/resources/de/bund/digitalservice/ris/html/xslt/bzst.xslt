<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:akn="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
                xmlns:ris="http://ldml.neuris.de/adm/bzst/meta/"
                exclude-result-prefixes="akn ris">

	<xsl:output method="html" version="5.0" encoding="UTF-8" indent="yes"/>

	<!-- ================================================================
	     Section visibility parameters — set to false() to hide a section.
	     ================================================================ -->
	<xsl:param name="show-aktenzeichen"                  select="true()"/>
	<xsl:param name="show-aktivverweisung"               select="true()"/>
	<xsl:param name="show-aktivzitierung-rechtsprechung" select="true()"/>
	<xsl:param name="show-anwendungszeitraum"            select="true()"/>
	<xsl:param name="show-amtliche-langueberschrift"     select="true()"/>
	<xsl:param name="show-ausserkrafttretedatum"         select="true()"/>
	<xsl:param name="show-body"                          select="false()"/><!-- preface + mainBody -->
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
				<!-- extract last 10 chars to handle any leading +/- era prefix -->
				<xsl:variable name="d" select="substring($date, string-length($date) - 9)"/>
				<xsl:value-of select="concat(
          substring($d, 9, 2), '.',
          substring($d, 6, 2), '.',
          substring($d, 1, 4))"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- ================================================================
	     Root
	     ================================================================ -->
	<xsl:template match="/">
		<xsl:apply-templates select="akn:akomaNtoso/akn:doc"/>
	</xsl:template>

	<xsl:template match="akn:doc">
		<xsl:variable name="meta"  select="akn:meta"/>
		<!-- FRBR -->
		<xsl:variable name="frbr"                 select="$meta/akn:identification"/>
		<xsl:variable name="doknr"                select="$frbr/akn:FRBRWork/akn:FRBRalias[@name='dokumentnummer']/@value"/>
		<xsl:variable name="titel"                select="$frbr/akn:FRBRWork/akn:FRBRalias[@name='langueberschrift']/@value"/>
		<xsl:variable name="zitierdatum"           select="$frbr/akn:FRBRExpression/akn:FRBRdate[@name='zitierdatum']/@date"/>
		<xsl:variable name="letzteVeroeffentlichung" select="$frbr/akn:FRBRManifestation/akn:FRBRdate[@name='letzteVeroeffentlichung']/@date"/>
		<xsl:variable name="erstveroeffentlichung" select="$frbr/akn:FRBRManifestation/akn:FRBRdate[@name='erstveroeffentlichung']/@date"/>
		<!-- Metadata -->
		<xsl:variable name="prop"  select="$meta/akn:proprietary/ris:meta"/>
		<!-- References -->
		<xsl:variable name="refs"          select="$meta/akn:analysis/akn:otherReferences"/>
		<xsl:variable name="fundstelle"    select="$refs/akn:implicitReference[@ris:domainTerm='Fundstelle']"/>
		<xsl:variable name="normenKette"   select="$refs/akn:implicitReference[@ris:domainTerm='Norm']"/>
		<xsl:variable name="verweisNormen" select="$refs/akn:implicitReference[@ris:domainTerm='Normverweis']"/>
		<xsl:variable name="verweisVwv"    select="$refs/akn:implicitReference[@ris:domainTerm='Verweis Verwaltungsvorschrift']"/>
		<xsl:variable name="rspr"          select="$refs/akn:implicitReference[@ris:domainTerm='Referenz Rechtsprechung']"/>

		<div>
			<xsl:call-template name="render-header">
				<xsl:with-param name="titel"                   select="$titel"/>
				<xsl:with-param name="doknr"                   select="$doknr"/>
				<xsl:with-param name="zitierdatum"             select="$zitierdatum"/>
				<xsl:with-param name="letzteVeroeffentlichung" select="$letzteVeroeffentlichung"/>
				<xsl:with-param name="erstveroeffentlichung"   select="$erstveroeffentlichung"/>
				<xsl:with-param name="prop"                    select="$prop"/>
			</xsl:call-template>

			<xsl:call-template name="render-metadata">
				<xsl:with-param name="prop" select="$prop"/>
			</xsl:call-template>

			<xsl:call-template name="render-definitionen">
				<xsl:with-param name="prop" select="$prop"/>
			</xsl:call-template>

			<xsl:call-template name="render-schlagwoerter">
				<xsl:with-param name="meta" select="$meta"/>
			</xsl:call-template>

			<xsl:call-template name="render-referenzen">
				<xsl:with-param name="fundstelle"    select="$fundstelle"/>
				<xsl:with-param name="normenKette"   select="$normenKette"/>
				<xsl:with-param name="verweisNormen" select="$verweisNormen"/>
				<xsl:with-param name="verweisVwv"    select="$verweisVwv"/>
				<xsl:with-param name="rspr"          select="$rspr"/>
			</xsl:call-template>

			<xsl:if test="$show-body">
				<xsl:apply-templates select="akn:preface"/>
				<xsl:apply-templates select="akn:mainBody"/>
			</xsl:if>
		</div>
	</xsl:template>

	<!-- ================================================================
	     Header: Langtitel + FRBR date fields
	     ================================================================ -->
	<xsl:template name="render-header">
		<xsl:param name="titel"/>
		<xsl:param name="doknr"/>
		<xsl:param name="zitierdatum"/>
		<xsl:param name="letzteVeroeffentlichung"/>
		<xsl:param name="erstveroeffentlichung"/>
		<xsl:param name="prop"/>

		<xsl:if test="$show-amtliche-langueberschrift or $show-zitierdatum or $show-risAbkuerzung or $show-dokumentnummer">
			<header id="header">

				<xsl:if test="$titel != '' and $show-amtliche-langueberschrift">
					<h1>
						<xsl:value-of select="$titel"/>
					</h1>
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

					<xsl:if test="$show-risAbkuerzung and $prop/ris:risAbkuerzung != ''">
						<div>
							<dt>RIS-Abkürzung</dt>
							<dd><xsl:value-of select="$prop/ris:risAbkuerzung"/></dd>
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
		<xsl:param name="prop"/>

		<dl id="metadaten">
			<xsl:if test="$show-aktenzeichen and $prop/ris:aktenzeichenListe">
				<div>
					<dt>Aktenzeichen</dt>
					<dd>
						<xsl:for-each select="$prop/ris:aktenzeichenListe/ris:aktenzeichen">
							<xsl:if test="position() > 1"><br/></xsl:if>
							<xsl:value-of select="."/>
						</xsl:for-each>
					</dd>
				</div>
			</xsl:if>

			<xsl:if test="$show-normgeber and $prop/ris:normgeberListe/ris:normgeber">
				<div>
					<dt>Normgeber</dt>
					<dd>
						<xsl:for-each select="$prop/ris:normgeberListe/ris:normgeber">
							<xsl:if test="position() > 1">, </xsl:if>
							<abbr title="{ris:langbezeichnung}">
								<xsl:value-of select="ris:kurzbezeichnung"/>
							</abbr>
							<xsl:if test="normalize-space(ris:langbezeichnung)">
								<xsl:text> (</xsl:text>
								<xsl:value-of select="ris:langbezeichnung"/>
								<xsl:text>)</xsl:text>
							</xsl:if>
						</xsl:for-each>
					</dd>
				</div>
			</xsl:if>

			<xsl:if test="$show-dokumenttyp and $prop/ris:dokumenttypen/ris:dokumenttyp">
				<div>
					<dt>Dokumenttyp</dt>
					<dd>
						<xsl:for-each select="$prop/ris:dokumenttypen/ris:dokumenttyp">
							<xsl:if test="position() > 1">, </xsl:if>
							<xsl:value-of select="."/>
						</xsl:for-each>
					</dd>
				</div>
			</xsl:if>

			<xsl:if test="$show-sachgebiete and $prop/ris:sachgebiete/ris:sachgebiet">
				<div>
					<dt>Sachgebiete</dt>
					<dd>
						<ul>
							<xsl:for-each select="$prop/ris:sachgebiete/ris:sachgebiet">
								<li data-sachgebiet-id="{@sachgebiet-id}">
									<xsl:value-of select="."/>
								</li>
							</xsl:for-each>
						</ul>
					</dd>
				</div>
			</xsl:if>

			<xsl:if test="$show-inkrafttretedatum and $prop/ris:inkrafttretedatum != ''">
				<div>
					<dt>Inkrafttreten</dt>
					<dd>
					<xsl:call-template name="format-date">
						<xsl:with-param name="date" select="$prop/ris:inkrafttretedatum"/>
					</xsl:call-template>
				</dd>
				</div>
			</xsl:if>

			<xsl:if test="$show-ausserkrafttretedatum and $prop/ris:ausserkrafttretedatum != ''">
				<div>
					<dt>Außerkrafttreten</dt>
					<dd>
					<xsl:call-template name="format-date">
						<xsl:with-param name="date" select="$prop/ris:ausserkrafttretedatum"/>
					</xsl:call-template>
				</dd>
				</div>
			</xsl:if>

			<xsl:if test="$show-anwendungszeitraum and $prop/ris:anwendungszeitraum">
				<div>
					<dt>Anwendungsbeginn</dt>
					<dd><xsl:value-of select="$prop/ris:anwendungszeitraum/ris:anwendungsbeginn"/></dd>
				</div>
				<div>
					<dt>Anwendungsende</dt>
					<dd><xsl:value-of select="$prop/ris:anwendungszeitraum/ris:anwendungsende"/></dd>
				</div>
			</xsl:if>
		</dl>
	</xsl:template>

	<!-- ================================================================
	     Definitionen
	     ================================================================ -->
	<xsl:template name="render-definitionen">
		<xsl:param name="prop"/>

		<xsl:if test="$show-definitionen and $prop/ris:definitionen/ris:definition/ris:definierterBegriff">
			<section id="definitionen">
				<h2>Definitionen</h2>
				<ul>
					<xsl:for-each select="$prop/ris:definitionen/ris:definition/ris:definierterBegriff">
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
		<xsl:param name="meta"/>

		<xsl:if test="$show-schlagwoerter and $meta/akn:classification/akn:keyword">
			<section id="schlagwoerter">
				<h2>Schlagwörter</h2>
				<ul>
					<xsl:for-each select="$meta/akn:classification/akn:keyword">
						<li><xsl:value-of select="@showAs"/></li>
					</xsl:for-each>
				</ul>
			</section>
		</xsl:if>
	</xsl:template>

	<!-- ================================================================
	     Referenzen section
	     ================================================================ -->
	<xsl:template name="render-referenzen">
		<xsl:param name="fundstelle"/>
		<xsl:param name="normenKette"/>
		<xsl:param name="verweisNormen"/>
		<xsl:param name="verweisVwv"/>
		<xsl:param name="rspr"/>

		<xsl:if test="($show-fundstelle                    and $fundstelle)
		           or ($show-normenkette                   and $normenKette)
		           or ($show-aktivverweisung               and $verweisNormen)
		           or ($show-aktivverweisung               and $verweisVwv)
		           or ($show-aktivzitierung-rechtsprechung and $rspr)">
			<section id="referenzen">
				<h2>Referenzen</h2>

				<xsl:call-template name="render-fundstelle">
					<xsl:with-param name="fundstelle" select="$fundstelle"/>
				</xsl:call-template>

				<xsl:call-template name="render-normen">
					<xsl:with-param name="verweisNormen" select="$verweisNormen"/>
				</xsl:call-template>

				<xsl:call-template name="render-normenkette">
					<xsl:with-param name="normenKette" select="$normenKette"/>
				</xsl:call-template>

				<xsl:call-template name="render-vwv">
					<xsl:with-param name="verweisVwv" select="$verweisVwv"/>
				</xsl:call-template>

				<xsl:call-template name="render-rechtsprechung">
					<xsl:with-param name="rspr" select="$rspr"/>
				</xsl:call-template>
			</section>
		</xsl:if>
	</xsl:template>

	<xsl:template name="render-fundstelle">
		<xsl:param name="fundstelle"/>
		<xsl:if test="$show-fundstelle and $fundstelle">
			<div>
				<h3>Fundstelle</h3>
				<ul>
					<xsl:for-each select="$fundstelle">
						<xsl:variable name="fu" select="ris:fundstelle"/>
						<li>
							<span><xsl:value-of select="$fu/ris:periodikum/ris:abkuerzung"/></span>
							<xsl:if test="$fu/ris:periodikum/ris:untertitel != ''">
								<xsl:text>, </xsl:text>
								<span><xsl:value-of select="$fu/ris:periodikum/ris:untertitel"/></span>
							</xsl:if>
							<xsl:if test="$fu/ris:zitatstelle != ''">
								<xsl:text>, </xsl:text>
								<span><xsl:value-of select="$fu/ris:zitatstelle"/></span>
							</xsl:if>
						</li>
					</xsl:for-each>
				</ul>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template name="render-normen">
		<xsl:param name="verweisNormen"/>
		<xsl:if test="$show-aktivverweisung and $verweisNormen">
			<div>
				<h3>Normen</h3>
				<ul>
					<xsl:for-each select="$verweisNormen">
						<xsl:variable name="vn" select="ris:verweisNorm"/>
						<li>
							<span><xsl:value-of select="$vn/ris:abkuerzung"/></span>
							<xsl:if test="$vn/ris:einzelnorm/ris:bezeichnung != ''">
								<xsl:text> </xsl:text>
								<span><xsl:value-of select="$vn/ris:einzelnorm/ris:bezeichnung"/></span>
							</xsl:if>
							<xsl:if test="$vn/ris:einzelnorm/ris:normtext != ''">
								<xsl:text> </xsl:text>
								<span><xsl:value-of select="$vn/ris:einzelnorm/ris:normtext"/></span>
							</xsl:if>
							<xsl:if test="$vn/ris:verweistyp != ''">
								<span>(<xsl:value-of select="$vn/ris:verweistyp"/>)</span>
							</xsl:if>
							<xsl:if test="$vn/ris:einzelnorm/ris:fassungsdatum != ''">
								<span>
									<xsl:text>, </xsl:text>
									<xsl:call-template name="format-date">
										<xsl:with-param name="date" select="$vn/ris:einzelnorm/ris:fassungsdatum"/>
									</xsl:call-template>
								</span>
							</xsl:if>
							<xsl:if test="$vn/ris:einzelnorm/ris:ausserkrafttretedatum != ''">
								<span>
									<xsl:text>. Außerkrafttreten: </xsl:text>
									<xsl:call-template name="format-date">
										<xsl:with-param name="date" select="$vn/ris:einzelnorm/ris:ausserkrafttretedatum"/>
									</xsl:call-template>
								</span>
							</xsl:if>
						</li>
					</xsl:for-each>
				</ul>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template name="render-normenkette">
		<xsl:param name="normenKette"/>
		<xsl:if test="$show-normenkette and $normenKette">
			<div>
				<h3>Normenkette</h3>
				<ul>
					<xsl:for-each select="$normenKette">
						<xsl:variable name="norm" select="ris:referenzNorm"/>
						<li>
							<span><xsl:value-of select="$norm/ris:abkuerzung"/></span>
							<xsl:if test="$norm/ris:einzelnorm/ris:bezeichnung != ''">
								<xsl:text> </xsl:text>
								<span><xsl:value-of select="$norm/ris:einzelnorm/ris:bezeichnung"/></span>
							</xsl:if>
						</li>
					</xsl:for-each>
				</ul>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template name="render-vwv">
		<xsl:param name="verweisVwv"/>
		<xsl:if test="$show-aktivverweisung and $verweisVwv">
			<div>
				<h3>Verwaltungsvorschriften</h3>
				<ul>
					<xsl:for-each select="$verweisVwv">
						<xsl:variable name="vwv" select="ris:verweisVerwaltungsvorschrift"/>
						<li>
							<span><xsl:value-of select="$vwv/ris:abkuerzung"/></span>
							<xsl:if test="$vwv/ris:einzelnorm/ris:bezeichnung != ''">
								<xsl:text> </xsl:text>
								<span><xsl:value-of select="$vwv/ris:einzelnorm/ris:bezeichnung"/></span>
							</xsl:if>
							<xsl:if test="$vwv/ris:einzelnorm/ris:normtext != ''">
								<xsl:text> </xsl:text>
								<span><xsl:value-of select="$vwv/ris:einzelnorm/ris:normtext"/></span>
							</xsl:if>
							<xsl:if test="$vwv/ris:verweistyp != ''">
								<span>(<xsl:value-of select="$vwv/ris:verweistyp"/>)</span>
							</xsl:if>
						</li>
					</xsl:for-each>
				</ul>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template name="render-rechtsprechung">
		<xsl:param name="rspr"/>
		<xsl:if test="$show-aktivzitierung-rechtsprechung and $rspr">
			<div>
				<h3>Rechtsprechung</h3>
				<ul>
					<xsl:for-each select="$rspr">
						<xsl:variable name="r" select="ris:referenzRechtsprechung"/>
						<li>
							<xsl:if test="$r/ris:gericht/ris:gerichtsort != '' and $r/ris:gericht/ris:gerichtstyp != ''">
								<span>
									<xsl:value-of select="$r/ris:gericht/ris:gerichtstyp"/>
									<xsl:text> </xsl:text>
									<xsl:value-of select="$r/ris:gericht/ris:gerichtsort"/>
									<xsl:text>, </xsl:text>
								</span>
							</xsl:if>
							<xsl:if test="$r/ris:entscheidungsdatum != ''">
								<span>
									<xsl:text> </xsl:text>
									<xsl:call-template name="format-date">
										<xsl:with-param name="date" select="$r/ris:entscheidungsdatum"/>
									</xsl:call-template>
								</span>
							</xsl:if>
							<xsl:if test="$r/ris:aktenzeichen != ''">
								<span>
									<xsl:text> - </xsl:text>
									<xsl:value-of select="$r/ris:aktenzeichen"/>
								</span>
							</xsl:if>
							<xsl:if test="$r/ris:artDerZitierung != ''">
								<span>(<xsl:value-of select="$r/ris:artDerZitierung"/>)</span>
							</xsl:if>
							<xsl:if test="$r/ris:fundstelle/ris:periodikum/ris:abkuerzung != ''
							           or $r/ris:fundstelle/ris:zitatstelle != ''">
								<span>
									<xsl:text>, </xsl:text>
									<xsl:value-of select="$r/ris:fundstelle/ris:periodikum/ris:abkuerzung"/>
									<xsl:if test="$r/ris:fundstelle/ris:zitatstelle != ''">
										<xsl:text> </xsl:text>
										<xsl:value-of select="$r/ris:fundstelle/ris:zitatstelle"/>
									</xsl:if>
								</span>
							</xsl:if>
						</li>
					</xsl:for-each>
				</ul>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- ================================================================
	     Preface / MainBody
	     ================================================================ -->
	<xsl:template match="akn:preface[node()]">
		<div>
			<xsl:apply-templates/>
		</div>
	</xsl:template>

	<xsl:template match="akn:preface[not(node())]"/>

	<xsl:template match="akn:mainBody[node()]">
		<div>
			<xsl:apply-templates/>
		</div>
	</xsl:template>

	<xsl:template match="akn:mainBody[not(node())]"/>

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
