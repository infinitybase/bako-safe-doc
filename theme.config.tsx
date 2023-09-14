import React from 'react'
import { DocsThemeConfig } from 'nextra-theme-docs'
import logo from './assets/logo.svg'
import Image from "next/image";

const config: DocsThemeConfig = {
  logo: (
      <div style={{ display: 'flex', alignItems: 'center' }}>
        <Image src={logo} width={30} alt="Bsafe logo"  />
        <div style={{ marginLeft: 10 }}>SAFE</div>
      </div>
  ),
  project: {
    link: 'https://github.com/shuding/nextra-docs-template',
  },
  chat: {
    link: 'https://discord.com',
  },
  docsRepositoryBase: 'https://github.com/shuding/nextra-docs-template',
  footer: {
    text: 'Nextra Docs Template',
  },
}

export default config
