--[[

Other

Language grammars for Haskell and Markdown.

--]]

local DOUBLE_QUOTE = { open = '"', close = '"' }
local SINGLE_QUOTE = { open = "'", close = "'" }

local Haskell = {
    blockComments = { { "{-", "-}" } },
    builtins = {
        "abs",
        "ceiling",
        "concat",
        "concatMap",
        "div",
        "drop",
        "elem",
        "error",
        "filter",
        "flip",
        "fmap",
        "foldl",
        "foldr",
        "fromIntegral",
        "fst",
        "head",
        "id",
        "init",
        "last",
        "length",
        "lines",
        "lookup",
        "map",
        "mapM",
        "mapM_",
        "max",
        "maximum",
        "min",
        "minimum",
        "mod",
        "not",
        "notElem",
        "null",
        "otherwise",
        "print",
        "product",
        "putStr",
        "putStrLn",
        "read",
        "replicate",
        "return",
        "reverse",
        "round",
        "show",
        "snd",
        "span",
        "splitAt",
        "sum",
        "tail",
        "take",
        "undefined",
        "unlines",
        "unwords",
        "words",
        "zip",
        "zipWith",
    },
    keywords = {
        "as",
        "case",
        "class",
        "data",
        "default",
        "deriving",
        "do",
        "else",
        "forall",
        "foreign",
        "hiding",
        "if",
        "import",
        "in",
        "infix",
        "infixl",
        "infixr",
        "instance",
        "let",
        "module",
        "newtype",
        "of",
        "qualified",
        "then",
        "type",
        "where",
    },
    lineComments = { "--" },
    strings = {
        DOUBLE_QUOTE,
        SINGLE_QUOTE,
    },
    types = {
        "Bool",
        "Char",
        "Double",
        "Either",
        "Float",
        "IO",
        "Int",
        "Integer",
        "Maybe",
        "Ordering",
        "String",
        "Word",
    },
    uppercaseTypes = true,
}

local Markdown = {
    keywords = {},
    strings = {},
    detectFunctionCalls = false,
}

-- Diff highlighting is line-based rather than token-based.
-- The grammar is minimal — actual coloring is handled by the
-- SyntaxHighlighter init module which checks for "diff" language
-- and applies line-based coloring directly.
local Diff = {
    keywords = {},
    strings = {},
    detectFunctionCalls = false,
}

return {
    { aliases = { "diff", "patch" }, grammar = Diff },
    { aliases = { "haskell", "hs" }, grammar = Haskell },
    { aliases = { "markdown", "md" }, grammar = Markdown },
}
