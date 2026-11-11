package de.bund.digitalservice.ris.html;

import static org.assertj.core.api.Assertions.assertThat;

import de.bund.digitalservice.ris.html.service.xslt.UliLiteratureV1PdfXsltTransformer;
import de.bund.digitalservice.ris.html.service.xslt.UliLiteratureV1XsltTransformer;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

/**
 * The PDF stylesheet imports the portal one and only hides some sections, so the PDF output must
 * be identical to the portal output once the sections listed in {@link #HIDDEN_IN_PDF} are
 * removed from it.
 */
class UliLiteratureV1PdfXsltTransformerTest {

  private static final String SAMPLE_PATH = "/samples/literature/v1/uli/uli_all_data.xml";

  /** Selectors of the sections rendered in the portal HTML but hidden in the PDF HTML. */
  private static final List<String> HIDDEN_IN_PDF = List.of("template#referenzRechtsprechungAktiv");

  private static Document portalDoc;
  private static Document pdfDoc;

  @BeforeAll
  static void transform() throws IOException {
    try (InputStream is =
        UliLiteratureV1PdfXsltTransformerTest.class.getResourceAsStream(SAMPLE_PATH)) {
      assertThat(is).withFailMessage("Could not find: " + SAMPLE_PATH).isNotNull();
      byte[] bytes = is.readAllBytes();
      portalDoc = Jsoup.parse(new UliLiteratureV1XsltTransformer().transform(bytes));
      pdfDoc = Jsoup.parse(new UliLiteratureV1PdfXsltTransformer().transform(bytes));
    }
  }

  @Test
  void rendersSameAsPortalExceptHiddenSections() {
    Document expected = portalDoc.clone();
    HIDDEN_IN_PDF.forEach(selector -> expected.select(selector).remove());
    assertThat(pdfDoc.html()).isEqualTo(expected.html());
  }
}
