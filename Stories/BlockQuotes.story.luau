--[[

BlockQuotes.story

Demonstrates block quotes with nested content.

--]]

local dedent = require("@markdownrenderer/dedent")
local makeStory = require("@stories/makeStory")

return makeStory(dedent([[
    ## Block Quotes

    > This is a simple block quote.

    > This quote has **bold** and *italic* formatting.

    > This is a multi-line quote
    > that spans two lines.

    Some text between quotes.

    > Outer quote
    > > Nested quote inside
    > Back to outer
]]))
