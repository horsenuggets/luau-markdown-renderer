--[[

SanitizeTest

Tests for the HTML entity sanitization function.

--]]

local sanitize = require("@markdownrenderer/sanitize")

return function()
    it("should escape ampersands", function()
        expect(sanitize("a & b")).to.equal("a &amp; b")
    end)

    it("should escape less-than", function()
        expect(sanitize("<div>")).to.equal("&lt;div&gt;")
    end)

    it("should escape greater-than", function()
        expect(sanitize("a > b")).to.equal("a &gt; b")
    end)

    it("should escape double quotes", function()
        expect(sanitize('"hello"')).to.equal("&quot;hello&quot;")
    end)

    it("should handle multiple entities in one string", function()
        expect(sanitize('<a href="x">')).to.equal("&lt;a href=&quot;x&quot;&gt;")
    end)

    it("should not modify plain text", function()
        expect(sanitize("hello world")).to.equal("hello world")
    end)

    it("should handle empty string", function()
        expect(sanitize("")).to.equal("")
    end)

    it("should escape ampersands before other entities", function()
        expect(sanitize("&lt;")).to.equal("&amp;lt;")
    end)
end
