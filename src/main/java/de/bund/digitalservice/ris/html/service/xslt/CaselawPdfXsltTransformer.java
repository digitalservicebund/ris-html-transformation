package de.bund.digitalservice.ris.html.service.xslt;

import de.bund.digitalservice.ris.html.exception.FileTransformationException;
import org.apache.commons.io.IOUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Base64;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/** Class for transforming LegalDocML case law documents to the HTML-for-PDF using XSLT. */
public class CaselawPdfXsltTransformer extends XsltTransformer {
  private static final Logger logger = LogManager.getLogger(CaselawPdfXsltTransformer.class);
  private static final String DATA_URI_PREFIX = "data:";
  private static final Pattern IMAGE_SRC = Pattern.compile(
      "(<akn:img\\b[^>]*?\\bsrc\\s*=\\s*)([\\\"'])(?<imagesrc>[^\\\"']+)(\\2)", Pattern.CASE_INSENSITIVE);

  public CaselawPdfXsltTransformer() {
    super("XSLT/html/", "case-law-pdf.xslt");
  }

  /**
   * Key for the resource path parameter passed to the XSLT transformer.
   *
   * @param source the content of the xml file to be transformed
   * @param resourcesPath the path in which the resources referenced in the xml are stored
   *
   * @return the transformed HTML as a String
   */
  public String transform(byte[] source, Path resourcesPath) {
    Map<String, String> parameters = Map.of(
        RESOURCE_PATH_KEY, "",
        "css", getCss());
    return transformLegalDocMlFromBytes(embedLocalImages(source, resourcesPath), parameters);
  }

  private byte[] embedLocalImages(byte[] source, Path resourcesPath) {
    String xml = new String(source, StandardCharsets.UTF_8);
    Matcher matcher = IMAGE_SRC.matcher(xml);
    StringBuilder transformed = new StringBuilder();
    while (matcher.find()) {
      String imageReference = matcher.group("imagesrc");
      Path imagePath = resourcesPath.resolve(imageReference).normalize();

      // handle existing data uris
      if (imageReference.regionMatches(true, 0, DATA_URI_PREFIX, 0, DATA_URI_PREFIX.length())) {
        matcher.appendReplacement(transformed, Matcher.quoteReplacement(matcher.group()));
        continue;
      }

      try {
        matcher.appendReplacement(transformed, Matcher.quoteReplacement(
            matcher.group(1) + matcher.group(2) + toDataUri(imagePath) + matcher.group(4)));
      } catch (IOException | IllegalArgumentException e) {
        logger.warn("Could not embed image: {}", imagePath, e);
      }
    }
    matcher.appendTail(transformed);
    return transformed.toString().getBytes(StandardCharsets.UTF_8);
  }

  private static String toDataUri(Path imagePath) throws IOException, IllegalArgumentException {
    if (!Files.isRegularFile(imagePath)) {
      throw new IllegalArgumentException("ImagePath is not a regular file");
    }
    String mediaType = Files.probeContentType(imagePath);
    if (mediaType == null) {
      throw new IOException("Could not determine media type for image");
    }
    return DATA_URI_PREFIX + mediaType + ";base64,"
        + Base64.getEncoder().encodeToString(Files.readAllBytes(imagePath));
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
