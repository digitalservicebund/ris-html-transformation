# Build-time CSS generation

This folder compiles [`src/style.css`](src/style.css) (Tailwind CSS input) into a
WeasyPrint-compatible, self-contained CSS file using [Vite](https://vitejs.dev)
and [Tailwind CSS](https://tailwindcss.com).

It is invoked automatically as part of the Gradle build (see the root
`build.gradle.kts`) and its output (`dist/style.css`) is packaged into
`src/main/resources/style.css`, which ends up in the published jar.

For background on the required setup (individual tailwind imports instead of
`@layer`, disabling optimization to keep `@page :nth(...)` rules, and
replacing selectors unsupported by WeasyPrint), see:
https://github.com/digitalservicebund/ris-pdf-infra/blob/main/doc/how-to-use-weasyprint-with-tailwind.md

## Manual usage

```shell
npm install
npm run build
```

The compiled CSS is written to `dist/style.css`.

