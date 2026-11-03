package de.bund.digitalservice.ris.html.service.xslt;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import de.bund.digitalservice.ris.html.exception.FileTransformationException;
import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import java.io.StringReader;
import java.io.StringWriter;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.parallel.Isolated;

@Isolated("Captures System.err for Saxon diagnostics")
class XsltTransformerTest {
  private static final String AMBIGUOUS_STYLESHEET =
      """
      <xsl:stylesheet version="3.0"
          xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
        <xsl:output method="xml" omit-xml-declaration="yes"/>
        <xsl:template match="item">
          <result>first</result>
        </xsl:template>
        <xsl:template match="item">
          <result>second</result>
        </xsl:template>
      </xsl:stylesheet>
      """;

  @Test
  void transform_suppressesAmbiguousRuleWarningAndPreservesOutput() throws Exception {
    PrintStream originalErr = System.err;
    ByteArrayOutputStream diagnostics = new ByteArrayOutputStream();

    try (PrintStream capturedErr =
             new PrintStream(diagnostics, true, StandardCharsets.UTF_8)) {
      System.setErr(capturedErr);

      var defaultTransformer =
          TransformerFactory.newInstance()
              .newTransformer(new StreamSource(new StringReader(AMBIGUOUS_STYLESHEET)));
      StringWriter defaultOutput = new StringWriter();
      defaultTransformer.transform(
          new StreamSource(new StringReader("<item/>")),
          new StreamResult(defaultOutput));

      assertThat(diagnostics.toString(StandardCharsets.UTF_8))
          .contains("XTDE0540");
      assertThat(defaultOutput.toString()).isEqualTo("<result>second</result>");

      diagnostics.reset();

      String output = transform(AMBIGUOUS_STYLESHEET, "<item/>");

      assertThat(output).isEqualTo(defaultOutput.toString());
      assertThat(diagnostics.toString(StandardCharsets.UTF_8)).isEmpty();
    } finally {
      System.setErr(originalErr);
    }
  }

  @Test
  void transform_malformedXml_throwsFileTransformationException() {
    assertThatThrownBy(() -> transform(AMBIGUOUS_STYLESHEET, "<root>"))
        .isInstanceOf(FileTransformationException.class)
        .hasCauseInstanceOf(TransformerException.class);
  }

  @Test
  void transform_invalidStylesheet_throwsFileTransformationException() {
    String stylesheet =
        """
        <xsl:stylesheet version="3.0"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
          <xsl:template match="/">
            <xsl:invalid-instruction/>
          </xsl:template>
        </xsl:stylesheet>
        """;

    assertThatThrownBy(() -> transform(stylesheet, "<root/>"))
        .isInstanceOf(FileTransformationException.class)
        .hasCauseInstanceOf(TransformerException.class);
  }

  @Test
  void transform_runtimeError_throwsFileTransformationException() {
    String stylesheet =
        """
        <xsl:stylesheet version="3.0"
            xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
          <xsl:template match="/">
            <xsl:sequence select="error(
                QName('urn:test', 'TRANSFORMATION_FAILED'),
                'Deliberate runtime failure')"/>
          </xsl:template>
        </xsl:stylesheet>
        """;

    assertThatThrownBy(() -> transform(stylesheet, "<root/>"))
        .isInstanceOf(FileTransformationException.class)
        .hasMessageContaining("Deliberate runtime failure")
        .hasCauseInstanceOf(TransformerException.class);
  }

  private static String transform(String stylesheet, String xml) {
    var transformer =
        new XsltTransformer("de/bund/digitalservice/ris/html/xslt/", "unused.xslt") {
          @Override
          String getXslt() {
            return stylesheet;
          }
        };

    return transformer.transformLegalDocMlFromBytes(
        xml.getBytes(StandardCharsets.UTF_8), Map.of());
  }
}