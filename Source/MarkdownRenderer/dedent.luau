--[[

dedent

Strips common leading whitespace from a multi-line string. Removes
the first and last lines if they are blank so you can write multi-line
strings with the content starting on the next line. Detects the
indentation level from the first non-empty content line and removes
that many characters from the start of every line.

--]]

local t = require("@packages/t")

local function dedent(text: string): string
    assert(t.string(text))
    -- Remove a single leading newline and trailing whitespace
    text = text:gsub("^\n", "")
    text = text:gsub("%s+$", "")

    -- Find the indentation of the first non-empty line
    local indent = text:match("^(%s+)")
    if not indent then
        return text
    end

    -- Remove that indentation from every line
    local pattern = "\n" .. indent
    text = text:gsub("^" .. indent, "")
    text = text:gsub(pattern, "\n")

    return text
end

return dedent
