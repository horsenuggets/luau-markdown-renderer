--[[

SharedConstants

Common string delimiter and comment constants shared across
language grammar files.

--]]

local C_COMMENTS = { { "/*", "*/" } }
local C_LINE_COMMENTS = { "//" }
local DOUBLE_QUOTE = { open = '"', close = '"' }
local SINGLE_QUOTE = { open = "'", close = "'" }

return {
    C_COMMENTS = C_COMMENTS,
    C_LINE_COMMENTS = C_LINE_COMMENTS,
    DOUBLE_QUOTE = DOUBLE_QUOTE,
    SINGLE_QUOTE = SINGLE_QUOTE,
}
