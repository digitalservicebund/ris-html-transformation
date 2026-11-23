package de.bund.digitalservice.ris.html;

import static org.assertj.core.api.Assertions.assertThat;

import de.bund.digitalservice.ris.html.service.xslt.LiteratureXsltTransformer;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import org.jsoup.Jsoup;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

class LiteratureXsltTransformerTest {
  private final LiteratureXsltTransformer transformer = new LiteratureXsltTransformer();

  private final Path resourcesBasePath = TestResources.path("/samples/literature");

  @ParameterizedTest(name = "{1}")
  @CsvSource(
      value = {
        "uli/example1  | transforms mainTitle, alternativeHeadline, outline and mainBody",
        "uli/example2  | transforms only alternativeHeadline and mainBody",
        "uli/example3  | transforms only mainTitle and outline",
        "uli/example4  | transforms mainTitle, alternativeHeadline and mainTitleAdditions",
        "uli/example5  | transforms alternativeHeadline and mainTitleAdditions",
        "uli/example6  | transforms mainTitleAdditions",
        "uli/example7  | transforms mainTitle and mainTitleAdditions",
        "uli/example8  | transforms active citations",
        "uli/example9  | transforms passive citations",
        "uli/example10 | transforms active and passive citations",
      },
      delimiter = '|')
  void testTransform_literatureXmlSample_producesExpectedHtml(String testfileDir, String testName)
      throws IOException {
    Path inputFilePath = resourcesBasePath.resolve(testfileDir).resolve("literature.xml");
    Path expectedFilePath = resourcesBasePath.resolve(testfileDir).resolve("literature.html");

    byte[] bytes = Files.readAllBytes(inputFilePath);
    var result = transformer.transform(bytes);

    var expectedHtml = Files.readString(expectedFilePath);
    var expectedDocument = Jsoup.parse(expectedHtml);
    var actualDocument = Jsoup.parse(result);
    assertThat(actualDocument.html()).isEqualTo(expectedDocument.html());
  }
}
