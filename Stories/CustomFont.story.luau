--[[

CustomFont.story

Demonstrates rendering with a custom font (Nunito) instead of the
default Source Sans Pro.

--]]

local Fusion = require("@packages/Fusion")
local MarkdownRenderer = require("@markdownrenderer")
local dedent = require("@markdownrenderer/dedent")

local Children = Fusion.Children

local SOURCE = dedent([[
	# Custom Font Demo

	This story uses **Nunito** as the base font instead of the
	default Source Sans Pro. All text elements use this font.

	## Features

	- Bold text renders with the **bold weight** of the font
	- *Italic text* uses the italic variant
	- `inline code` still uses RobotoMono
	- ~~Strikethrough~~ works as expected

	## Code Block

	```luau
	local function hello(name: string)
	    print(`Hello, {name}!`)
	end
	```

	> Block quotes inherit the custom font as well.

	---

	1. Numbered lists
	2. Also use the custom font
	3. For all text content
]])

return {
    fusion = Fusion,
    story = function(props)
        local scope = props.scope

        local ui = MarkdownRenderer.render(scope, {
            Source = SOURCE,
            Font = Font.new("rbxasset://fonts/families/Nunito.json"),
            BoldFont = Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.Bold),
        })
        ui.AnchorPoint = Vector2.new(0.5, 0.5)
        ui.Position = UDim2.fromScale(0.5, 0.5)
        ui.Size = UDim2.new(1, -50, 1, -50)
        ui.Parent = props.target
    end,
}
