--[[

DedentTest.spec

Tests for the dedent utility that strips common leading whitespace
from multi-line strings.

--]]

const dedent = require("@markdownrenderer/dedent")

return function()
    it("should strip common leading tabs", function()
        const result = dedent("\n\tline one\n\tline two\n")
        expect(result).to.equal("line one\nline two")
    end)

    it("should strip common leading spaces", function()
        const result = dedent("\n    line one\n    line two\n")
        expect(result).to.equal("line one\nline two")
    end)

    it("should preserve relative indentation", function()
        const result = dedent("\n\tline one\n\t\tindented\n\tline three\n")
        expect(result).to.equal("line one\n\tindented\nline three")
    end)

    it("should handle no indentation", function()
        const result = dedent("\nline one\nline two\n")
        expect(result).to.equal("line one\nline two")
    end)

    it("should handle single line", function()
        const result = dedent("\n\thello\n")
        expect(result).to.equal("hello")
    end)

    it("should handle empty string", function()
        const result = dedent("")
        expect(result).to.equal("")
    end)

    it("should remove leading newline", function()
        const result = dedent("\nhello")
        expect(result).to.equal("hello")
    end)

    it("should remove trailing whitespace", function()
        const result = dedent("\nhello   \n")
        expect(result).to.equal("hello")
    end)

    it("should work with bracket string pattern", function()
        -- Simulates [[ ... ]] usage
        const result = dedent([[
            Hello
            World
        ]])
        expect(result).to.equal("Hello\nWorld")
    end)
end
