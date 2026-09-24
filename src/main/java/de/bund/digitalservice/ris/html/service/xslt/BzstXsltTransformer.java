package de.bund.digitalservice.ris.html.service.xslt;

import java.util.Collections;

/** Class for transforming LegalDocML BZSt documents to HTML using XSLT. */
public class BzstXsltTransformer extends XsltTransformer {

  public BzstXsltTransformer() {
    super("de/bund/digitalservice/ris/html/xslt/", "bzst.xslt");
  }

  public String transform(byte[] source) {
    return transformLegalDocMlFromBytes(source, Collections.emptyMap());
  }

}
