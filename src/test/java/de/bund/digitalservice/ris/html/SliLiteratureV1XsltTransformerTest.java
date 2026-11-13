package de.bund.digitalservice.ris.html;

import static org.assertj.core.api.Assertions.assertThat;

import de.bund.digitalservice.ris.html.service.xslt.SliLiteratureV1XsltTransformer;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Objects;
import org.jsoup.Jsoup;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

class SliLiteratureV1XsltTransformerTest {
  private final SliLiteratureV1XsltTransformer transformer = new SliLiteratureV1XsltTransformer();

  private final String resourcesBasePath =
      Objects.requireNonNull(getClass().getResource("/samples/literature/v1/sli")).getPath();

  @ParameterizedTest(name = "{1}")
  @CsvSource(
      value = {
        "sli_all_data | renders all data points",
        "sli_passivzitierungen | does not render passivzitierungen",
        "sli_no_haupttitel | uses the dokumentarischer Titel as title without haupttitel",
        "sli_only_haupttitelzusatz | uses the Haupttitelzusatz as title without haupttitel and dokumentarischer Titel",
        "sli_gesamttitel_as_title | uses the Gesamttitel as title without haupttitel and dokumentarischer Titel",
        "sli_partial_data | renders references, normen and kongresse with partial data",
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
