--[[

renderFlowText

Renders an array of InlineSpan objects as individual UI elements
inside a container Frame with manual flow layout. Each span becomes
its own TextLabel, and code spans get a Frame wrapper with rounded
corners, padding, and a distinct background color.

Text measurement via TextService determines element widths, and
spans are positioned left-to-right with automatic line wrapping.
The layout dynamically reflows when the container is resized.

--]]

local Fusion = require("@packages/Fusion")
local Types = require("./Types")
local sanitize = require("./sanitize")

local Children = Fusion.Children
local TextService = game:GetService("TextService")

local CODE_BACKGROUND = Color3.fromRGB(50, 50, 50)
local CODE_CORNER_RADIUS = UDim.new(0, 4)
local CODE_MARGIN_X = 4
local CODE_PADDING_X = 4
local CODE_TEXT_SIZE = 14
local LINE_SPACING = 4
local MONO_FONT = Font.new("rbxasset://fonts/families/RobotoMono.json")

local function measureText(text: string, font: Font, textSize: number): Vector2
    local params = Instance.new("GetTextBoundsParams")
    params.Text = text
    params.Font = font
    params.Size = textSize
    params.Width = math.huge
    local bounds = TextService:GetTextBoundsAsync(params)
    return bounds
end

local function applyRichText(text: string, span: Types.InlineSpan): string
    if span.Bold then
        text = `<b>{text}</b>`
    end
    if span.Italic then
        text = `<i>{text}</i>`
    end
    if span.Strikethrough then
        text = `<s>{text}</s>`
    end
    return text
end

-- Split text into words, preserving leading and trailing
-- whitespace by attaching spaces to adjacent words.
local function splitIntoWords(text: string): { string }
    local words = {}
    for word in string.gmatch(text, "%s*%S+%s*") do
        table.insert(words, word)
    end
    if #words == 0 and #text > 0 then
        table.insert(words, text)
    end
    return words
end

type CodeWord = {
    text: string,
    width: number,
}

type CodeGroup = {
    height: number,
    pills: { Frame },
    words: { CodeWord },
}

type FlowItem = {
    codeGroup: CodeGroup?,
    element: Instance,
    margin: number?,
    width: number,
}

type FlowConfig = {
    font: Font,
    textColor: Color3,
    textSize: number,
}

-- Distribute code group words into pre-allocated pill frames
-- based on available width. Each pill gets the words that fit on
-- one line. Unused pills are hidden.
local function reflowCodeGroup(group: CodeGroup, startX: number, startY: number, containerWidth: number)
    local availWidth = containerWidth - startX - CODE_MARGIN_X * 2
    local pillIdx = 1
    local lineWords: { string } = {}
    local lineWidth = 0
    local cursorY = startY
    local totalHeight = group.height

    for _, word in group.words do
        if lineWidth > 0 and lineWidth + word.width > availWidth then
            -- Flush current line to a pill
            if pillIdx <= #group.pills then
                local pill = group.pills[pillIdx]
                local text = table.concat(lineWords)
                pill.Visible = true
                pill.Size = UDim2.fromOffset(lineWidth + CODE_PADDING_X * 2, totalHeight)
                pill.Position = UDim2.fromOffset(startX + CODE_MARGIN_X, cursorY)
                local label = pill:FindFirstChildOfClass("TextLabel")
                if label then
                    label.Text = text
                end
                pillIdx += 1
            end
            -- New line
            cursorY += totalHeight + LINE_SPACING
            lineWords = {}
            lineWidth = 0
            availWidth = containerWidth - CODE_MARGIN_X * 2
        end
        table.insert(lineWords, word.text)
        lineWidth += word.width
    end

    -- Flush remaining words
    if #lineWords > 0 and pillIdx <= #group.pills then
        local pill = group.pills[pillIdx]
        local text = table.concat(lineWords)
        pill.Visible = true
        pill.Size = UDim2.fromOffset(lineWidth + CODE_PADDING_X * 2, totalHeight)
        pill.Position = UDim2.fromOffset(startX + CODE_MARGIN_X, cursorY)
        local label = pill:FindFirstChildOfClass("TextLabel")
        if label then
            label.Text = text
        end
        pillIdx += 1
    end

    -- Hide unused pills
    for i = pillIdx, #group.pills do
        group.pills[i].Visible = false
    end

    -- Return the total width of the last line and the final Y
    local lastLineWidth = lineWidth + CODE_PADDING_X * 2 + CODE_MARGIN_X * 2
    return lastLineWidth, cursorY
end

-- Reposition all flow items based on the given container width.
-- Returns the total height of the reflowed content.
local function reflow(items: { FlowItem }, containerWidth: number, lineHeight: number, baseTextSize: number): number
    local cursorX = 0
    local cursorY = 0

    for _, item in items do
        if item.codeGroup then
            -- Code groups handle their own multi-line layout
            if cursorX > 0 and cursorX + item.width > containerWidth then
                cursorX = 0
                cursorY += lineHeight
            end
            local lastWidth, lastY = reflowCodeGroup(item.codeGroup, cursorX, cursorY, containerWidth)
            cursorX = lastWidth
            cursorY = lastY
        else
            local actualWidth = item.element.AbsoluteSize.X
            local itemWidth = if actualWidth > 0 then actualWidth else item.width
            if cursorX > 0 and cursorX + itemWidth > containerWidth then
                cursorX = 0
                cursorY += lineHeight
            end
            local margin = item.margin or 0
            item.element.Position = UDim2.fromOffset(cursorX + margin, cursorY)
            cursorX += itemWidth
        end
    end

    return cursorY + baseTextSize
end

local function renderFlowText(
    scope: Fusion.Scope<typeof(Fusion)>,
    spans: { Types.InlineSpan },
    config: FlowConfig
): Frame
    local baseFont = config.font
    local textColor = config.textColor
    local textSize = config.textSize
    local lineHeight = textSize + LINE_SPACING

    local items: { FlowItem } = {}
    local elements: { Instance } = {}
    local order = 0

    for _, span in spans do
        local isCode = span.Code == true
        local font = if isCode then MONO_FONT else baseFont
        local spanTextSize = if isCode then CODE_TEXT_SIZE else textSize
        local text = span.Text

        if isCode then
            -- Measure each word individually for line-breaking
            local codeWords = splitIntoWords(text)
            local wordData: { CodeWord } = {}
            local totalTextWidth = 0
            local pillHeight = 0
            for _, word in codeWords do
                local bounds = measureText(word, font, spanTextSize)
                local w = math.ceil(bounds.X)
                table.insert(wordData, { text = word, width = w })
                totalTextWidth += w
                if bounds.Y + 4 > pillHeight then
                    pillHeight = bounds.Y + 4
                end
            end

            -- Pre-allocate pill frames (one per potential line,
            -- max 8). During reflow, words are distributed across
            -- pills and unused ones are hidden.
            local MAX_PILLS = 8
            local pills: { Frame } = {}
            for pillIdx = 1, MAX_PILLS do
                order += 1
                local pill = scope:New("Frame")({
                    BackgroundColor3 = CODE_BACKGROUND,
                    LayoutOrder = order,
                    Name = string.format("Code_%04d", order),
                    Size = UDim2.fromOffset(0, pillHeight),
                    Visible = false,
                    [Children] = {
                        scope:New("UICorner")({
                            CornerRadius = CODE_CORNER_RADIUS,
                        }),
                        scope:New("TextLabel")({
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            BackgroundTransparency = 1,
                            FontFace = font,
                            Position = UDim2.fromScale(0.5, 0.5),
                            RichText = true,
                            Size = UDim2.new(1, 0, 1, 0),
                            Text = "",
                            TextColor3 = Color3.fromRGB(220, 220, 220),
                            TextSize = spanTextSize,
                        }),
                    },
                }) :: Frame
                table.insert(pills, pill)
                table.insert(elements, pill)
            end

            -- Single flow item represents the entire code group
            local fullWidth = totalTextWidth + CODE_PADDING_X * 2 + CODE_MARGIN_X * 2
            table.insert(items, {
                codeGroup = {
                    height = pillHeight,
                    pills = pills,
                    words = wordData,
                },
                element = pills[1],
                width = fullWidth,
            })
        else
            local words = splitIntoWords(text)

            for _, word in words do
                local richWord = applyRichText(sanitize(word), span)
                local bounds = measureText(word, font, spanTextSize)
                local wordWidth = math.ceil(bounds.X)

                order += 1
                local label = scope:New("TextLabel")({
                    BackgroundTransparency = 1,
                    FontFace = font,
                    LayoutOrder = order,
                    Name = string.format("Word_%04d", order),
                    RichText = true,
                    Size = UDim2.fromOffset(wordWidth, spanTextSize),
                    Text = richWord,
                    TextColor3 = textColor,
                    TextSize = spanTextSize,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                })
                table.insert(items, { element = label, width = wordWidth })
                table.insert(elements, label)
            end
        end
    end

    local container = scope:New("Frame")({
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Name = "FlowText",
        Size = UDim2.new(1, 0, 0, 0),
        [Children] = elements,
    }) :: Frame

    local function onResize()
        local containerWidth = container.AbsoluteSize.X
        if containerWidth <= 0 then
            return
        end
        local totalHeight = reflow(items, containerWidth, lineHeight, textSize)
        container.Size = UDim2.new(1, 0, 0, totalHeight)
    end

    -- Listen for container width changes (e.g. window resize)
    local lastWidth = 0
    container:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
        local newWidth = container.AbsoluteSize.X
        if newWidth ~= lastWidth and newWidth > 0 then
            lastWidth = newWidth
            onResize()
        end
    end)

    -- Multi-pass layout: first pass uses measured widths,
    -- subsequent passes use actual AbsoluteSize for accuracy.
    -- AutomaticSize needs multiple frames to settle.
    task.defer(function()
        onResize()
        task.defer(function()
            onResize()
            task.defer(onResize)
        end)
    end)

    return container
end

return renderFlowText
