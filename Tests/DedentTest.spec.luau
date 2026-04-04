--[[

DedentTest.spec

Tests for the dedent utility that strips common leading whitespace
from multi-line strings.

--]]

local dedent = require("@markdownrenderer/dedent")

return function()
    it("should strip common leading tabs", function()
        local result = dedent("\n\tline one\n\tline two\n")
        expect(result).to.equal("line one\nline two")
    end)

    it("should strip common leading spaces", function()
        local result = dedent("\n    line one\n    line two\n")
        expect(result).to.equal("line one\nline two")
    end)

    it("should preserve relative indentation", function()
        local result = dedent("\n\tline one\n\t\tindented\n\tline three\n")
        expect(result).to.equal("line one\n\tindented\nline three")
    end)

    it("should handle no indentation", function()
        local result = dedent("\nline one\nline two\n")
        expect(result).to.equal("line one\nline two")
    end)

    it("should handle single line", function()
        local result = dedent("\n\thello\n")
        expect(result).to.equal("hello")
    end)

    it("should handle empty string", function()
        local result = dedent("")
        expect(result).to.equal("")
    end)

    it("should remove leading newline", function()
        local result = dedent("\nhello")
        expect(result).to.equal("hello")
    end)

    it("should remove trailing whitespace", function()
        local result = dedent("\nhello   \n")
        expect(result).to.equal("hello")
    end)

    it("should work with bracket string pattern", function()
        -- Simulates [[ ... ]] usage
        local result = dedent([[
            Hello
            World
        ]])
        expect(result).to.equal("Hello\nWorld")
    end)
end
