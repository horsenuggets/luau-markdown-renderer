--[[

Parser

A zero-dependency Markdown parser that converts Markdown text into an
abstract syntax tree. Supports headings, paragraphs, code blocks, bullet
lists, numbered lists, block quotes, horizontal rules, and inline
formatting (bold, italic, strikethrough, inline code).

--]]

local Types = require("./Types")

local Parser = {}

local function parseInline(text: string): { Types.InlineSpan }
    local spans: { Types.InlineSpan } = {}
    local pos = 1
    local len = #text
    local current = ""
    local bold = false
    local italic = false
    local strikethrough = false
    local code = false

    local function flush()
        if current ~= "" then
            table.insert(spans, {
                Text = current,
                Bold = bold,
                Italic = italic,
                Strikethrough = strikethrough,
                Code = code,
            })
            current = ""
        end
    end

    while pos <= len do
        if code then
            if string.sub(text, pos, pos) == "`" then
                flush()
                code = false
                pos += 1
            else
                current ..= string.sub(text, pos, pos)
                pos += 1
            end
        elseif string.sub(text, pos, pos) == "`" then
            flush()
            code = true
            pos += 1
        elseif string.sub(text, pos, pos + 1) == "**" then
            flush()
            bold = not bold
            pos += 2
        elseif string.sub(text, pos, pos + 1) == "__" then
            flush()
            bold = not bold
            pos += 2
        elseif string.sub(text, pos, pos + 1) == "~~" then
            flush()
            strikethrough = not strikethrough
            pos += 2
        elseif string.sub(text, pos, pos) == "*" or string.sub(text, pos, pos) == "_" then
            flush()
            italic = not italic
            pos += 1
        else
            current ..= string.sub(text, pos, pos)
            pos += 1
        end
    end

    flush()
    return spans
end

local function isHorizontalRule(line: string): boolean
    local stripped = string.gsub(line, "%s", "")
    if #stripped < 3 then
        return false
    end
    local char = string.sub(stripped, 1, 1)
    if char ~= "-" and char ~= "*" and char ~= "_" then
        return false
    end
    for i = 2, #stripped do
        if string.sub(stripped, i, i) ~= char then
            return false
        end
    end
    return true
end

local function countLeadingSpaces(line: string): number
    local count = 0
    for i = 1, #line do
        if string.sub(line, i, i) == " " then
            count += 1
        elseif string.sub(line, i, i) == "\t" then
            count += 4
        else
            break
        end
    end
    return count
end

local function stripBlockQuotePrefix(line: string): string
    local result = string.match(line, "^%s*> ?(.*)")
    return result or line
end

local function isBlockQuoteLine(line: string): boolean
    return string.match(line, "^%s*>") ~= nil
end

local function parseHeading(line: string): (number?, string?)
    local hashes, rest = string.match(line, "^(#+) (.+)")
    if not hashes or not rest then
        return nil, nil
    end
    local level = #hashes
    if level < 1 or level > 6 then
        return nil, nil
    end
    return level, rest
end

local function parseBlocks(lines: { string }): { Types.BlockNode }
    local nodes: { Types.BlockNode } = {}
    local pos = 1
    local lineCount = #lines

    local function skipBlankLines()
        while pos <= lineCount and string.match(lines[pos], "^%s*$") do
            pos += 1
        end
    end

    local function collectParagraphLines(): { string }
        local collected: { string } = {}
        while pos <= lineCount do
            local line = lines[pos]
            if string.match(line, "^%s*$") then
                break
            end
            local hLevel = parseHeading(line)
            if hLevel then
                break
            end
            if string.match(line, "^```") then
                break
            end
            if isHorizontalRule(line) then
                break
            end
            if string.match(line, "^%s*[-*+] ") then
                break
            end
            if string.match(line, "^%s*%d+%. ") then
                break
            end
            if isBlockQuoteLine(line) then
                break
            end
            table.insert(collected, line)
            pos += 1
        end
        return collected
    end

    while pos <= lineCount do
        skipBlankLines()
        if pos > lineCount then
            break
        end

        local line = lines[pos]

        -- Headings
        local headingLevel, headingText = parseHeading(line)
        if headingLevel and headingText then
            table.insert(nodes, {
                Type = "Heading",
                Level = headingLevel,
                Content = parseInline(headingText),
            })
            pos += 1
            continue
        end

        -- Code blocks
        local codeLang = string.match(line, "^```(.*)")
        if codeLang then
            pos += 1
            local codeLines: { string } = {}
            while pos <= lineCount do
                if string.match(lines[pos], "^```%s*$") then
                    pos += 1
                    break
                end
                table.insert(codeLines, lines[pos])
                pos += 1
            end
            local language: string? = nil
            if codeLang ~= "" then
                language = string.match(codeLang, "^%s*(%S+)")
            end
            table.insert(nodes, {
                Type = "CodeBlock",
                Language = language,
                Code = table.concat(codeLines, "\n"),
            })
            continue
        end

        -- Horizontal rules
        if isHorizontalRule(line) then
            table.insert(nodes, {
                Type = "HorizontalRule",
            })
            pos += 1
            continue
        end

        -- Block quotes
        if isBlockQuoteLine(line) then
            local quoteLines: { string } = {}
            while pos <= lineCount and isBlockQuoteLine(lines[pos]) do
                table.insert(quoteLines, stripBlockQuotePrefix(lines[pos]))
                pos += 1
            end
            table.insert(nodes, {
                Type = "BlockQuote",
                Children = parseBlocks(quoteLines),
            })
            continue
        end

        -- Bullet lists
        local bulletMatch = string.match(line, "^%s*[-*+] ")
        if bulletMatch then
            local items: { Types.ListItem } = {}
            while pos <= lineCount do
                local currentLine = lines[pos]
                local spaces, itemText = string.match(currentLine, "^(%s*)[-*+] (.+)")
                if not spaces or not itemText then
                    break
                end
                local indent = math.floor(countLeadingSpaces(spaces) / 2)
                table.insert(items, {
                    Content = parseInline(itemText),
                    Indent = indent,
                })
                pos += 1
            end
            table.insert(nodes, {
                Type = "BulletList",
                Items = items,
            })
            continue
        end

        -- Numbered lists
        local numberedMatch = string.match(line, "^%s*%d+%. ")
        if numberedMatch then
            local items: { Types.ListItem } = {}
            while pos <= lineCount do
                local currentLine = lines[pos]
                local spaces, itemText = string.match(currentLine, "^(%s*)%d+%. (.+)")
                if not spaces or not itemText then
                    break
                end
                local indent = math.floor(countLeadingSpaces(spaces) / 2)
                table.insert(items, {
                    Content = parseInline(itemText),
                    Indent = indent,
                })
                pos += 1
            end
            table.insert(nodes, {
                Type = "NumberedList",
                Items = items,
            })
            continue
        end

        -- Paragraphs (default)
        local paragraphLines = collectParagraphLines()
        if #paragraphLines > 0 then
            local text = table.concat(paragraphLines, " ")
            table.insert(nodes, {
                Type = "Paragraph",
                Content = parseInline(text),
            })
        else
            pos += 1
        end
    end

    return nodes
end

function Parser.parse(source: string): { Types.BlockNode }
    assert(type(source) == "string", "Expected source to be a string")
    local lines = string.split(source, "\n")
    return parseBlocks(lines)
end

Parser.parseInline = parseInline

return Parser
