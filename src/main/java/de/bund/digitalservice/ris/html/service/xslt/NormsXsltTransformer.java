package de.bund.digitalservice.ris.html.service.xslt;

import java.io.ByteArrayInputStream;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.HashMap;
import java.util.Map;
import javax.xml.XMLConstants;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParserFactory;
import javax.xml.transform.Source;
import javax.xml.transform.TransformerException;
import javax.xml.transform.URIResolver;
import javax.xml.transform.sax.SAXSource;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.XMLReader;

/** Class for transforming LegalDocML Norms LDML XML documents to HTML using XSLT. */
public class NormsXsltTransformer extends XsltTransformer {

  public NormsXsltTransformer() {
    super("de/bund/digitalservice/ris/html/xslt/", "norms.xslt");
  }

  /**
   * Transforms a norm that does not reference other documents.
   *
   * @see #transformNorm(Source, String, String, String, Map)
   */
  public String transformNorm(
      Source in, String language, String resourcesBasePath, String subtype) {
    return transformNorm(in, language, resourcesBasePath, subtype, Map.of());
  }

  /**
   * Transforms a norm to a complete HTML document.
   *
   * @param in the content of the norm's XML file
   * @param language the language part of the manifestation ELI, used for links
   * @param resourcesBasePath the base path prepended to links to images and PDF files
   * @param subtype the subtype of the norm, used for links
   * @param referencedDocuments XML documents referenced by the norm (e.g. attachments), keyed by
   *     their ELI path such as {@code
   *     eli/bund/bgbl-1/2000/s1/2000-01-01/1/deu/2000-01-01/anlage-regelungstext-1.xml}
   * @return the transformed HTML as a String
   * @throws de.bund.digitalservice.ris.html.exception.FileTransformationException if the XML is
   *     invalid or a referenced document is missing from {@code referencedDocuments}
   */
  public String transformNorm(
      Source in,
      String language,
      String resourcesBasePath,
      String subtype,
      Map<String, byte[]> referencedDocuments) {
    var parameters = standardParameters(resourcesBasePath);
    parameters.put("dokumentpfad", language);
    parameters.put("subtype", subtype);
    return transformLegalDocMlFromBytes(
        in, parameters, new ReferencedDocumentResolver(referencedDocuments));
  }

  /**
   * Transforms an article of a norm that does not reference other documents.
   *
   * @see #transformArticle(Source, String, String, Map)
   */
  public String transformArticle(Source in, String eId, String resourcesBasePath) {
    return transformArticle(in, eId, resourcesBasePath, Map.of());
  }

  /**
   * Transforms a single article, attachment or formula of a norm to a complete HTML document.
   *
   * @param in the content of the norm's XML file
   * @param eId the literal (not URL-encoded) eId of the element to transform
   * @param resourcesBasePath the base path prepended to links to images and PDF files
   * @param referencedDocuments XML documents referenced by the norm, keyed by ELI path
   * @return the transformed HTML as a String
   * @throws de.bund.digitalservice.ris.html.exception.XMLElementNotFoundException if no element
   *     with the given eId exists
   * @throws de.bund.digitalservice.ris.html.exception.FileTransformationException if the XML is
   *     invalid or a referenced document is missing from {@code referencedDocuments}
   */
  public String transformArticle(
      Source in,
      String eId,
      String resourcesBasePath,
      Map<String, byte[]> referencedDocuments) {
    var parameters = standardParameters(resourcesBasePath);
    parameters.put("article-eid", eId);
    return transformLegalDocMlFromBytes(
        in, parameters, new ReferencedDocumentResolver(referencedDocuments));
  }

  private Map<String, String> standardParameters(String resourcesBasePath) {
    return new HashMap<>(
        Map.ofEntries(
            Map.entry("debugging", "false"), Map.entry("ressourcenpfad", resourcesBasePath)));
  }

  /** Serves referenced documents only from the supplied map; never loads anything else. */
  private record ReferencedDocumentResolver(Map<String, byte[]> documents) implements URIResolver {

    @Override
    public Source resolve(String href, String base) throws TransformerException {
      String path = toEliPath(href);
      byte[] content = documents.get(path);
      if (content == null) {
        throw new TransformerException("Referenced document not supplied: " + path);
      }
      return toSecureSource(content, href);
    }

    private static Source toSecureSource(byte[] content, String href) throws TransformerException {
      try {
        SAXParserFactory spf = SAXParserFactory.newInstance();
        spf.setNamespaceAware(true);
        spf.setFeature(XMLConstants.FEATURE_SECURE_PROCESSING, true);
        spf.setFeature("http://apache.org/xml/features/disallow-doctype-decl", true);
        spf.setFeature("http://xml.org/sax/features/external-general-entities", false);
        spf.setFeature("http://xml.org/sax/features/external-parameter-entities", false);
        spf.setFeature("http://apache.org/xml/features/nonvalidating/load-external-dtd", false);

        XMLReader reader = spf.newSAXParser().getXMLReader();
        InputSource input = new InputSource(new ByteArrayInputStream(content));
        input.setSystemId(href);
        return new SAXSource(reader, input);
      } catch (ParserConfigurationException | SAXException e) {
        throw new TransformerException("Could not create secure parser for: " + href, e);
      }
    }

    private static String toEliPath(String href) throws TransformerException {
      try {
        String path = new URI(href).getPath();
        if (path != null && path.startsWith("/")) {
          path = path.substring(1);
        }
        if (path == null || !path.startsWith("eli/") || path.contains("..")) {
          throw new TransformerException("Invalid document reference: " + href);
        }
        return path;
      } catch (URISyntaxException e) {
        throw new TransformerException("Invalid document reference: " + href, e);
      }
    }
  }
}
