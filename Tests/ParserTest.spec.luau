--[[

ParserTest.spec

Tests for the Markdown parser covering block-level and inline parsing.

--]]

const Parser = require("@markdownrenderer/Parser")

return function()
    describe("Headings", function()
        it("should parse H1 through H6", function()
            for level = 1, 6 do
                const prefix = string.rep("#", level)
                const nodes = Parser.parse(`{prefix} Heading {level}`)
                expect(#nodes).to.equal(1)
                expect(nodes[1].Type).to.equal("Heading")
                expect(nodes[1].Level).to.equal(level)
            end
        end)

        it("should parse heading inline content", function()
            const nodes = Parser.parse("# **Bold** heading")
            expect(#nodes).to.equal(1)
            const content = nodes[1].Content
            expect(#content).to.equal(2)
            expect(content[1].Bold).to.equal(true)
            expect(content[1].Text).to.equal("Bold")
            expect(content[2].Bold).to.equal(false)
            expect(content[2].Text).to.equal(" heading")
        end)
    end)

    describe("Paragraphs", function()
        it("should parse a simple paragraph", function()
            const nodes = Parser.parse("Hello world")
            expect(#nodes).to.equal(1)
            expect(nodes[1].Type).to.equal("Paragraph")
            expect(nodes[1].Content[1].Text).to.equal("Hello world")
        end)

        it("should merge consecutive lines into one paragraph", function()
            const nodes = Parser.parse("Line one\nLine two")
            expect(#nodes).to.equal(1)
            expect(nodes[1].Type).to.equal("Paragraph")
            expect(nodes[1].Content[1].Text).to.equal("Line one Line two")
        end)

        it("should split paragraphs on blank lines", function()
            const nodes = Parser.parse("Para one\n\nPara two")
            expect(#nodes).to.equal(2)
            expect(nodes[1].Type).to.equal("Paragraph")
            expect(nodes[2].Type).to.equal("Paragraph")
        end)
    end)

    describe("Code blocks", function()
        it("should parse a fenced code block", function()
            const source = "```\nhello\nworld\n```"
            const nodes = Parser.parse(source)
            expect(#nodes).to.equal(1)
            expect(nodes[1].Type).to.equal("CodeBlock")
            expect(nodes[1].Code).to.equal("hello\nworld")
        end)

        it("should capture the language tag", function()
            const source = "```luau\nlocal x = 1\n```"
            const nodes = Parser.parse(source)
            expect(nodes[1].Language).to.equal("luau")
        end)

        it("should have nil language when none specified", function()
            const source = "```\ncode\n```"
            const nodes = Parser.parse(source)
            expect(nodes[1].Language).to.equal(nil)
        end)
    end)

    describe("Bullet lists", function()
        it("should parse simple bullet items", function()
            const source = "- Item one\n- Item two\n- Item three"
            const nodes = Parser.parse(source)
            expect(#nodes).to.equal(1)
            expect(nodes[1].Type).to.equal("BulletList")
            expect(#nodes[1].Items).to.equal(3)
        end)

        it("should detect nesting by indentation", function()
            const source = "- Parent\n  - Child"
            const nodes = Parser.parse(source)
            const items = nodes[1].Items
            expect(items[1].Indent).to.equal(0)
            expect(items[2].Indent).to.equal(1)
        end)
    end)

    describe("Numbered lists", function()
        it("should parse numbered items", function()
            const source = "1. First\n2. Second\n3. Third"
            const nodes = Parser.parse(source)
            expect(#nodes).to.equal(1)
            expect(nodes[1].Type).to.equal("NumberedList")
            expect(#nodes[1].Items).to.equal(3)
        end)
    end)

    describe("Block quotes", function()
        it("should parse a simple block quote", function()
            const source = "> Quoted text"
            const nodes = Parser.parse(source)
            expect(#nodes).to.equal(1)
            expect(nodes[1].Type).to.equal("BlockQuote")
            expect(#nodes[1].Children).to.equal(1)
            expect(nodes[1].Children[1].Type).to.equal("Paragraph")
        end)

        it("should merge consecutive quote lines", function()
            const source = "> Line one\n> Line two"
            const nodes = Parser.parse(source)
            expect(#nodes).to.equal(1)
            expect(nodes[1].Type).to.equal("BlockQuote")
        end)
    end)

    describe("Horizontal rules", function()
        it("should parse dashes as a rule", function()
            const nodes = Parser.parse("---")
            expect(#nodes).to.equal(1)
            expect(nodes[1].Type).to.equal("HorizontalRule")
        end)

        it("should parse asterisks as a rule", function()
            const nodes = Parser.parse("***")
            expect(#nodes).to.equal(1)
            expect(nodes[1].Type).to.equal("HorizontalRule")
        end)

        it("should parse underscores as a rule", function()
            const nodes = Parser.parse("___")
            expect(#nodes).to.equal(1)
            expect(nodes[1].Type).to.equal("HorizontalRule")
        end)

        it("should not parse two dashes as a rule", function()
            const nodes = Parser.parse("--")
            expect(nodes[1].Type).to.equal("Paragraph")
        end)
    end)

    describe("Inline parsing", function()
        it("should parse bold with double asterisks", function()
            const spans = Parser.parseInline("**bold**")
            expect(#spans).to.equal(1)
            expect(spans[1].Text).to.equal("bold")
            expect(spans[1].Bold).to.equal(true)
        end)

        it("should parse italic with single asterisk", function()
            const spans = Parser.parseInline("*italic*")
            expect(#spans).to.equal(1)
            expect(spans[1].Text).to.equal("italic")
            expect(spans[1].Italic).to.equal(true)
        end)

        it("should parse strikethrough with double tildes", function()
            const spans = Parser.parseInline("~~struck~~")
            expect(#spans).to.equal(1)
            expect(spans[1].Text).to.equal("struck")
            expect(spans[1].Strikethrough).to.equal(true)
        end)

        it("should parse inline code with backticks", function()
            const spans = Parser.parseInline("`code`")
            expect(#spans).to.equal(1)
            expect(spans[1].Text).to.equal("code")
            expect(spans[1].Code).to.equal(true)
        end)

        it("should not process formatting inside code spans", function()
            const spans = Parser.parseInline("`**not bold**`")
            expect(#spans).to.equal(1)
            expect(spans[1].Text).to.equal("**not bold**")
            expect(spans[1].Code).to.equal(true)
            expect(spans[1].Bold).to.equal(false)
        end)

        it("should handle mixed inline formatting", function()
            const spans = Parser.parseInline("plain **bold** plain")
            expect(#spans).to.equal(3)
            expect(spans[1].Text).to.equal("plain ")
            expect(spans[1].Bold).to.equal(false)
            expect(spans[2].Text).to.equal("bold")
            expect(spans[2].Bold).to.equal(true)
            expect(spans[3].Text).to.equal(" plain")
            expect(spans[3].Bold).to.equal(false)
        end)
    end)
end
