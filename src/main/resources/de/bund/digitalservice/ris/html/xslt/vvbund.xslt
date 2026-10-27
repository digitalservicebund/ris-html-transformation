<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:akn="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
                xmlns:ris="http://rechtsinformationen.bund.de/schema/ris/0.1"
                exclude-result-prefixes="akn ris">

    <xsl:output method="html" encoding="UTF-8" indent="yes"/>

    <xsl:template match="/">
        <html lang="de">
            <head>
                <meta charset="utf-8" />
                <title>
                    <xsl:value-of select="normalize-space((//akn:longTitle//akn:docTitle, //akn:longTitle//akn:shortTitle)[1])" />
                </title>
            </head>
            <body>
                <xsl:apply-templates select="(//akn:longTitle)[1]" />
            </body>
        </html>
    </xsl:template>

    <xsl:template match="akn:longTitle">
        <h1 id="title">
            <xsl:value-of select="normalize-space((.//akn:docTitle, .//akn:shortTitle)[1])" />
        </h1>
    </xsl:template>
</xsl:stylesheet>