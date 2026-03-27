--[[

CodeBlocks.story

Demonstrates fenced code blocks with and without language tags.

--]]

local dedent = require("@markdownrenderer/dedent")
local makeStory = require("@stories/makeStory")

return makeStory(dedent([[
    ## Code Examples

    A Luau code block:

    ```luau
    local function greet(name: string)
        print(`Hello, {name}!`)
    end

    greet("World")
    ```

    A code block with no language:

    ```
    just some plain text
    in a code block
    ```

    And some `inline code` in a paragraph.
]]))
