package de.bund.digitalservice.ris.html;

import de.bund.digitalservice.ris.html.service.xslt.BzstPdfXsltTransformer;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;

import java.io.IOException;
import java.io.InputStream;
import java.util.function.Consumer;
import java.util.stream.Stream;

import static org.assertj.core.api.Assertions.assertThat;

class BzstPdfXsltTransformerTest {

  private static final BzstPdfXsltTransformer TRANSFORMER = new BzstPdfXsltTransformer();
  private static final String SAMPLE_PATH = "/samples/bzst/full.xml";

  private static Document transform() throws IOException {
    try (InputStream is = BzstPdfXsltTransformerTest.class.getResourceAsStream(SAMPLE_PATH)) {
      assertThat(is).withFailMessage("Could not find: " + SAMPLE_PATH).isNotNull();
      return Jsoup.parse(TRANSFORMER.transform(is.readAllBytes()));
    }
  }

  static Stream<Arguments> sectionTests() {
    return Stream.of(
        Arguments.of("hides Normen (show-aktivverweisung=false)",
            (Consumer<Document>) doc ->
                assertThat(doc.select("#referenzen h3").eachText()).doesNotContain("Normen")),

        Arguments.of("hides Verwaltungsvorschriften (show-aktivverweisung=false)",
            (Consumer<Document>) doc ->
                assertThat(doc.select("#referenzen h3").eachText()).doesNotContain("Verwaltungsvorschriften")),

        Arguments.of("hides Rechtsprechung (show-aktivzitierung-rechtsprechung=false)",
            (Consumer<Document>) doc ->
                assertThat(doc.select("#referenzen h3").eachText()).doesNotContain("Rechtsprechung")),

        Arguments.of("renders Normenkette (not overridden in PDF variant)",
            (Consumer<Document>) doc -> {
              assertThat(doc.select("#referenzen h3").eachText()).contains("Normenkette");
              assertThat(doc.select("#referenzen").text()).contains("AStG");
            }),

        Arguments.of("renders Fundstelle (not overridden in PDF variant)",
            (Consumer<Document>) doc -> {
              assertThat(doc.select("#referenzen h3").eachText()).contains("Fundstelle");
              assertThat(doc.select("#referenzen").text()).contains("BStBl I");
            })
    );
  }

  @ParameterizedTest(name = "{0}")
  @MethodSource("sectionTests")
  void testTransform_section(String description, Consumer<Document> assertions) throws IOException {
    assertions.accept(transform());
  }
}
