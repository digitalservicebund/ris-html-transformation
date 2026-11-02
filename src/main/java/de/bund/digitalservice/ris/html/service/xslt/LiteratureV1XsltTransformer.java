package de.bund.digitalservice.ris.html.service.xslt;

import java.util.Collections;

/**
 * Class for transforming LegalDocML ULI literature documents in the V1 format (namespace {@code
 * http://rechtsinformationen.bund.de/schema/ris/0.1}, as produced by ris-literature) to HTML using
 * XSLT. Documents in the previous format are handled by {@link LiteratureXsltTransformer}.
 */
public class LiteratureV1XsltTransformer extends XsltTransformer {

  public LiteratureV1XsltTransformer() {
    super("de/bund/digitalservice/ris/html/xslt/v1/", "literature.xslt");
  }

  public String transform(byte[] source) {
    return transformLegalDocMlFromBytes(source, Collections.emptyMap());
  }
}
