// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin");
const fs = require("fs");
const path = require("path");

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/sentinel_web.ex",
    "../lib/sentinel_web/**/*.*ex",
    "./node_modules/flowbite/**/*.js",
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: "#f4f6fb",
          100: "#e9ecf5",
          200: "#ced8e9",
          300: "#a3b7d6",
          400: "#7190bf",
          500: "#4f71a8",
          600: "#385383",
          700: "#324872",
          800: "#2c3e60",
          900: "#293651",
          950: "#1b2336",
        },
        danger: {
          50: "#fff1f0",
          100: "#ffdfdd",
          200: "#ffc5c1",
          300: "#ff9b95",
          400: "#ff6359",
          500: "#ff3225",
          600: "#fd190b",
          700: "#d50c00",
          800: "#b00e04",
          900: "#91130b",
          950: "#500500",
        },
        success: {
          50: "#f0fdf6",
          100: "#dbfdec",
          200: "#b9f9d8",
          300: "#83f2bb",
          400: "#45e395",
          500: "#1bbc6d",
          600: "#12a75e",
          700: "#12834c",
          800: "#14673f",
          900: "#125536",
          950: "#042f1c",
        },
        warning: {
          50: "#fbfee8",
          100: "#f6ffc2",
          200: "#f1ff88",
          300: "#f1ff43",
          400: "#f9ff10",
          500: "#efea03",
          600: "#dec800",
          700: "#a48704",
          800: "#87690c",
          900: "#735510",
          950: "#432e05",
        },
      },
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    require("flowbite/plugin")({ charts: true }),

    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({ addVariant }) =>
      addVariant("phx-no-feedback", [
        ".phx-no-feedback&",
        ".phx-no-feedback &",
      ]),
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-click-loading", [
        ".phx-click-loading&",
        ".phx-click-loading &",
      ]),
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-submit-loading", [
        ".phx-submit-loading&",
        ".phx-submit-loading &",
      ]),
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-change-loading", [
        ".phx-change-loading&",
        ".phx-change-loading &",
      ]),
    ),

    // Embeds Heroicons (https://heroicons.com) into your app.css bundle
    // See your `CoreComponents.icon/1` for more information.
    //
    plugin(function ({ matchComponents, theme }) {
      let iconsDir = path.join(__dirname, "./vendor/heroicons/optimized");
      let values = {};
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"],
      ];
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).forEach((file) => {
          let name = path.basename(file, ".svg") + suffix;
          values[name] = { name, fullPath: path.join(iconsDir, dir, file) };
        });
      });
      matchComponents(
        {
          hero: ({ name, fullPath }) => {
            let content = fs
              .readFileSync(fullPath)
              .toString()
              .replace(/\r?\n|\r/g, "");
            return {
              [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
              "-webkit-mask": `var(--hero-${name})`,
              mask: `var(--hero-${name})`,
              "mask-repeat": "no-repeat",
              "background-color": "currentColor",
              "vertical-align": "middle",
              display: "inline-block",
              width: theme("spacing.5"),
              height: theme("spacing.5"),
            };
          },
        },
        { values },
      );
    }),
  ],
};
