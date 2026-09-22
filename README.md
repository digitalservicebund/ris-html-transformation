# ris-html-transformation

[![Pipeline](https://github.com/digitalservicebund/ris-html-transformation/actions/workflows/pipeline.yml/badge.svg)](https://github.com/digitalservicebund/ris-html-transformation/actions/workflows/pipeline.yml)

This repository provides a Java library that converts LegalDocML documents into HTML. It supports two output targets:

- **Portal HTML** — HTML rendered for the [RIS portal](https://testphase.rechtsinformationen.bund.de/), used to display documents to end users.
- **PDF HTML** — a separately styled HTML variant (with embedded CSS from the [`pdf-html-styling`](./pdf-html-styling) module and inlined images) intended to be rendered into PDF documents.

The transformation is implemented using XSLT stylesheets, applied via Saxon, for the following document types:

- Caselaw documents (`CaselawXsltTransformer` for portal HTML, `CaselawPdfXsltTransformer` for PDF HTML)
- ULI documents (`LiteratureXsltTransformer` for portal HTML)
- SLI documents (`SliLiteratureXsltTransformer` for portal HTML)

## Usage in a Java project

The library is published to [GitHub Packages](https://github.com/digitalservicebund/ris-html-transformation/packages).

### Gradle

Add the GitHub Packages repository (requires a GitHub token with `read:packages` scope) and the dependency:

```kotlin
repositories {
    mavenCentral()
    maven {
        url = uri("https://maven.pkg.github.com/digitalservicebund/ris-html-transformation")
        credentials {
            username = System.getenv("GITHUB_ACTOR")
            password = System.getenv("GITHUB_TOKEN")
        }
    }
}

dependencies {
    implementation("de.bund.digitalservice:ris-html-transformation:<version>")
}
```

### Example

```java
System.setProperty("javax.xml.transform.TransformerFactory", "net.sf.saxon.TransformerFactoryImpl");

// Portal HTML for a case law document
String caselawHtml = new CaselawXsltTransformer().transform(ldmlBytes, resourcesBasePath);

// HTML for PDF generation, resolving referenced images yourself
String pdfHtml = new CaselawPdfXsltTransformer().transform(ldmlBytes, imageReference -> {
    // load and return the image bytes and media type
    return new CaselawPdfXsltTransformer.ResolvedImage(imageBytes, "image/png");
});

// Literature documents
String uliHtml = new LiteratureXsltTransformer().transform(ldmlBytes);
String sliHtml = new SliLiteratureXsltTransformer().transform(ldmlBytes);
```

## Running the tests

The project uses Gradle and JUnit 5. Run the test suite with:

```sh
./gradlew test
```

## Creating a new release

Releases are created via the GitHub UI by pushing a new tag:

1. Go to the repository's [Releases page](https://github.com/digitalservicebund/ris-html-transformation/releases) and click **"Draft a new release"**.
2. Under **"Choose a tag"**, create a new tag following the pattern `vX.Y.Z` (e.g. `v1.2.3`), targeting the `main` branch.
3. Fill in the release title and notes, then click **"Publish release"**.

Pushing a tag matching `v[0-9]+.[0-9]+.[0-9]+` automatically triggers the [`Publish to GitHub Packages`](./.github/workflows/publish.yml) workflow, which runs the pipeline and publishes the corresponding version (derived from the tag, without the `v` prefix) to GitHub Packages.
