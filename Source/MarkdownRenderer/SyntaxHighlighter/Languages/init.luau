--[[

Languages

Registry that maps language names and aliases to their grammar
tables. Aggregates all language family modules into a single
lookup table.

--]]

local CFamily = require("@self/CFamily")
local Data = require("@self/Data")
local Other = require("@self/Other")
local Scripting = require("@self/Scripting")
local Shell = require("@self/Shell")
local WebJS = require("@self/WebJS")

local Types = require("@self/../Types")

local registry: { [string]: Types.LanguageGrammar } = {}

local function registerFamily(family: { { aliases: { string }, grammar: Types.LanguageGrammar } })
    for _, entry in family do
        for _, alias in entry.aliases do
            registry[string.lower(alias)] = entry.grammar
        end
    end
end

registerFamily(CFamily)
registerFamily(Data)
registerFamily(Other)
registerFamily(Scripting)
registerFamily(Shell)
registerFamily(WebJS)

local Languages = {}

function Languages.get(name: string): Types.LanguageGrammar?
    return registry[string.lower(name)]
end

function Languages.list(): { string }
    local names = {}
    local seen: { [string]: boolean } = {}
    for name in registry do
        if not seen[name] then
            seen[name] = true
            table.insert(names, name)
        end
    end
    table.sort(names)
    return names
end

return Languages
