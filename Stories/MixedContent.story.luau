--[[

MixedContent.story

Demonstrates a realistic README-style document with mixed Markdown
elements.

--]]

local dedent = require("@markdownrenderer/dedent")
local makeStory = require("@stories/makeStory")

return makeStory(dedent([[
	# luau-markdown-renderer

	Renders Markdown text into **Roblox Studio** UI elements.

	## Features

	- Parse Markdown into an AST
	- Render AST as Fusion UI components
	- Supports **bold**, *italic*, ~~strikethrough~~, and `code`
	- Headings, lists, code blocks, and more

	## Installation

	Add to your `wally.toml`:

	```toml
	[dependencies]
	MarkdownRenderer = "horsenuggets/luau-markdown-renderer@latest"
	```

	## Usage

	```luau
	local MarkdownRenderer = require("@packages/MarkdownRenderer")

	local ui = MarkdownRenderer(scope, {
	    Source = "# Hello\n\nWorld",
	})
	```

	---

	## Notes

	> The parser is zero-dependency and can be used independently
	> from the renderer.

	### Supported Blocks

	1. Paragraphs
	2. Headings (H1-H6)
	3. Code blocks
	4. Bullet lists
	5. Numbered lists
	6. Block quotes
	7. Horizontal rules

	#### Inline Formatting

	All inline formatting works inside paragraphs, headings, and list
	items. Code blocks preserve raw text without formatting.
]]))
