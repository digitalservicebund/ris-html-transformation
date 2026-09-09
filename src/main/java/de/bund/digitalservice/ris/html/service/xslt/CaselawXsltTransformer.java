package de.bund.digitalservice.ris.html.service.xslt;

import java.util.Map;

/** Class for transforming LegalDocML case law documents to HTML using XSLT. */
public class CaselawXsltTransformer extends XsltTransformer {

  public CaselawXsltTransformer() {
    super("de/bund/digitalservice/ris/html/xslt/", "case-law.xslt");
  }

  /**
   * Key for the resource path parameter passed to the XSLT transformer.
   *
   * @param source the content of the xml file to be transformed
   * @param resourcesBasePath the base path of the xml file to be transformed
   *
   * @return the transformed HTML as a String
   */
  public String transform(byte[] source, String resourcesBasePath) {
    Map<String, String> parameters = Map.of(RESOURCE_PATH_KEY, resourcesBasePath);
    return transformLegalDocMlFromBytes(source, parameters);
  }
}
