#!/usr/bin/env -S lune run
--!nocheck

--[[

RunTests

Executes all test suites and exits with appropriate status code.

--]]

local Testable = require("@devpackages/Testable")
local process = require("@lune/process")

Testable.configure({
    Coverage = true,
    CoverageThreshold = 0,
    CoverageRoots = script.Parent.Parent.Source,
})

local function runTests()
    local _, passed = Testable.run(script.Parent.Parent.Tests)
    process.exit(if passed then 0 else 1)
end

runTests()
