package de.bund.digitalservice.ris.html;

import de.bund.digitalservice.ris.html.service.xslt.BzstXsltTransformer;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;

import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import java.util.function.Consumer;
import java.util.stream.Stream;

import static org.assertj.core.api.Assertions.assertThat;

class BzstXsltTransformerTest {

  private static final BzstXsltTransformer TRANSFORMER = new BzstXsltTransformer();
  private static final String SAMPLE_PATH = "/samples/bzst/full.xml";

  private static Document transform() throws IOException {
    try (InputStream is = BzstXsltTransformerTest.class.getResourceAsStream(SAMPLE_PATH)) {
      assertThat(is).withFailMessage("Could not find: " + SAMPLE_PATH).isNotNull();
      return Jsoup.parse(TRANSFORMER.transform(is.readAllBytes()));
    }
  }

  static Stream<Arguments> sectionTests() {
    return Stream.of(
        Arguments.of("renders Langtitel in header",
            (Consumer<Document>) doc ->
                assertThat(doc.select("#header h1").text())
                    .isEqualTo("Anwendung des § 1 Abs. 1 AStG bei Verrechnungspreisen mit nahestehenden Personen")),

        Arguments.of("renders Zitierdatum in header",
            (Consumer<Document>) doc -> {
              assertThat(doc.select("#header dt").eachText()).contains("Zitierdatum");
              assertThat(doc.select("#header dd").eachText()).contains("01.04.2003");
            }),

        Arguments.of("renders Aktenzeichen",
            (Consumer<Document>) doc -> {
              assertThat(doc.select("#metadaten dt").eachText()).contains("Aktenzeichen");
              assertThat(doc.select("#metadaten").text())
                  .contains("IV B 4 - S 1341/07/10017")
                  .contains("IV B 4 - S 1341/07/10018");
            }),

        Arguments.of("renders Normgeber with Kurzbezeichnung and Langbezeichnung as abbr title",
            (Consumer<Document>) doc -> {
              assertThat(doc.select("#metadaten dt").eachText()).contains("Normgeber");
              assertThat(doc.select("#metadaten abbr").eachText()).contains("BMG");
              assertThat(doc.select("#metadaten abbr[title]").attr("title"))
                  .isEqualTo("Bundesministerium des Geldes");
            }),

        Arguments.of("renders Dokumenttyp",
            (Consumer<Document>) doc -> {
              assertThat(doc.select("#metadaten dt").eachText()).contains("Dokumenttyp");
              assertThat(doc.select("#metadaten").text())
                  .contains("BMF-Schreiben")
                  .contains("Verwaltungsanweisung");
            }),

        Arguments.of("renders Inkrafttreten with formatted date",
            (Consumer<Document>) doc -> {
              assertThat(doc.select("#metadaten dt").eachText()).contains("Inkrafttreten");
              assertThat(doc.select("#metadaten").text()).contains("01.04.2003");
            }),

        Arguments.of("renders Außerkrafttreten as unbefristet",
            (Consumer<Document>) doc -> {
              assertThat(doc.select("#metadaten dt").eachText()).contains("Außerkrafttreten");
              assertThat(doc.select("#metadaten").text()).contains("unbefristet");
            }),

        Arguments.of("renders Anwendungszeitraum with begin and end",
            (Consumer<Document>) doc -> {
              assertThat(doc.select("#metadaten dt").eachText())
                  .containsAll(List.of("Anwendungsbeginn", "Anwendungsende"));
              assertThat(doc.select("#metadaten").text()).contains("2003").contains("2023");
            }),

        Arguments.of("renders Normenkette in Referenzen",
            (Consumer<Document>) doc -> {
              assertThat(doc.select("#referenzen h3").eachText()).contains("Normenkette");
              assertThat(doc.select("#referenzen").text()).contains("AStG").contains("EStG");
            }),

        Arguments.of("renders Normen (Aktivverweisung) in Referenzen",
            (Consumer<Document>) doc -> {
              assertThat(doc.select("#referenzen h3").eachText()).contains("Normen");
              assertThat(doc.select("#referenzen").text())
                  .contains("KStG")
                  .contains("§ 8a")
                  .contains("Durchführungsvorschrift");
            }),

        Arguments.of("renders Verwaltungsvorschriften in Referenzen",
            (Consumer<Document>) doc -> {
              assertThat(doc.select("#referenzen h3").eachText()).contains("Verwaltungsvorschriften");
              assertThat(doc.select("#referenzen").text()).contains("VWG VP 2023");
            }),

        Arguments.of("renders Rechtsprechung in Referenzen",
            (Consumer<Document>) doc -> {
              assertThat(doc.select("#referenzen h3").eachText()).contains("Rechtsprechung");
              assertThat(doc.select("#referenzen").text())
                  .contains("BFH München")
                  .contains("I R 45/01");
            }),

        Arguments.of("renders Fundstelle in Referenzen",
            (Consumer<Document>) doc -> {
              assertThat(doc.select("#referenzen h3").eachText()).contains("Fundstelle");
              assertThat(doc.select("#referenzen").text())
                  .contains("BStBl I")
                  .contains("Ausgabe A")
                  .contains("2042, 42");
            })
    );
  }

  @ParameterizedTest(name = "{0}")
  @MethodSource("sectionTests")
  void testTransform_section(String description, Consumer<Document> assertions) throws IOException {
    assertions.accept(transform());
  }
}
