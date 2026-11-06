package de.bund.digitalservice.ris.html.service.xslt;

import java.util.Collections;

/**
 * Class for transforming LegalDocML SLI literature documents in the V1 format (namespace {@code
 * http://rechtsinformationen.bund.de/schema/ris/0.1}, as produced by ris-literature) to HTML using
 * XSLT. Documents in the previous format are handled by {@link SliLiteratureXsltTransformer}.
 */
public class SliLiteratureV1XsltTransformer extends XsltTransformer {

  public SliLiteratureV1XsltTransformer() {
    super("de/bund/digitalservice/ris/html/xslt/v1/", "sli-literature.xslt");
  }

  public String transform(byte[] source) {
    return transformLegalDocMlFromBytes(source, Collections.emptyMap());
  }
}
