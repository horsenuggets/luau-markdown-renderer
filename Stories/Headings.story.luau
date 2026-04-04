--[[

Headings.story

Demonstrates all six heading levels with proper sizing and bold
rendering.

--]]

local dedent = require("@markdownrenderer/dedent")
local makeStory = require("@stories/makeStory")

return makeStory(dedent([[
    # Heading Level 1

    ## Heading Level 2

    ### Heading Level 3

    #### Heading Level 4

    ##### Heading Level 5

    ###### Heading Level 6

    Some paragraph text after the headings.
]]))
