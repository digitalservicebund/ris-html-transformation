package de.bund.digitalservice.ris.html;

import de.bund.digitalservice.ris.html.service.xslt.BzstPdfXsltTransformer;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.io.InputStream;

import static org.assertj.core.api.Assertions.assertThat;

class BzstPdfXsltTransformerTest {

  private static final BzstPdfXsltTransformer TRANSFORMER = new BzstPdfXsltTransformer();
  private static final String SAMPLE_PATH = "/samples/bzst/bzst.xml";
  private static Document doc;

  @BeforeAll
  static void transform() throws IOException {
    try (InputStream is = BzstPdfXsltTransformerTest.class.getResourceAsStream(SAMPLE_PATH)) {
      assertThat(is).withFailMessage("Could not find: " + SAMPLE_PATH).isNotNull();
      doc = Jsoup.parse(TRANSFORMER.transform(is.readAllBytes()));
    }
  }

  @Test
  void hidesNormen() {
    assertThat(doc.select("#referenzen h3").eachText()).doesNotContain("Normen");
  }

  @Test
  void hidesVerwaltungsvorschriften() {
    assertThat(doc.select("#referenzen h3").eachText()).doesNotContain("Verwaltungsvorschriften");
  }

  @Test
  void hidesRechtsprechung() {
    assertThat(doc.select("#referenzen h3").eachText()).doesNotContain("Rechtsprechung");
  }

  @Test
  void rendersNormenkette() {
    assertThat(doc.select("#referenzen h3").eachText()).contains("Normenkette");
    assertThat(doc.select("#referenzen").text()).contains("AStG");
  }

  @Test
  void rendersFundstelle() {
    assertThat(doc.select("#referenzen h3").eachText()).contains("Fundstelle");
    assertThat(doc.select("#referenzen").text()).contains("BStBl I");
  }
}
