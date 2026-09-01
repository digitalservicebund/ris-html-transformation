<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:math="http://www.w3.org/1998/Math/MathML"
                xmlns:akn="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
                xmlns:ris="http://rechtsinformationen.bund.de/schema/ris/0.1"
                xmlns:local="http://rechtsinformationen.bund.de/schema/ris/0.1"
                exclude-result-prefixes="ris xs math akn local xsi"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xsi:schemaLocation="http://docs.oasis-open.org/legaldocml/ns/akn/3.0 https://docs.oasis-open.org/legaldocml/akn-core/v2.0/cs01/part2-specs/schemas/akomantoso30.xsd">
    <xsl:import href="case-law.xslt"/>

    <xsl:output method="html" encoding="UTF-8" indent="yes" />

    <xsl:param name="css" as="xs:string" select="''"/>

    <xsl:template match="akn:judgment">
        <html lang="de">
            <head>
                <meta charset="utf-8" />
                <title>
                    <xsl:value-of select=".//akn:shortTitle"/>
                </title>
                <xsl:if test="$css != ''">
                    <style>
                        <xsl:value-of select="$css" disable-output-escaping="yes"/>
                    </style>
                </xsl:if>
            </head>
            <body class="case-law">
                <dl class="content-grid gap-y-24">
                    <div class="col-span-12 grid grid-cols-subgrid items-baseline">
                        <dt>Stand PDF:</dt>
                        <dd>
                            <xsl:value-of select="format-dateTime(current-dateTime(), '[D01].[M01].[Y0001], [H01]:[m01] Uhr')" />
                        </dd>
                    </div>
                    <div>
                        <dt>Link Portal:</dt>
                        <dd>https://testphase.rechtsinformationen.bund.de/gerichtsentscheidungen/<xsl:call-template name="documentnumber-value" /></dd>
                    </div>
                </dl>

                <xsl:call-template name="judgment-title"/>


                <dl class="content-grid gap-y-24">
                    <div class="col-span-12 grid grid-cols-subgrid items-baseline">
                        <dt>Dokumenttyp:</dt>
                        <dd>
                            <xsl:call-template name="dokumenttyp-value" />
                        </dd>
                    </div>
                    <div class="col-span-12 grid grid-cols-subgrid items-baseline">
                        <dt>ECLI:</dt>
                        <dd>
                            <xsl:call-template name="ecli-value" />
                        </dd>
                    </div>
                    <div class="col-span-12 grid grid-cols-subgrid items-baseline">
                        <dt>Entscheidungsdatum:</dt>
                        <dd>
                            <xsl:call-template name="entscheidungsdatum-value" />
                        </dd>
                    </div>
                    <div class="col-span-12 grid grid-cols-subgrid items-baseline">
                        <dt>Aktenzeichen:</dt>
                        <dd>
                            <xsl:call-template name="aktenzeichen-value" />
                        </dd>
                    </div>
                    <div class="col-span-12 grid grid-cols-subgrid items-baseline">
                        <dt>Gericht:</dt>
                        <dd>
                            <xsl:call-template name="gericht-value" />
                        </dd>
                    </div>
                    <div class="col-span-12 grid grid-cols-subgrid items-baseline">
                        <dt>Spruchkörper:</dt>
                        <dd>
                            <xsl:call-template name="spruchkoerper-value" />
                        </dd>
                    </div>
                    <div class="col-span-12 grid grid-cols-subgrid items-baseline">
                        <dt>Streitjahr:</dt>
                        <dd>
                            <xsl:call-template name="streitjahre-value" />
                        </dd>
                    </div>
                    <div class="col-span-12 grid grid-cols-subgrid items-baseline">
                        <dt>Vorabdokument:</dt>
                        <dd>
                            <xsl:call-template name="vorabdokument-value" />
                        </dd>
                    </div>
                    <div class="col-span-12 grid grid-cols-subgrid items-baseline">
                        <dt>Vorgehende Entscheidungen:</dt>
                        <dd>
                            <xsl:call-template name="vorgehende-entscheidungen-value" />
                        </dd>
                    </div>
                    <div class="col-span-12 grid grid-cols-subgrid items-baseline">
                        <dt>Nachgehende Entscheidungen:</dt>
                        <dd>
                            <xsl:call-template name="nachgehende-entscheidungen-value" />
                        </dd>
                    </div>
                    <div class="col-span-12 grid grid-cols-subgrid items-baseline">
                        <dt>Nachgehende Entscheidungen (anhängig):</dt>
                        <dd>
                            <xsl:call-template name="nachgehende-entscheidungen-anhaengig-value" />
                        </dd>
                    </div>
                    <div class="col-span-12 grid grid-cols-subgrid items-baseline">
                        <dt>Norm:</dt>
                        <dd>
                            <xsl:call-template name="normen-value" />
                        </dd>
                    </div>
                </dl>

                <xsl:call-template name="judgment-content"/>
            </body>
        </html>
    </xsl:template>

    <xsl:template name="aktenzeichen-value">
        <xsl:variable name="value" select="akn:meta/akn:identification/akn:FRBRWork/akn:FRBRalias[@eId='aktenzeichen']/@value" />
        <xsl:choose>
            <xsl:when test="$value != ''">
                <xsl:value-of select="$value" />
            </xsl:when>
            <xsl:otherwise>—</xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="dokumenttyp-value">
        <xsl:variable name="value" select="akn:meta/akn:proprietary/ris:meta/ris:dokumenttyp" />
        <xsl:choose>
            <xsl:when test="$value != ''">
                <xsl:value-of select="$value" />
            </xsl:when>
            <xsl:otherwise>—</xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="ecli-value">
        <xsl:variable name="value" select="akn:meta/akn:identification/akn:FRBRWork/akn:FRBRalias[@name='ecli']/@value" />
        <xsl:choose>
            <xsl:when test="$value != ''">
                <xsl:value-of select="$value" />
            </xsl:when>
            <xsl:otherwise>—</xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="entscheidungsdatum-value">
        <xsl:variable name="value" select="akn:meta/akn:identification/akn:FRBRWork/akn:FRBRdate[@eId='entscheidungsdatum']/@date" />
        <xsl:choose>
            <xsl:when test="$value != ''">
                <xsl:call-template name="format-date">
                    <xsl:with-param name="date" select="$value" />
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>—</xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="gericht-value">
        <xsl:variable name="value" select="akn:meta/akn:proprietary/ris:meta/ris:gericht/@showAs" />
        <xsl:choose>
            <xsl:when test="$value != ''">
                <xsl:value-of select="$value" />
            </xsl:when>
            <xsl:otherwise>—</xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="spruchkoerper-value">
        <xsl:variable name="value" select="akn:meta/akn:proprietary/ris:meta/ris:gericht/ris:spruchkoerper" />
        <xsl:choose>
            <xsl:when test="$value != ''">
                <xsl:value-of select="$value" />
            </xsl:when>
            <xsl:otherwise>—</xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="streitjahre-value">
        <xsl:choose>
            <xsl:when test="akn:meta/akn:proprietary/ris:meta/ris:streitjahre/ris:streitjahr">
                <xsl:for-each select="akn:meta/akn:proprietary/ris:meta/ris:streitjahre/ris:streitjahr">
                    <xsl:if test="position() > 1">, </xsl:if>
                    <xsl:value-of select="." />
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>—</xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="vorabdokument-value">
        <xsl:variable name="value" select="akn:meta/akn:proprietary/ris:meta/ris:vorabdokument" />
        <xsl:choose>
            <xsl:when test="$value != ''">
                <xsl:value-of select="$value" />
            </xsl:when>
            <xsl:otherwise>Nein</xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="vorgehende-entscheidungen-value">
        <xsl:variable name="items" select="akn:meta/akn:analysis/akn:otherReferences/akn:implicitReference/ris:vorgehendeEntscheidung" />
        <xsl:choose>
            <xsl:when test="$items">
                <ul>
                    <xsl:for-each select="$items">
                        <li>
                            <xsl:call-template name="rechtszug-entscheidung" />
                        </li>
                    </xsl:for-each>
                </ul>
            </xsl:when>
            <xsl:otherwise>—</xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="nachgehende-entscheidungen-value">
        <xsl:variable name="items" select="akn:meta/akn:analysis/akn:otherReferences/akn:implicitReference/ris:nachgehendeEntscheidung[@art='nachgehend']" />
        <xsl:choose>
            <xsl:when test="$items">
                <ul>
                    <xsl:for-each select="$items">
                        <li>
                            <xsl:call-template name="rechtszug-entscheidung" />
                        </li>
                    </xsl:for-each>
                </ul>
            </xsl:when>
            <xsl:otherwise>—</xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="nachgehende-entscheidungen-anhaengig-value">
        <xsl:variable name="items" select="akn:meta/akn:analysis/akn:otherReferences/akn:implicitReference/ris:nachgehendeEntscheidung[@art='anhängig']" />
        <xsl:choose>
            <xsl:when test="$items">
                <ul>
                    <xsl:for-each select="$items">
                        <li>
                            <xsl:call-template name="rechtszug-entscheidung" />
                        </li>
                    </xsl:for-each>
                </ul>
            </xsl:when>
            <xsl:otherwise>—</xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Renders a single rechtszug entry (vorgehende/nachgehende Entscheidung) from the current context node -->
    <xsl:template name="rechtszug-entscheidung">
        <xsl:variable name="parts">
            <xsl:if test="ris:gericht/@showAs != ''">
                <part><xsl:value-of select="ris:gericht/@showAs" /></part>
            </xsl:if>
            <xsl:if test="ris:entscheidungsdatum != ''">
                <part>
                    <xsl:call-template name="format-date">
                        <xsl:with-param name="date" select="normalize-space(ris:entscheidungsdatum)" />
                    </xsl:call-template>
                </part>
            </xsl:if>
            <xsl:if test="ris:aktenzeichen != ''">
                <part>Az: <xsl:value-of select="normalize-space(ris:aktenzeichen)" /></part>
            </xsl:if>
        </xsl:variable>
        <xsl:for-each select="$parts/part">
            <xsl:if test="position() > 1">
                <xsl:text>, </xsl:text>
            </xsl:if>
            <xsl:value-of select="." />
        </xsl:for-each>
        <xsl:if test="ris:vermerk != ''">
            <xsl:text> (</xsl:text>
            <xsl:value-of select="normalize-space(ris:vermerk)" />
            <xsl:text>)</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template name="normen-value">
        <xsl:variable name="items" select="akn:meta/akn:analysis/akn:otherReferences/akn:implicitReference/ris:referenzNorm" />
        <xsl:choose>
            <xsl:when test="$items">
                <xsl:for-each select="$items">
                    <xsl:if test="position() > 1">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                    <xsl:if test="ris:abkuerzung != ''">
                        <xsl:value-of select="normalize-space(ris:abkuerzung)" />
                    </xsl:if>
                    <xsl:for-each select="ris:einzelnorm">
                        <xsl:if test="ris:bezeichnung != ''">
                            <xsl:text> </xsl:text>
                            <xsl:value-of select="normalize-space(ris:bezeichnung)" />
                        </xsl:if>
                        <xsl:if test="ris:fassungsdatum != ''">
                            <xsl:text> (</xsl:text>
                            <xsl:call-template name="format-date">
                                <xsl:with-param name="date" select="normalize-space(ris:fassungsdatum)" />
                            </xsl:call-template>
                            <xsl:text>)</xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>—</xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="documentnumber-value">
        <xsl:value-of select="akn:meta/akn:identification/akn:FRBRWork/akn:FRBRuri/@value" />
    </xsl:template>

    <xsl:template name="format-date">
        <xsl:param name="date" as="xs:string" />
        <xsl:choose>
            <xsl:when test="$date castable as xs:date">
                <xsl:value-of select="format-date(xs:date($date), '[D01].[M01].[Y0001]')" />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$date" />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
