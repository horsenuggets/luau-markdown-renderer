--[[

SyntaxHighlighter

Public API for syntax highlighting. Takes source code and a language
name, tokenizes the code, and returns a RichText string with color
tags matching the selected theme.

--]]

local Languages = require("@self/Languages")
local Theme = require("@self/Theme")
local Tokenizer = require("@self/Tokenizer")

local sanitize = require("@markdownrenderer/sanitize")

local DIFF_ALIASES = { diff = true, patch = true }

-- Diff is line-based: + lines are green (string), - lines are
-- red (keyword), @@ lines are purple (function_call), and
-- everything else is normal.
local function highlightDiff(code: string, themeName: string?): string
    local theme = Theme.get(themeName)
    local parts: { string } = {}

    for line in string.gmatch(code .. "\n", "(.-)\n") do
        local sanitized = sanitize(line)
        local prefix = string.sub(line, 1, 1)
        local prefix2 = string.sub(line, 1, 2)

        if prefix2 == "@@" then
            table.insert(parts, `<font color="{theme.function_call}">{sanitized}</font>`)
        elseif prefix == "+" then
            table.insert(parts, `<font color="{theme.string}">{sanitized}</font>`)
        elseif prefix == "-" then
            table.insert(parts, `<font color="{theme.keyword}">{sanitized}</font>`)
        else
            table.insert(parts, sanitized)
        end
        table.insert(parts, "\n")
    end

    -- Remove trailing newline
    if #parts > 0 then
        table.remove(parts)
    end

    return table.concat(parts)
end

local function highlight(code: string, language: string?, themeName: string?): string
    if not language or language == "" then
        return sanitize(code)
    end

    if DIFF_ALIASES[string.lower(language)] then
        return highlightDiff(code, themeName)
    end

    local grammar = Languages.get(language)
    if not grammar then
        return sanitize(code)
    end

    local theme = Theme.get(themeName)
    local tokens = Tokenizer.tokenize(code, grammar)
    local parts: { string } = {}

    local lastColor: string? = nil

    for _, token in tokens do
        local color = (theme :: any)[token.type] :: string
        local text = sanitize(token.text)

        if color == theme.normal then
            -- Normal text doesn't need a font tag
            if lastColor then
                table.insert(parts, "</font>")
                lastColor = nil
            end
            table.insert(parts, text)
        elseif color == lastColor then
            -- Same color as previous — already inside the right tag
            table.insert(parts, text)
        else
            if lastColor then
                table.insert(parts, "</font>")
            end
            table.insert(parts, `<font color="{color}">`)
            table.insert(parts, text)
            lastColor = color
        end
    end

    if lastColor then
        table.insert(parts, "</font>")
    end

    return table.concat(parts)
end

local SyntaxHighlighter = {}
SyntaxHighlighter.Languages = Languages
SyntaxHighlighter.Theme = Theme
SyntaxHighlighter.highlight = highlight

return SyntaxHighlighter
