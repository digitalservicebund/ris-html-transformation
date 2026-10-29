package de.bund.digitalservice.ris.html;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import de.bund.digitalservice.ris.html.exception.FileTransformationException;
import de.bund.digitalservice.ris.html.exception.XMLElementNotFoundException;
import de.bund.digitalservice.ris.html.service.xslt.NormsXsltTransformer;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.concurrent.Callable;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;
import javax.xml.transform.Source;
import javax.xml.transform.stream.StreamSource;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.CsvSource;
import org.xmlunit.builder.DiffBuilder;
import org.xmlunit.diff.Diff;

class NormsXsltTransformerTest {
  private static final String SAMPLES = "/samples/norms/";
  private static final String RESOURCES_BASE_PATH = "res://";
  private static final String ATTACHMENT_KEY =
      "eli/bund/bgbl-1/0000/s1000/2000-01-01/1/deu/2000-01-01/anlage-regelungstext-1.xml";

  private final String resourcesPath =
      Objects.requireNonNull(getClass().getResource("/samples/norms/")).getPath();

  /**
   * Previously this path was longer and was:
   * /norm/eli/bund/bgbl-1/1991/s101/1991-01-01/1/deu/1991-01-01/ but for simplicity I changed this
   * to a shorter path for the resources belonging to it.
   */
  private final String specificResourcesPath =
      Objects.requireNonNull(getClass().getResource("/samples/norms/specific/")).getPath();

  private final NormsXsltTransformer transformer = new NormsXsltTransformer();

  @Test
  void transformNorm_returnsCompleteHtmlDocument() throws IOException {
    String html =
        transformer.transformNorm(
            read("simple.xml"),
            "deu",
            RESOURCES_BASE_PATH,
            "regelungstext-1",
            Map.of(ATTACHMENT_KEY, read("anlage-regelungstext-1.xml")));

    Document document = Jsoup.parse(html);
    assertThat(Objects.requireNonNull(document.selectFirst("html")).attr("lang")).isEqualTo("de");
    assertThat(document.title()).contains("Testgesetz");
    assertThat(document.select("body.akn-akomaNtoso")).hasSize(1);
    assertThat(document.select("#art-z1_bezeichnung-n1").text()).isEqualTo("§ 1");
    assertThat(document.select("#art-z1_abs-z1_inhalt-n1_text-n1 b").text()).isEqualTo("Text");
    assertThat(document.select("a[href=regelungstext-1/art-z1.html]")).hasSize(1);
  }

  @Test
  void transformArticle_returnsOnlyRequestedArticle() throws IOException {
    String html = transformer.transformArticle(read("simple.xml"), "art-z1", RESOURCES_BASE_PATH);

    Document document = Jsoup.parse(html);
    assertThat(document.selectFirst("html")).isNotNull();
    assertThat(document.select("h2.einzelvorschrift").text()).isEqualTo("§ 1 Erster Artikel");
    assertThat(document.select(".included-document")).isEmpty();
  }

  @Test
  void transformArticle_unknownEId_throws() throws IOException {
    Source source = read("simple.xml");

    assertThatThrownBy(() -> transformer.transformArticle(source, "art-z99", RESOURCES_BASE_PATH))
        .isInstanceOf(XMLElementNotFoundException.class)
        .hasMessageContaining("art-z99");
  }

  @ParameterizedTest(name = "{2}")
  @CsvSource({
    "main,         twoParagraphArticle.xml, twoParagraphArticle.html,                               Should transform an article with two paragraphs",
    "main,         list.xml, list.html,                                                             Should transform list to HTML",
    "main,         fullDepthArticle.xml, fullDepthArticle.html,                                     Should transform full depth article to HTML",
    "main,         nestedArticles.xml, nestedArticles.html,                                         Should transform articles at every level to HTML",
    "main,         formatting.xml, formatting.html,                                                 Should transform an article with formatting to HTML",
    "main,         heading.xml, heading.html,                                                       Should transform a heading with marker inside",
    "main,         authorialNote.xml, authorialNote.html,                                           Should transform authorialNotes to HTML",
    "main,         authorialNoteWithPlacementBase.xml, authorialNoteWithPlacementBase.html,         Should transform authorialNotes with placementBase",
    "main,         authorialNoteInDocTitle.xml, authorialNoteInDocTitle.html,                       Should transform authorialNotes in title",
    "attachment,   authorialNoteInDocParent.xml, authorialNoteInDoc.html,                           Should transform authorialNotes in attachment body",
    "main,         notes.xml, notes.html,                                                           Should transform notes",
    "main,         image.xml, image.html,                                                           Should transform img tag",
    "main,         pdf.xml, pdf.html,                                                               Should transform links with pdf file",
    "main,         noPdfLinks.xml, noPdfLinks.html,                                                 Should not apply any special transformation to non-pdf links",
    "main,         container.xml, container.html,                                                   Should transform container elements in the preface",
    "main,         preambleFormula.xml, preambleFormula.html,                                       Should transform a preamble formula",
    "main,         preambleFormulaNotes.xml, preambleFormulaNotes.html,                             Should output notes of a preamble formula",
    "main,         preambleFormulaAndTocNotes.xml, preambleFormulaAndTocNotes.html,                 Should output notes of a preamble formula and of the official toc in their own containers",
    "main,         conclusionsFormula.xml, conclusionsFormula.html,                                 Should transform a conclusions formula",
    "main,         conclusionsFormulaNotes.xml, conclusionsFormulaNotes.html,                       Should output notes of a conclusions formula",
    "main,         blockList.xml, blockList.html,                                                   Should transform a blockList",
    "main,         preformatted.xml, preformatted.html,                                             Should transform preformatted paragraphs",
    "main,         proprietary.xml, proprietary.html,                                               Should transform proprietary metadata"
  })
  void testTransformNormLegalDocMlFull(
      String type, String inputFileName, String expectedFileName, String testName)
      throws IOException {
    Source in = sourceOf(Path.of(resourcesPath, inputFileName));

    Map<String, Source> references =
        Map.of(
            "eli/bund/bgbl-1/0000/s1000/2000-01-01/1/deu/2000-01-01/authorialNoteInDocAttachment.xml",
            sourceOf(Path.of(resourcesPath, "authorialNoteInDocAttachment.xml")));

    var result =
        type.equals("attachment")
            ? transformer.transformArticle(
                in, "anlagen-n1_anlage-n1", RESOURCES_BASE_PATH, references)
            : transformer.transformNorm(
                in, "deu", RESOURCES_BASE_PATH, "regelungstext-1", references);

    var outputSettings =
        new Document.OutputSettings()
            // Needed so not closing tags in html like <br> are transformed to self-closing tags
            // e.g. </br>
            .syntax(Document.OutputSettings.Syntax.xml)
            .prettyPrint(true);

    var expectedHtml =
        Jsoup.parse(Files.readString(Path.of(resourcesPath, expectedFileName)))
            .outputSettings(outputSettings)
            .body()
            .html();
    var actualHtml = Jsoup.parse(result).outputSettings(outputSettings).body().html();

    // Use xml Diffbuilder to be able to do a structural comparison not affected by whitespaces
    // around nodes
    Diff diff =
        DiffBuilder.compare(expectedHtml)
            .withTest(actualHtml)
            .ignoreWhitespace()
            .checkForIdentical()
            .build();
    assertThat(diff.hasDifferences()).describedAs(diff::toString).isFalse();
  }

  @Test
  void testTransformNormWithAttachments() throws IOException {
    Source in =
        new StreamSource(
            new ByteArrayInputStream(
                Files.readAllBytes(Path.of(resourcesPath, "attachments.xml"))));

    Map<String, Source> references =
        Map.of(
            "eli/bund/bgbl-1/0000/s1000/2000-01-01/1/deu/2000-01-01/anlage-regelungstext-1.xml",
            new StreamSource(
                new ByteArrayInputStream(
                    Files.readAllBytes(Path.of(resourcesPath, "anlage-regelungstext-1.xml")))),
            "eli/bund/bgbl-1/0000/s1000/2000-01-01/1/deu/2000-01-01/anlage-regelungstext-2.xml",
            new StreamSource(
                new ByteArrayInputStream(
                    Files.readAllBytes(Path.of(resourcesPath, "anlage-regelungstext-2.xml")))));

    var actualHtml =
        transformer.transformNorm(
            in, "subtype", RESOURCES_BASE_PATH, "regelungstext-1", references);

    var expectedHtml = Files.readString(Path.of(resourcesPath, "attachments.html"));
    var expectedDocument = Jsoup.parse(expectedHtml);
    var actualDocument = Jsoup.parse(actualHtml);
    assertThat(actualDocument.body().html()).isEqualTo(expectedDocument.body().html());
  }

  @Test
  void testHandlesMissingAttachment() throws IOException {
    // same file as in testTransformNormWithAttachments, but normsBucketMock isn't set up to serve
    // included files
    Source in =
        new StreamSource(
            new ByteArrayInputStream(
                Files.readAllBytes(Path.of(resourcesPath, "attachments.xml"))));

    FileTransformationException exception =
        Assertions.assertThrows(
            FileTransformationException.class,
            () -> transformer.transformNorm(in, "subtype", RESOURCES_BASE_PATH, "regelungstext-1"));
    assertThat(exception.getMessage()).endsWith("anlage-regelungstext-1.xml");
  }

  @Test
  @DisplayName("Includes a link to authorialNotes in the heading when in article mode")
  void testArticleHeadingWithAuthorialNote() throws IOException {
    Source in =
        new StreamSource(
            new ByteArrayInputStream(
                Files.readAllBytes(Path.of(resourcesPath, "authorialNote.xml"))));
    var actualHtml = transformer.transformArticle(in, "c", RESOURCES_BASE_PATH);
    var actualDocument = Jsoup.parse(actualHtml);
    var heading = actualDocument.select("h2").html();
    assertThat(heading)
        .isEqualTo(
            """
            <span class="akn-num" id="c_num-1">§ 1</span> <span class="akn-heading" id="c_heading-1">Article title <a href="#c_heading-1_amtlfnote-1"><sup>1</sup></a></span>""");
  }

  @Test
  @DisplayName("Outputs the same Eingangsformel footnotes in the norm and the single article view")
  void testPreambleFormulaNotesInBothViews() throws IOException {
    Path path = Path.of(resourcesPath, "preambleFormulaNotes.xml");

    var normView =
        Jsoup.parse(
            transformer.transformNorm(
                sourceOf(path), "deu", RESOURCES_BASE_PATH, "regelungstext-1"));
    var articleView =
        Jsoup.parse(
            transformer.transformArticle(
                sourceOf(path), "praeambel-n1_formel-n1", RESOURCES_BASE_PATH));

    for (Document view : List.of(normView, articleView)) {
      assertThat(view.select("ul.nichtamtliche-fussnoten > li.fussnote").text())
          .isEqualTo("Eingangsformel: Note attached to the Eingangsformel");
      assertThat(view.select("ol.fussnoten > li.fussnote").text())
          .startsWith("* Authorial note in the Eingangsformel");
    }

    // both lists belong to the Eingangsformel, not to the enclosing preamble
    assertThat(normView.select("#praeambel-n1_formel-n1 > ul.nichtamtliche-fussnoten")).hasSize(1);
    assertThat(normView.select("#praeambel-n1_formel-n1 > ol.fussnoten")).hasSize(1);
  }

  @Test
  @DisplayName("In can parse special characters in ids")
  void testSpecialCharacterInArticleEId() throws IOException {
    Source in =
        new StreamSource(
            new ByteArrayInputStream(
                Files.readAllBytes(
                    Path.of(resourcesPath, "articleWithSpecialCharactersInId.xml"))));
    // actual eid is "art-z§§ 1 bis 3"
    var result =
        transformer.transformArticle(in, "art-z%c2%a7%c2%a7%201%20bis%203", RESOURCES_BASE_PATH);

    var actualHtml = Jsoup.parse(result).body().html();

    var expectedHtml =
        Jsoup.parse(
                Files.readString(Path.of(resourcesPath, "articleWithSpecialCharactersInId.html")))
            .body()
            .html();

    assertThat(actualHtml).isEqualTo(expectedHtml);
  }

  @Test
  void testTransformsNormTocCorrectly() throws IOException {
    Source xml =
        new StreamSource(
            new ByteArrayInputStream(
                Files.readAllBytes(Path.of(specificResourcesPath, "regelungstext-1.xml"))));
    var html = transformer.transformNorm(xml, "subtype", RESOURCES_BASE_PATH, "regelungstext-1");
    var expectedToc =
        """
        <div class="level-1">
         <span class="akn-span" id="praeambel-n1_blockcontainer-n1_inhuebs-n1_eintrag-n1_span-n1">Abschnitt 1</span>
        </div>
        <div class="level-2">
         <span class="akn-span" id="praeambel-n1_blockcontainer-n1_inhuebs-n1_eintrag-n2_span-n1">Allgemeine Bestimmungen</span>
        </div>
        <div class="level-5">
         <span class="akn-span" id="praeambel-n1_blockcontainer-n1_inhuebs-n1_eintrag-n3_span-n1">Art 1</span> <span class="akn-span" id="praeambel-n1_blockcontainer-n1_inhuebs-n1_eintrag-n3_span-n2">Test Title</span>
        </div>
        <div class="level-1">
         <span class="akn-span" id="praeambel-n1_blockcontainer-n1_inhuebs-n1_eintrag-n4_span-n1">Art 2</span> <span class="akn-span" id="praeambel-n1_blockcontainer-n1_inhuebs-n1_eintrag-n4_span-n2">Another Test Title</span>
        </div>""";
    final Document parsed = Jsoup.parse(html);

    String actualToc = parsed.selectXpath("//div[@class='official-toc']").html();
    assertThat(actualToc).isEqualTo(expectedToc);
    String tocHeader = parsed.selectXpath("//div[@class='official-toc']/../span").html();
    assertThat(tocHeader).isEqualTo("Inhaltsübersicht");
  }

  @Test
  void testTransformsNormArticleCorrectly() throws IOException {
    Source xml =
        new StreamSource(
            new ByteArrayInputStream(
                Files.readAllBytes(Path.of(specificResourcesPath, "regelungstext-1.xml"))));
    var html = transformer.transformArticle(xml, "art-z1", RESOURCES_BASE_PATH);
    var expectedArticle =
        """
         <div id="art-z1" data-period="#meta-n1_geltzeiten-n1_geltungszeitgr-n1">
            <h2 class="einzelvorschrift">
              <span class="akn-num" id="art-z1_bezeichnung-n1">§ 1</span>
              <span class="akn-heading" id="art-z1_ueberschrift-n1">
                Basic HTML Elements
              </span>
            </h2>
            <section class="akn-paragraph" id="art-z1_abs-z1">
               <span class="akn-num" id="art-z1_abs-z1_bezeichnung-n1">(1)</span>
               <div class="akn-content" id="art-z1_abs-z1_inhalt-n1">
                  <p class="akn-p" id="art-z1_abs-z1_inhalt-n1_text-n1">
                     <b id="art-z1_abs-z1_inhalt-n1_text-n1_fettschrift-n1">Bold</b> text. <i id="art-z1_abs-z1_inhalt-n1_text-n1_kursiv-n1">Italic</i> text. <u id="art-z1_abs-z1_inhalt-n1_text-n1_u-n1">Underlined</u> text. This contains <sub id="art-z1_abs-z1_inhalt-n1_text-n1_sub-n1">subscript</sub> text. This contains <sup id="art-z1_abs-z1_inhalt-n1_text-n1_sup-n1">superscript</sup> text. This text contains a <a href="#" id="art-z1_abs-z1_inhalt-n1_text-n1_a-n1">link</a>. <span class="akn-span" id="art-z1_abs-z1_inhalt-n1_text-n1_span-n1">Inline container</span>. <br id="art-z1_abs-z1_inhalt-n1_text-n1_br-n1"><br id="art-z1_abs-z1_inhalt-n1_text-n1_br-n2">This text has two preceding line breaks.</p>
                  </div>
               </section>
             </div>
        """;
    var expectedDocument = Jsoup.parse(expectedArticle);
    var actualDocument = Jsoup.parse(html);
    assertThat(actualDocument.body().html()).isEqualTo(expectedDocument.body().html());
  }

  @Test
  void transformNorm_sameInputTwice_returnsIdenticalHtml() throws IOException {
    String first = normHtml();
    String second = normHtml();

    assertThat(bodyOf(second)).isEqualTo(bodyOf(first));
  }

  @Test
  void transform_concurrentCalls_returnSameResultAsSingleThreaded() throws Exception {
    String expectedNorm = bodyOf(normHtml());
    String expectedArticle = bodyOf(articleHtml());

    int threads = 8;
    int calls = 80;
    ExecutorService executor = Executors.newFixedThreadPool(threads);
    CountDownLatch start = new CountDownLatch(1);
    try {
      List<Future<String>> futures = new ArrayList<>();
      for (int i = 0; i < calls; i++) {
        boolean norm = i % 2 == 0;
        Callable<String> task =
            () -> {
              start.await();
              return norm ? normHtml() : articleHtml();
            };
        futures.add(executor.submit(task));
      }
      start.countDown();

      for (int i = 0; i < calls; i++) {
        String actual = futures.get(i).get(30, TimeUnit.SECONDS);
        assertThat(bodyOf(actual)).isEqualTo(i % 2 == 0 ? expectedNorm : expectedArticle);
      }
    } finally {
      executor.shutdownNow();
    }
  }

  private Source read(String name) throws IOException {
    try (InputStream in = getClass().getResourceAsStream(SAMPLES + name)) {
      assertThat(in).as(name).isNotNull();
      return new StreamSource(new ByteArrayInputStream(in.readAllBytes()));
    }
  }

  private String normHtml() throws IOException {
    return transformer.transformNorm(
        read("simple.xml"),
        "deu",
        RESOURCES_BASE_PATH,
        "regelungstext-1",
        Map.of(ATTACHMENT_KEY, read("anlage-regelungstext-1.xml")));
  }

  private String articleHtml() throws IOException {
    return transformer.transformArticle(read("simple.xml"), "art-z1", RESOURCES_BASE_PATH);
  }

  private static String bodyOf(String html) {
    return Jsoup.parse(html).body().html();
  }

  private static Source sourceOf(Path path) throws IOException {
    return new StreamSource(new ByteArrayInputStream(Files.readAllBytes(path)));
  }
}
