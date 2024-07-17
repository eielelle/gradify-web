const defaultTheme = require("tailwindcss/defaultTheme");

module.exports = {
  content: [
    "./public/*.html",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/views/**/*.{erb,haml,html,slim}",
  ],
  theme: {
    extend: {
      keyframes: {
        pop: {
          '0%, 100%': { transform: 'scale(1)' },
          '50%': { transform: 'scale(1.2)' },
        },
      },
      animation: {
        pop: 'pop 0.3s ease-in-out',
      },
      fontFamily: {
        sans: ["Inter var", ...defaultTheme.fontFamily.sans],
      },
    },
  },
  plugins: [
    // require("@tailwindcss/forms"), // NOTE: This causes weird artifacts in daisyui. Please don't use this.
    require("@tailwindcss/typography"),
    require("@tailwindcss/container-queries"),
    // require("flowbite/plugin"),
    require('daisyui'),
  ],
};
