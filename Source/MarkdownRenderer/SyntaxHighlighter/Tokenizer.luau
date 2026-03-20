--[[

Tokenizer

Generic single-pass tokenization engine for syntax highlighting.
Accepts source code and a language grammar table, produces an array
of typed tokens. The engine is data-driven and has no language-specific
logic — all language knowledge lives in grammar tables.

--]]

local Types = require("./Types")

local DEFAULT_OPERATORS = "+-*/%=<>!&|^~?:#"
local DEFAULT_PUNCTUATION = "(){}[];,.@"

-- Convert an array of strings to a lookup set for O(1) membership
-- checks.
local function toSet(list: { string }?): { [string]: boolean }
    local set = {}
    if list then
        for _, item in list do
            set[item] = true
        end
    end
    return set
end

-- Pre-process a grammar table into an optimized form with lookup
-- sets instead of arrays.
local function prepareGrammar(grammar: Types.LanguageGrammar): Types.PreparedGrammar
    return {
        blockComments = grammar.blockComments,
        builtins = toSet(grammar.builtins),
        detectFunctionCalls = grammar.detectFunctionCalls ~= false,
        htmlTags = grammar.htmlTags == true,
        keywords = toSet(grammar.keywords),
        lineComments = grammar.lineComments,
        operators = grammar.operators or DEFAULT_OPERATORS,
        punctuation = grammar.punctuation or DEFAULT_PUNCTUATION,
        strings = grammar.strings,
        types = toSet(grammar.types),
        uppercaseTypes = grammar.uppercaseTypes == true,
    }
end

local function tokenize(source: string, grammar: Types.LanguageGrammar): { Types.Token }
    local prepared = prepareGrammar(grammar)
    local tokens: { Types.Token } = {}
    local pos = 1
    local len = #source

    local function emit(tokenType: Types.TokenType, text: string)
        -- Merge with previous token if same type
        local prev = tokens[#tokens]
        if prev and prev.type == tokenType then
            prev.text ..= text
        else
            table.insert(tokens, { type = tokenType, text = text })
        end
    end

    local function startsWith(prefix: string): boolean
        return string.sub(source, pos, pos + #prefix - 1) == prefix
    end

    local function tryBlockComment(): boolean
        if not prepared.blockComments then
            return false
        end
        for _, delim in prepared.blockComments do
            local open = delim[1]
            local close = delim[2]
            if startsWith(open) then
                local closePos = string.find(source, close, pos + #open, true)
                if closePos then
                    emit("comment", string.sub(source, pos, closePos + #close - 1))
                    pos = closePos + #close
                else
                    -- Unclosed block comment — consume rest of source
                    emit("comment", string.sub(source, pos))
                    pos = len + 1
                end
                return true
            end
        end
        return false
    end

    local function tryLineComment(): boolean
        if not prepared.lineComments then
            return false
        end
        for _, prefix in prepared.lineComments do
            if startsWith(prefix) then
                local lineEnd = string.find(source, "\n", pos, true)
                if lineEnd then
                    emit("comment", string.sub(source, pos, lineEnd - 1))
                    pos = lineEnd
                else
                    emit("comment", string.sub(source, pos))
                    pos = len + 1
                end
                return true
            end
        end
        return false
    end

    local function tryString(): boolean
        if not prepared.strings then
            return false
        end
        for _, delim in prepared.strings do
            local open = delim.open
            if startsWith(open) then
                local escape = delim.escape or "\\"
                local multiline = delim.multiline == true
                local close = delim.close
                local i = pos + #open

                while i <= len do
                    -- Check for close delimiter
                    if string.sub(source, i, i + #close - 1) == close then
                        emit("string", string.sub(source, pos, i + #close - 1))
                        pos = i + #close
                        return true
                    end

                    local ch = string.sub(source, i, i)

                    -- Check for escape character
                    if #escape > 0 and string.sub(source, i, i + #escape - 1) == escape then
                        i += #escape + 1
                    elseif not multiline and ch == "\n" then
                        -- Non-multiline string ended by newline
                        emit("string", string.sub(source, pos, i - 1))
                        pos = i
                        return true
                    else
                        i += 1
                    end
                end

                -- Unclosed string — consume rest
                emit("string", string.sub(source, pos))
                pos = len + 1
                return true
            end
        end
        return false
    end

    local function tryNumber(): boolean
        -- Hex: 0x or 0X
        local _, hexEnd = string.find(source, "^0[xX]%x+", pos)
        if hexEnd then
            emit("number", string.sub(source, pos, hexEnd))
            pos = hexEnd + 1
            return true
        end

        -- Binary: 0b or 0B
        local _, binEnd = string.find(source, "^0[bB][01]+", pos)
        if binEnd then
            emit("number", string.sub(source, pos, binEnd))
            pos = binEnd + 1
            return true
        end

        -- Decimal with optional fraction and exponent
        local _, numEnd = string.find(source, "^%d+%.?%d*[eE]?[+-]?%d*", pos)
        if numEnd and numEnd >= pos then
            local text = string.sub(source, pos, numEnd)
            -- Make sure we actually matched digits (not just empty)
            if string.find(text, "^%d") then
                emit("number", text)
                pos = numEnd + 1
                return true
            end
        end

        return false
    end

    local function tryIdentifier(): boolean
        local _, idEnd = string.find(source, "^[%a_][%w_]*", pos)
        if not idEnd then
            return false
        end

        local word = string.sub(source, pos, idEnd)
        pos = idEnd + 1

        if prepared.keywords[word] then
            emit("keyword", word)
        elseif prepared.builtins[word] then
            emit("builtin", word)
        elseif prepared.types[word] then
            emit("type", word)
        elseif prepared.uppercaseTypes and string.find(word, "^%u") then
            emit("type", word)
        elseif prepared.detectFunctionCalls then
            -- Look ahead for ( to detect function calls
            local nextNonSpace = string.find(source, "%S", pos)
            if nextNonSpace and string.sub(source, nextNonSpace, nextNonSpace) == "(" then
                emit("function_call", word)
            else
                emit("normal", word)
            end
        else
            emit("normal", word)
        end

        return true
    end

    local function tryOperator(): boolean
        local ch = string.sub(source, pos, pos)
        if string.find(prepared.operators, ch, 1, true) then
            emit("operator", ch)
            pos += 1
            return true
        end
        return false
    end

    local function tryPunctuation(): boolean
        local ch = string.sub(source, pos, pos)
        if string.find(prepared.punctuation, ch, 1, true) then
            emit("punctuation", ch)
            pos += 1
            return true
        end
        return false
    end

    while pos <= len do
        local ch = string.sub(source, pos, pos)

        -- Whitespace
        if ch == " " or ch == "\t" or ch == "\n" or ch == "\r" then
            local _, wsEnd = string.find(source, "^%s+", pos)
            emit("normal", string.sub(source, pos, wsEnd))
            pos = (wsEnd :: number) + 1
        elseif
            tryBlockComment()
            or tryLineComment()
            or tryString()
            or tryNumber()
            or tryIdentifier()
            or tryOperator()
            or tryPunctuation()
        then
            -- Handled by the try function
        else
            -- Unknown character — emit as normal
            emit("normal", ch)
            pos += 1
        end
    end

    return tokens
end

local Tokenizer = {}
Tokenizer.prepareGrammar = prepareGrammar
Tokenizer.tokenize = tokenize

return Tokenizer
