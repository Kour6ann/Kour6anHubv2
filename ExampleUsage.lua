--[[
    ========================================================================
    Kour6anHub v9.0 - Example Usage Script
    ========================================================================
    This script demonstrates how to set up, customize, and use the Kour6anHub 
    UI library in your own Roblox scripts.
    
    It covers:
      1. Loading the library and elements module
      2. Creating a main window with custom title and theme
      3. Creating tabs and sections
      4. Using all UI components (Buttons, Toggles, Sliders, Dropdowns, etc.)
      5. Integrating InterfaceManager (theme changer) & SaveManager (config saving)
    ========================================================================
--]]

-- ============================================================================
-- 1. LOADING THE LIBRARY
-- ============================================================================

-- If you are running locally from executor files:
local Kour6anHub = loadstring(readfile("NewKour6anHub.lua"))()
local Elements = loadstring(readfile("Elements.lua"))()
local InterfaceManager = loadstring(readfile("InterfaceManager.lua"))()
local SaveManager = loadstring(readfile("SaveManager.lua"))()

-- Connect Elements module to the Hub (required for UI components to work)
Kour6anHub.Elements = Elements

--[[
    NOTE for Roblox Studio / ModuleScripts:
    If you placed the files as ModuleScripts in ReplicatedStorage:
    
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Kour6anHub = require(ReplicatedStorage.Kour6anHub.NewKour6anHub)
    local Elements = require(ReplicatedStorage.Kour6anHub.Elements)
    local InterfaceManager = require(ReplicatedStorage.Kour6anHub.InterfaceManager)
    local SaveManager = require(ReplicatedStorage.Kour6anHub.SaveManager)
    Kour6anHub.Elements = Elements
--]]


-- ============================================================================
-- 2. CREATE MAIN WINDOW
-- ============================================================================
-- Themes available: "Modern" (light), "Dark", "Midnight", "Ocean", "Crimson"
local Window = Kour6anHub.CreateLib("Kour6anHub - Demo Script", "Midnight")

-- Set the keyboard shortcut to hide/show the UI (Default is RightControl)
Window:SetToggleKey(Enum.KeyCode.RightControl)

-- Show a welcome notification on startup
Window:Notify("Kour6anHub Loaded", "Press Right Control to toggle the menu.", 4)


-- ============================================================================
-- 3. CREATE TABS
-- ============================================================================
local MainTab     = Window:NewTab("Main")
local VisualsTab  = Window:NewTab("Visuals")
local MiscTab     = Window:NewTab("Miscellaneous")
local SettingsTab = Window:NewTab("Settings")


-- ============================================================================
-- 4. TAB 1: MAIN (Buttons, Toggles, Sliders)
-- ============================================================================
local PlayerSection = MainTab:NewSection("Character Modifications")

-- Descriptive Label
PlayerSection:NewLabel("Adjust your character's movement attributes below:")

-- Separator line
PlayerSection:NewSeparator()

-- Button Example 1: Without description (Smart 2-argument format fixed in Issue 1.1)
PlayerSection:NewButton("Reset Character", function()
    local player = game:GetService("Players").LocalPlayer
    if player and player.Character then
        player.Character:BreakJoints()
        Window:Notify("Action", "Character was reset.", 2)
    end
end)

-- Button Example 2: With description (3-argument format)
PlayerSection:NewButton("Print Coordinates", "Prints your current position to console", function()
    local player = game:GetService("Players").LocalPlayer
    local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if root then
        print("[Demo] Current Position:", root.Position)
        Window:Notify("Position", tostring(root.Position), 3)
    end
end)

-- Toggle Example 1: Without description (Smart format)
local SpeedToggle = PlayerSection:NewToggle("Speed Boost", false, function(state)
    print("Speed Boost toggled:", state)
    local player = game:GetService("Players").LocalPlayer
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = state and 32 or 16
    end
end)

-- Toggle Example 2: With description
local JumpToggle = PlayerSection:NewToggle("High Jump", "Increases your jump power", false, function(state)
    local player = game:GetService("Players").LocalPlayer
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.UseJumpPower = true
        hum.JumpPower = state and 100 or 50
    end
end)

-- Slider Example: Min, Max, Default, Callback
local WalkSpeedSlider = PlayerSection:NewSlider("Custom WalkSpeed", 16, 250, 16, function(value)
    local player = game:GetService("Players").LocalPlayer
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = value
    end
end)


-- ============================================================================
-- 5. TAB 2: VISUALS (Dropdowns, Color Pickers)
-- ============================================================================
local ESPSection = VisualsTab:NewSection("ESP & Highlights")

-- Dropdown Menu (Single selection)
local EspModeDropdown = ESPSection:NewDropdown("Highlight Mode", {"Off", "Boxes", "Tracers", "Chams"}, "Off", function(selected)
    print("Highlight Mode set to:", selected)
    Window:Notify("Visuals", "Mode set to: " .. tostring(selected), 2)
end)

-- Multi-Dropdown Menu (Multiple selections allowed)
local TargetFilter = ESPSection:NewMultiDropdown("Target Filter", {"Enemies", "Teammates", "NPCs", "Friends"}, {"Enemies"}, function(selectedTable)
    print("Active target filters:")
    for option, isEnabled in pairs(selectedTable) do
        print("  - " .. tostring(option) .. ": " .. tostring(isEnabled))
    end
end)

-- Color Picker Example
local ESPColorPicker = ESPSection:NewColorpicker("Highlight Color", Color3.fromRGB(0, 170, 255), function(color)
    print("New color selected: RGB(" .. math.floor(color.R * 255) .. ", " .. math.floor(color.G * 255) .. ", " .. math.floor(color.B * 255) .. ")")
end)


-- ============================================================================
-- 6. TAB 3: MISC (Textboxes, Keybinds)
-- ============================================================================
local MiscSection = MiscTab:NewSection("General Tools")

-- Textbox Example: Placeholder, Default text, Callback on Enter
local MessageTextbox = MiscSection:NewTextbox("Type message here...", "", function(text)
    print("User entered text:", text)
    Window:Notify("Message Received", text, 3)
end)

-- Keybind Example: Description, Default KeyCode, Callback when key is pressed
local FlyKeybind = MiscSection:NewKeybind("Fly Toggle Key", Enum.KeyCode.F, function()
    print("Fly keybind triggered!")
    Window:Notify("Keybind", "Fly key (F) was pressed!", 2)
end)


-- ============================================================================
-- 7. TAB 4: SETTINGS (InterfaceManager & SaveManager)
-- ============================================================================

-- Build Theme & UI Management section using InterfaceManager
local IM = InterfaceManager:New()
IM:SetLibrary(Window)
IM:SetFolder("MyHubConfigs")
IM:BuildInterfaceSection(SettingsTab)

-- Build Config Save / Load section using SaveManager
local SM = SaveManager:New("MyHubConfigs")
SM:SetLibrary(Window)

-- Register elements you want to automatically save and load in configs
SM:RegisterElement("SpeedToggle", SpeedToggle, "Toggle")
SM:RegisterElement("JumpToggle", JumpToggle, "Toggle")
SM:RegisterElement("WalkSpeedSlider", WalkSpeedSlider, "Slider")
SM:RegisterElement("EspModeDropdown", EspModeDropdown, "Dropdown")
SM:RegisterElement("TargetFilter", TargetFilter, "MultiDropdown")
SM:RegisterElement("ESPColorPicker", ESPColorPicker, "ColorPicker")

-- Build the UI for saving, loading, and auto-loading configs
SM:BuildConfigSection(SettingsTab)

-- (Optional) Automatically load the user's default saved config if one exists
pcall(function()
    SM:LoadAutoloadConfig()
end)

print("[Kour6anHub] Demo script initialized successfully!")
