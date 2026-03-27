--[[

Lists.story

Demonstrates bullet lists and numbered lists, including nested
items.

--]]

local dedent = require("@markdownrenderer/dedent")
local makeStory = require("@stories/makeStory")

return makeStory(dedent([[
    ## Bullet List

    - First item
    - Second item
      - Nested item A
      - Nested item B
        - Deeply nested
    - Third item

    ## Numbered List

    1. Step one
    2. Step two
    3. Step three

    ## Mixed Content in Lists

    - An item with **bold** text
    - An item with `inline code`
    - An item with *italic* and ~~strikethrough~~
]]))
