package de.bund.digitalservice.ris.html.service.xslt;

import java.util.HashMap;
import java.util.Map;

/** Class for transforming LegalDocML Norms LDML XML documents to HTML using XSLT. */
public class NormsXsltTransformer extends XsltTransformer {

  public NormsXsltTransformer() {
    super("de/bund/digitalservice/ris/html/xslt/", "norms.xslt");
  }

  public String transformNorm(byte[] source, String language, String resourcesBasePath, String subtype) {
    var parameters = standardParameters(resourcesBasePath);
    parameters.put("dokumentpfad", language);
    parameters.put("subtype", subtype);
    return transformLegalDocMlFromBytes(source, parameters);
  }

  public String transformArticle(byte[] source, String eId, String resourcesBasePath) {
    var parameters = standardParameters(resourcesBasePath);
    parameters.put("article-eid", eId);
    return transformLegalDocMlFromBytes(source, parameters);
  }

  private Map<String, String> standardParameters(String resourcesBasePath) {
    return new HashMap<>(
        Map.ofEntries(
            Map.entry("debugging", "false"), Map.entry("ressourcenpfad", resourcesBasePath)));
  }
}
