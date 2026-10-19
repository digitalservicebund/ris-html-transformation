package de.bund.digitalservice.ris.html;

import de.bund.digitalservice.ris.html.service.xslt.BzstPdfXsltTransformer;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;

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
      doc.outputSettings().prettyPrint(true);
      Path out = Path.of("build/test-output/bzst-pdf.html");
      Files.createDirectories(out.getParent());
      Files.writeString(out, doc.outerHtml());
    }
  }

  @Test
  void hidesNormen() {
    assertThat(doc.select("template#verweisNormen")).isEmpty();
  }

  @Test
  void hidesVerwaltungsvorschriften() {
    assertThat(doc.select("template#verweisVerwaltungsvorschriften")).isEmpty();
  }

  @Test
  void hidesRechtsprechung() {
    assertThat(doc.select("template#referenzRechtsprechungen")).isEmpty();
  }

  @Test
  void rendersNormenkette() {
    assertThat(doc.select("template#referenzNormen li").eachText())
        .anyMatch(t -> t.contains("AStG"));
  }

  @Test
  void rendersFundstelle() {
    assertThat(doc.select("template#fundstellen li").eachText())
        .anyMatch(t -> t.contains("BStBl I"));
  }
}
