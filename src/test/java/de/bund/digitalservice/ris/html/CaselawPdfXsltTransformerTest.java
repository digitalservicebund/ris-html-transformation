package de.bund.digitalservice.ris.html;

import de.bund.digitalservice.ris.html.service.xslt.CaselawPdfXsltTransformer;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.io.InputStream;
import java.net.URLConnection;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Base64;
import java.util.Objects;

import static org.assertj.core.api.Assertions.assertThat;

class CaselawPdfXsltTransformerTest {

  private static final CaselawPdfXsltTransformer XSLT_TRANSFORMER = new CaselawPdfXsltTransformer();

  private static final String SAMPLE_CLASSPATH_ROOT = "/samples/caselaw/";
  private static final Path SAMPLE_FILESYSTEM_ROOT =
      Path.of("src/test/resources/samples/caselaw").toAbsolutePath();

  private static final String RESOURCE_NOT_FOUND_MESSAGE = "Could not find local sample file at classpath: ";

  @Test
  void embedsImages() throws IOException {
    String actualHtml = transformSampleWithImages();

    assertThat(actualHtml)
        .doesNotContain("src=\"bild1.jpg\"");
    assertThat(Jsoup.parse(actualHtml).select("img[src^=data:image/jpeg;base64,]"))
        .hasSize(49);
  }

  @Test
  void embedsImagesUsingCallerProvidedMediaType() throws IOException {
    String actualHtml = XSLT_TRANSFORMER.transform(
        readResourceAsBytes(SAMPLE_CLASSPATH_ROOT + "image.xml"),
        imageReference -> {
          assertThat(imageReference).isEqualTo("bild1.jpg");
          return new CaselawPdfXsltTransformer.ResolvedImage(
              new byte[]{1, 2, 3}, "image/custom");
        });

    assertThat(Jsoup.parse(actualHtml).select("img[src^=data:image/custom;base64,]"))
        .hasSize(1);
  }

  @Test
  void fallsBackToPlaceholderImageWhenImageIsMissing() throws IOException {
    Document document = Jsoup.parse(transformSample("image.xml"));

    Element image = document.selectFirst("img");
    assertThat(image).isNotNull();

    byte[] placeholderImage =
        readResourceAsBytes("/de/bund/digitalservice/ris/html/xslt/placeholder.png");
    String expectedDataUri =
        "data:image/png;base64," + Base64.getEncoder().encodeToString(placeholderImage);
    assertThat(image.attr("src")).isEqualTo(expectedDataUri);
  }

  @Test
  void rendersDocumentMetadataAndJudgmentContent() throws IOException {
    Document document = Jsoup.parse(transformSampleWithImages());

    assertThat(element(document, "html").attr("lang")).isEqualTo("de");
    assertThat(document.title()).isEqualTo("BPatG, Beschluss vom 10. Juni 2013 - 20 W (pat) 24/12");
    assertThat(document.select("body.case-law")).isNotEmpty();
    assertThat(element(document, "h1#title").text()).isEqualTo("BPatG, Beschluss vom 10. Juni 2013 - 20 W (pat) 24/12");

    assertThat(element(document, "meta[name=author]").attr("content")).isEqualTo("BPatG");
    assertThat(element(document, "meta[name=description]").attr("content")).isEqualTo(
        "(Patentbeschwerdeverfahren – „Abgedichtetes Antennensystem“ – zu den Anforderungen an die elektronische Signatur als Unterschriftserfordernis für elektronische Amtsakten des DPMA)");
    assertThat(element(document, "meta[name=keywords]").attr("content"))
        .contains("Amtsakte, Anforderung, Anmeldebeschwerdeverfahren");
    assertThat(element(document, "meta[name=generator]").attr("content"))
        .isEqualTo("Rechtsinformationen des Bundes");
    assertThat(document.select("style")).isNotEmpty();

    assertThat(document.select("dl.metadata-pdf > div")).hasSize(2);
    assertThat(document.select("dl.metadata-pdf").text()).contains("Stand PDF:", "Link Portal:",
        "https://testphase.rechtsinformationen.bund.de/gerichtsentscheidungen/MPRE183880964");
    assertThat(document.select("dl.metadata").text()).contains("10. Juni 2013", "BPatG",
        "20 W (pat) 24/12");
    assertThat(document.select(".langtexte").text()).contains(
        "Die Patentanmeldung 10 2009 007 910.6 mit der Bezeichnung");
  }

  @Test
  void rendersNormListFromExistingFixture() throws IOException {
    Document document = Jsoup.parse(transformSampleWithImages());

    var norms = document.select("dl.metadata > div").stream()
        .filter(row -> row.select("dt").text().equals("Norm:"))
        .findFirst()
        .orElseThrow();

    assertThat(norms.select("li")).hasSize(10);
    assertThat(norms.text()).contains(
        "PatG, Patentgesetz § 47 Abs 1 S 1",
        "EAPatV, Verordnung über die elektronische Aktenführung bei dem Deutschen Patent- und Markenamt, dem Patentgericht und dem Bundesgerichtshof § 2",
        "ZPO, Zivilprozessordnung § 315 Abs 1");
  }

  @Test
  void rendersPendingProceedingFixture() throws IOException {
    Document document = Jsoup.parse(transformSample("pendingProceeding.xml"));

    assertThat(document.select("dl.metadata").text()).contains("Anhängiges Verfahren", "1. Januar 2020");
    assertThat(document.select(".langtexte").text()).contains("Lorem ipsum dolor sit amet");
  }

  @Test
  void rendersAuthorialNotesInPdfOutput() throws IOException {
    Document document = Jsoup.parse(transformSample("authorialNote.xml"));

    assertThat(document.select("a[href^=#fussnoten_]")).hasSize(3);
    assertThat(document.select("span.footnote")).hasSize(3);
    assertThat(document.select("span.footnote")).extracting(Element::text)
        .containsExactly("Fußnotentext 1", "Fußnotentext 2", "Fußnotentext 3");
  }

  @Test
  void omitsMissingMetadata() throws IOException {
    Document document = Jsoup.parse(transformSample("missingMetadata.xml"));

    assertThat(document.select("dl.metadata > div")).isEmpty();
    assertThat(document.select("dl.metadata").text()).doesNotContain("—", "Gericht:",
        "Dokumenttyp:", "Entscheidungsdatum:", "Aktenzeichen:", "Spruchkörper:", "ECLI:",
        "Streitjahr:", "Vorabdokument:", "Norm:");
  }

  private String transformSample(String samplePath) throws IOException {
    return XSLT_TRANSFORMER.transform(
        readResourceAsBytes(SAMPLE_CLASSPATH_ROOT + samplePath),
        localImageResolver(SAMPLE_FILESYSTEM_ROOT));
  }

  private String transformSampleWithImages() throws IOException {
    return XSLT_TRANSFORMER.transform(
        readResourceAsBytes(SAMPLE_CLASSPATH_ROOT + "MPRE183880964/MPRE183880964.xml"),
        localImageResolver(SAMPLE_FILESYSTEM_ROOT.resolve("MPRE183880964")));
  }

  private CaselawPdfXsltTransformer.ImageResolver localImageResolver(Path resourcesPath) {
    Path normalizedResourcesPath = resourcesPath.toAbsolutePath().normalize();
    return imageReference -> {
      Path imagePath = normalizedResourcesPath.resolve(imageReference).normalize();
      if (!imagePath.startsWith(normalizedResourcesPath)) {
        throw new IllegalArgumentException("Image path is traversing outside of resources directory");
      }

      try {
        String mediaType = Files.probeContentType(imagePath);
        if (mediaType == null) {
          mediaType = URLConnection.guessContentTypeFromName(imagePath.toString());
        }
        return new CaselawPdfXsltTransformer.ResolvedImage(Files.readAllBytes(imagePath), mediaType);
      } catch (IOException e) {
        throw new CaselawPdfXsltTransformer.ImageResolver.ImageNotFoundException(
            "Could not read image: " + imageReference, e);
      }
    };
  }

  private Element element(Document document, String selector) {
    return Objects.requireNonNull(document.selectFirst(selector), "Missing HTML element: " + selector);
  }

  private byte[] readResourceAsBytes(String classpath) throws IOException {
    try (InputStream inputStream = getClass().getResourceAsStream(classpath)) {
      assertThat(inputStream)
              .withFailMessage(RESOURCE_NOT_FOUND_MESSAGE + classpath)
              .isNotNull();
      return inputStream.readAllBytes();
    }
  }
}