package de.bund.digitalservice.ris.html;

import de.bund.digitalservice.ris.html.service.xslt.BzstXsltTransformer;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.Objects;

import static org.assertj.core.api.Assertions.assertThat;

class BzstXsltTransformerTest {

  private static final BzstXsltTransformer TRANSFORMER = new BzstXsltTransformer();
  private static final String SAMPLE_PATH = "/samples/bzst/bzst.xml";
  private static Document doc;

  @BeforeAll
  static void transform() throws IOException {
    try (InputStream is = BzstXsltTransformerTest.class.getResourceAsStream(SAMPLE_PATH)) {
      assertThat(is).withFailMessage("Could not find: " + SAMPLE_PATH).isNotNull();
      byte[] xml = is.readAllBytes();
      String html = TRANSFORMER.transform(xml);
      doc = Jsoup.parse(html);
      doc.outputSettings().prettyPrint(true);
      Path out = Path.of("build/test-output/bzst.html");
      Files.createDirectories(out.getParent());
      Files.writeString(out, doc.outerHtml());
    }
  }

  @Test
  void rendersLangtitel() {
    assertThat(doc.select("#header h1").text())
        .isEqualTo("Anwendung des § 1 Abs. 1 AStG bei Verrechnungspreisen mit nahestehenden Personen");
  }

  @Test
  void rendersZitierdatum() {
    assertThat(doc.select("#header dt").eachText()).contains("Zitierdatum");
    assertThat(doc.select("#header dd").eachText()).contains("01.04.2003");
  }

  @Test
  void rendersAktenzeichen() {
    assertThat(doc.select("#metadaten dt").eachText()).contains("Aktenzeichen");
    assertThat(doc.select("#metadaten").text())
        .contains("XYZ 123/7")
        .contains("XYZ 123/8");
  }

  @Test
  void rendersNormgeber() {
    assertThat(doc.select("#metadaten dt").eachText()).contains("Normgeber");
    assertThat(doc.select("#metadaten abbr").eachText()).contains("BMG");
    assertThat(doc.select("#metadaten abbr[title]").attr("title"))
        .isEqualTo("Bundesministerium des Geldes");
  }

  @Test
  void rendersDokumenttyp() {
    assertThat(doc.select("#metadaten dt").eachText()).contains("Dokumenttyp");
    assertThat(doc.select("#metadaten").text())
        .contains("BMF-Schreiben")
        .contains("Verwaltungsanweisung");
  }

  @Test
  void rendersInkrafttreten() {
    assertThat(doc.select("#metadaten dt").eachText()).contains("Inkrafttreten");
    assertThat(doc.select("#metadaten").text()).contains("01.04.2003");
  }

  @Test
  void rendersAusserkrafttreten() {
    assertThat(doc.select("#metadaten dt").eachText()).contains("Außerkrafttreten");
    assertThat(doc.select("#metadaten").text()).contains("unbefristet");
  }

  @Test
  void rendersAnwendungszeitraum() {
    assertThat(doc.select("#metadaten dt").eachText())
        .containsAll(List.of("Anwendungsbeginn", "Anwendungsende"));
    assertThat(doc.select("#metadaten").text()).contains("2003").contains("2023");
  }

  @Test
  void rendersNormenkette() {
    assertThat(doc.select("template#normenKette li").eachText())
        .contains("AStG § 1 Abs 1")
        .contains("EStG § 15 Abs 1");
  }

  @Test
  void rendersNormen() {
    assertThat(Objects.requireNonNull(doc.select("template#verweisNormen li").first()).text())
        .contains("KStG")
        .contains("§ 8a")
        .contains("Durchführungsvorschrift");
  }

  @Test
  void rendersVerwaltungsvorschriften() {
    assertThat(Objects.requireNonNull(doc.select("template#verweisVwv li").first()).text())
        .contains("VV Fantasie 2019");
  }

  @Test
  void rendersRechtsprechung() {
    assertThat(Objects.requireNonNull(doc.select("template#rspr li").first()).text())
        .contains("BFH München")
        .contains("I R 45/01");
  }

  @Test
  void rendersFundstelle() {
    assertThat(Objects.requireNonNull(doc.select("template#fundstelle li").first()).text())
        .contains("BStBl I")
        .contains("Ausgabe A")
        .contains("2042, 42");
  }
}
