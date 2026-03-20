#!/usr/bin/env -S lune run

--[[

Lint

Runs luau-lsp analyze to report type errors and deprecation warnings.
Analyzes Scripts with the Lune platform and Source with the Roblox
platform.

[Usage] ./Scripts/Lint.luau

--]]

local process = require("@lune/process")

local function lint()
    local luneResult = process.exec("luau-lsp", {
        "analyze",
        "--platform=lune",
        "--no-flags-enabled",
        "--enable-new-solver",
        "--ignore=DevPackages/**",
        "--ignore=Packages/**",
        "--ignore=Submodules/**",
        "Scripts/",
    })

    if luneResult.stdout ~= "" then
        print(luneResult.stdout)
    end
    if luneResult.stderr ~= "" then
        print(luneResult.stderr)
    end

    local sourcemap = process.exec("rojo", {
        "sourcemap",
        "dev.project.json",
        "--output",
        "sourcemap.json",
    })

    if not sourcemap.ok then
        print("Failed to generate sourcemap.")
        if sourcemap.stderr ~= "" then
            print(sourcemap.stderr)
        end
        process.exit(1)
    end

    local robloxResult = process.exec("luau-lsp", {
        "analyze",
        "--platform=roblox",
        "--sourcemap=sourcemap.json",
        "--no-flags-enabled",
        "--enable-new-solver",
        "--ignore=DevPackages/**",
        "--ignore=Packages/**",
        "--ignore=Submodules/**",
        "Source/",
    })

    if robloxResult.stdout ~= "" then
        print(robloxResult.stdout)
    end
    if robloxResult.stderr ~= "" then
        print(robloxResult.stderr)
    end

    if luneResult.ok and robloxResult.ok then
        print("No lint errors found.")
    else
        process.exit(1)
    end
end

lint()
