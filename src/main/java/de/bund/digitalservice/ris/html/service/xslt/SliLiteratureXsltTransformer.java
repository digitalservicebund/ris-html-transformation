package de.bund.digitalservice.ris.html.service.xslt;

import java.util.Collections;

/** Class for transforming LegalDocML SLI literature documents to HTML using XSLT. */
public class SliLiteratureXsltTransformer extends XsltTransformer {

  public SliLiteratureXsltTransformer() {
    super("XSLT/html/", "sli-literature.xslt");
  }

  public String transform(byte[] source) {
    return transformLegalDocMlFromBytes(source, Collections.emptyMap());
  }
}
