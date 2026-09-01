package de.bund.digitalservice.ris.html.service.xslt;

import de.bund.digitalservice.ris.html.exception.FileTransformationException;
import org.apache.commons.io.IOUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.Map;

/** Class for transforming LegalDocML case law documents to the HTML-for-PDF using XSLT. */
public class CaselawPdfXsltTransformer extends XsltTransformer {
  private static final Logger logger = LogManager.getLogger(CaselawPdfXsltTransformer.class);

  public CaselawPdfXsltTransformer() {
    super("XSLT/html/", "case-law-pdf.xslt");
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
    Map<String, String> parameters = Map.of(
        RESOURCE_PATH_KEY, resourcesBasePath,
        "css", getCss());
    return transformLegalDocMlFromBytes(source, parameters);
  }



  /**
   * Reads the CSS built by the {@code pdf-html-styling} module (see {@code build.gradle.kts}),
   * which is packaged as the classpath resource {@code style.css}.
   *
   * @return the content of {@code style.css}
   */
  private static String getCss() {
    try (InputStream inputStream =
             XsltTransformer.class.getClassLoader().getResourceAsStream("style.css")) {
      if (inputStream == null) {
        throw new FileTransformationException("CSS file not found: style.css");
      }
      return IOUtils.toString(inputStream, StandardCharsets.UTF_8);
    } catch (IOException e) {
      logger.error("Could not read CSS file.", e);
      throw new FileTransformationException(e.getMessage(), e);
    }
  }
}
