import React from "react";

const Container = ({children}) => {
    return (
        <div style={{
            width: '100%',
            padding: 12,
            border: '1px solid',
            marginTop: 12,
            marginBottom: 12
        }}>
            {children}
        </div>
    )
}

const Button = ({children, ...rest}) => {
    const { style, ...props } = rest;

    return (
        <button
            style={{
                ...style,
                backgroundColor: '#57d57d',
                color: 'rgba(16,44,24)',
                padding: '0.3rem 0.5rem',
                fontWeight: 600
            }}
            {...props}
        >
            {children}
        </button>
    )
}

const Box = ({as = 'div', ...props}) => {
    return React.createElement(as, props)
}

const Text = ({as = 'p', ...props}) => {
    return React.createElement(as, props)
}

const Example = {
    Box,
    Text,
    Button,
    Container,
}

export {Example}
