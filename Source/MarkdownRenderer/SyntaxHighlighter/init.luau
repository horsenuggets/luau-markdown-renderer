--[[

SyntaxHighlighter

Public API for syntax highlighting. Takes source code and a language
name, tokenizes the code, and returns a RichText string with color
tags matching the selected theme.

--]]

const Languages = require("@self/Languages")
const Theme = require("@self/Theme")
const Tokenizer = require("@self/Tokenizer")
const t = require("@packages/t")

const sanitize = require("@markdownrenderer/sanitize")

const DIFF_ALIASES = { diff = true, patch = true }

-- Diff is line-based: + lines are green (string), - lines are
-- red (keyword), @@ lines are purple (function_call), and
-- everything else is normal.
const function highlightDiff(code: string, themeName: string?): string
    assert(t.string(code))
    assert(t.optional(t.string)(themeName))
    const theme = Theme.get(themeName)
    const parts: { string } = {}

    for line in string.gmatch(code .. "\n", "(.-)\n") do
        const sanitized = sanitize(line)
        const prefix = string.sub(line, 1, 1)
        const prefix2 = string.sub(line, 1, 2)

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

const function highlight(code: string, language: string?, themeName: string?): string
    assert(t.string(code))
    assert(t.optional(t.string)(language))
    assert(t.optional(t.string)(themeName))
    if not language or language == "" then
        return sanitize(code)
    end

    if DIFF_ALIASES[string.lower(language)] then
        return highlightDiff(code, themeName)
    end

    const grammar = Languages.get(language)
    if not grammar then
        return sanitize(code)
    end

    const theme = Theme.get(themeName)
    const tokens = Tokenizer.tokenize(code, grammar)
    const parts: { string } = {}

    local lastColor: string? = nil

    for _, token in tokens do
        const color = (theme :: any)[token.type] :: string
        const text = sanitize(token.text)

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

const SyntaxHighlighter = {}
SyntaxHighlighter.Languages = Languages
SyntaxHighlighter.Theme = Theme
SyntaxHighlighter.highlight = highlight

return SyntaxHighlighter
