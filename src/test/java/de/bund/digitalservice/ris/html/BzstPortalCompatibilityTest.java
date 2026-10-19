package de.bund.digitalservice.ris.html;

import static org.assertj.core.api.Assertions.assertThat;

import de.bund.digitalservice.ris.html.service.xslt.BzstXsltTransformer;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Objects;
import org.jsoup.Jsoup;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

class BzstPortalCompatibilityTest {

  private static final BzstXsltTransformer XSLT_TRANSFORMER = new BzstXsltTransformer();
  private static final String SAMPLE_BASE_PATH = "/samples/bzst/";
  private static final String RESOURCE_NOT_FOUND_MESSAGE =
      "Could not find local sample file at classpath: ";
  private static String actualHtml;

  @BeforeAll
  static void transform() throws IOException {
    try (InputStream is =
        BzstPortalCompatibilityTest.class.getResourceAsStream(SAMPLE_BASE_PATH + "bzst.xml")) {
      assertThat(is)
          .withFailMessage(RESOURCE_NOT_FOUND_MESSAGE + SAMPLE_BASE_PATH + "bzst.xml")
          .isNotNull();
      actualHtml = XSLT_TRANSFORMER.transform(is.readAllBytes());
      Path out = Path.of("build/test-output/bzst-portal-compatibility.html");
      Files.createDirectories(out.getParent());
      Files.writeString(out, Jsoup.parse(actualHtml).outerHtml());
    }
  }

  @Test
  void testTransform_bzstSample_matchesExpectedHtml() throws IOException {
    String expectedHTML = readResourceAsString(SAMPLE_BASE_PATH + "bzst.html");
    assertHtmlEqualsIgnoringWhitespace(expectedHTML, actualHtml);
  }

  @Test
  void testTransform_bzstSample_templateIdsArePresent() {

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
      assertThat(actualHtml).withFailMessage("Missing expected template ID: %s", id).contains(id);
    }
  }

  private byte[] readResourceAsBytes(String classpath) throws IOException {
    try (InputStream inputStream = getClass().getResourceAsStream(classpath)) {
      assertThat(inputStream).withFailMessage(RESOURCE_NOT_FOUND_MESSAGE + classpath).isNotNull();
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
