package de.bund.digitalservice.ris.html;

import static org.assertj.core.api.Assertions.assertThat;

import de.bund.digitalservice.ris.html.service.xslt.BzstXsltTransformer;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;

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
  void rendersHtmlTitle() {
    assertThat(doc.title())
        .isEqualTo("Anwendung des § 1 Abs. 1 AStG bei Verrechnungspreisen mit nahestehenden Personen");
  }

  @Test
  void rendersLangtitel() {
    assertThat(doc.select("meta[name=amtliche-langueberschrift]").attr("content"))
        .isEqualTo("Anwendung des § 1 Abs. 1 AStG bei Verrechnungspreisen mit nahestehenden Personen");
  }

  @Test
  void rendersZitierdatum() {
    assertThat(doc.select("meta[name=zitierdatum]").attr("content"))
        .isEqualTo("01.04.2003");
  }

  @Test
  void rendersAktenzeichen() {
    assertThat(doc.select("template#aktenzeichen li").eachText())
        .contains("XYZ 123/7", "XYZ 123/8");
  }

  @Test
  void rendersNormgeber() {
    assertThat(doc.select("template#normgeber abbr").eachText()).contains("BMG");
    assertThat(doc.select("template#normgeber abbr[title]").attr("title"))
        .isEqualTo("Bundesministerium des Geldes");
  }

  @Test
  void rendersDokumenttyp() {
    assertThat(doc.select("template#dokumenttypen li").eachText())
        .contains("BMF-Schreiben", "Verwaltungsanweisung");
  }

  @Test
  void rendersInkrafttreten() {
    assertThat(doc.select("meta[name=inkrafttretedatum]").attr("content"))
        .isEqualTo("01.04.2003");
  }

  @Test
  void rendersAusserkrafttreten() {
    assertThat(doc.select("meta[name=ausserkrafttretedatum]").attr("content"))
        .isEqualTo("unbefristet");
  }

  @Test
  void rendersAnwendungszeitraum() {
    assertThat(doc.select("meta[name=anwendungsbeginn]").attr("content")).contains("2003");
    assertThat(doc.select("meta[name=anwendungsende]").attr("content")).contains("2023");
  }

  @Test
  void rendersNormenkette() {
    assertThat(doc.select("template#referenzNormen li").eachText())
        .anyMatch(t -> t.contains("AStG § 1 Abs 1"))
        .anyMatch(t -> t.contains("EStG § 15 Abs 1"));
  }

  @Test
  void rendersNormen() {
    assertThat(doc.select("template#verweisNormen li").eachText())
        .anyMatch(t -> t.contains("KStG") && t.contains("§ 8a") && t.contains("Durchführungsvorschrift"));
  }

  @Test
  void rendersVerwaltungsvorschriften() {
    assertThat(doc.select("template#verweisVerwaltungsvorschriften li").eachText())
        .anyMatch(t -> t.contains("VV Fantasie 2019"));
  }

  @Test
  void rendersRechtsprechung() {
    assertThat(doc.select("template#referenzRechtsprechungen li").eachText())
        .anyMatch(t -> t.contains("BFH München") && t.contains("I R 45/01"));
  }

  @Test
  void rendersFundstelle() {
    assertThat(doc.select("template#fundstellen li").eachText())
        .anyMatch(t -> t.contains("BStBl I") && t.contains("Ausgabe A") && t.contains("2042, 42"));
  }

  @Test
  void doesNotRenderHiddenByDefaultSections() {
    assertThat(doc.select("template#schlagwoerter")).isEmpty();
    assertThat(doc.select("template#definierteBegriffe")).isEmpty();
    assertThat(doc.select("template#sachgebiete")).isEmpty();
    assertThat(doc.select("meta[name=dokumentnummer]")).isEmpty();
  }
}
