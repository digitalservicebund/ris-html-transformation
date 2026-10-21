package de.bund.digitalservice.ris.html;

import static org.assertj.core.api.Assertions.assertThat;

import de.bund.digitalservice.ris.html.service.xslt.CaselawPdfXsltTransformer;
import java.io.IOException;
import java.io.InputStream;
import java.net.URLConnection;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Base64;
import java.util.Iterator;
import java.util.List;
import java.util.Objects;
import javax.xml.namespace.NamespaceContext;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpressionException;
import javax.xml.xpath.XPathFactory;
import org.assertj.core.api.SoftAssertions;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jspecify.annotations.NonNull;
import org.junit.jupiter.api.Test;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;

class CaselawPdfXsltTransformerTest {

  private static final CaselawPdfXsltTransformer XSLT_TRANSFORMER = new CaselawPdfXsltTransformer();

  private static final String SAMPLE_CLASSPATH_ROOT = "/samples/caselaw/";
  private static final Path SAMPLE_FILESYSTEM_ROOT =
      Path.of("src/test/resources/samples/caselaw").toAbsolutePath();

  private static final String RESOURCE_NOT_FOUND_MESSAGE =
      "Could not find local sample file at classpath: ";

  @Test
  void testTransform_xmlWithMultipleImages_embedsImagesAsBase64() throws IOException {
    String actualHtml = transformSampleWithImages();

    assertThat(actualHtml).doesNotContain("src=\"bild1.jpg\"");
    assertThat(Jsoup.parse(actualHtml).select("img[src^=data:image/jpeg;base64,]")).hasSize(49);
  }

  @Test
  void testTransform_customImageResolverWithMediaType_embedsImageUsingProvidedMediaType()
      throws IOException {
    String actualHtml =
        XSLT_TRANSFORMER.transform(
            readResourceAsBytes(SAMPLE_CLASSPATH_ROOT + "image.xml"),
            imageReference -> {
              assertThat(imageReference).isEqualTo("bild1.jpg");
              return new CaselawPdfXsltTransformer.ResolvedImage(
                  new byte[] {1, 2, 3}, "image/custom");
            });

    assertThat(Jsoup.parse(actualHtml).select("img[src^=data:image/custom;base64,]")).hasSize(1);
  }

  @Test
  void testTransform_missingImage_fallsBackToPlaceholderImage() throws IOException {
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
  void testTransform_judgmentSample_rendersDocumentMetadataAndJudgmentContent() throws IOException {
    Document document = Jsoup.parse(transformSampleWithImages());

    assertThat(element(document, "html").attr("lang")).isEqualTo("de");
    assertThat(document.title()).isEqualTo("BPatG, Beschluss vom 10. Juni 2013 - 20 W (pat) 24/12");
    assertThat(document.select("body.case-law")).isNotEmpty();
    assertThat(element(document, "h1#title").text())
        .isEqualTo("BPatG, Beschluss vom 10. Juni 2013 - 20 W (pat) 24/12");

    assertThat(element(document, "meta[name=author]").attr("content")).isEqualTo("BPatG");
    assertThat(element(document, "meta[name=description]").attr("content"))
        .isEqualTo(
            "(Patentbeschwerdeverfahren – „Abgedichtetes Antennensystem“ – zu den Anforderungen an die elektronische Signatur als Unterschriftserfordernis für elektronische Amtsakten des DPMA)");
    assertThat(element(document, "meta[name=keywords]").attr("content"))
        .contains("Amtsakte, Anforderung, Anmeldebeschwerdeverfahren");
    assertThat(element(document, "meta[name=generator]").attr("content"))
        .isEqualTo("Rechtsinformationen des Bundes");
    assertThat(document.select("style")).isNotEmpty();

    assertThat(document.select("dl.metadata-pdf > div")).hasSize(2);
    assertThat(document.select("dl.metadata-pdf").text())
        .contains(
            "Stand PDF:",
            "Link Portal:",
            "https://testphase.rechtsinformationen.bund.de/gerichtsentscheidungen/MPRE183880964");
    assertThat(document.select("dl.metadata").text())
        .contains("10. Juni 2013", "BPatG", "20 W (pat) 24/12");
    assertThat(document.select(".langtexte").text())
        .contains("Die Patentanmeldung 10 2009 007 910.6 mit der Bezeichnung");
  }

  @Test
  void testTransform_judgmentSample_rendersNormList() throws IOException {
    Document document = Jsoup.parse(transformSampleWithImages());

    var norms =
        document.select("dl.metadata > div").stream()
            .filter(row -> row.select("dt").text().equals("Normen:"))
            .findFirst()
            .orElseThrow();

    assertThat(norms.select("li")).hasSize(10);
    assertThat(norms.text())
        .contains(
            "PatG, Patentgesetz § 47 Abs 1 S 1",
            "EAPatV, Verordnung über die elektronische Aktenführung bei dem Deutschen Patent- und Markenamt, dem Patentgericht und dem Bundesgerichtshof § 2",
            "ZPO, Zivilprozessordnung § 315 Abs 1");
  }

  @Test
  void testTransform_withOneMetadataForEach_shouldRenderSingular() throws IOException {
    Document document = Jsoup.parse(transformSample("all_sections_singular.xml"));

    var metadataDivs = document.select("dl.metadata > div");
    var norms =
        metadataDivs.stream()
            .filter(row -> row.select("dt").text().equals("Norm:"))
            .findFirst();
    var previousDecisions =
        metadataDivs.stream()
            .filter(row -> row.select("dt").text().equals("Vorgehende Entscheidung:"))
            .findFirst();
    var ensuringDecisions =
        metadataDivs.stream()
            .filter(row -> row.select("dt").text().equals("Nachgehende Entscheidung:"))
            .findFirst();
    var pendingDecisions =
        metadataDivs.stream()
            .filter(row -> row.select("dt").text().equals("Nachgehende Entscheidung (anhängig):"))
            .findFirst();
    var yearsOfDispute =
        metadataDivs.stream()
            .filter(row -> row.select("dt").text().equals("Streitjahr:"))
            .findFirst();

    assertThat(norms).isPresent();
    assertThat(norms.get().select("li")).hasSize(1);
    assertThat(norms.get().text()).contains("PatG, Patentgesetz § 1");

    assertThat(previousDecisions).isPresent();
    assertThat(previousDecisions.get().select("li")).hasSize(1);
    assertThat(previousDecisions.get().text()).contains("LG Köln, Urteil vom 1. Januar 2020 - AZ-V-1");

    assertThat(ensuringDecisions).isPresent();
    assertThat(ensuringDecisions.get().select("li")).hasSize(1);
    assertThat(ensuringDecisions.get().text()).contains("BVerfG, Beschluss vom 1. Oktober 2022 - AZ-N-1");

    assertThat(pendingDecisions).isPresent();
    assertThat(pendingDecisions.get().select("li")).hasSize(1);
    assertThat(pendingDecisions.get().text()).contains("BGH, Urteil vom 3. April 2023 - AZ-A-1");

    assertThat(yearsOfDispute).isPresent();
    assertThat(yearsOfDispute.get().select("li")).hasSize(1);
    assertThat(yearsOfDispute.get().text()).contains("2024");
  }

  @Test
  void testTransform_withMultipleMetadataForEach_shouldRenderPlural() throws IOException {
    Document document = Jsoup.parse(transformSample("all_sections_plural.xml"));

    var metadataDivs = document.select("dl.metadata > div");
    var norms =
        metadataDivs.stream()
            .filter(row -> row.select("dt").text().equals("Normen:"))
            .findFirst();
    var previousDecisions =
        metadataDivs.stream()
            .filter(row -> row.select("dt").text().equals("Vorgehende Entscheidungen:"))
            .findFirst();
    var ensuringDecisions =
        metadataDivs.stream()
            .filter(row -> row.select("dt").text().equals("Nachgehende Entscheidungen:"))
            .findFirst();
    var pendingDecisions =
        metadataDivs.stream()
            .filter(row -> row.select("dt").text().equals("Nachgehende Entscheidungen (anhängig):"))
            .findFirst();
    var yearsOfDispute =
        metadataDivs.stream()
            .filter(row -> row.select("dt").text().equals("Streitjahre:"))
            .findFirst();

    assertThat(norms).isPresent();
    assertThat(norms.get().select("li")).hasSize(3);
    assertThat(norms.get().text()).contains("PatG § 1", "BGB § 5 Abs. 1", "HGB, Handelsgesetzbuch");

    assertThat(previousDecisions).isPresent();
    assertThat(previousDecisions.get().select("li")).hasSize(2);
    assertThat(previousDecisions.get().text()).contains("LG Köln, Urteil vom 1. Januar 2020 - AZ-V-1", "OLG Köln, Urteil vom 4. März 2021");

    assertThat(ensuringDecisions).isPresent();
    assertThat(ensuringDecisions.get().select("li")).hasSize(2);
    assertThat(ensuringDecisions.get().text()).contains("BGH, Urteil vom 17. September 2020 - AZ-N-1", "BVerfG, Beschluss vom 1. Oktober 2022 - AZ-N-2");

    assertThat(pendingDecisions).isPresent();
    assertThat(pendingDecisions.get().select("li")).hasSize(2);
    assertThat(pendingDecisions.get().text()).contains("BGH, Beschluss vom 3. April 2023 - AZ-A-1", "BSG, Beschluss vom 28. Juni 2017 - AZ-A-2");

    assertThat(yearsOfDispute).isPresent();
    assertThat(yearsOfDispute.get().select("li")).hasSize(2);
    assertThat(yearsOfDispute.get().text()).contains("2023", "2024");
  }

  @Test
  void testTransform_pendingProceedingSample_rendersPendingProceedingContent() throws IOException {
    Document document = Jsoup.parse(transformSample("pendingProceeding.xml"));

    assertThat(document.select("dl.metadata").text())
        .contains("Anhängiges Verfahren", "1. Januar 2020");
    assertThat(document.select(".langtexte").text()).contains("Lorem ipsum dolor sit amet");
  }

  @Test
  void testTransform_authorialNoteSample_rendersFootnotesInPdfOutput() throws IOException {
    Document document = Jsoup.parse(transformSample("authorialNote.xml"));

    assertThat(document.select("a[href^=#fussnoten_]")).hasSize(3);
    assertThat(document.select("span.footnote")).hasSize(3);
    assertThat(document.select("span.footnote"))
        .extracting(Element::text)
        .containsExactly("Fußnotentext 1", "Fußnotentext 2", "Fußnotentext 3");
  }

  @Test
  void testTransform_missingMetadataSample_omitsMissingMetadataFields() throws IOException {
    Document document = Jsoup.parse(transformSample("missingMetadata.xml"));

    assertThat(document.select("dl.metadata > div")).isEmpty();
    assertThat(document.select("dl.metadata").text())
        .doesNotContain(
            "—",
            "Gericht:",
            "Dokumenttyp:",
            "Entscheidungsdatum:",
            "Aktenzeichen:",
            "Spruchkörper:",
            "ECLI:",
            "Streitjahr:",
            "Vorabdokument:",
            "Norm:");
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
        throw new IllegalArgumentException(
            "Image path is traversing outside of resources directory");
      }

      try {
        String mediaType = Files.probeContentType(imagePath);
        if (mediaType == null) {
          mediaType = URLConnection.guessContentTypeFromName(imagePath.toString());
        }
        return new CaselawPdfXsltTransformer.ResolvedImage(
            Files.readAllBytes(imagePath), mediaType);
      } catch (IOException e) {
        throw new CaselawPdfXsltTransformer.ImageResolver.ImageNotFoundException(
            "Could not read image: " + imageReference, e);
      }
    };
  }

  private Element element(Document document, String selector) {
    return Objects.requireNonNull(
        document.selectFirst(selector), "Missing HTML element: " + selector);
  }

  private byte[] readResourceAsBytes(String classpath) throws IOException {
    try (InputStream inputStream = getClass().getResourceAsStream(classpath)) {
      assertThat(inputStream).withFailMessage(RESOURCE_NOT_FOUND_MESSAGE + classpath).isNotNull();
      return inputStream.readAllBytes();
    }
  }
}
