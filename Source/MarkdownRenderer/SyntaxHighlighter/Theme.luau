--[[

Theme

Color theme definitions for syntax highlighting. Each theme maps
token types to hex color strings for use in RichText font tags.

--]]

local Types = require("./Types")
local t = require("@packages/t")

local THEMES: { [string]: Types.Theme } = {
    ["github-dark"] = {
        builtin = "#ffa657",
        comment = "#8b949e",
        function_call = "#d2a8ff",
        keyword = "#ff7b72",
        normal = "#c9d1d9",
        number = "#79c0ff",
        operator = "#ff7b72",
        punctuation = "#c9d1d9",
        string = "#a5d6ff",
        type = "#ffa657",
    },
    ["github-light"] = {
        builtin = "#953800",
        comment = "#6e7781",
        function_call = "#8250df",
        keyword = "#cf222e",
        normal = "#24292f",
        number = "#0550ae",
        operator = "#cf222e",
        punctuation = "#24292f",
        string = "#0a3069",
        type = "#953800",
    },
    monokai = {
        builtin = "#66d9ef",
        comment = "#75715e",
        function_call = "#a6e22e",
        keyword = "#f92672",
        normal = "#f8f8f2",
        number = "#ae81ff",
        operator = "#f92672",
        punctuation = "#f8f8f2",
        string = "#e6db74",
        type = "#66d9ef",
    },
    ["one-dark"] = {
        builtin = "#d19a66",
        comment = "#5c6370",
        function_call = "#61afef",
        keyword = "#c678dd",
        normal = "#abb2bf",
        number = "#d19a66",
        operator = "#56b6c2",
        punctuation = "#abb2bf",
        string = "#98c379",
        type = "#e5c07b",
    },
}

local DEFAULT_THEME = "github-dark"

local Theme = {}

function Theme.get(name: string?): Types.Theme
    assert(t.optional(t.string)(name))
    return THEMES[name or DEFAULT_THEME] or THEMES[DEFAULT_THEME]
end

function Theme.list(): { string }
    local names = {}
    for name in THEMES do
        table.insert(names, name)
    end
    table.sort(names)
    return names
end

return Theme
