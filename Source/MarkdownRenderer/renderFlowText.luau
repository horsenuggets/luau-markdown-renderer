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

type FlowItem = {
    autoHeight: boolean?,
    element: Instance,
    margin: number?,
    width: number,
}

type FlowConfig = {
    font: Font,
    textColor: Color3,
    textSize: number,
}

-- Reposition all flow items based on the given container width.
-- Returns the total height of the reflowed content.
local function reflow(items: { FlowItem }, containerWidth: number, lineHeight: number, baseTextSize: number): number
    local cursorX = 0
    local cursorY = 0
    local lastItemHeight = baseTextSize

    for _, item in items do
        local actualWidth = item.element.AbsoluteSize.X
        local itemWidth = if actualWidth > 0 then actualWidth else item.width
        if cursorX > 0 and cursorX + itemWidth > containerWidth then
            cursorX = 0
            cursorY += lastItemHeight + (lineHeight - baseTextSize)
            lastItemHeight = baseTextSize
        end
        local margin = item.margin or 0
        item.element.Position = UDim2.fromOffset(cursorX + margin, cursorY)
        cursorX += itemWidth

        if item.autoHeight then
            -- Clamp code pill width to available space
            local itemStart = cursorX - itemWidth
            local maxWidth = containerWidth - itemStart - margin * 2
            if itemWidth > maxWidth + margin * 2 then
                item.element.Size = UDim2.fromOffset(maxWidth, 0)
            end
            local h = item.element.AbsoluteSize.Y
            if h > lastItemHeight then
                lastItemHeight = h
            end
        end
    end

    return cursorY + lastItemHeight
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
            local codeText = applyRichText(sanitize(text), span)
            local bounds = measureText(text, font, spanTextSize)
            local totalWidth = math.ceil(bounds.X) + CODE_PADDING_X * 2
            local totalHeight = bounds.Y + 4
            local elementWidth = totalWidth + CODE_MARGIN_X * 2

            order += 1
            local codeFrame = scope:New("Frame")({
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = CODE_BACKGROUND,
                LayoutOrder = order,
                Name = string.format("Code_%04d", order),
                Size = UDim2.fromOffset(totalWidth, totalHeight),
                [Children] = {
                    scope:New("UICorner")({
                        CornerRadius = CODE_CORNER_RADIUS,
                    }),
                    scope:New("UIPadding")({
                        PaddingBottom = UDim.new(0, 2),
                        PaddingLeft = UDim.new(0, CODE_PADDING_X),
                        PaddingRight = UDim.new(0, CODE_PADDING_X),
                        PaddingTop = UDim.new(0, 2),
                    }),
                    scope:New("TextLabel")({
                        AutomaticSize = Enum.AutomaticSize.Y,
                        BackgroundTransparency = 1,
                        FontFace = font,
                        RichText = true,
                        Size = UDim2.new(1, 0, 0, 0),
                        Text = codeText,
                        TextColor3 = Color3.fromRGB(220, 220, 220),
                        TextSize = spanTextSize,
                        TextWrapped = true,
                        TextXAlignment = Enum.TextXAlignment.Left,
                    }),
                },
            })
            table.insert(items, {
                autoHeight = true,
                element = codeFrame,
                width = elementWidth,
                margin = CODE_MARGIN_X,
            })
            table.insert(elements, codeFrame)
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
