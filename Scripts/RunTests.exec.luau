#!/usr/bin/env -S lune run

--[[

RunTests.exec

Executes all test suites and exits with appropriate status code.

[Usage] ./Scripts/RunTests.exec.luau

--]]

const Testable = require("@devpackages/Testable")
const process = require("@lune/process")

const RunTests = {}

function RunTests.test()
    const _, passed = Testable.run(project.Tests)
    process.exit(if passed then 0 else 1)
end

function RunTests.exec()
    Testable.configure({
        Coverage = true,
        CoverageThreshold = 0,
        CoverageRoots = project.Source,
    })
    RunTests.test()
end

RunTests.exec()
