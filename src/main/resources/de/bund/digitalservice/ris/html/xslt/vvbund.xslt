<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:ris="http://rechtsinformationen.bund.de/schema/ris/0.1"
                exclude-result-prefixes="ris">

    <xsl:output method="html" encoding="UTF-8" indent="yes" />

    <xsl:template match="/">
        <html lang="de">
            <head>
                <meta charset="utf-8" />
                <title><xsl:value-of select="normalize-space((//ris:langtitel)[1])" /></title>
            </head>
            <body>
                <xsl:apply-templates select="(//ris:langtitel)[1]" />
            </body>
        </html>
    </xsl:template>

    <xsl:template match="ris:langtitel">
        <h1 id="title"><xsl:value-of select="normalize-space(.)" /></h1>
    </xsl:template>
</xsl:stylesheet>
