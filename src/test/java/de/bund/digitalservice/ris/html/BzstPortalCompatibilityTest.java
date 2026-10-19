package de.bund.digitalservice.ris.html;

import de.bund.digitalservice.ris.html.service.xslt.BzstXsltTransformer;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Objects;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class BzstPortalCompatibilityTest {

  private static final BzstXsltTransformer XSLT_TRANSFORMER = new BzstXsltTransformer();
  private static final String SAMPLE_BASE_PATH = "/samples/bzst/";
  private static final String RESOURCE_NOT_FOUND_MESSAGE = "Could not find local sample file at classpath: ";

  @Test
  void testTransform_bzstSample_matchesExpectedHtml() throws IOException {
    String sampleLDMLPath = SAMPLE_BASE_PATH + "bzst.xml";
    String sampleHTMLPath = SAMPLE_BASE_PATH + "bzst.html";

    byte[] ldmlBytes = readResourceAsBytes(sampleLDMLPath);
    String expectedHTML = readResourceAsString(sampleHTMLPath);

    String actualHtml = XSLT_TRANSFORMER.transform(ldmlBytes);
    assertHtmlEqualsIgnoringWhitespace(expectedHTML, actualHtml);
  }

  @Test
  void testTransform_bzstSample_templateIdsArePresent() throws IOException {
    byte[] ldmlBytes = readResourceAsBytes(SAMPLE_BASE_PATH + "bzst.xml");
    String actualHtml = XSLT_TRANSFORMER.transform(ldmlBytes);

    String[] expectedTemplateIds = {
        "id=\"aktenzeichen\"",
        "id=\"normgeber\"",
        "id=\"dokumenttypen\"",
        "id=\"fundstellen\"",
        "id=\"verweisNormen\"",
        "id=\"referenzNormen\"",
        "id=\"verweisVerwaltungsvorschriften\"",
        "id=\"referenzRechtsprechungen\""
    };

    for (String id : expectedTemplateIds) {
      assertThat(actualHtml)
          .withFailMessage("Missing expected template ID: %s", id)
          .contains(id);
    }
  }

  private byte[] readResourceAsBytes(String classpath) throws IOException {
    try (InputStream inputStream = getClass().getResourceAsStream(classpath)) {
      assertThat(inputStream)
          .withFailMessage(RESOURCE_NOT_FOUND_MESSAGE + classpath)
          .isNotNull();
      return inputStream.readAllBytes();
    }
  }

  private String readResourceAsString(String classpath) throws IOException {
    return new String(readResourceAsBytes(classpath), StandardCharsets.UTF_8);
  }

  private void assertHtmlEqualsIgnoringWhitespace(String expected, String actual) {
    assertThat(normalizeWhitespace(actual)).isEqualTo(normalizeWhitespace(expected));
  }

  private String normalizeWhitespace(String content) {
    return Objects.requireNonNull(content).replaceAll("\\s+", "");
  }
}
