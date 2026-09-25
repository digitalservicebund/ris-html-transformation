<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:akn="http://docs.oasis-open.org/legaldocml/ns/akn/3.0"
                xmlns:ris="http://ldml.neuris.de/adm/bzst/meta/"
                exclude-result-prefixes="akn ris">

	<xsl:import href="bzst.xslt"/>

	<xsl:output method="html" version="5.0" encoding="UTF-8" indent="yes"/>

	<!-- ================================================================
	     Section visibility overrides for PDF rendering.
	     Only list params whose value differs from bzst.xslt defaults.
	     ================================================================ -->

	<xsl:param name="show-aktivverweisung"               select="false()"/>
	<xsl:param name="show-aktivzitierung-rechtsprechung" select="false()"/>

</xsl:stylesheet>
