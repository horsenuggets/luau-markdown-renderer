--[[

LongContent.story

Tests text wrapping behavior for long list items, paragraphs, and
headings. Wrapped text in lists should stay flush with the text
start, not the bullet or number prefix.

--]]

local dedent = require("@markdownrenderer/dedent")
local makeStory = require("@stories/makeStory")

return makeStory(dedent([[
	## Long List Items

	- This is a very long bullet point item that should wrap to multiple lines and the wrapped text should align with "This", not with the bullet character
	- Short item
	  - Nested with enough text to wrap and verify alignment at the second indent level properly
	    - Deeply nested long text wrapping to verify three levels of indent

	## Numbered Wrapping

	1. This is a long numbered item that wraps and the second line should align with "This", not the number prefix
	2. Short
	3. Another long numbered item to test how wrapping works with significant amounts of text in a single item

	## Long Paragraph

	This is a very long paragraph with **bold text** and *italic text* and `inline code` all mixed together to verify that wrapping works correctly for paragraphs with mixed inline formatting elements.

	## Long Inline Code

	Here is text with `a very long inline code span that should wrap to the next line properly` and then more text after it.
]]))
