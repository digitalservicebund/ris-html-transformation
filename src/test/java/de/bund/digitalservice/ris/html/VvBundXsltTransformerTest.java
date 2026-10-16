package de.bund.digitalservice.ris.html;

import static org.assertj.core.api.Assertions.assertThat;

import de.bund.digitalservice.ris.html.service.xslt.VvBundXsltTransformer;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestInstance;

class VvBundXsltTransformerTest {

  private static final VvBundXsltTransformer TRANSFORMER = new VvBundXsltTransformer();
  private static final String SAMPLE_BASE_PATH = "/samples/vvbund/";

  @Nested
  @TestInstance(TestInstance.Lifecycle.PER_CLASS)
  class VvBundAllData {
    private String rawTransformedHtml;
    private Document doc;

    @BeforeAll
    void setup() throws IOException {
      rawTransformedHtml = transformResourceToString("vvbund_all_data.xml");
      doc = Jsoup.parse(rawTransformedHtml);
    }

    @Test
    void renders_Langueberschrift() {
      var title = "Bekanntmachung der Verfahrensordnung für die Vergabe öffentlicher ...";
      assertThat(doc.select("h1#title").text()).isEqualTo(title);
    }

    @Test
    void matches_expectedHtmlFile() throws IOException {
      String expectedRawHtml = readResourceToString("vvbund_all_data.html");

      assertThat(Jsoup.parse(rawTransformedHtml).html())
          .isEqualTo(Jsoup.parse(expectedRawHtml).html());
    }
  }

  @Nested
  @TestInstance(TestInstance.Lifecycle.PER_CLASS)
  class VvBundMinimalData {
    private String rawTransformedHtml;
    private Document doc;

    @BeforeAll
    void setup() throws IOException {
      rawTransformedHtml = transformResourceToString("vvbund_minimal_data.xml");
      doc = Jsoup.parse(rawTransformedHtml);
    }

    @Test
    void renders_withoutLangueberschrift() {
      var placeholderLongtitle = "Placeholder für die Amtliche Langüberschrift";
      assertThat(doc.select("h1#title").text()).isEqualTo(placeholderLongtitle);
    }

    @Test
    void matches_expectedHtmlFile() throws IOException {
      String expectedRawHtml = readResourceToString("vvbund_minimal_data.html");

      assertThat(Jsoup.parse(rawTransformedHtml).html())
          .isEqualTo(Jsoup.parse(expectedRawHtml).html());
    }
  }

  /** Reads an XML file from the classpath resources and applies the XSLT transformation. */
  private static String transformResourceToString(String filename) throws IOException {
    String path = SAMPLE_BASE_PATH + filename;
    try (InputStream inputStream = VvBundXsltTransformer.class.getResourceAsStream(path)) {
      assertThat(inputStream).withFailMessage("Could not find: " + path).isNotNull();
      return TRANSFORMER.transform(inputStream.readAllBytes());
    }
  }

  /** Reads a reference file from the classpath resources into a UTF-8 string. */
  private static String readResourceToString(String filename) throws IOException {
    String path = SAMPLE_BASE_PATH + filename;
    try (InputStream inputStream = VvBundXsltTransformer.class.getResourceAsStream(path)) {
      assertThat(inputStream).withFailMessage("Could not find: " + path).isNotNull();
      return new String(inputStream.readAllBytes(), StandardCharsets.UTF_8);
    }
  }
}
