--[[

sanitize

Escapes special HTML/XML characters for safe use in Roblox RichText
strings. Converts &, <, >, and " to their entity equivalents.

--]]

local function sanitize(text: string): string
    text = string.gsub(text, "&", "&amp;")
    text = string.gsub(text, "<", "&lt;")
    text = string.gsub(text, ">", "&gt;")
    text = string.gsub(text, '"', "&quot;")
    return text
end

return sanitize
