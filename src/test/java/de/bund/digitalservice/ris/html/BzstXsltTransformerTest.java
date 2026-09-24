package de.bund.digitalservice.ris.html;

import de.bund.digitalservice.ris.html.service.xslt.BzstXsltTransformer;
import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class BzstXsltTransformerTest {

  private static final BzstXsltTransformer XSLT_TRANSFORMER = new BzstXsltTransformer();
  private static final String SAMPLE_PATH = "/samples/bzst/full.xml";
  private static final Path OUTPUT_PATH = Paths.get("src/test/resources/samples/bzst/full.html");

  @Test
  void testTransform_placeholder_writesHtmlToDisk() throws IOException {
    byte[] ldmlBytes;
    try (InputStream is = getClass().getResourceAsStream(SAMPLE_PATH)) {
      assertThat(is).withFailMessage("Could not find: " + SAMPLE_PATH).isNotNull();
      ldmlBytes = is.readAllBytes();
    }

    String html = XSLT_TRANSFORMER.transform(ldmlBytes);

    assertThat(html).isNotNull().isNotEmpty();
    String page = "<!DOCTYPE html>\n<html lang=\"de\"><head><meta charset=\"UTF-8\"><title>BZST Preview</title></head><body>\n"
        + html
        + "\n</body></html>";
    Files.writeString(OUTPUT_PATH, page, StandardCharsets.UTF_8);
  }
}
