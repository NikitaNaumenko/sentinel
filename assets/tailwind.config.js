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
        border: "hsl(var(--border))",
        input: "hsl(var(--input))",
        ring: "hsl(var(--ring))",
        background: "hsl(var(--background))",
        foreground: "hsl(var(--foreground))",
        primary: {
          DEFAULT: "var(--primary)",
          foreground: "var(--primary-foreground)",
        },
        secondary: {
          DEFAULT: "hsl(var(--secondary))",
          foreground: "hsl(var(--secondary-foreground))",
        },
        danger: {
          DEFAULT: "hsl(var(--danger) / <alpha-value>)",
          foreground: "hsl(var(--danger-foreground) / <alpha-value>)",
        },
        success: {
          DEFAULT: "hsl(var(--success) / <alpha-value>)",
          foreground: "hsl(var(--success-foreground) / <alpha-value>)",
        },
        muted: {
          DEFAULT: "hsl(var(--muted))",
          foreground: "hsl(var(--muted-foreground))",
        },
        accent: {
          DEFAULT: "hsl(var(--accent))",
          foreground: "hsl(var(--accent-foreground))",
        },
      },
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    require("flowbite/plugin"),

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
    // plugin(
    //   function ({ matchComponents, theme }) {
    //     let iconsDir = path.join(__dirname, "./node_modules/lucide-static/");
    //     let values = {};
    //     let icons = [["", "/icons"]];
    //     icons.forEach(([suffix, dir]) => {
    //       fs.readdirSync(path.join(iconsDir, dir)).forEach((file) => {
    //         let name = path.basename(file, ".svg") + suffix;
    //         values[name] = { name, fullPath: path.join(iconsDir, dir, file) };
    //       });
    //     });
    //     matchComponents(
    //       {
    //         icon: ({ name, fullPath }) => {
    //           let content = fs
    //             .readFileSync(fullPath)
    //             .toString()
    //             .replace(/\r?\n|\r/g, "");
    //           return {
    //             [`--icon-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
    //             "-webkit-mask": `var(--icon-${name})`,
    //             mask: `var(--icon-${name})`,
    //             "mask-repeat": "no-repeat",
    //             "background-color": "currentColor",
    //             "vertical-align": "middle",
    //             display: "inline-block",
    //             width: theme("spacing.6"),
    //             height: theme("spacing.6"),
    //           };
    //         },
    //       },
    //       { values },
    //     );
    //   },
    //   // plugin(function ({ matchComponents, theme }) {
    //   //   let iconsDir = path.join(__dirname, "./vendor/heroicons/optimized");
    //   //   let values = {};
    //   //   let icons = [
    //   //     ["", "/24/outline"],
    //   //     ["-solid", "/24/solid"],
    //   //     ["-mini", "/20/solid"],
    //   //   ];
    //   //   icons.forEach(([suffix, dir]) => {
    //   //     fs.readdirSync(path.join(iconsDir, dir)).forEach((file) => {
    //   //       let name = path.basename(file, ".svg") + suffix;
    //   //       values[name] = { name, fullPath: path.join(iconsDir, dir, file) };
    //   //     });
    //   //   });
    //   //   matchComponents(
    //   //     {
    //   //       hero: ({ name, fullPath }) => {
    //   //         let content = fs
    //   //           .readFileSync(fullPath)
    //   //           .toString()
    //   //           .replace(/\r?\n|\r/g, "");
    //   //         return {
    //   //           [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
    //   //           "-webkit-mask": `var(--hero-${name})`,
    //   //           mask: `var(--hero-${name})`,
    //   //           "mask-repeat": "no-repeat",
    //   //           "background-color": "currentColor",
    //   //           "vertical-align": "middle",
    //   //           display: "inline-block",
    //   //           width: theme("spacing.5"),
    //   //           height: theme("spacing.5"),
    //   //         };
    //   //       },
    //   //     },
    //   //     { values },
    //   //   );
    //   // }
    // ),
  ],
};
