package de.bund.digitalservice.ris.html.service.xslt;

import java.util.Collections;

/** Class for transforming VVBund documents to HTML using XSLT. */
public class VvBundXsltTransformer extends XsltTransformer {

  public VvBundXsltTransformer() {
    super("de/bund/digitalservice/ris/html/xslt/", "vvbund.xslt");
  }

  /**
   * Transforms XML bytes to HTML
   *
   * @param source XML byte source
   * @return String representing transformed HTML
   */
  public String transform(byte[] source) {
    return transformLegalDocMlFromBytes(source, Collections.emptyMap());
  }
}
