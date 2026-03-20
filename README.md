# luau-markdown-renderer

Renders Markdown text into Roblox Studio UI elements.

## Usage

```luau
local Fusion = require("@packages/Fusion")
local MarkdownRenderer = require("@packages/MarkdownRenderer")

local scope = Fusion.scoped(Fusion)

local ui = MarkdownRenderer.render(scope, {
    Source = "# Hello\n\nThis is **bold** and `code`.",
    Width = 400,
})
ui.Parent = someFrame
```

## Supported Markdown

- Headings (H1-H6)
- Paragraphs
- **Bold**, *italic*, ~~strikethrough~~, `inline code`
- Fenced code blocks with language tags
- Bullet lists with nesting
- Numbered lists
- Block quotes with nesting
- Horizontal rules

## Parser

The parser can be used independently without Fusion:

```luau
local Parser = require("@packages/MarkdownRenderer/Parser")

local nodes = Parser.parse("# Hello\n\nWorld")
```
