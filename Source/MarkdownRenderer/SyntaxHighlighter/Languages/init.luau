--[[

Languages

Registry that maps language names and aliases to their grammar
tables. Aggregates all language family modules into a single
lookup table.

--]]

const CFamily = require("@self/CFamily")
const Data = require("@self/Data")
const Other = require("@self/Other")
const Scripting = require("@self/Scripting")
const Shell = require("@self/Shell")
const WebJS = require("@self/WebJS")

const Types = require("@markdownrenderer/SyntaxHighlighter/Types")
const t = require("@packages/t")

const registry: { [string]: Types.LanguageGrammar } = {}

const function registerFamily(family: { { aliases: { string }, grammar: Types.LanguageGrammar } })
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

const Languages = {}

function Languages.get(name: string): Types.LanguageGrammar?
    assert(t.string(name))
    return registry[string.lower(name)]
end

function Languages.list(): { string }
    const names = {}
    const seen: { [string]: boolean } = {}
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
