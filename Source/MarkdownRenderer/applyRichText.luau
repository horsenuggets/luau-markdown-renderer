--[[

applyRichText

Wraps text in RichText XML tags for bold, italic, and
strikethrough based on the formatting flags in an InlineSpan.

--]]

local Types = require("./Types")

local function applyRichText(text: string, span: Types.InlineSpan): string
    if span.Bold then
        text = `<b>{text}</b>`
    end
    if span.Italic then
        text = `<i>{text}</i>`
    end
    if span.Strikethrough then
        text = `<s>{text}</s>`
    end
    return text
end

return applyRichText
