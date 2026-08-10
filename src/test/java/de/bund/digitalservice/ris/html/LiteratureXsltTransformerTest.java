package de.bund.digitalservice.ris.html;

import de.bund.digitalservice.ris.html.service.xslt.LiteratureXsltTransformer;
import org.jsoup.Jsoup;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Objects;

import static org.assertj.core.api.Assertions.assertThat;

class LiteratureXsltTransformerTest {
  private final LiteratureXsltTransformer transformer = new LiteratureXsltTransformer();

  private final String resourcesBasePath =
      Objects.requireNonNull(getClass().getResource("/samples/literature")).getPath();

  LiteratureXsltTransformerTest() throws IOException {}

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
  void testTransformLiteratureXmlDocuments(String testfileDir, String testName) throws IOException {
    Path inputFilePath = Paths.get(resourcesBasePath, testfileDir, "literature.xml");
    Path expectedFilePath = Paths.get(resourcesBasePath, testfileDir, "literature.html");

    byte[] bytes = Files.readAllBytes(inputFilePath);
    var result = transformer.transform(bytes);

    var expectedHtml = Files.readString(expectedFilePath);
    var expectedDocument = Jsoup.parse(expectedHtml);
    var actualDocument = Jsoup.parse(result);
    assertThat(actualDocument.html()).isEqualTo(expectedDocument.html());
  }
}
