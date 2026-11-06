--[[
    ========================================================================
    Kour6anHub v9.0 - Master Loader (init.lua)
    ========================================================================
    This master loader allows you to load the entire Kour6anHub library
    (including Elements, InterfaceManager, and SaveManager) with just ONE line!
--]]

local GITHUB_URL = "https://raw.githubusercontent.com/Kour6ann/Kour6anHubv2/main/"

local function loadFile(fileName)
    -- 1. Try loading from GitHub
    local success, content = pcall(function()
        return game:HttpGet(GITHUB_URL .. fileName)
    end)

    -- 2. Fallback to local file if GitHub is unavailable
    if not success or not content or #content == 0 then
        if typeof(readfile) == "function" and pcall(readfile, fileName) then
            content = readfile(fileName)
        else
            error("[Kour6anHub] Failed to load " .. fileName .. ". Please check your GitHub URL: " .. GITHUB_URL .. fileName)
        end
    end

    local fn, err = loadstring(content)
    if not fn then
        error("[Kour6anHub] Syntax error in " .. fileName .. ": " .. tostring(err))
    end
    return fn()
end

-- Load all 4 core components
local Kour6anHub       = loadFile("NewKour6anHub.lua")
local Elements         = loadFile("Elements.lua")
local InterfaceManager = loadFile("InterfaceManager.lua")
local SaveManager      = loadFile("SaveManager.lua")

-- Attach everything directly to Kour6anHub
Kour6anHub.Elements         = Elements
Kour6anHub.InterfaceManager = InterfaceManager
Kour6anHub.SaveManager      = SaveManager

-- Return Kour6anHub (plus managers as optional extra returns)
return Kour6anHub, InterfaceManager, SaveManager
