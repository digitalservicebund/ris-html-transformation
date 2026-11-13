package de.bund.digitalservice.ris.html;

import static org.assertj.core.api.Assertions.assertThat;

import de.bund.digitalservice.ris.html.service.xslt.UliLiteratureV1XsltTransformer;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Objects;
import org.jsoup.Jsoup;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

class UliLiteratureV1XsltTransformerTest {
  private final UliLiteratureV1XsltTransformer transformer = new UliLiteratureV1XsltTransformer();

  private final String resourcesBasePath =
      Objects.requireNonNull(getClass().getResource("/samples/literature/v1/uli")).getPath();

  @ParameterizedTest(name = "{1}")
  @CsvSource(
      value = {
        "uli_all_data | renders all data points",
        "uli_passivzitierungen | does not render passivzitierungen",
        "uli_multiple_haupttitel | renders additional haupttitel as zusätzliche Titel",
        "uli_no_haupttitel | uses the dokumentarischer Titel as title without haupttitel",
        "uli_only_haupttitelzusatz | uses the Haupttitelzusatz as title without haupttitel and dokumentarischer Titel",
        "uli_partial_fundstellen | renders fundstellen with partial data",
      },
      delimiter = '|')
  void testTransform_literatureXmlSample_producesExpectedHtml(String sampleName, String testName)
      throws IOException {
    Path inputFilePath = Paths.get(resourcesBasePath, sampleName + ".xml");
    Path expectedFilePath = Paths.get(resourcesBasePath, sampleName + ".html");

    byte[] bytes = Files.readAllBytes(inputFilePath);
    var result = transformer.transform(bytes);

    var expectedHtml = Files.readString(expectedFilePath);
    var expectedDocument = Jsoup.parse(expectedHtml);
    var actualDocument = Jsoup.parse(result);
    assertThat(actualDocument.html()).isEqualTo(expectedDocument.html());
  }
}
