--[[

sanitize

Escapes special HTML/XML characters for safe use in Roblox RichText
strings. Converts &, <, >, and " to their entity equivalents.

--]]

local t = require("@packages/t")

local function sanitize(text: string): string
    assert(t.string(text))
    text = string.gsub(text, "&", "&amp;")
    text = string.gsub(text, "<", "&lt;")
    text = string.gsub(text, ">", "&gt;")
    text = string.gsub(text, '"', "&quot;")
    return text
end

return sanitize
