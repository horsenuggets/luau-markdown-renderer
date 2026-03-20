--[[

renderInline

Converts an array of InlineSpan objects into a Roblox RichText string.
Handles bold, italic, strikethrough, and inline code formatting using
the appropriate RichText XML tags.

--]]

local Types = require("./Types")
local sanitize = require("./sanitize")

local function renderInline(spans: { Types.InlineSpan }): string
    local parts: { string } = {}
    for _, span in spans do
        local text = sanitize(span.Text)
        if span.Code then
            text = `<font face="RobotoMono" size="14"><mark color="#333333">\u{00A0}{text}\u{00A0}</mark></font>`
        end
        if span.Bold then
            text = `<b>{text}</b>`
        end
        if span.Italic then
            text = `<i>{text}</i>`
        end
        if span.Strikethrough then
            text = `<s>{text}</s>`
        end
        table.insert(parts, text)
    end
    return table.concat(parts)
end

return renderInline
