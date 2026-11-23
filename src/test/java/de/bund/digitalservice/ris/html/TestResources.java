package de.bund.digitalservice.ris.html;

import java.net.URISyntaxException;
import java.net.URL;
import java.nio.file.Path;
import java.util.Objects;

/** Helper for resolving classpath test resources to file system paths in an OS-independent way. */
final class TestResources {

  private TestResources() {}

  /**
   * Resolves a classpath resource to a {@link Path}. Uses {@link URL#toURI()} instead of {@link
   * URL#getPath()}, since the latter yields invalid paths on Windows (e.g. {@code /C:/...}) and
   * does not decode URL-encoded characters such as spaces.
   */
  static Path path(String classpathLocation) {
    URL url =
        Objects.requireNonNull(
            TestResources.class.getResource(classpathLocation),
            "Resource not found: " + classpathLocation);
    try {
      return Path.of(url.toURI());
    } catch (URISyntaxException e) {
      throw new IllegalStateException("Invalid resource URL: " + url, e);
    }
  }
}
