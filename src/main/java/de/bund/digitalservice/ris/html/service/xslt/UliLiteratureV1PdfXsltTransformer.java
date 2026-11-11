package de.bund.digitalservice.ris.html.service.xslt;

import java.util.Collections;

/**
 * Class for transforming LegalDocML ULI literature documents in the V1 format to HTML-for-PDF using
 * XSLT. See {@link UliLiteratureV1XsltTransformer} for the HTML rendering.
 */
public class UliLiteratureV1PdfXsltTransformer extends XsltTransformer {

  public UliLiteratureV1PdfXsltTransformer() {
    super("de/bund/digitalservice/ris/html/xslt/v1/", "uli-literature-pdf.xslt");
  }

  public String transform(byte[] source) {
    return transformLegalDocMlFromBytes(source, Collections.emptyMap());
  }
}
