package de.bund.digitalservice.ris.html;

import de.bund.digitalservice.ris.html.service.xslt.CaselawXsltTransformer;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.Objects;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;


class CaselawPortalCompatibilityTest {

  private static final CaselawXsltTransformer XSLT_TRANSFORMER = new CaselawXsltTransformer();
  private static final String SAMPLE_BASE_PATH = "/samples/caselaw/";
  private static final String API_RESOURCE_BASE_PATH = "api/v1/";
  private static final String RESOURCE_NOT_FOUND_MESSAGE = "Could not find local sample file at classpath: ";

  @Test
  void testHeadingHasCorrectId() throws IOException {
    /** The id is used to extract the title from the HTML.
     * If the transformation of the heading in the xslt transformation
     * changes unexpectedly and thus breaks the frontend rendering, this test will fail. **/
    String sampleLDMLPath = SAMPLE_BASE_PATH + "all_sections.xml";
    String sampleHTMLPath = SAMPLE_BASE_PATH + "all_sections.html";

    byte[] ldmlBytes = readResourceAsBytes(sampleLDMLPath);
    String expectedHTML = readResourceAsString(sampleHTMLPath);

    String actualHtml = XSLT_TRANSFORMER.transformCaseLaw(ldmlBytes, API_RESOURCE_BASE_PATH);
    assertHtmlEqualsIgnoringWhitespace(expectedHTML, actualHtml);

    assertTrue(actualHtml.contains("id=\"title\""));
  }

  @Test
  void testSectionsHaveCorrectIdsAndOrder() throws IOException {
    /** The generation of the TabledOfContents relies on the headings having specific ids.
     * If the transformation of the headings in the xslt transformation changes unexpectedly
     * and thus breaks the frontend rendering, this test will fail. **/
    String sampleLDMLPath = SAMPLE_BASE_PATH + "all_sections.xml";
    String sampleHTMLPath = SAMPLE_BASE_PATH + "all_sections.html";

    byte[] ldmlBytes = readResourceAsBytes(sampleLDMLPath);
    String expectedHTML = readResourceAsString(sampleHTMLPath);

    String actualHtml = XSLT_TRANSFORMER.transformCaseLaw(ldmlBytes, API_RESOURCE_BASE_PATH);
    assertHtmlEqualsIgnoringWhitespace(expectedHTML, actualHtml);

    String[] expectedOrder = {
            "id=\"leitsatz\"",
            "id=\"orientierungssatz\"",
            "id=\"sonstigerOrientierungssatz\"",
            "id=\"gliederung\"",
            "id=\"tatbestand\"",
            "id=\"entscheidungsgruende\"",
            "id=\"gruende\"",
            "id=\"sonstigerLangtext\"",
            "id=\"abweichendeMeinung\""
    };

    for (String id : expectedOrder) {
      assertTrue(actualHtml.contains(id), "Missing expected heading ID: " + id);
    }

    for (int i = 0; i < expectedOrder.length - 1; i++) {
      String currentId = expectedOrder[i];
      String nextId = expectedOrder[i + 1];

      int currentIndex = actualHtml.indexOf(currentId);
      int nextIndex = actualHtml.indexOf(nextId);

      assertTrue(nextIndex > currentIndex,
              String.format("Order violation: '%s' (index %d) should appear before '%s' (index %d)",
                      currentId, currentIndex, nextId, nextIndex));
    }
  }

  @Test
  void testTransformsCaselawBorderNumbersCorrectly() throws IOException {
    /**
     * If the rendering of the broder numbers changes, the portal would have to adapt the CSS in the
     * frontend to display the border numbers correctly. This test ensures that the
     * transformation of the border numbers in the xslt transformation does not change
     * unexpectedly and thus break the frontend rendering. **/
    String sampleLDMLPath = SAMPLE_BASE_PATH + "bordernumbers.xml";
    String sampleHTMLPath = SAMPLE_BASE_PATH + "bordernumbers.html";

    byte[] ldmlBytes = readResourceAsBytes(sampleLDMLPath);
    String expectedHTML = readResourceAsString(sampleHTMLPath);

    var actualHtml = XSLT_TRANSFORMER.transformCaseLaw(ldmlBytes, API_RESOURCE_BASE_PATH);

    assertNotNull(actualHtml);
    assertHtmlEqualsIgnoringWhitespace(expectedHTML, actualHtml);
    assertAll(
        () -> assertTrue(actualHtml.contains("id=\"randnummer-1\"")),
        () -> assertTrue(actualHtml.contains("id=\"randnummer-2\"")),
        () -> assertTrue(actualHtml.contains("Example Tatbestand/CaseFacts. More background")),
        () -> assertTrue(actualHtml.contains("even more background")));
  }

  @Test
  void testTablesAreTransferredCorrectly() throws IOException {
    /** The current structure is needed for styling, especially for setting the table
     * width to allow horizontal scrolling when the table is too wide for our layout. **/

    String sampleLDMLPath = SAMPLE_BASE_PATH + "table.xml";
    String sampleHTMLPath = SAMPLE_BASE_PATH + "table.html";

    byte[] ldmlBytes = readResourceAsBytes(sampleLDMLPath);
    String expectedHTML = readResourceAsString(sampleHTMLPath);

    var actualHtml = XSLT_TRANSFORMER.transformCaseLaw(ldmlBytes, API_RESOURCE_BASE_PATH);

    assertNotNull(actualHtml);
    assertHtmlEqualsIgnoringWhitespace(expectedHTML, actualHtml);
  }

  @Test
  void testImagetagsAreTransferredCorrectly() throws IOException {
    /** Important here is that the src attribute is correctly set,
     * so that the backend can provide the right image from the bucket. **/
    String sampleLDMLPath = SAMPLE_BASE_PATH + "image.xml";
    String sampleHTMLPath = SAMPLE_BASE_PATH + "image.html";

    byte[] ldmlBytes = readResourceAsBytes(sampleLDMLPath);
    String expectedHTML = readResourceAsString(sampleHTMLPath);

    var actualHtml = XSLT_TRANSFORMER.transformCaseLaw(ldmlBytes, API_RESOURCE_BASE_PATH);

    assertNotNull(actualHtml);
    assertHtmlEqualsIgnoringWhitespace(expectedHTML, actualHtml);
  }



  private byte[] readResourceAsBytes(String classpath) throws IOException {
    try (InputStream inputStream = getClass().getResourceAsStream(classpath)) {
      assertNotNull(inputStream, RESOURCE_NOT_FOUND_MESSAGE + classpath);
      return inputStream.readAllBytes();
    }
  }

  private String readResourceAsString(String classpath) throws IOException {
    return new String(readResourceAsBytes(classpath), StandardCharsets.UTF_8);
  }

  private void assertHtmlEqualsIgnoringWhitespace(String expected, String actual) {
    assertEquals(
        normalizeWhitespace(expected),
        normalizeWhitespace(actual),
        "Transformed HTML should match expected HTML ignoring whitespace differences");
  }

  private String normalizeWhitespace(String content) {
    return Objects.requireNonNull(content).replaceAll("\\s+", "");
  }
}
