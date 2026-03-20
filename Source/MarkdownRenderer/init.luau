--[[

MarkdownRenderer

A Fusion-based renderer that converts Markdown text into Roblox Studio
UI elements. Parses Markdown into an AST and produces a scrollable Frame
containing TextLabels, Frames, and other UI elements.

--]]

local Fusion = require("@packages/Fusion")
local Parser = require("@self/Parser")
local SyntaxHighlighter = require("@self/SyntaxHighlighter")
local Types = require("@self/Types")
local renderFlowText = require("@self/renderFlowText")
local renderInline = require("@self/renderInline")

local Children = Fusion.Children

local HEADING_SIZES = {
    [1] = 28,
    [2] = 24,
    [3] = 20,
    [4] = 18,
    [5] = 16,
    [6] = 14,
}
local CODE_BACKGROUND = Color3.fromRGB(30, 30, 30)
local DEFAULT_TEXT_COLOR = Color3.fromRGB(204, 204, 204)
local DEFAULT_TEXT_SIZE = 16
local HEADING_TEXT_COLOR = Color3.fromRGB(228, 228, 228)
local QUOTE_BORDER_COLOR = Color3.fromRGB(100, 100, 100)
local RULE_COLOR = Color3.fromRGB(80, 80, 80)
local STROKE_COLOR = Color3.fromRGB(60, 60, 60)
local TEXT_FONT = Font.new("rbxasset://fonts/families/SourceSansPro.json")
local HEADING_FONT = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold)
local MONO_FONT = Font.new("rbxasset://fonts/families/RobotoMono.json")

local function hasCode(spans: { Types.InlineSpan }): boolean
    for _, span in spans do
        if span.Code then
            return true
        end
    end
    return false
end

local function renderBlock(
    scope: Fusion.Scope<typeof(Fusion)>,
    node: Types.BlockNode,
    layoutOrder: number,
    textFont: Font,
    headingFont: Font
): Instance?
    if node.Type == "Paragraph" then
        local spans = node.Content :: { Types.InlineSpan }
        if hasCode(spans) then
            local container = renderFlowText(scope, spans, {
                font = textFont,
                textColor = DEFAULT_TEXT_COLOR,
                textSize = DEFAULT_TEXT_SIZE,
            })
            container.LayoutOrder = layoutOrder
            return container
        end
        return scope:New("TextLabel")({
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            FontFace = textFont,
            LayoutOrder = layoutOrder,
            RichText = true,
            Size = UDim2.new(1, 0, 0, 0),
            Text = renderInline(spans),
            TextColor3 = DEFAULT_TEXT_COLOR,
            TextSize = DEFAULT_TEXT_SIZE,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
        })
    elseif node.Type == "Heading" then
        local level = node.Level :: number
        local spans = node.Content :: { Types.InlineSpan }
        local headingSize = HEADING_SIZES[level] or DEFAULT_TEXT_SIZE
        local topMargin = if layoutOrder > 1 then 8 else 0
        if hasCode(spans) then
            local container = renderFlowText(scope, spans, {
                font = headingFont,
                textColor = HEADING_TEXT_COLOR,
                textSize = headingSize,
            })
            container.LayoutOrder = layoutOrder
            return container
        end
        return scope:New("Frame")({
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            LayoutOrder = layoutOrder,
            Size = UDim2.new(1, 0, 0, 0),
            [Children] = {
                scope:New("UIPadding")({
                    PaddingTop = UDim.new(0, topMargin),
                }),
                scope:New("TextLabel")({
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    FontFace = headingFont,
                    RichText = true,
                    Size = UDim2.new(1, 0, 0, 0),
                    Text = renderInline(spans),
                    TextColor3 = HEADING_TEXT_COLOR,
                    TextSize = headingSize,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                }),
            },
        })
    elseif node.Type == "CodeBlock" then
        return scope:New("Frame")({
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = CODE_BACKGROUND,
            LayoutOrder = layoutOrder,
            Size = UDim2.new(1, 0, 0, 0),
            [Children] = {
                scope:New("UICorner")({
                    CornerRadius = UDim.new(0, 4),
                }),
                scope:New("UIPadding")({
                    PaddingBottom = UDim.new(0, 8),
                    PaddingLeft = UDim.new(0, 12),
                    PaddingRight = UDim.new(0, 12),
                    PaddingTop = UDim.new(0, 8),
                }),
                scope:New("TextLabel")({
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    FontFace = MONO_FONT,
                    RichText = true,
                    Size = UDim2.new(1, 0, 0, 0),
                    Text = SyntaxHighlighter.highlight(node.Code or "", node.Language),
                    TextColor3 = Color3.fromRGB(212, 212, 212),
                    TextSize = 14,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                }),
            },
        })
    elseif node.Type == "BulletList" then
        local items = node.Items :: { Types.ListItem }
        local listChildren: { Instance } = {
            scope:New("UIListLayout")({
                Padding = UDim.new(0, 4),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
        }
        local BULLET_WIDTH = 22
        for i, item in items do
            local indent = 16 + (item.Indent or 0) * 24
            local textLeft = indent + BULLET_WIDTH
            local content: GuiObject
            if hasCode(item.Content) then
                content = renderFlowText(scope, item.Content, {
                    font = textFont,
                    textColor = DEFAULT_TEXT_COLOR,
                    textSize = DEFAULT_TEXT_SIZE,
                })
                content.Position = UDim2.fromOffset(textLeft, 0)
                content.Size = UDim2.new(1, -textLeft, 0, 0)
            else
                content = scope:New("TextLabel")({
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    FontFace = textFont,
                    Position = UDim2.fromOffset(textLeft, 0),
                    RichText = true,
                    Size = UDim2.new(1, -textLeft, 0, 0),
                    Text = renderInline(item.Content),
                    TextColor3 = DEFAULT_TEXT_COLOR,
                    TextSize = DEFAULT_TEXT_SIZE,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                }) :: GuiObject
            end
            table.insert(
                listChildren,
                scope:New("Frame")({
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    LayoutOrder = i,
                    Size = UDim2.new(1, 0, 0, 0),
                    [Children] = {
                        scope:New("TextLabel")({
                            BackgroundTransparency = 1,
                            FontFace = textFont,
                            Position = UDim2.fromOffset(indent + 4, 0),
                            Size = UDim2.new(0, BULLET_WIDTH, 0, DEFAULT_TEXT_SIZE),
                            Text = "\u{25CF}",
                            TextColor3 = DEFAULT_TEXT_COLOR,
                            TextSize = math.floor(DEFAULT_TEXT_SIZE * 0.65),
                            TextXAlignment = Enum.TextXAlignment.Left,
                            TextYAlignment = Enum.TextYAlignment.Center,
                        }),
                        content,
                    },
                })
            )
        end
        return scope:New("Frame")({
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            LayoutOrder = layoutOrder,
            Size = UDim2.new(1, 0, 0, 0),
            [Children] = listChildren,
        })
    elseif node.Type == "NumberedList" then
        local items = node.Items :: { Types.ListItem }
        local listChildren: { Instance } = {
            scope:New("UIListLayout")({
                Padding = UDim.new(0, 4),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
        }
        local NUMBER_WIDTH = 22
        local number = 0
        for i, item in items do
            local indent = 16 + (item.Indent or 0) * 24
            local textLeft = indent + NUMBER_WIDTH
            number += 1
            local content: GuiObject
            if hasCode(item.Content) then
                content = renderFlowText(scope, item.Content, {
                    font = textFont,
                    textColor = DEFAULT_TEXT_COLOR,
                    textSize = DEFAULT_TEXT_SIZE,
                })
                content.Position = UDim2.fromOffset(textLeft, 0)
                content.Size = UDim2.new(1, -textLeft, 0, 0)
            else
                content = scope:New("TextLabel")({
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    FontFace = textFont,
                    Position = UDim2.fromOffset(textLeft, 0),
                    RichText = true,
                    Size = UDim2.new(1, -textLeft, 0, 0),
                    Text = renderInline(item.Content),
                    TextColor3 = DEFAULT_TEXT_COLOR,
                    TextSize = DEFAULT_TEXT_SIZE,
                    TextWrapped = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = Enum.TextYAlignment.Top,
                }) :: GuiObject
            end
            table.insert(
                listChildren,
                scope:New("Frame")({
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    LayoutOrder = i,
                    Size = UDim2.new(1, 0, 0, 0),
                    [Children] = {
                        scope:New("TextLabel")({
                            BackgroundTransparency = 1,
                            FontFace = textFont,
                            Position = UDim2.fromOffset(indent, 0),
                            Size = UDim2.new(0, NUMBER_WIDTH, 0, DEFAULT_TEXT_SIZE),
                            Text = `{number}.`,
                            TextColor3 = DEFAULT_TEXT_COLOR,
                            TextSize = DEFAULT_TEXT_SIZE,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            TextYAlignment = Enum.TextYAlignment.Top,
                        }),
                        content,
                    },
                })
            )
        end
        return scope:New("Frame")({
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            LayoutOrder = layoutOrder,
            Size = UDim2.new(1, 0, 0, 0),
            [Children] = listChildren,
        })
    elseif node.Type == "BlockQuote" then
        local quoteChildren: { Instance } = {
            scope:New("UIListLayout")({
                Padding = UDim.new(0, 6),
                SortOrder = Enum.SortOrder.LayoutOrder,
            }),
            scope:New("UIPadding")({
                PaddingLeft = UDim.new(0, 12),
            }),
        }
        local children = node.Children :: { Types.BlockNode }
        for i, child in children do
            local rendered = renderBlock(scope, child, i, textFont, headingFont)
            if rendered then
                table.insert(quoteChildren, rendered)
            end
        end
        return scope:New("Frame")({
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            LayoutOrder = layoutOrder,
            Size = UDim2.new(1, 0, 0, 0),
            [Children] = {
                -- Left border
                scope:New("Frame")({
                    BackgroundColor3 = QUOTE_BORDER_COLOR,
                    Size = UDim2.new(0, 4, 1, 0),
                }),
                -- Content container
                scope:New("Frame")({
                    AutomaticSize = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(4, 0),
                    Size = UDim2.new(1, -4, 0, 0),
                    [Children] = quoteChildren,
                }),
            },
        })
    elseif node.Type == "HorizontalRule" then
        return scope:New("Frame")({
            BackgroundTransparency = 1,
            LayoutOrder = layoutOrder,
            Size = UDim2.new(1, 0, 0, 21),
            [Children] = {
                scope:New("Frame")({
                    BackgroundColor3 = RULE_COLOR,
                    Position = UDim2.fromOffset(0, 16),
                    Size = UDim2.new(1, 0, 0, 1),
                }),
            },
        })
    end
    return nil
end

local function render(
    scope: Fusion.Scope<typeof(Fusion)>,
    props: {
        HeadingFont: Font?,
        Font: Font?,
        Height: number?,
        Source: string,
        Width: number?,
    }
): Instance
    local PADDING = 12
    local textFont = props.Font or TEXT_FONT
    local headingFont = props.HeadingFont or HEADING_FONT
    local nodes = Parser.parse(props.Source)
    local blockChildren: { Instance } = {
        scope:New("UIListLayout")({
            Padding = UDim.new(0, 8),
            SortOrder = Enum.SortOrder.LayoutOrder,
        }),
        scope:New("UIPadding")({
            PaddingBottom = UDim.new(0, PADDING),
            PaddingLeft = UDim.new(0, PADDING),
            PaddingRight = UDim.new(0, PADDING),
            PaddingTop = UDim.new(0, PADDING),
        }),
    }
    for i, node in nodes do
        local rendered = renderBlock(scope, node, i, textFont, headingFont)
        if rendered then
            table.insert(blockChildren, rendered)
        end
    end
    local width = props.Width
    local height = props.Height
    local size: UDim2
    if width and height then
        size = UDim2.fromOffset(width, height)
    elseif width then
        size = UDim2.new(0, width, 1, 0)
    elseif height then
        size = UDim2.new(1, 0, 0, height)
    else
        size = UDim2.fromScale(1, 1)
    end
    local scrollFrame: ScrollingFrame = scope:New("ScrollingFrame")({
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(24, 24, 24),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarImageColor3 = Color3.fromRGB(60, 60, 60),
        ScrollBarImageTransparency = 1,
        ScrollBarThickness = 6,
        Size = size,
        [Children] = {
            scope:New("UICorner")({
                CornerRadius = UDim.new(0, 8),
            }),
            scope:New("UIStroke")({
                Color = STROKE_COLOR,
                Thickness = 1,
            }),
            blockChildren,
        },
    })

    -- Fade scrollbar in/out on hover and scroll
    local TweenService = game:GetService("TweenService")
    local FADE_IN = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local FADE_OUT = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local hideTimer: thread? = nil

    local function showScrollbar()
        if hideTimer then
            task.cancel(hideTimer)
            hideTimer = nil
        end
        TweenService:Create(scrollFrame, FADE_IN, { ScrollBarImageTransparency = 0 }):Play()
    end

    local function hideScrollbar()
        hideTimer = task.delay(1, function()
            TweenService:Create(scrollFrame, FADE_OUT, { ScrollBarImageTransparency = 1 }):Play()
            hideTimer = nil
        end)
    end

    scrollFrame.MouseEnter:Connect(showScrollbar)
    scrollFrame.MouseLeave:Connect(hideScrollbar)
    scrollFrame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
        showScrollbar()
        hideScrollbar()
    end)

    return scrollFrame
end

local MarkdownRenderer = {}
MarkdownRenderer.Parser = Parser
MarkdownRenderer.Types = Types
MarkdownRenderer.render = render

return MarkdownRenderer
