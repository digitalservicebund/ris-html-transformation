export default {
  plugins: {
    "@tailwindcss/postcss": {
      // Tailwind's default optimization strips @page :nth(...) rules,
      // which are required for our print (WeasyPrint) page headers/footers.
      optimize: false,
    },
  },
}

