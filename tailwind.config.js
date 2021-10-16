module.exports = {
  mode: 'jit',
  purge: ['./app/**/*.html.erb', './app/**/*.html.haml', './app/helpers/**/*.rb', './app/**/**/*.js',],
  darkMode: false, // or 'media' or 'class'
  corePlugins: {
    preflight: false,
  },
  prefix: 'tw-',
  theme: {
    extend: {},
  },
  variants: {
    extend: {},
  },
  plugins: [],
}
