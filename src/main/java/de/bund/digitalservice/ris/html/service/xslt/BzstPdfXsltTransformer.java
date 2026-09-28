package de.bund.digitalservice.ris.html.service.xslt;

import java.util.Collections;

/** Class for transforming LegalDocML BZSt documents to HTML-for-PDF using XSLT. */
public class BzstPdfXsltTransformer extends XsltTransformer {

  /** Transformer XML -> PDF */
  public BzstPdfXsltTransformer() {
    super("de/bund/digitalservice/ris/html/xslt/", "bzst-pdf.xslt");
  }

  /**
   * Transforms XML bytes to PDF
   * @param source XML byte source
   * @return String representing transformed HTML
   */
  public String transform(byte[] source) {
    return transformLegalDocMlFromBytes(source, Collections.emptyMap());
  }

}
