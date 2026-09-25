package de.bund.digitalservice.ris.html.service.xslt;

import java.util.Collections;

/** Class for transforming LegalDocML BZSt documents to HTML-for-PDF using XSLT. */
public class BzstPdfXsltTransformer extends XsltTransformer {

  public BzstPdfXsltTransformer() {
    super("de/bund/digitalservice/ris/html/xslt/", "bzst-pdf.xslt");
  }

  public String transform(byte[] source) {
    return transformLegalDocMlFromBytes(source, Collections.emptyMap());
  }

}
