import React from 'react'
import {DocsThemeConfig} from 'nextra-theme-docs'
import logo from './assets/BAKO_CONNECTOR_ICON.svg'
import favicon from './assets/BAKO_CONNECTOR_ICON.svg'
import Image from "next/image";

const config: DocsThemeConfig = {
    color: {
        hue: {
            dark: 50,
            light: 50
        }
    },
    head: (
        <>
            <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
            <meta property="og:title" content="Bako Safe (SDK)"/>
            <meta property="og:description" content="Documentation of Bako Safe SDK"/>
            <link rel="icon" href={favicon.src}/>
        </>
    ),
    logo: (
        <Image src={logo} width={40} alt="Bako Safe logo"/>
    ),
    project: {
        link: 'https://github.com/infinitybase/bako-safe',
    },
    chat: {
        link: 'https://discord.gg/gSXeZkF2',
    },
    footer: {
        content: 'Bako Safe'
    },
    feedback: {
        content: <></>
    },
    editLink: {
        component: () => <></>
    }
}

export default config
