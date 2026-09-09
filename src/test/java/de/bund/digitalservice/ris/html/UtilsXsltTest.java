package de.bund.digitalservice.ris.html;

import static org.assertj.core.api.Assertions.assertThat;

import java.io.StringReader;
import java.io.StringWriter;
import java.net.URL;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

class UtilsXsltTest {

  private static final String XSLT_BASE_PATH = "de/bund/digitalservice/ris/html/xslt/";

  private static final String WRAPPER_XSLT =
      """
      <?xml version="1.0" encoding="UTF-8"?>
      <xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                      xmlns:xs="http://www.w3.org/2001/XMLSchema"
                      xmlns:local="http://rechtsinformationen.bund.de/schema/ris/0.1">
          <xsl:include href="utils.xslt" />
          <xsl:output method="text" />
          <xsl:param name="date" as="xs:string" select="''" />
          <xsl:template match="/">
              <xsl:value-of select="local:format-date-long($date)" />
          </xsl:template>
      </xsl:stylesheet>
      """;

  @ParameterizedTest
  @CsvSource({
      "2021-02-05, 5. Februar 2021",
      "2013-06-10, 10. Juni 2013",
      "2020-01-01, 1. Januar 2020",
      "2020-12-31, 31. Dezember 2020",
      "'', ''",
      "not-a-date, not-a-date",
      "'2020-13-40', '2020-13-40'"
  })
  void formatsDateInGermanLongForm(String input, String expected) throws Exception {
    assertThat(formatDateLong(input)).isEqualTo(expected);
  }

  private String formatDateLong(String date) throws Exception {
    URL basePathUrl = getClass().getClassLoader().getResource(XSLT_BASE_PATH);
    assertThat(basePathUrl).withFailMessage("XSLT base path not found: " + XSLT_BASE_PATH).isNotNull();

    TransformerFactory transformerFactory = TransformerFactory.newInstance();
    Transformer transformer =
        transformerFactory.newTransformer(
            new StreamSource(new StringReader(WRAPPER_XSLT), basePathUrl.toString()));
    transformer.setParameter("date", date);

    StringWriter output = new StringWriter();
    transformer.transform(
        new StreamSource(new StringReader("<root/>")), new StreamResult(output));
    return output.toString();
  }
}
