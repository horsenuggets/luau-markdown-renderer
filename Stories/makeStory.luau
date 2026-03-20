--[[

makeStory

Creates a UI Labs Fusion story definition from a Markdown source
string. Renders the Markdown centered in the story frame with 25px
padding on each side.

--]]

local Fusion = require("@packages/Fusion")
local MarkdownRenderer = require("@markdownrenderer")

local function makeStory(source: string)
    return {
        fusion = Fusion,
        story = function(props)
            local scope = props.scope

            local ui = MarkdownRenderer.render(scope, {
                Source = source,
            })
            ui.AnchorPoint = Vector2.new(0.5, 0.5)
            ui.Position = UDim2.fromScale(0.5, 0.5)
            ui.Size = UDim2.new(1, -50, 1, -50)
            ui.Parent = props.target
        end,
    }
end

return makeStory
