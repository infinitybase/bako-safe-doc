import React from 'react'
import {DocsThemeConfig} from 'nextra-theme-docs'
import logo from './assets/bakoLogoWhite.svg'
import favicon from './assets/favicon.ico'
import Image from "next/image";

const config: DocsThemeConfig = {
    primaryHue: {
        dark: 50,
        light: 162,
    },
    head: (
        <>
            <meta name="viewport" content="width=device-width, initial-scale=1.0" />
            <meta property="og:title" content="Bako Safe (SDK)" />
            <meta property="og:description" content="Documentation of Bako Safe SDK" />
            <link rel="icon" href={favicon.src} />
        </>
    ),
    logo: (
        <Image src={logo} width={90} alt="Bako Safe logo"/>
    ),
    project: {
        link: 'https://github.com/infinitybase/bsafe',
    },
    chat: {
        link: 'https://discord.gg/dbejzM7f',
    },
    footer: {
        text: 'Bako Safe',
    },
    useNextSeoProps() {
        return {
            titleTemplate: 'Bako Safe SDK - %s'
        }
    },
    feedback: {
        content: <></>
    },
    editLink: {
        component: () => <></>
    }
}

export default config
