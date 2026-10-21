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
  void testTransform_withOneNorm_shouldRenderSingular() throws IOException {
    String transform = new XMLStringObject("all_sections.xml")
        .changeOrAddNorms(List.of(List.of("PatG", "Patentgesetz", "§ 1")), true)
        .transform();
    Document document = Jsoup.parse(transform);

    var norms =
        document.select("dl.metadata > div").stream()
            .filter(row -> row.select("dt").text().equals("Norm:"))
            .findFirst()
            .orElseThrow();

    assertThat(norms.select("li")).hasSize(1);
    assertThat(norms.text()).contains("PatG, Patentgesetz § 1");
  }

  @Test
  void testTransform_withTwoNorm_shouldRenderPlural() throws IOException {
    String transform = new XMLStringObject("all_sections.xml")
        .changeOrAddNorms(
            List.of(
                List.of("PatG", "Patentgesetz", "§ 1"),
                List.of("BGB", "Bundesgesetzbuch", "§ 2")
            ),
            true
        )
        .transform();
    Document document = Jsoup.parse(transform);

    var norms =
        document.select("dl.metadata > div").stream()
            .filter(row -> row.select("dt").text().equals("Normen:"))
            .findFirst()
            .orElseThrow();

    assertThat(norms.select("li")).hasSize(2);
    assertThat(norms.text()).contains("PatG, Patentgesetz § 1", "BGB, Bundesgesetzbuch § 2");
  }

  @Test
  void testTransform_withOnePreviousDecision_shouldRenderSingular() throws IOException {
    String transform = new XMLStringObject("all_sections.xml")
        .changeOrAddPreviousDecisions(
            List.of(
                List.of("Urt", "12.12.2010", "TEST123456789", "AZ 5", "BGH", "", "Ordentliche Gerichtsbarkeit")
            ),
            true
        )
        .transform();
    Document document = Jsoup.parse(transform);

    var norms =
        document.select("dl.metadata > div").stream()
            .filter(row -> row.select("dt").text().equals("Vorgehende Entscheidung:"))
            .findFirst()
            .orElseThrow();

    assertThat(norms.select("li")).hasSize(1);
    assertThat(norms.text()).contains("BGH, vom 12.12.2010 - AZ 5");
  }

  @Test
  void testTransform_withTwoPreviousDecision_shouldRenderPlural() throws IOException {
    String transform = new XMLStringObject("all_sections.xml")
        .changeOrAddPreviousDecisions(
            List.of(
                List.of("Urt", "12.12.2010", "TEST123456789", "AZ 5", "BGH", "", "Ordentliche Gerichtsbarkeit"),
                List.of("Urt", "10.10.2010", "TEST012345678", "AZ 16", "LG", "Köln", "")
            ),
            true
        )
        .transform();
    Document document = Jsoup.parse(transform);

    var norms =
        document.select("dl.metadata > div").stream()
            .filter(row -> row.select("dt").text().equals("Vorgehende Entscheidungen:"))
            .findFirst()
            .orElseThrow();

    assertThat(norms.select("li")).hasSize(2);
    assertThat(norms.text()).contains("BGH, vom 12.12.2010 - AZ 5", "LG Köln, vom 10.10.2010 - AZ 16");
  }

  @Test
  void testTransform_withOneEnsuringDecision_shouldRenderSingular() throws IOException {
    String transform = new XMLStringObject("all_sections.xml")
        .changeOrAddEnsuringDecisions(
            List.of(
                List.of("Urt", "12.12.2010", "TEST123456789", "AZ 5", "BGH", "", "Ordentliche Gerichtsbarkeit")
            ),
            true
        )
        .transform();
    Document document = Jsoup.parse(transform);

    var norms =
        document.select("dl.metadata > div").stream()
            .filter(row -> row.select("dt").text().equals("Nachgehende Entscheidung:"))
            .findFirst()
            .orElseThrow();

    assertThat(norms.select("li")).hasSize(1);
    assertThat(norms.text()).contains("BGH, vom 12.12.2010 - AZ 5");
  }

  @Test
  void testTransform_withTwoEnsuringDecision_shouldRenderPlural() throws IOException {
    String transform = new XMLStringObject("all_sections.xml")
        .changeOrAddEnsuringDecisions(
            List.of(
                List.of("Urt", "12.12.2010", "TEST123456789", "AZ 5", "BGH", "", "Ordentliche Gerichtsbarkeit"),
                List.of("Urt", "10.10.2010", "TEST012345678", "AZ 16", "LG", "Köln", "")
            ),
            true
        )
        .transform();
    Document document = Jsoup.parse(transform);

    var norms =
        document.select("dl.metadata > div").stream()
            .filter(row -> row.select("dt").text().equals("Nachgehende Entscheidungen:"))
            .findFirst()
            .orElseThrow();

    assertThat(norms.select("li")).hasSize(2);
    assertThat(norms.text()).contains("BGH, vom 12.12.2010 - AZ 5", "LG Köln, vom 10.10.2010 - AZ 16");
  }

  @Test
  void testTransform_withOnePendingDecision_shouldRenderSingular() throws IOException {
    String transform = new XMLStringObject("all_sections.xml")
        .changeOrAddPendingDecisions(
            List.of(
                List.of("Urt", "12.12.2010", "TEST123456789", "AZ 5", "BGH", "", "Ordentliche Gerichtsbarkeit")
            ),
            true
        )
        .transform();
    Document document = Jsoup.parse(transform);

    var norms =
        document.select("dl.metadata > div").stream()
            .filter(row -> row.select("dt").text().equals("Nachgehende Entscheidung (anhängig):"))
            .findFirst()
            .orElseThrow();

    assertThat(norms.select("li")).hasSize(1);
    assertThat(norms.text()).contains("BGH, vom 12.12.2010 - AZ 5");
  }

  @Test
  void testTransform_withTwoPendingDecision_shouldRenderPlural() throws IOException {
    String transform = new XMLStringObject("all_sections.xml")
        .changeOrAddPendingDecisions(
            List.of(
                List.of("Urt", "12.12.2010", "TEST123456789", "AZ 5", "BGH", "", "Ordentliche Gerichtsbarkeit"),
                List.of("Urt", "10.10.2010", "TEST012345678", "AZ 16", "LG", "Köln", "")
            ),
            true
        )
        .transform();
    Document document = Jsoup.parse(transform);

    var norms =
        document.select("dl.metadata > div").stream()
            .filter(row -> row.select("dt").text().equals("Nachgehende Entscheidungen (anhängig):"))
            .findFirst()
            .orElseThrow();

    assertThat(norms.select("li")).hasSize(2);
    assertThat(norms.text()).contains("BGH, vom 12.12.2010 - AZ 5", "LG Köln, vom 10.10.2010 - AZ 16");
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

  private class XMLStringObject {
    private final org.w3c.dom.Document baseDoc;
    private final XPath xpath;
    private static final String AKN_NAMESPACE_URI = "http://docs.oasis-open.org/legaldocml/ns/akn/3.0";
    private static final String RIS_NAMESPACE_URI = "http://rechtsinformationen.bund.de/schema/ris/0.1";

    private XMLStringObject(String samplePath) {
      var factory = DocumentBuilderFactory.newInstance();
      factory.setNamespaceAware(true);
      try {
        baseDoc = factory.newDocumentBuilder().parse(this.getClass().getResourceAsStream(SAMPLE_CLASSPATH_ROOT + samplePath));
      } catch (IOException | ParserConfigurationException | SAXException e) {
        throw new RuntimeException(e);
      }
      xpath = XPathFactory.newInstance().newXPath();
      NamespaceContext namespaceContext = new NamespaceContext() {
        public String getNamespaceURI(String prefix) {
          if (prefix.equals("ris")) {
            return RIS_NAMESPACE_URI;
          } else if (prefix.equals("akn")) {
            return AKN_NAMESPACE_URI;
          }
          return null;
        }
        public Iterator getPrefixes(String val) {
          return null;
        }
        public String getPrefix(String uri) {
          return null;
        }
      };
      xpath.setNamespaceContext(namespaceContext);
    }

    private XMLStringObject changeOrAddEnsuringDecisions(List<List<String>> pendingProceedings, boolean replace) {
      try {
        NodeList pendingProceedingReferences = (NodeList) xpath.evaluate(
            "/akn:akomaNtoso/akn:judgment/akn:meta/akn:analysis/akn:otherReferences/akn:implicitReference/ris:nachgehendeEntscheidung",
            baseDoc, XPathConstants.NODESET);

        Node otherReference = getOtherReferences(pendingProceedingReferences);

        if (otherReference == null) {
          return this;
        }

        if (replace) {
          for (int i = 0; i < pendingProceedingReferences.getLength(); i++) {
            otherReference.removeChild(pendingProceedingReferences.item(i).getParentNode());
          }
        }

        for (List<String> decisionParts : pendingProceedings) {
          if (decisionParts.size() != 7) {
            continue;
          }

          generateRelatedDecisionsReference(otherReference, decisionParts, DecisionType.ENSURING);
        }
      } catch (XPathExpressionException e) {
        throw new RuntimeException(e);
      }
      return this;
    }

    private XMLStringObject changeOrAddPendingDecisions(List<List<String>> pendingProceedings, boolean replace) {
      try {
        NodeList pendingProceedingReferences = (NodeList) xpath.evaluate(
            "/akn:akomaNtoso/akn:judgment/akn:meta/akn:analysis/akn:otherReferences/akn:implicitReference/ris:nachgehendeEntscheidung",
            baseDoc, XPathConstants.NODESET);

        Node otherReference = getOtherReferences(pendingProceedingReferences);

        if (otherReference == null) {
          return this;
        }

        if (replace) {
          for (int i = 0; i < pendingProceedingReferences.getLength(); i++) {
            otherReference.removeChild(pendingProceedingReferences.item(i).getParentNode());
          }
        }

        for (List<String> decisionParts : pendingProceedings) {
          if (decisionParts.size() != 7) {
            continue;
          }

          generateRelatedDecisionsReference(otherReference, decisionParts, DecisionType.PENDING);
        }
      } catch (XPathExpressionException e) {
        throw new RuntimeException(e);
      }
      return this;
    }

    private XMLStringObject changeOrAddPreviousDecisions(List<List<String>> previousDecisions, boolean replace) {
      try {
        NodeList previousDecisionReferences = (NodeList) xpath.evaluate(
            "/akn:akomaNtoso/akn:judgment/akn:meta/akn:analysis/akn:otherReferences/akn:implicitReference/ris:vorgehendeEntscheidung",
            baseDoc, XPathConstants.NODESET);

        Node otherReference = getOtherReferences(previousDecisionReferences);

        if (otherReference == null) {
          return this;
        }

        if (replace) {
          for (int i = 0; i < previousDecisionReferences.getLength(); i++) {
            otherReference.removeChild(previousDecisionReferences.item(i).getParentNode());
          }
        }

        for (List<String> decisionParts : previousDecisions) {
          if (decisionParts.size() != 7) {
            continue;
          }

          generateRelatedDecisionsReference(otherReference, decisionParts, DecisionType.PREVIOUS);
        }
      } catch (XPathExpressionException e) {
        throw new RuntimeException(e);
      }
      return this;
    }

    private void generateRelatedDecisionsReference(Node otherReference, List<String> decisionParts, DecisionType type) {
      org.w3c.dom.Element implicitReference = createElement("akn:implicitReference", "Rechtszug", null);
      org.w3c.dom.Element decisionReference = switch (type) {
        case PREVIOUS -> createElement("ris:vorgehendeEntscheidung", "Vorgehende Entscheidung", null);
        case ENSURING -> {
          var element = createElement("ris:nachgehendeEntscheidung", "Nachgehende Entscheidung", null);
          element.setAttribute("art", "nachgehend");
          yield element;
        }
        case PENDING -> {
          var element = createElement("ris:nachgehendeEntscheidung", "Nachgehende Entscheidung", null);
          element.setAttribute("art", "anhängig");
          yield element;
        }
      };
      decisionReference.appendChild(createElement("ris:documenttyp", "Dokumenttyp", decisionParts.getFirst()));
      if (type == DecisionType.PENDING) {
        decisionReference.appendChild(
            createElement("ris:mitteilungsdatum", "Mitteilungsdatum", decisionParts.get(1)));
      } else {
        decisionReference.appendChild(
            createElement("ris:entscheidungsdatum", "Entscheidungsdatum", decisionParts.get(1)));
      }
      decisionReference.appendChild(createElement("ris:dokumentnummer", "Dokumentnummer", decisionParts.get(2)));
      decisionReference.appendChild(createElement("ris:aktenzeichen", "Aktenzeichen", decisionParts.get(3)));
      var court = createElement("ris:gericht", "Gericht", null);
      court.appendChild(createElement("ris:gerichtstyp", "Gerichtstyp", decisionParts.get(4)));
      court.appendChild(createElement("ris:gerichtsort", "Gerichtsort", decisionParts.get(5).isBlank() ? null : decisionParts.get(5)));
      court.appendChild(createElement("ris:gerichtsbarkeit", "Gerichtsbarkeit", decisionParts.get(6).isBlank() ? null : decisionParts.get(6)));
      decisionReference.appendChild(court);
      implicitReference.appendChild(decisionReference);
      otherReference.appendChild(implicitReference);
    }

    private XMLStringObject changeOrAddNorms(List<List<String>> norms, boolean replace) {
      try {
        NodeList normsReferences = (NodeList) xpath.evaluate(
            "/akn:akomaNtoso/akn:judgment/akn:meta/akn:analysis/akn:otherReferences/akn:implicitReference/ris:referenzNorm",
            baseDoc, XPathConstants.NODESET);

        Node otherReference = getOtherReferences(normsReferences);

        if (otherReference == null) {
          return this;
        }

        if (replace) {
          for (int i = 0; i < normsReferences.getLength(); i++) {
            otherReference.removeChild(normsReferences.item(i).getParentNode());
          }
        }

        for (List<String> normParts : norms) {
          if (normParts.size() != 3) {
            continue;
          }
          org.w3c.dom.Element implicitReference = createElement("akn:implicitReference", "Norm", null);
          org.w3c.dom.Element normReference = createElement("ris:referenzNorm", "Norm", null);
          normReference.appendChild(createElement("ris:abkuerzung", "Abkürzung", normParts.getFirst()));
          normReference.appendChild(createElement("ris:titel", "Amtliche Langüberschrift", normParts.get(1)));
          var singleNorm = createElement("ris:einzelnorm", "Einzelnorm", null);
          singleNorm.appendChild(createElement("ris:bezeichnung", "Bezeichnung", normParts.get(2)));
          normReference.appendChild(singleNorm);
          implicitReference.appendChild(normReference);
          otherReference.appendChild(implicitReference);
        }
      } catch (XPathExpressionException e) {
        throw new RuntimeException(e);
      }
      return this;
    }

    private Node getOtherReferences(NodeList references) throws XPathExpressionException {
      Node otherReference = null;
      if (references != null && references.getLength() > 0) {
        otherReference = references.item(0).getParentNode().getParentNode();
      } else {
        Node node = (Node) xpath.evaluate("/akn:akomaNtoso/akn:judgment/akn:meta/akn:analysis/akn:otherReferences", baseDoc, XPathConstants.NODE);
        if (node == null) {
          node = (Node) xpath.evaluate("/akn:akomaNtoso/akn:judgment/akn:meta/akn:analysis", baseDoc, XPathConstants.NODE);
          if (node == null) {
            return null;
          } else {
            Node child = baseDoc.createElement("akn:otherReferences");
            node.appendChild(child);
            otherReference = child;
          }
        } else {
          otherReference = node;
        }
      }
      return otherReference;
    }

    private org.w3c.dom.@NonNull Element createElement(String tagName, String domainTerm, String text) {
      org.w3c.dom.Element abbreviation = baseDoc.createElement(tagName);
      String namespacePrefix = "";
      if (tagName.startsWith("akn:")) {
        namespacePrefix = "ris:";
      }
      if (domainTerm != null && !domainTerm.isBlank()) {
        abbreviation.setAttribute(namespacePrefix + "domainTerm", domainTerm);
      }
      if (text != null && !text.isBlank()) {
        abbreviation.setTextContent(text);
      }
      return abbreviation;
    }

    private String transform() throws IOException {
      return XSLT_TRANSFORMER.transform(baseDoc, localImageResolver(SAMPLE_FILESYSTEM_ROOT));
    }

    private enum DecisionType { PREVIOUS, ENSURING, PENDING}
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
