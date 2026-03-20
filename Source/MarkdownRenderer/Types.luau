--[[

Types

Shared type definitions for the Markdown parser AST. These types describe
the structure of parsed Markdown documents and are used by both the parser
and renderer modules.

--]]

local Types = {}

export type InlineSpan = {
    Text: string,
    Bold: boolean,
    Italic: boolean,
    Strikethrough: boolean,
    Code: boolean,
}

export type ListItem = {
    Content: { InlineSpan },
    Indent: number,
}

export type BlockNode = {
    Type: "Paragraph" | "Heading" | "CodeBlock" | "BulletList" | "NumberedList" | "BlockQuote" | "HorizontalRule",
    Content: { InlineSpan }?,
    Level: number?,
    Language: string?,
    Code: string?,
    Items: { ListItem }?,
    Children: { BlockNode }?,
}

return Types
