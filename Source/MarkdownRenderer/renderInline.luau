--[[

renderInline

Converts an array of InlineSpan objects into a Roblox RichText string.
Handles bold, italic, strikethrough, and inline code formatting using
the appropriate RichText XML tags.

--]]

local Types = require("./Types")
local applyRichText = require("./applyRichText")
local sanitize = require("./sanitize")
local t = require("@packages/t")

local function renderInline(spans: { Types.InlineSpan }): string
    assert(t.array(t.table)(spans))
    local parts: { string } = {}
    for _, span in spans do
        local text = sanitize(span.Text)
        if span.Code then
            text = `<font face="RobotoMono" size="14"><mark color="#333333">\u{00A0}{text}\u{00A0}</mark></font>`
        end
        text = applyRichText(text, span)
        table.insert(parts, text)
    end
    return table.concat(parts)
end

return renderInline
