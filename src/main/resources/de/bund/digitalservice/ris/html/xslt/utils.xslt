<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:local="http://rechtsinformationen.bund.de/schema/ris/0.1"
                exclude-result-prefixes="xs local">

    <!-- Formats an ISO date (YYYY-MM-DD) in German long form, e.g. "5. Februar 2021". If $date is
         not a valid ISO date (blank/malformed/legacy data), it is displayed as-is instead of
         aborting the transformation. -->
    <xsl:function name="local:format-date-long" as="xs:string">
        <xsl:param name="date" as="xs:string" />

        <xsl:variable name="formatted">
            <xsl:choose>
                <xsl:when test="$date castable as xs:date">
                    <xsl:value-of select="format-date(xs:date($date), '[D1]. ')" />
                    <xsl:choose>
                        <!-- XSLT 1.0 has no locale-supported date formatting -->
                        <xsl:when test="format-date(xs:date($date), '[M01]') = '01'">Januar</xsl:when>
                        <xsl:when test="format-date(xs:date($date), '[M01]') = '02'">Februar</xsl:when>
                        <xsl:when test="format-date(xs:date($date), '[M01]') = '03'">März</xsl:when>
                        <xsl:when test="format-date(xs:date($date), '[M01]') = '04'">April</xsl:when>
                        <xsl:when test="format-date(xs:date($date), '[M01]') = '05'">Mai</xsl:when>
                        <xsl:when test="format-date(xs:date($date), '[M01]') = '06'">Juni</xsl:when>
                        <xsl:when test="format-date(xs:date($date), '[M01]') = '07'">Juli</xsl:when>
                        <xsl:when test="format-date(xs:date($date), '[M01]') = '08'">August</xsl:when>
                        <xsl:when test="format-date(xs:date($date), '[M01]') = '09'">September</xsl:when>
                        <xsl:when test="format-date(xs:date($date), '[M01]') = '10'">Oktober</xsl:when>
                        <xsl:when test="format-date(xs:date($date), '[M01]') = '11'">November</xsl:when>
                        <xsl:when test="format-date(xs:date($date), '[M01]') = '12'">Dezember</xsl:when>
                    </xsl:choose>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="format-date(xs:date($date), '[Y0001]')" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$date" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:sequence select="string($formatted)" />
    </xsl:function>
</xsl:stylesheet>
