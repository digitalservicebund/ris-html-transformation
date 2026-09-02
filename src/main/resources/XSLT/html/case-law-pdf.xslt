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
                <dl class="metadata-pdf">
                    <xsl:call-template name="stand-pdf" />
                    <xsl:call-template name="link-portal" />
                </dl>

                <xsl:call-template name="judgment-title"/>

                <dl class="metadata">
                    <xsl:call-template name="dokumenttyp-metadata" />
                    <xsl:call-template name="ecli-metadata" />
                    <xsl:call-template name="entscheidungsdatum-metadata" />
                    <xsl:call-template name="aktenzeichen-metadata" />
                    <xsl:call-template name="gericht-metadata" />
                    <xsl:call-template name="spruchkoerper-metadata" />
                    <xsl:call-template name="streitjahre-metadata" />
                    <xsl:call-template name="vorabdokument-metadata" />
                    <xsl:call-template name="vorgehende-entscheidungen-metadata" />
                    <xsl:call-template name="nachgehende-entscheidungen-metadata" />
                    <xsl:call-template name="nachgehende-entscheidungen-anhaengig-metadata" />
                    <xsl:call-template name="normen-metadata" />
                </dl>

                <div class="langtexte">
                    <xsl:call-template name="judgment-content"/>
                </div>
            </body>
        </html>
    </xsl:template>

    <xsl:template name="metadata-row">
        <xsl:param name="label" as="xs:string" />
        <xsl:param name="value" as="item()*" />
        <xsl:param name="label-lines" as="xs:string" select="'1'"/>
        <div>
            <xsl:attribute name="class">label-lines-<xsl:value-of select="$label-lines" /></xsl:attribute>
            <dt><xsl:value-of select="$label" /></dt>
            <dd><xsl:copy-of select="$value" /></dd>
        </div>
    </xsl:template>

    <xsl:template name="stand-pdf">
        <xsl:call-template name="metadata-row">
            <xsl:with-param name="label" select="'Stand PDF:'" />
            <xsl:with-param name="value" select="format-dateTime(current-dateTime(), '[D01].[M01].[Y0001], [H01]:[m01] Uhr')" />
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="link-portal">
        <xsl:call-template name="metadata-row">
            <xsl:with-param name="label" select="'Link Portal:'" />
            <xsl:with-param name="value">
                <a>
                    <xsl:attribute name="href">
                        <xsl:text>https://testphase.rechtsinformationen.bund.de/gerichtsentscheidungen/</xsl:text>
                        <xsl:call-template name="documentnumber-value" />
                    </xsl:attribute>
                    <xsl:text>https://testphase.rechtsinformationen.bund.de/gerichtsentscheidungen/</xsl:text>
                    <xsl:call-template name="documentnumber-value" />
                </a>
            </xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="dokumenttyp-metadata">
        <xsl:call-template name="metadata-row">
            <xsl:with-param name="label" select="'Dokumenttyp:'" />
            <xsl:with-param name="value"><xsl:call-template name="dokumenttyp-value" /></xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="ecli-metadata">
        <xsl:call-template name="metadata-row">
            <xsl:with-param name="label" select="'ECLI:'" />
            <xsl:with-param name="value"><xsl:call-template name="ecli-value" /></xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="entscheidungsdatum-metadata">
        <xsl:call-template name="metadata-row">
            <xsl:with-param name="label" select="'Entscheidungsdatum:'" />
            <xsl:with-param name="value"><xsl:call-template name="entscheidungsdatum-value" /></xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="aktenzeichen-metadata">
        <xsl:call-template name="metadata-row">
            <xsl:with-param name="label" select="'Aktenzeichen:'" />
            <xsl:with-param name="value"><xsl:call-template name="aktenzeichen-value" /></xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="gericht-metadata">
        <xsl:call-template name="metadata-row">
            <xsl:with-param name="label" select="'Gericht:'" />
            <xsl:with-param name="value"><xsl:call-template name="gericht-value" /></xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="spruchkoerper-metadata">
        <xsl:call-template name="metadata-row">
            <xsl:with-param name="label" select="'Spruchkörper:'" />
            <xsl:with-param name="value"><xsl:call-template name="spruchkoerper-value" /></xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="streitjahre-metadata">
        <xsl:call-template name="metadata-row">
            <xsl:with-param name="label" select="'Streitjahr:'" />
            <xsl:with-param name="value"><xsl:call-template name="streitjahre-value" /></xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="vorabdokument-metadata">
        <xsl:call-template name="metadata-row">
            <xsl:with-param name="label" select="'Vorabdokument:'" />
            <xsl:with-param name="value"><xsl:call-template name="vorabdokument-value" /></xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="vorgehende-entscheidungen-metadata">
        <xsl:call-template name="metadata-row">
            <xsl:with-param name="label" select="'Vorgehende Entscheidungen:'" />
            <xsl:with-param name="label-lines">2</xsl:with-param>
            <xsl:with-param name="value"><xsl:call-template name="vorgehende-entscheidungen-value" /></xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="nachgehende-entscheidungen-metadata">
        <xsl:call-template name="metadata-row">
            <xsl:with-param name="label" select="'Nachgehende Entscheidungen:'" />
            <xsl:with-param name="label-lines">2</xsl:with-param>
            <xsl:with-param name="value"><xsl:call-template name="nachgehende-entscheidungen-value" /></xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="nachgehende-entscheidungen-anhaengig-metadata">
        <xsl:call-template name="metadata-row">
            <xsl:with-param name="label" select="'Nachgehende Entscheidungen (anhängig):'" />
            <xsl:with-param name="label-lines">2</xsl:with-param>
            <xsl:with-param name="value"><xsl:call-template name="nachgehende-entscheidungen-anhaengig-value" /></xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="normen-metadata">
        <xsl:call-template name="metadata-row">
            <xsl:with-param name="label" select="'Norm:'" />
            <xsl:with-param name="value"><xsl:call-template name="normen-value" /></xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="aktenzeichen-value">
        <xsl:variable name="value" select="akn:meta/akn:identification/akn:FRBRWork/akn:FRBRalias[@eId='aktenzeichen']/@value" />
        <xsl:choose>
            <xsl:when test="$value != ''">
                <xsl:value-of select="$value" />
            </xsl:when>
            <xsl:otherwise><xsl:call-template name="placeholder-value" /></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="dokumenttyp-value">
        <xsl:variable name="value" select="akn:meta/akn:proprietary/ris:meta/ris:dokumenttyp" />
        <xsl:choose>
            <xsl:when test="$value != ''">
                <xsl:value-of select="$value" />
            </xsl:when>
            <xsl:otherwise><xsl:call-template name="placeholder-value" /></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="ecli-value">
        <xsl:variable name="value" select="akn:meta/akn:identification/akn:FRBRWork/akn:FRBRalias[@name='ecli']/@value" />
        <xsl:choose>
            <xsl:when test="$value != ''">
                <xsl:value-of select="$value" />
            </xsl:when>
            <xsl:otherwise><xsl:call-template name="placeholder-value" /></xsl:otherwise>
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
            <xsl:otherwise><xsl:call-template name="placeholder-value" /></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="gericht-value">
        <xsl:variable name="value" select="akn:meta/akn:proprietary/ris:meta/ris:gericht/@showAs" />
        <xsl:choose>
            <xsl:when test="$value != ''">
                <xsl:value-of select="$value" />
            </xsl:when>
            <xsl:otherwise><xsl:call-template name="placeholder-value" /></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="spruchkoerper-value">
        <xsl:variable name="value" select="akn:meta/akn:proprietary/ris:meta/ris:gericht/ris:spruchkoerper" />
        <xsl:choose>
            <xsl:when test="$value != ''">
                <xsl:value-of select="$value" />
            </xsl:when>
            <xsl:otherwise><xsl:call-template name="placeholder-value" /></xsl:otherwise>
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
            <xsl:otherwise><xsl:call-template name="placeholder-value" /></xsl:otherwise>
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
                            <xsl:call-template name="rechtszug" />
                        </li>
                    </xsl:for-each>
                </ul>
            </xsl:when>
            <xsl:otherwise><xsl:call-template name="placeholder-value" /></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="nachgehende-entscheidungen-value">
        <xsl:variable name="items" select="akn:meta/akn:analysis/akn:otherReferences/akn:implicitReference/ris:nachgehendeEntscheidung[@art='nachgehend']" />
        <xsl:choose>
            <xsl:when test="$items">
                <ul>
                    <xsl:for-each select="$items">
                        <li>
                            <xsl:call-template name="rechtszug" />
                        </li>
                    </xsl:for-each>
                </ul>
            </xsl:when>
            <xsl:otherwise><xsl:call-template name="placeholder-value" /></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="nachgehende-entscheidungen-anhaengig-value">
        <xsl:variable name="items" select="akn:meta/akn:analysis/akn:otherReferences/akn:implicitReference/ris:nachgehendeEntscheidung[@art='anhängig']" />
        <xsl:choose>
            <xsl:when test="$items">
                <ul>
                    <xsl:for-each select="$items">
                        <li>
                            <xsl:call-template name="rechtszug" />
                        </li>
                    </xsl:for-each>
                </ul>
            </xsl:when>
            <xsl:otherwise><xsl:call-template name="placeholder-value" /></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="rechtszug">
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
                <ul>
                    <xsl:for-each select="$items">
                        <li>
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
                        </li>
                    </xsl:for-each>
                </ul>
            </xsl:when>
            <xsl:otherwise><xsl:call-template name="placeholder-value" /></xsl:otherwise>
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

    <xsl:template name="placeholder-value">—</xsl:template>
</xsl:stylesheet>
