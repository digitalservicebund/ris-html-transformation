import { defineConfig } from 'vite'

export default defineConfig({
  plugins: [
    {
      name: 'transform-file',
      transform(src, id) {
        if (id.endsWith('css')) {
          return {
            code: src
              // remove unsupported selector
              .replaceAll(/:host/g, ':not(*)')
              // remove unsupported pseudo class
              .replaceAll(/::backdrop/g, ':not(*)')
              // remove unsupported pseudo class
              .replaceAll(/::file-selector-button/g, ':not(*)')
            ,
            map: null,
          }
        }
      },
    }
  ],

  build: {
    minify: false,
    target: 'esnext',
    lib: {
      formats: ['es'],
      entry: {
        "index": "src/index.ts",
      },
      cssFileName: "style",
    },
  },
})