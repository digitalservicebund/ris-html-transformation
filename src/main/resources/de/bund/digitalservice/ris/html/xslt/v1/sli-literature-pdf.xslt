<?xml version="1.0" encoding="UTF-8"?>
<!-- SLI literature documents in the V1 format, rendered as HTML for PDF generation. -->
<xsl:stylesheet version="2.0"
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:akn="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
				xmlns:ris="http://rechtsinformationen.bund.de/schema/ris/0.1"
				exclude-result-prefixes="akn ris">

	<xsl:import href="sli-literature.xslt"/>

	<xsl:output method="html" encoding="UTF-8" indent="yes"/>

	<!-- ================================================================
	     Section visibility overrides for PDF rendering.
	     Only list params whose value differs from sli-literature.xslt defaults.
	     ================================================================ -->

	<xsl:param name="show-aktivzitierung-rechtsprechung"              select="false()"/>
	<xsl:param name="show-aktivzitierung-unselbststaendige-literatur" select="false()"/>
	<xsl:param name="show-aktivzitierung-selbststaendige-literatur"   select="false()"/>

</xsl:stylesheet>
