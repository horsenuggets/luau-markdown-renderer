--[[

TokenizerTest

Tests for the syntax highlighting tokenizer engine covering
keywords, strings, comments, numbers, operators, function calls,
and edge cases across multiple language grammars.

--]]

local Tokenizer = require("@markdownrenderer/SyntaxHighlighter/Tokenizer")

local function tokTypes(tokens)
    local types = {}
    for _, t in tokens do
        table.insert(types, t.type)
    end
    return types
end

local function _tokTexts(tokens)
    local texts = {}
    for _, t in tokens do
        table.insert(texts, t.text)
    end
    return texts
end

return function()
    describe("Keywords", function()
        it("should identify keywords", function()
            local grammar = { keywords = { "local", "function", "end" } }
            local tokens = Tokenizer.tokenize("local x", grammar)
            expect(tokens[1].type).to.equal("keyword")
            expect(tokens[1].text).to.equal("local")
        end)

        it("should not match partial keywords", function()
            local grammar = { keywords = { "for" } }
            local tokens = Tokenizer.tokenize("format", grammar)
            expect(tokens[1].type).to.equal("normal")
            expect(tokens[1].text).to.equal("format")
        end)
    end)

    describe("Strings", function()
        it("should parse double-quoted strings", function()
            local grammar = {
                strings = { { open = '"', close = '"' } },
            }
            local tokens = Tokenizer.tokenize('"hello world"', grammar)
            expect(tokens[1].type).to.equal("string")
            expect(tokens[1].text).to.equal('"hello world"')
        end)

        it("should handle escape characters", function()
            local grammar = {
                strings = { { open = '"', close = '"' } },
            }
            local tokens = Tokenizer.tokenize('"say \\"hi\\""', grammar)
            expect(tokens[1].type).to.equal("string")
            expect(tokens[1].text).to.equal('"say \\"hi\\""')
        end)

        it("should parse single-quoted strings", function()
            local grammar = {
                strings = { { open = "'", close = "'" } },
            }
            local tokens = Tokenizer.tokenize("'hello'", grammar)
            expect(tokens[1].type).to.equal("string")
            expect(tokens[1].text).to.equal("'hello'")
        end)

        it("should parse multiline strings", function()
            local grammar = {
                strings = { { open = "[[", close = "]]", multiline = true } },
            }
            local tokens = Tokenizer.tokenize("[[line1\nline2]]", grammar)
            expect(tokens[1].type).to.equal("string")
            expect(tokens[1].text).to.equal("[[line1\nline2]]")
        end)

        it("should stop non-multiline strings at newline", function()
            local grammar = {
                strings = { { open = '"', close = '"' } },
            }
            local tokens = Tokenizer.tokenize('"unclosed\nnext', grammar)
            expect(tokens[1].type).to.equal("string")
            expect(tokens[1].text).to.equal('"unclosed')
        end)

        it("should parse triple-quoted strings", function()
            local grammar = {
                strings = { { open = '"""', close = '"""', multiline = true } },
            }
            local tokens = Tokenizer.tokenize('"""multi\nline"""', grammar)
            expect(tokens[1].type).to.equal("string")
            expect(tokens[1].text).to.equal('"""multi\nline"""')
        end)
    end)

    describe("Comments", function()
        it("should parse line comments", function()
            local grammar = { lineComments = { "--" } }
            local tokens = Tokenizer.tokenize("-- comment\ncode", grammar)
            expect(tokens[1].type).to.equal("comment")
            expect(tokens[1].text).to.equal("-- comment")
        end)

        it("should parse block comments", function()
            local grammar = { blockComments = { { "/*", "*/" } } }
            local tokens = Tokenizer.tokenize("/* block */", grammar)
            expect(tokens[1].type).to.equal("comment")
            expect(tokens[1].text).to.equal("/* block */")
        end)

        it("should handle unclosed block comments", function()
            local grammar = { blockComments = { { "/*", "*/" } } }
            local tokens = Tokenizer.tokenize("/* never closed", grammar)
            expect(tokens[1].type).to.equal("comment")
            expect(tokens[1].text).to.equal("/* never closed")
        end)

        it("should parse Lua block comments", function()
            local grammar = { blockComments = { { "--[[", "]]" } } }
            local tokens = Tokenizer.tokenize("--[[ block ]]", grammar)
            expect(tokens[1].type).to.equal("comment")
        end)

        it("should parse hash comments", function()
            local grammar = { lineComments = { "#" } }
            local tokens = Tokenizer.tokenize("# comment\ncode", grammar)
            expect(tokens[1].type).to.equal("comment")
            expect(tokens[1].text).to.equal("# comment")
        end)
    end)

    describe("Numbers", function()
        it("should parse integers", function()
            local grammar = {}
            local tokens = Tokenizer.tokenize("42", grammar)
            expect(tokens[1].type).to.equal("number")
            expect(tokens[1].text).to.equal("42")
        end)

        it("should parse hex numbers", function()
            local grammar = {}
            local tokens = Tokenizer.tokenize("0xFF", grammar)
            expect(tokens[1].type).to.equal("number")
            expect(tokens[1].text).to.equal("0xFF")
        end)

        it("should parse binary numbers", function()
            local grammar = {}
            local tokens = Tokenizer.tokenize("0b1010", grammar)
            expect(tokens[1].type).to.equal("number")
            expect(tokens[1].text).to.equal("0b1010")
        end)

        it("should parse decimal numbers", function()
            local grammar = {}
            local tokens = Tokenizer.tokenize("3.14", grammar)
            expect(tokens[1].type).to.equal("number")
            expect(tokens[1].text).to.equal("3.14")
        end)

        it("should parse scientific notation", function()
            local grammar = {}
            local tokens = Tokenizer.tokenize("1e10", grammar)
            expect(tokens[1].type).to.equal("number")
        end)
    end)

    describe("Operators and punctuation", function()
        it("should parse operators", function()
            local grammar = {}
            local tokens = Tokenizer.tokenize("= + -", grammar)
            local types = tokTypes(tokens)
            expect(types[1]).to.equal("operator")
            expect(types[3]).to.equal("operator")
            expect(types[5]).to.equal("operator")
        end)

        it("should parse punctuation", function()
            local grammar = { detectFunctionCalls = false }
            local tokens = Tokenizer.tokenize("( )", grammar)
            expect(tokens[1].type).to.equal("punctuation")
            expect(tokens[1].text).to.equal("(")
        end)
    end)

    describe("Function calls", function()
        it("should detect function calls with parentheses", function()
            local grammar = { detectFunctionCalls = true }
            local tokens = Tokenizer.tokenize("foo()", grammar)
            expect(tokens[1].type).to.equal("function_call")
            expect(tokens[1].text).to.equal("foo")
        end)

        it("should not detect function calls without parentheses", function()
            local grammar = { detectFunctionCalls = true }
            local tokens = Tokenizer.tokenize("foo bar", grammar)
            expect(tokens[1].type).to.equal("normal")
        end)

        it("should not detect when disabled", function()
            local grammar = { detectFunctionCalls = false }
            local tokens = Tokenizer.tokenize("foo()", grammar)
            expect(tokens[1].type).to.equal("normal")
        end)
    end)

    describe("Types", function()
        it("should identify type keywords", function()
            local grammar = { types = { "int", "string" } }
            local tokens = Tokenizer.tokenize("int x", grammar)
            expect(tokens[1].type).to.equal("type")
            expect(tokens[1].text).to.equal("int")
        end)

        it("should detect uppercase types when enabled", function()
            local grammar = { uppercaseTypes = true }
            local tokens = Tokenizer.tokenize("MyClass", grammar)
            expect(tokens[1].type).to.equal("type")
        end)

        it("should not detect uppercase types when disabled", function()
            local grammar = { uppercaseTypes = false }
            local tokens = Tokenizer.tokenize("MyClass", grammar)
            expect(tokens[1].type).to.equal("normal")
        end)
    end)

    describe("Builtins", function()
        it("should identify builtin names", function()
            local grammar = { builtins = { "print", "warn" } }
            local tokens = Tokenizer.tokenize("print", grammar)
            expect(tokens[1].type).to.equal("builtin")
        end)
    end)

    describe("Whitespace", function()
        it("should include whitespace in token output", function()
            local grammar = { keywords = { "if" } }
            local tokens = Tokenizer.tokenize("if  then", grammar)
            expect(tokens[1].type).to.equal("keyword")
            expect(tokens[1].text).to.equal("if")
            -- Whitespace and "then" merge into normal since "then"
            -- is not a keyword in this grammar
            local fullText = ""
            for _, t in tokens do
                fullText ..= t.text
            end
            expect(fullText).to.equal("if  then")
        end)

        it("should preserve newlines in output", function()
            local grammar = {}
            local tokens = Tokenizer.tokenize("a\nb", grammar)
            local fullText = ""
            for _, t in tokens do
                fullText ..= t.text
            end
            expect(fullText).to.equal("a\nb")
        end)
    end)

    describe("Token merging", function()
        it("should merge adjacent tokens of the same type", function()
            local grammar = {}
            local tokens = Tokenizer.tokenize("abc def", grammar)
            -- "abc" "  " "def" should merge "abc" normal, " " normal, "def"
            -- normal into fewer tokens since they're all normal
            local allNormal = true
            for _, t in tokens do
                if t.type ~= "normal" then
                    allNormal = false
                end
            end
            expect(allNormal).to.equal(true)
        end)
    end)

    describe("Mixed content", function()
        it("should tokenize a Luau-like snippet correctly", function()
            local grammar = {
                keywords = { "local", "function", "end", "return" },
                lineComments = { "--" },
                strings = { { open = '"', close = '"' } },
            }
            local source = 'local x = "hello" -- comment'
            local tokens = Tokenizer.tokenize(source, grammar)

            expect(tokens[1].type).to.equal("keyword")
            expect(tokens[1].text).to.equal("local")

            local foundString = false
            local foundComment = false
            for _, t in tokens do
                if t.type == "string" then
                    foundString = true
                end
                if t.type == "comment" then
                    foundComment = true
                end
            end
            expect(foundString).to.equal(true)
            expect(foundComment).to.equal(true)
        end)

        it("should handle empty input", function()
            local grammar = {}
            local tokens = Tokenizer.tokenize("", grammar)
            expect(#tokens).to.equal(0)
        end)

        it("should handle input with only whitespace", function()
            local grammar = {}
            local tokens = Tokenizer.tokenize("   \n\t  ", grammar)
            expect(#tokens).to.be.ok()
            for _, t in tokens do
                expect(t.type).to.equal("normal")
            end
        end)
    end)
end
