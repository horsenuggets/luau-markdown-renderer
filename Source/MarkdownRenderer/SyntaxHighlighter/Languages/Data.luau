--[[

Data

Language grammars for data formats: JSON, TOML, and YAML.

--]]

local DOUBLE_QUOTE = { open = '"', close = '"' }
local SINGLE_QUOTE = { open = "'", close = "'" }

local JSON = {
    keywords = { "false", "null", "true" },
    strings = {
        DOUBLE_QUOTE,
    },
    detectFunctionCalls = false,
}

local TOML = {
    keywords = { "false", "true" },
    lineComments = { "#" },
    strings = {
        { open = '"""', close = '"""', multiline = true },
        { open = "'''", close = "'''", multiline = true },
        DOUBLE_QUOTE,
        SINGLE_QUOTE,
    },
    detectFunctionCalls = false,
}

local YAML = {
    keywords = { "false", "null", "true", "yes", "no", "on", "off" },
    lineComments = { "#" },
    strings = {
        DOUBLE_QUOTE,
        SINGLE_QUOTE,
    },
    detectFunctionCalls = false,
}

return {
    { aliases = { "json", "jsonc" }, grammar = JSON },
    { aliases = { "toml" }, grammar = TOML },
    { aliases = { "yaml", "yml" }, grammar = YAML },
}
