package de.bund.digitalservice.ris.html.service.xslt;

import de.bund.digitalservice.ris.html.exception.FileTransformationException;
import org.apache.commons.io.IOUtils;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jspecify.annotations.NonNull;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
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
    super("de/bund/digitalservice/ris/html/xslt/", "case-law-pdf.xslt");
  }

  /**
   * The resolved image content and its media type.
   */
  public record ResolvedImage(byte @NonNull [] content, @NonNull String mediaType) {}

  /** Resolver for image references in the content of the LegalDocML */
  public interface ImageResolver {
    /**
     * Resolves an image reference
     * @param imageReference the reference of the image
     * @return the data about the image
     * @throws ImageNotFoundException when the image could not be resolved
     */
    @NonNull ResolvedImage resolveImage(@NonNull String imageReference) throws ImageNotFoundException;

    /**
     * The image could not be found
     */
    class ImageNotFoundException extends Exception {
      public ImageNotFoundException(String message) {
        super(message);
      }

      public ImageNotFoundException(String message, Throwable cause) {
        super(message, cause);
      }
    }
  }

  /**
   * Transforms a document, resolving every non-data-URI image through the supplied resolver.
   *
   * @param source the content of the XML file to be transformed
   * @param imageResolver resolver for image references found in the XML
   * @return the transformed HTML as a String
   */
  public String transform(byte @NonNull [] source, @NonNull ImageResolver imageResolver) {
    Map<String, String> parameters = Map.of(
        RESOURCE_PATH_KEY, "",
        "css", getCss());
    return transformLegalDocMlFromBytes(embedLocalImages(source, imageResolver), parameters);
  }


  private byte[] embedLocalImages(byte[] source, ImageResolver imageResolver) {
    String xml = new String(source, StandardCharsets.UTF_8);
    Matcher matcher = IMAGE_SRC.matcher(xml);
    StringBuilder transformed = new StringBuilder();
    while (matcher.find()) {
      String imageReference = matcher.group("imagesrc");

      // handle existing data uris
      if (imageReference.regionMatches(true, 0, DATA_URI_PREFIX, 0, DATA_URI_PREFIX.length())) {
        matcher.appendReplacement(transformed, Matcher.quoteReplacement(matcher.group()));
        continue;
      }

      try {
        if (Path.of(imageReference).isAbsolute()) {
          throw new IllegalArgumentException("Image reference is absolute");
        }

        if (Path.of(imageReference).normalize().startsWith("..")) {
          throw new IllegalArgumentException("Image reference is traversing outside of current directory");
        }

        var image = imageResolver.resolveImage(imageReference);

        matcher.appendReplacement(transformed, Matcher.quoteReplacement(
            matcher.group(1) + matcher.group(2) + toDataUri(image) + matcher.group(4)));
      } catch (IllegalArgumentException | ImageResolver.ImageNotFoundException e) {
        throw new FileTransformationException("Could not embed image: " + imageReference, e);
      }
    }
    matcher.appendTail(transformed);
    return transformed.toString().getBytes(StandardCharsets.UTF_8);
  }

  private static String toDataUri(@NonNull ResolvedImage image) {
    if (image.mediaType().isBlank()) {
      throw new IllegalArgumentException("Could not determine media type for image");
    }

    return DATA_URI_PREFIX + image.mediaType() + ";base64,"
        + Base64.getEncoder().encodeToString(image.content());
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
