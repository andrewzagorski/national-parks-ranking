import { type Config } from 'prettier'

const config: Config = {
  trailingComma: 'none',
  semi: false,
  singleQuote: true,
  useTabs: false,
  plugins: ['prettier-plugin-tailwindcss']
}

export default config
