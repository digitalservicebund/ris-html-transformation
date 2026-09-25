package de.bund.digitalservice.ris.html.service.xslt;

import java.util.Collections;

/** Class for transforming LegalDocML BZSt documents to HTML using XSLT. */
public class BzstXsltTransformer extends XsltTransformer {

  /** Transformer XML -> HTML */
  public BzstXsltTransformer() {
    super("de/bund/digitalservice/ris/html/xslt/", "bzst.xslt");
  }

  /**
   * Transforms XML bytes to HTML
   * @param source XML byte source
   * @return String representing transformed HTML
   */
  public String transform(byte[] source) {
    return transformLegalDocMlFromBytes(source, Collections.emptyMap());
  }

}
