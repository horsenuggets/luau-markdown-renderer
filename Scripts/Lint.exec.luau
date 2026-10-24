#!/usr/bin/env -S lune run

--[[

Lint.exec

Runs luau-lsp analyze to report type errors and deprecation warnings.
Analyzes Scripts with the Lune platform and Source with the Roblox
platform.

[Usage] ./Scripts/Lint.exec.luau

--]]

const Lint = {}

function Lint.exec()
    require("@submodules/luau-cicd/Scripts/Helpers/Lint").run({
        Platforms = {
            { Platform = "lune", Targets = { "/Scripts" } },
            { Platform = "roblox", Targets = { "/Source" }, RojoProject = "dev.project.json" },
        },
    })
end

Lint.exec()
