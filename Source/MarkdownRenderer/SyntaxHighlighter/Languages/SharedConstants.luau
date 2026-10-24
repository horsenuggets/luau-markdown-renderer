--[[

SharedConstants

Common string delimiter and comment constants shared across
language grammar files.

--]]

const C_COMMENTS = { { "/*", "*/" } }
const C_LINE_COMMENTS = { "//" }
const DOUBLE_QUOTE = { open = '"', close = '"' }
const SINGLE_QUOTE = { open = "'", close = "'" }

return {
    C_COMMENTS = C_COMMENTS,
    C_LINE_COMMENTS = C_LINE_COMMENTS,
    DOUBLE_QUOTE = DOUBLE_QUOTE,
    SINGLE_QUOTE = SINGLE_QUOTE,
}
