package de.bund.digitalservice.ris.html;

import de.bund.digitalservice.ris.html.service.xslt.VvBundXsltTransformer;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.Objects;
import org.jsoup.Jsoup;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class VvBundXsltTransformerTest {

  private static final VvBundXsltTransformer TRANSFORMER = new VvBundXsltTransformer();
  private static final String SAMPLE_BASE_PATH = "/samples/vvbund/";
  private static final String TITLE =
      "Bekanntmachung der Verfahrensordnung für die Vergabe öffentlicher Liefer- und Dienstleistungsaufträge unterhalb der EU-Schwellenwerte (Unterschwellenvergabeordnung – UVgO) – Ausgabe 2017 –";

  @Test
  void transformsLangtitelSample() throws IOException {
    String actualHtml = transformSample("langtitel");

    assertHtmlEqualsIgnoringWhitespace(readResourceAsString("langtitel.html"), actualHtml);
    var document = Jsoup.parse(actualHtml);
    assertThat(document.select("h1#title").text()).isEqualTo(TITLE);
    assertThat(document.title()).isEqualTo(TITLE);
  }

  @Test
  void transformsSampleWithoutLangtitel() throws IOException {
    String actualHtml = transformSample("without_langtitel");

    assertHtmlEqualsIgnoringWhitespace(readResourceAsString("without_langtitel.html"), actualHtml);
    var document = Jsoup.parse(actualHtml);
    assertThat(document.select("h1#title")).isEmpty();
    assertThat(document.title()).isEmpty();
  }

  private String transformSample(String sampleName) throws IOException {
    return TRANSFORMER.transform(readResourceAsBytes(sampleName + ".xml"));
  }

  private byte[] readResourceAsBytes(String filename) throws IOException {
    String resourcePath = SAMPLE_BASE_PATH + filename;
    try (InputStream inputStream = getClass().getResourceAsStream(resourcePath)) {
      assertThat(inputStream).withFailMessage("Could not find: " + resourcePath).isNotNull();
      return inputStream.readAllBytes();
    }
  }

  private String readResourceAsString(String filename) throws IOException {
    return new String(readResourceAsBytes(filename), StandardCharsets.UTF_8);
  }

  private void assertHtmlEqualsIgnoringWhitespace(String expected, String actual) {
    assertThat(normalizeWhitespace(actual)).isEqualTo(normalizeWhitespace(expected));
  }

  private String normalizeWhitespace(String content) {
    return Objects.requireNonNull(content).replaceAll("\\s+", "");
  }
}

