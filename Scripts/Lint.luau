#!/usr/bin/env -S lune run

--[[

Lint

Runs luau-lsp analyze to report type errors and deprecation warnings.
Analyzes Scripts with the Lune platform and Source with the Roblox
platform.

[Usage] ./Scripts/Lint.luau

--]]

local Lint = require("../Submodules/luau-cicd/Scripts/Helpers/Lint")

Lint.run({
    Platforms = {
        { Platform = "lune", Targets = { "/Scripts" } },
        { Platform = "roblox", Targets = { "/Source" }, RojoProject = "dev.project.json" },
    },
})
