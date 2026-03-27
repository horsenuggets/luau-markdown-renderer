--[[

ParserEdgeCasesTest

Additional parser tests covering edge cases, mixed content, and
complex nesting scenarios.

--]]

local Parser = require("@markdownrenderer/Parser")

return function()
    describe("Empty and whitespace input", function()
        it("should handle empty string", function()
            local nodes = Parser.parse("")
            expect(#nodes).to.equal(0)
        end)

        it("should handle whitespace-only input", function()
            local nodes = Parser.parse("   \n   \n   ")
            expect(#nodes).to.equal(0)
        end)

        it("should handle single newline", function()
            local nodes = Parser.parse("\n")
            expect(#nodes).to.equal(0)
        end)
    end)

    describe("Headings edge cases", function()
        it("should not parse # without space as heading", function()
            local nodes = Parser.parse("#NotAHeading")
            expect(nodes[1].Type).to.equal("Paragraph")
        end)

        it("should parse heading with trailing hashes", function()
            local nodes = Parser.parse("## Heading ##")
            expect(nodes[1].Type).to.equal("Heading")
        end)

        it("should parse heading with inline code", function()
            local nodes = Parser.parse("# `code` heading")
            expect(nodes[1].Type).to.equal("Heading")
            local content = nodes[1].Content
            local foundCode = false
            for _, span in content do
                if span.Code then
                    foundCode = true
                end
            end
            expect(foundCode).to.equal(true)
        end)
    end)

    describe("Code block edge cases", function()
        it("should handle empty code block", function()
            local nodes = Parser.parse("```\n```")
            expect(nodes[1].Type).to.equal("CodeBlock")
            expect(nodes[1].Code).to.equal("")
        end)

        it("should preserve indentation in code blocks", function()
            local source = "```\n    indented\n```"
            local nodes = Parser.parse(source)
            expect(nodes[1].Code).to.equal("    indented")
        end)

        it("should not process markdown inside code blocks", function()
            local source = "```\n**not bold**\n# not heading\n```"
            local nodes = Parser.parse(source)
            expect(#nodes).to.equal(1)
            expect(nodes[1].Type).to.equal("CodeBlock")
            expect(string.find(nodes[1].Code, "**not bold**")).to.be.ok()
        end)
    end)

    describe("List edge cases", function()
        it("should parse deeply nested bullets", function()
            local source = "- L0\n  - L1\n    - L2\n      - L3"
            local nodes = Parser.parse(source)
            local items = nodes[1].Items
            expect(items[1].Indent).to.equal(0)
            expect(items[2].Indent).to.equal(1)
            expect(items[3].Indent).to.equal(2)
            expect(items[4].Indent).to.equal(3)
        end)

        it("should parse bullet list with inline formatting", function()
            local source = "- **bold** item\n- *italic* item"
            local nodes = Parser.parse(source)
            expect(nodes[1].Type).to.equal("BulletList")
            local firstItem = nodes[1].Items[1]
            local foundBold = false
            for _, span in firstItem.Content do
                if span.Bold then
                    foundBold = true
                end
            end
            expect(foundBold).to.equal(true)
        end)

        it("should parse bullet list with inline code", function()
            local source = "- has `code` here"
            local nodes = Parser.parse(source)
            local item = nodes[1].Items[1]
            local foundCode = false
            for _, span in item.Content do
                if span.Code then
                    foundCode = true
                end
            end
            expect(foundCode).to.equal(true)
        end)
    end)

    describe("Block quotes edge cases", function()
        it("should handle nested block quotes", function()
            local source = "> Outer\n> > Inner"
            local nodes = Parser.parse(source)
            expect(nodes[1].Type).to.equal("BlockQuote")
        end)

        it("should handle block quote with inline formatting", function()
            local source = "> **bold** quote"
            local nodes = Parser.parse(source)
            expect(nodes[1].Type).to.equal("BlockQuote")
            local para = nodes[1].Children[1]
            expect(para.Type).to.equal("Paragraph")
        end)
    end)

    describe("Mixed content", function()
        it("should parse heading followed by paragraph", function()
            local nodes = Parser.parse("# Title\n\nParagraph text.")
            expect(#nodes).to.equal(2)
            expect(nodes[1].Type).to.equal("Heading")
            expect(nodes[2].Type).to.equal("Paragraph")
        end)

        it("should parse paragraph with horizontal rule", function()
            local nodes = Parser.parse("Above\n\n---\n\nBelow")
            expect(#nodes).to.equal(3)
            expect(nodes[1].Type).to.equal("Paragraph")
            expect(nodes[2].Type).to.equal("HorizontalRule")
            expect(nodes[3].Type).to.equal("Paragraph")
        end)

        it("should parse list followed by code block", function()
            local source = "- Item one\n- Item two\n\n```\ncode\n```"
            local nodes = Parser.parse(source)
            expect(nodes[1].Type).to.equal("BulletList")
            expect(nodes[2].Type).to.equal("CodeBlock")
        end)
    end)

    describe("Inline edge cases", function()
        it("should handle unclosed bold", function()
            local spans = Parser.parseInline("**unclosed")
            expect(#spans >= 1).to.equal(true)
        end)

        it("should handle unclosed italic", function()
            local spans = Parser.parseInline("*unclosed")
            expect(#spans >= 1).to.equal(true)
        end)

        it("should handle unclosed code", function()
            local spans = Parser.parseInline("`unclosed")
            expect(#spans >= 1).to.equal(true)
        end)

        it("should handle consecutive formatting", function()
            local spans = Parser.parseInline("**bold***italic*")
            local foundBold = false
            local foundItalic = false
            for _, span in spans do
                if span.Bold then
                    foundBold = true
                end
                if span.Italic then
                    foundItalic = true
                end
            end
            expect(foundBold).to.equal(true)
            expect(foundItalic).to.equal(true)
        end)

        it("should handle special characters in text", function()
            local spans = Parser.parseInline("a < b & c > d")
            expect(#spans >= 1).to.equal(true)
            local fullText = ""
            for _, span in spans do
                fullText ..= span.Text
            end
            expect(fullText).to.equal("a < b & c > d")
        end)

        it("should parse bold with underscores", function()
            local spans = Parser.parseInline("__bold__")
            expect(#spans).to.equal(1)
            expect(spans[1].Bold).to.equal(true)
            expect(spans[1].Text).to.equal("bold")
        end)

        it("should parse italic with underscores", function()
            local spans = Parser.parseInline("_italic_")
            expect(#spans).to.equal(1)
            expect(spans[1].Italic).to.equal(true)
            expect(spans[1].Text).to.equal("italic")
        end)
    end)
end
