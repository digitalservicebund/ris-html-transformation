package de.bund.digitalservice.ris.html;

import static org.assertj.core.api.Assertions.assertThat;

import de.bund.digitalservice.ris.html.service.xslt.UliLiteratureV1PdfXsltTransformer;
import java.io.IOException;
import java.io.InputStream;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

class UliLiteratureV1PdfXsltTransformerTest {

  private static final UliLiteratureV1PdfXsltTransformer TRANSFORMER =
      new UliLiteratureV1PdfXsltTransformer();
  private static final String SAMPLE_PATH = "/samples/literature/v1/uli/uli_all_data.xml";
  private static Document doc;

  @BeforeAll
  static void transform() throws IOException {
    try (InputStream is =
        UliLiteratureV1PdfXsltTransformerTest.class.getResourceAsStream(SAMPLE_PATH)) {
      assertThat(is).withFailMessage("Could not find: " + SAMPLE_PATH).isNotNull();
      doc = Jsoup.parse(TRANSFORMER.transform(is.readAllBytes()));
    }
  }

  @Test
  void hidesAktivzitierungRechtsprechung() {
    assertThat(doc.select("template#referenzRechtsprechungAktiv")).isEmpty();
  }

  @Test
  void rendersHaupttitel() {
    assertThat(doc.select("h1").text()).isEqualTo("Haupttitel mit \"Anführungszeichen\"");
  }

  @Test
  void rendersZusaetzlicheTitel() {
    assertThat(doc.select("section#zusaetzliche-titel p").eachText())
        .contains("Dokumentarischer Titel", "Haupttitelzusatz");
  }
}
