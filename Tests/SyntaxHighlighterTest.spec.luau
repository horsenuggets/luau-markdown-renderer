--[[

SyntaxHighlighterTest

Tests for the syntax highlighter covering the highlight function,
language registry, theme system, and diff highlighting.

--]]

local SyntaxHighlighter = require("@markdownrenderer/SyntaxHighlighter")
local Languages = SyntaxHighlighter.Languages
local Theme = SyntaxHighlighter.Theme

return function()
    describe("highlight", function()
        it("should return plain text for unknown languages", function()
            local result = SyntaxHighlighter.highlight("hello", "nonexistent")
            expect(result).to.equal("hello")
        end)

        it("should return plain text for nil language", function()
            local result = SyntaxHighlighter.highlight("hello", nil)
            expect(result).to.equal("hello")
        end)

        it("should return plain text for empty language", function()
            local result = SyntaxHighlighter.highlight("hello", "")
            expect(result).to.equal("hello")
        end)

        it("should sanitize HTML entities in plain text", function()
            local result = SyntaxHighlighter.highlight("<div>", nil)
            expect(result).to.equal("&lt;div&gt;")
        end)

        it("should produce font tags for Luau keywords", function()
            local result = SyntaxHighlighter.highlight("local x", "luau")
            expect(string.find(result, "<font")).to.be.ok()
            expect(string.find(result, "local")).to.be.ok()
        end)

        it("should highlight strings in Luau", function()
            local result = SyntaxHighlighter.highlight('"hello"', "luau")
            expect(string.find(result, "<font")).to.be.ok()
            expect(string.find(result, "hello")).to.be.ok()
        end)

        it("should highlight comments in Luau", function()
            local result = SyntaxHighlighter.highlight("-- comment", "luau")
            expect(string.find(result, "<font")).to.be.ok()
            expect(string.find(result, "comment")).to.be.ok()
        end)

        it("should sanitize special characters in highlighted code", function()
            local result = SyntaxHighlighter.highlight('local x = "<>"', "luau")
            expect(string.find(result, "&lt;")).to.be.ok()
            expect(string.find(result, "&gt;")).to.be.ok()
        end)

        it("should handle empty code", function()
            local result = SyntaxHighlighter.highlight("", "luau")
            expect(result).to.equal("")
        end)
    end)

    describe("Languages", function()
        it("should resolve Luau", function()
            expect(Languages.get("luau")).to.be.ok()
        end)

        it("should resolve Lua", function()
            expect(Languages.get("lua")).to.be.ok()
        end)

        it("should resolve Python", function()
            expect(Languages.get("python")).to.be.ok()
            expect(Languages.get("py")).to.be.ok()
        end)

        it("should resolve JavaScript", function()
            expect(Languages.get("javascript")).to.be.ok()
            expect(Languages.get("js")).to.be.ok()
        end)

        it("should resolve TypeScript", function()
            expect(Languages.get("typescript")).to.be.ok()
            expect(Languages.get("ts")).to.be.ok()
        end)

        it("should resolve C-family languages", function()
            expect(Languages.get("c")).to.be.ok()
            expect(Languages.get("cpp")).to.be.ok()
            expect(Languages.get("csharp")).to.be.ok()
            expect(Languages.get("java")).to.be.ok()
            expect(Languages.get("go")).to.be.ok()
            expect(Languages.get("rust")).to.be.ok()
        end)

        it("should resolve data formats", function()
            expect(Languages.get("json")).to.be.ok()
            expect(Languages.get("toml")).to.be.ok()
            expect(Languages.get("yaml")).to.be.ok()
        end)

        it("should resolve shell languages", function()
            expect(Languages.get("bash")).to.be.ok()
            expect(Languages.get("sh")).to.be.ok()
            expect(Languages.get("sql")).to.be.ok()
        end)

        it("should resolve other languages", function()
            expect(Languages.get("haskell")).to.be.ok()
            expect(Languages.get("diff")).to.be.ok()
        end)

        it("should be case-insensitive", function()
            expect(Languages.get("LUAU")).to.be.ok()
            expect(Languages.get("Python")).to.be.ok()
            expect(Languages.get("JSON")).to.be.ok()
        end)

        it("should return nil for unknown languages", function()
            expect(Languages.get("nonexistent")).to.equal(nil)
        end)

        it("should list available languages", function()
            local names = Languages.list()
            expect(#names > 20).to.equal(true)
        end)
    end)

    describe("Theme", function()
        it("should return github-dark by default", function()
            local theme = Theme.get(nil)
            expect(theme.keyword).to.be.ok()
            expect(theme.string).to.be.ok()
            expect(theme.comment).to.be.ok()
        end)

        it("should return named themes", function()
            expect(Theme.get("github-dark").keyword).to.be.ok()
            expect(Theme.get("github-light").keyword).to.be.ok()
            expect(Theme.get("monokai").keyword).to.be.ok()
            expect(Theme.get("one-dark").keyword).to.be.ok()
        end)

        it("should fall back to default for unknown theme", function()
            local theme = Theme.get("nonexistent")
            expect(theme.keyword).to.be.ok()
        end)

        it("should have all token type colors", function()
            local theme = Theme.get("github-dark")
            expect(theme.builtin).to.be.ok()
            expect(theme.comment).to.be.ok()
            expect(theme.function_call).to.be.ok()
            expect(theme.keyword).to.be.ok()
            expect(theme.normal).to.be.ok()
            expect(theme.number).to.be.ok()
            expect(theme.operator).to.be.ok()
            expect(theme.punctuation).to.be.ok()
            expect(theme.string).to.be.ok()
            expect(theme.type).to.be.ok()
        end)

        it("should list available themes", function()
            local names = Theme.list()
            expect(#names >= 4).to.equal(true)
        end)
    end)

    describe("Diff highlighting", function()
        it("should color added lines", function()
            local result = SyntaxHighlighter.highlight("+added line", "diff")
            expect(string.find(result, "<font")).to.be.ok()
        end)

        it("should color removed lines", function()
            local result = SyntaxHighlighter.highlight("-removed line", "diff")
            expect(string.find(result, "<font")).to.be.ok()
        end)

        it("should color hunk headers", function()
            local result = SyntaxHighlighter.highlight("@@ -1,3 +1,4 @@", "diff")
            expect(string.find(result, "<font")).to.be.ok()
        end)

        it("should leave context lines plain", function()
            local result = SyntaxHighlighter.highlight("context line", "diff")
            expect(string.find(result, "<font")).to.equal(nil)
        end)
    end)
end
