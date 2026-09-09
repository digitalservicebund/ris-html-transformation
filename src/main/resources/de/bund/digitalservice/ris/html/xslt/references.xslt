<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:akn="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
                xmlns:ris="http://rechtsinformationen.bund.de/schema/ris/0.1"
                xmlns:local="http://rechtsinformationen.bund.de/schema/ris/0.1"
                exclude-result-prefixes="ris xs akn local">

    <!-- Ignore the otherReferences container itself; its content is rendered separately via
         reference-list into the <template> blocks built in the html head. -->
    <xsl:template match="akn:otherReferences" />

    <!-- German month names, indexed by month-from-date() (1-12); Saxon HE's format-date only ships
         English localization data, so German dates are built manually with these. -->
    <xsl:variable name="local:german-months" as="xs:string+"
                  select="('Januar', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember')" />

    <!-- Joins the non-blank values of $parts with $separator, so that missing values don't leave
         behind stray or doubled separators. -->
    <xsl:function name="local:join-non-empty" as="xs:string">
        <xsl:param name="parts" as="xs:string*" />
        <xsl:param name="separator" as="xs:string" />
        <xsl:sequence select="string-join($parts[normalize-space(.) != ''], $separator)" />
    </xsl:function>

    <!-- Formats an ISO date (YYYY-MM-DD) in German long form, e.g. "5. Februar 2021". If $date is
         non-blank but not a valid ISO date (malformed/legacy data), it is displayed as-is instead
         of aborting the transformation. -->
    <xsl:function name="local:format-date" as="xs:string">
        <xsl:param name="date" as="xs:string?" />

        <xsl:variable name="trimmedDate" select="normalize-space($date)" />

        <xsl:variable name="parsedDate" as="xs:date?">
            <xsl:try>
                <xsl:sequence select="if ($trimmedDate != '') then xs:date($trimmedDate) else ()" />
                <xsl:catch>
                    <xsl:sequence select="()" />
                </xsl:catch>
            </xsl:try>
        </xsl:variable>

        <xsl:sequence select="
            if ($trimmedDate = '')
            then ''
            else if (empty($parsedDate))
            then $trimmedDate
            else concat(
                string(day-from-date($parsedDate)), '. ',
                $local:german-months[month-from-date($parsedDate)], ' ',
                string(year-from-date($parsedDate)))" />
    </xsl:function>

    <!-- Formats a court decision reference (referenzRechtsprechung, vorgehendeEntscheidung,
         nachgehendeEntscheidung) as:
         "<gerichtstyp> <gerichtsort>, <dokumenttyp> vom <entscheidungsdatum|mitteilungsdatum> - <aktenzeichen>".
         Any missing value is left out without leaving stray separators behind. -->
    <xsl:function name="local:format-court-decision-reference" as="xs:string">
        <xsl:param name="reference" as="element()" />

        <xsl:variable name="gericht" select="local:join-non-empty(($reference/ris:gericht/ris:gerichtstyp, $reference/ris:gericht/ris:gerichtsort), ' ')" />
        <xsl:variable name="datum" select="($reference/ris:entscheidungsdatum, $reference/ris:mitteilungsdatum)[1]" />
        <xsl:variable name="datumMitPraefix" select="if ($datum) then concat('vom ', local:format-date($datum)) else ''" />
        <xsl:variable name="dokumenttypMitDatum" select="local:join-non-empty(($reference/ris:dokumenttyp, $datumMitPraefix), ' ')" />
        <xsl:variable name="main" select="local:join-non-empty(($gericht, $dokumenttypMitDatum), ', ')" />

        <xsl:sequence select="local:join-non-empty(($main, $reference/ris:aktenzeichen), ' - ')" />
    </xsl:function>

    <!-- Formats a vorgehendeEntscheidung/nachgehendeEntscheidung reference like
         local:format-court-decision-reference, additionally appending " (anhängig)" when @art is
         "anhängig". -->
    <xsl:function name="local:format-entscheidung-reference" as="xs:string">
        <xsl:param name="reference" as="element()" />

        <xsl:variable name="formatted" select="local:format-court-decision-reference($reference)" />
        <xsl:variable name="anhaengigSuffix" select="if ($reference/@art = 'anhängig') then '(anhängig)' else ''" />

        <xsl:sequence select="local:join-non-empty(($formatted, $anhaengigSuffix), ' ')" />
    </xsl:function>

    <!-- Formats a fundstelle (periodikum + zitatstelle) as "<periodikum> <zitatstelle>", using the
         periodikum's abkuerzung and falling back to its titel when no abkuerzung is given. -->
    <xsl:function name="local:format-fundstelle" as="xs:string">
        <xsl:param name="fundstelle" as="element()?" />

        <xsl:variable name="periodikum" select="($fundstelle/ris:periodikum/ris:abkuerzung, $fundstelle/ris:periodikum/ris:titel)[1]" />

        <xsl:sequence select="local:join-non-empty(($periodikum, $fundstelle/ris:zitatstelle), ' ')" />
    </xsl:function>

    <!-- Formats a referenzVerwaltungsvorschrift reference as "<jurisAbkuerzung>, <fundstelle>". -->
    <xsl:function name="local:format-verwaltungsvorschrift-reference" as="xs:string">
        <xsl:param name="reference" as="element()" />

        <xsl:sequence select="local:join-non-empty(($reference/ris:jurisAbkuerzung, local:format-fundstelle($reference/ris:fundstelle)), ', ')" />
    </xsl:function>

    <!-- Formats a referenzUnselbstaendigeLiteratur reference as "<autor>, <fundstelle>". -->
    <xsl:function name="local:format-unselbstaendige-literatur-reference" as="xs:string">
        <xsl:param name="reference" as="element()" />

        <xsl:sequence select="local:join-non-empty(($reference/ris:autor, local:format-fundstelle($reference/ris:fundstelle)), ', ')" />
    </xsl:function>

    <!-- Formats a referenzSelbstaendigeLiteratur reference as "<autor>, <titel>, <veroeffentlichungsjahr>". -->
    <xsl:function name="local:format-selbstaendige-literatur-reference" as="xs:string">
        <xsl:param name="reference" as="element()" />

        <xsl:sequence select="local:join-non-empty(($reference/ris:autor, $reference/ris:titel, $reference/ris:veroeffentlichungsjahr), ', ')" />
    </xsl:function>

    <!-- Formats one einzelnorm as "<abkuerzung> <bezeichnung>, vom <fassungsdatum>,
         <gesetzeskraftTyp> <geltungsbereich>", leaving out whichever of these values is missing. -->
    <xsl:function name="local:format-einzelnorm" as="xs:string">
        <xsl:param name="abkuerzung" as="xs:string?" />
        <xsl:param name="einzelnorm" as="element()" />

        <xsl:variable name="bezeichnungMitAbkuerzung" select="local:join-non-empty(($abkuerzung, $einzelnorm/ris:bezeichnung), ' ')" />
        <xsl:variable name="datum" select="if ($einzelnorm/ris:fassungsdatum) then concat('vom ', local:format-date($einzelnorm/ris:fassungsdatum)) else ''" />
        <xsl:variable name="gesetzeskraft" select="local:join-non-empty(($einzelnorm/ris:gesetzeskraft/ris:gesetzeskraftTyp, $einzelnorm/ris:gesetzeskraft/ris:geltungsbereich), ' ')" />

        <xsl:sequence select="local:join-non-empty(($bezeichnungMitAbkuerzung, $datum, $gesetzeskraft), ', ')" />
    </xsl:function>

    <!-- Formats a referenzNorm reference as a Normenkette: the abkuerzung (with its titel appended
         when present) combined with each einzelnorm's details via local:format-einzelnorm, joined by
         ', '. When there are no einzelnorm children, just the abkuerzung/titel is used. Missing
         values are left out without leaving stray separators behind. -->
    <xsl:function name="local:format-norm-reference" as="xs:string">
        <xsl:param name="reference" as="element()" />

        <xsl:variable name="abkuerzung" select="$reference/ris:abkuerzung" />
        <xsl:variable name="abkuerzungMitTitel" select="local:join-non-empty(($abkuerzung, $reference/ris:titel), ', ')" />
        <xsl:variable name="einzelnormen" select="$reference/ris:einzelnorm" />

        <xsl:sequence select="
            if (empty($einzelnormen))
            then $abkuerzungMitTitel
            else local:join-non-empty(
                for $einzelnorm in $einzelnormen return local:format-einzelnorm($abkuerzungMitTitel, $einzelnorm),
                ', ')" />
    </xsl:function>

    <!-- Builds a template block (identified by $id) containing one ul of the given references, with
         each reference rendered as a li. $format selects how the li text is built: 'court-decision',
         'entscheidung', 'verwaltungsvorschrift', 'uli', 'sli' and 'normenkette' use the formatting
         functions above, while 'default' (the default) joins the reference's own values with ', '.
         If a reference has a referenzURI (risUri) and a $linkBasePath was given, the li content is
         wrapped in a link built from $linkBasePath and the reference's dokumentnummer. -->
    <xsl:template name="reference-list">
        <xsl:param name="id" as="xs:string" />
        <xsl:param name="references" />
        <xsl:param name="linkBasePath" as="xs:string" select="''" />
        <xsl:param name="format" as="xs:string" select="'default'" />

        <xsl:if test="$references">
            <template id="{$id}">
                <ul>
                    <xsl:for-each select="$references">
                        <li>
                            <xsl:variable name="text" as="xs:string">
                                <xsl:choose>
                                    <xsl:when test="$format = 'entscheidung'">
                                        <xsl:sequence select="local:format-entscheidung-reference(.)" />
                                    </xsl:when>
                                    <xsl:when test="$format = 'court-decision'">
                                        <xsl:sequence select="local:format-court-decision-reference(.)" />
                                    </xsl:when>
                                    <xsl:when test="$format = 'verwaltungsvorschrift'">
                                        <xsl:sequence select="local:format-verwaltungsvorschrift-reference(.)" />
                                    </xsl:when>
                                    <xsl:when test="$format = 'uli'">
                                        <xsl:sequence select="local:format-unselbstaendige-literatur-reference(.)" />
                                    </xsl:when>
                                    <xsl:when test="$format = 'sli'">
                                        <xsl:sequence select="local:format-selbstaendige-literatur-reference(.)" />
                                    </xsl:when>
                                    <xsl:when test="$format = 'normenkette'">
                                        <xsl:sequence select="local:format-norm-reference(.)" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:sequence select="string-join(for $value in .//text()[normalize-space(.) != '' and not(ancestor::ris:referenzURI)] return normalize-space($value), ', ')" />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:choose>
                                <xsl:when test="$linkBasePath != '' and ris:referenzURI">
                                    <a href="{concat($linkBasePath, ris:dokumentnummer)}">
                                        <xsl:value-of select="$text" />
                                    </a>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$text" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </li>
                    </xsl:for-each>
                </ul>
            </template>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
