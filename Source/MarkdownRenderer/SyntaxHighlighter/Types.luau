--[[

Types

Type definitions for the syntax highlighting system.

--]]

export type TokenType =
    "builtin"
    | "comment"
    | "function_call"
    | "keyword"
    | "normal"
    | "number"
    | "operator"
    | "punctuation"
    | "string"
    | "type"

export type Token = {
    text: string,
    type: TokenType,
}

export type StringDelimiter = {
    close: string,
    escape: string?,
    multiline: boolean?,
    open: string,
}

export type LanguageGrammar = {
    blockComments: { { string } }?,
    builtins: { string }?,
    detectFunctionCalls: boolean?,
    htmlTags: boolean?,
    keywords: { string }?,
    lineComments: { string }?,
    operators: string?,
    punctuation: string?,
    strings: { StringDelimiter }?,
    types: { string }?,
    uppercaseTypes: boolean?,
}

export type PreparedGrammar = {
    blockComments: { { string } }?,
    builtins: { [string]: boolean },
    detectFunctionCalls: boolean,
    htmlTags: boolean,
    keywords: { [string]: boolean },
    lineComments: { string }?,
    operators: string,
    punctuation: string,
    strings: { StringDelimiter }?,
    types: { [string]: boolean },
    uppercaseTypes: boolean,
}

export type Theme = {
    builtin: string,
    comment: string,
    function_call: string,
    keyword: string,
    normal: string,
    number: string,
    operator: string,
    punctuation: string,
    string: string,
    type: string,
}

return {}
