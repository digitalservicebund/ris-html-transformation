package de.bund.digitalservice.ris.html.service.xslt;

import java.util.Collections;

/** Class for transforming LegalDocML literature documents to HTML using XSLT. */
public class LiteratureXsltTransformer extends XsltTransformer {

  public LiteratureXsltTransformer() {
    super("XSLT/html/", "literature.xslt");
  }

  public String transform(byte[] source) {
    return transformLegalDocMlFromBytes(source, Collections.emptyMap());
  }

}
