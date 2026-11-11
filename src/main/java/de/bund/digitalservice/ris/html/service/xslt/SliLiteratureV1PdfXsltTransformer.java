package de.bund.digitalservice.ris.html.service.xslt;

import java.util.Collections;

/**
 * Class for transforming LegalDocML SLI literature documents in the V1 format to HTML-for-PDF using
 * XSLT. See {@link SliLiteratureV1XsltTransformer} for the HTML rendering.
 */
public class SliLiteratureV1PdfXsltTransformer extends XsltTransformer {

  /** Transformer XML -> PDF */
  public SliLiteratureV1PdfXsltTransformer() {
    super("de/bund/digitalservice/ris/html/xslt/v1/", "sli-literature-pdf.xslt");
  }

  /**
   * Transforms XML bytes to PDF
   *
   * @param source XML byte source
   * @return String representing transformed HTML
   */
  public String transform(byte[] source) {
    return transformLegalDocMlFromBytes(source, Collections.emptyMap());
  }
}
