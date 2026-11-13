# 2. Common structure for generated HTML

Date: 2026-11-09

## Status

Proposed

## Context

This library turns LegalDocML documents into HTML with one XSLT stylesheet per
document kind: case law, literature (ULI and SLI), VV-Bund and BZSt. The HTML has
two purposes:

1. **Portal.** The portal frontend only needs rich text from it: text that
   keeps the structure and formatting from the LDML, such as paragraphs, lists,
   tables, headings and bold or italic text, so none of it gets lost when the
   text is displayed. Mostly this is the document text itself, for example the
   Leitsatz and Gründe of a decision. Some metadata may also be rich text that
   the portal needs to show elsewhere on the document page. All
   other metadata and all references of a document the Portal fetches from the JSON API, for
   example `/v1/rechtsprechung/{documentNumber}`.
2. **Public API.** API users download it from the `.html` endpoints, for example
   `/v1/rechtsprechung/{documentNumber}.html`. For them it can be convenient if
   the HTML also contains some metadata, so they can work with a document
   without also calling the JSON API.

Each stylesheet was written separately, so each produces a slightly differently
structured document. As a result, API users can't process documents of different kinds the same way, and every new document kind
might have its own structure.

## Decision

All stylesheets produce HTML with the same structure. Which text a document
contains is up to the team responsible for the document kind.

Whether metadata is added to the HTML at all, and which metadata, needs to be
decided separately. If metadata (e.g. when it contains rich text) is added, we suggest adding it as described
below.

```html
<!DOCTYPE html>
<html lang="de">
  <head>
    <meta charset="utf-8" />
    <title>Document title</title>

    <!-- Metadata: one entry per value, named as in the LDML -->
    <meta name="entscheidungsdatum" content="2026-01-15" />
    <template id="aktenzeichenListe">
      <ul>
        <li>1 BvR 123/24</li>
      </ul>
    </template>
  </head>
  <body>
    <!-- Only the title and the document text -->
    <h1 id="title">Document title</h1>
    <section id="leitsatz">
      <h2>Leitsatz</h2>
      …
    </section>
  </body>
</html>
```

### What goes where

| Content | Needed by the portal | Where it goes |
|---|---|---|
| Rich text that is part of the document text, e.g. Leitsatz, Tatbestand, Gründe | Yes | `<body>`, as sections in the order in which the portal displays them |
| Rich text in the metadata | Maybe, if the portal displays it elsewhere on the page | `<template id="…">` in `<head>` |
| Other metadata, e.g. dates, file numbers, courts | No, the portal gets it from the JSON API | If added: `<head>` |
| References (Verweise) to other documents | No, the portal gets them from the JSON API | If added: `<head>` |

### `<head>`: metadata

- Every document has `<html lang="de">`, `<meta charset="utf-8" />` and a
  `<title>`.
- Rich text that the portal should show elsewhere on the document page, not as part
  of the document text, is a `<template id="…">` in `<head>`, never part of
  `<body>`.

If metadata is added, we suggest adding it as follows:

- All metadata goes into `<head>`. That includes references to other
  documents.
- Every metadata entry is identified by a name taken from the LDML, as a rule
  of thumb:
  - the element name without prefix, for example `aktenzeichenListe` for
    `<ris:aktenzeichenListe>`,
  - or the `name` attribute of the element, for example `haupttitel` for
    `<akn:FRBRalias name="haupttitel" … />`.

  If neither fits, the team picks whatever it thinks is best.

- A single plain value is a `<meta name="…" content="…" />`, identified by its
  `name`.
- A list, or a value that is rich text, is a `<template id="…">`, identified by
  its `id`, with HTML inside, for example a `<ul>` with one `<li>` per entry.

### `<body>`: the document text

- The portal renders the content of `<body>` unchanged as the document text.
  Therefore `<body>` contains only the document title and text that is meant to
  be displayed there, and nothing else: no metadata and no references.
- Anything else that should not appear in the document text goes into
  `<head>`, even if it is shown elsewhere on the page.
- `<body>` may start with one `<h1 id="title">` that holds the document title.
- After the title, the text is split into `<section>` elements that are direct
  children of `<body>`, in the order in which the portal displays them. Each
  section has an `id` and starts with exactly one `<h2>`. Subheadings inside a
  section use `<h3>` and lower.
- A section id is the `xsi:type` of the LDML element without the prefix, for
  example `tatbestand` for `<akn:background xsi:type="ris:tatbestand">`. If the
  element has no `xsi:type`, the id follows the same rule as metadata entries.
- The `<h2>` of a section holds the `ris:domainTerm` of the LDML element, if it
  has one, for example `Tatbestand`.

### Consumers

- The **portal** displays the `<body>` as the document text and builds its table
  of contents from the sections. It shows the title at the top of the page
  itself, so it hides the `<h1 id="title">`. When it needs rich text from the
  metadata somewhere else on the page, it reads the matching `<template>` from
  `<head>` by `id`. All other metadata and all references come from the JSON
  API.
- The **public API** returns the complete HTML, including `<head>`. If metadata
  is added, it is mainly there for API users, so the HTML is complete on its
  own.

### Out of scope

- **Norms.** Their HTML follows the hierarchy of LegalDocML.de and is split into
  several files per norm. Norms can only adopt the `<head>` rules.

## Consequences

- The portal can display the text of every document kind the same way, straight
  from `<body>`, and find any other rich text by `id` in `<head>` instead
  of searching the document for it.
- API users can read every document kind the same way: text from `<body>`, and
  metadata, if added, by its LDML name from `<head>`.
- Teams stay free to decide which sections their document kind has, and a new
  document kind gets a known structure from the start.