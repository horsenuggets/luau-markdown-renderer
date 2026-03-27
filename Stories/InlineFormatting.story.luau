--[[

InlineFormatting.story

Demonstrates inline formatting: bold, italic, strikethrough, and
inline code rendering.

--]]

local dedent = require("@markdownrenderer/dedent")
local makeStory = require("@stories/makeStory")

return makeStory(dedent([[
    This is **bold text** in a paragraph.

    This is *italic text* in a paragraph.

    This is ~~strikethrough text~~ in a paragraph.

    This is `inline code` in a paragraph.

    This has **bold and *italic* together** in one line.

    Mix everything: **bold**, *italic*, ~~struck~~, and `code` all at once.
]]))
