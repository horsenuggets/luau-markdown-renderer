--[[

Data

Language grammars for data formats: JSON, TOML, and YAML.

--]]

const SharedConstants = require("./SharedConstants")

const DOUBLE_QUOTE = SharedConstants.DOUBLE_QUOTE
const SINGLE_QUOTE = SharedConstants.SINGLE_QUOTE

const JSON = {
    keywords = { "false", "null", "true" },
    strings = {
        DOUBLE_QUOTE,
    },
    detectFunctionCalls = false,
}

const TOML = {
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

const YAML = {
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
