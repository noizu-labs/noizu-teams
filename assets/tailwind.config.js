// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")
const fs = require("fs")
const path = require("path")

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/*_web.ex",
    "../lib/*_web/**/*.*ex"
  ],
  theme: {
    extend: {
      zIndex: {
        'main': '1',
        'nav': '5',
        '0': '0',
        '10': '10',
        '20': '20',
        '30': '30',
        '40': '40',
        '50': '50',
        '60': '60',
        '70': '70',
        '80': '80',
        '90': '90',
        '100': '100',
        'modal-base': '1000',
        'modal-base-1': '1010',
        'modal-base-2': '1020',
        'modal-base-3': '1030',
        'modal-base-4': '1040',
        'modal-base-5': '1050',
        'modal-container-1': '1500',
        'modal-container-1-0': '1550',
        'modal-container-1-1': '1600',
        'modal-container-1-2': '1700',
        'modal-container-1-3': '1800',
        'modal-container-1-4': '1900',

        'modal-container-2': '1500',
        'modal-container-2-0': '2050',
        'modal-container-2-1': '2100',
        'modal-container-2-2': '2200',
        'modal-container-2-3': '2300',
        'modal-container-2-4': '2400',

        'modal-container-3': '1500',
        'modal-container-3-0': '2550',
        'modal-container-3-1': '2600',
        'modal-container-3-2': '2700',
        'modal-container-3-3': '2800',
        'modal-container-3-4': '2900',

        'modal-container-4': '1500',
        'modal-container-4-0': '3050',
        'modal-container-4-1': '3100',
        'modal-container-4-2': '3200',
        'modal-container-4-3': '3300',
        'modal-container-4-4': '3400',

        'modal-container-5': '1500',
        'modal-container-5-0': '2550',
        'modal-container-5-1': '3600',
        'modal-container-5-2': '3700',
        'modal-container-5-3': '3800',
        'modal-container-5-4': '3900',

        'modal-container-6': '1500',
        'modal-container-6-0': '2050',
        'modal-container-6-1': '4100',
        'modal-container-6-2': '4200',
        'modal-container-6-3': '4300',
        'modal-container-6-4': '4400',

        'modal-container-7': '1500',
        'modal-container-7-0': '5550',
        'modal-container-7-1': '5600',
        'modal-container-7-2': '5700',
        'modal-container-7-3': '5800',
        'modal-container-7-4': '5900',





      },
      colors: {
        brand: "#FD4F00",
      }
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({addVariant}) => addVariant("phx-no-feedback", [".phx-no-feedback&", ".phx-no-feedback &"])),
    plugin(({addVariant}) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({addVariant}) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({addVariant}) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),

    // Embeds Hero Icons (https://heroicons.com) into your app.css bundle
    // See your `CoreComponents.icon/1` for more information.
    //
    plugin(function({matchComponents, theme}) {
      let iconsDir = path.join(__dirname, "./vendor/heroicons/optimized")
      let values = {}
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"]
      ]
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).map(file => {
          let name = path.basename(file, ".svg") + suffix
          values[name] = {name, fullPath: path.join(iconsDir, dir, file)}
        })
      })
      matchComponents({
        "hero": ({name, fullPath}) => {
          let content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")
          return {
            [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
            "-webkit-mask": `var(--hero-${name})`,
            "mask": `var(--hero-${name})`,
            "background-color": "currentColor",
            "vertical-align": "middle",
            "display": "inline-block",
            "width": theme("spacing.5"),
            "height": theme("spacing.5")
          }
        }
      }, {values})
    })
  ]
}
