--[[

RenderInlineTest

Tests for the renderInline function that converts InlineSpan arrays
to RichText strings.

--]]

local renderInline = require("@markdownrenderer/renderInline")

return function()
    it("should render plain text", function()
        local spans = { { Text = "hello", Bold = false, Italic = false, Strikethrough = false, Code = false } }
        expect(renderInline(spans)).to.equal("hello")
    end)

    it("should render bold text", function()
        local spans = { { Text = "bold", Bold = true, Italic = false, Strikethrough = false, Code = false } }
        expect(renderInline(spans)).to.equal("<b>bold</b>")
    end)

    it("should render italic text", function()
        local spans = { { Text = "italic", Bold = false, Italic = true, Strikethrough = false, Code = false } }
        expect(renderInline(spans)).to.equal("<i>italic</i>")
    end)

    it("should render strikethrough text", function()
        local spans = { { Text = "struck", Bold = false, Italic = false, Strikethrough = true, Code = false } }
        expect(renderInline(spans)).to.equal("<s>struck</s>")
    end)

    it("should render inline code with mark tag", function()
        local spans = { { Text = "code", Bold = false, Italic = false, Strikethrough = false, Code = true } }
        local result = renderInline(spans)
        expect(string.find(result, "RobotoMono")).to.be.ok()
        expect(string.find(result, "mark")).to.be.ok()
        expect(string.find(result, "code")).to.be.ok()
    end)

    it("should combine bold and italic", function()
        local spans = { { Text = "both", Bold = true, Italic = true, Strikethrough = false, Code = false } }
        local result = renderInline(spans)
        expect(string.find(result, "<b>")).to.be.ok()
        expect(string.find(result, "<i>")).to.be.ok()
    end)

    it("should sanitize HTML in text", function()
        local spans = { { Text = "<script>", Bold = false, Italic = false, Strikethrough = false, Code = false } }
        local result = renderInline(spans)
        expect(string.find(result, "&lt;script&gt;")).to.be.ok()
    end)

    it("should handle multiple spans", function()
        local spans = {
            { Text = "plain ", Bold = false, Italic = false, Strikethrough = false, Code = false },
            { Text = "bold", Bold = true, Italic = false, Strikethrough = false, Code = false },
            { Text = " end", Bold = false, Italic = false, Strikethrough = false, Code = false },
        }
        local result = renderInline(spans)
        expect(result).to.equal("plain <b>bold</b> end")
    end)

    it("should handle empty spans array", function()
        local result = renderInline({})
        expect(result).to.equal("")
    end)
end
