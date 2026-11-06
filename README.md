# 🚀 Kour6anHub v9.0 UI Framework
> A modern, sleek, and feature-rich UI library for Roblox scripts. Built with smooth animations, customizable color themes, built-in configuration saving, and a 1-line loader.
---
## ✨ Features
- **⚡ 1-Line Master Loader**: Load the entire library, elements, and managers with a single `loadstring`.
- **🎨 5 Built-in Themes**: `Midnight` (Default), `Dark`, `Modern` (Light), `Ocean`, and `Crimson`.
- **🧩 Complete Element Suite**:
  - **Buttons**: Smart argument detection (works with or without descriptions).
  - **Toggle Switches**: Smooth toggling with live ON/OFF feedback.
  - **Sliders**: Customizable ranges, step precision, and real-time drag updates.
  - **Dropdowns**: Single-selection menus with auto-close and scroll support.
  - **Multi-Dropdowns**: Multi-choice selection for advanced tagging and filters.
  - **Color Pickers**: Full RGB & HSV color picker with live visual preview.
  - **Textboxes**: User text inputs with Enter-key trigger.
  - **Keybinds**: Customizable keyboard shortcuts to trigger in-game actions.
- **💾 SaveManager**: Automatic config saving, loading, and auto-loading on player join.
- **🎛️ InterfaceManager**: In-game theme switcher and UI visibility toggle key settings.
- **🔔 Notifications**: Native, animated popup notification cards.
---
## ⚡ Quick Start (1-Line Loader)
You can load the entire library with just one line of code:
```lua
local Kour6anHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/init.lua"))()
-- Create your window
local Window = Kour6anHub.CreateLib("My Script Hub", "Midnight")
-- Create a tab and section
local MainTab = Window:NewTab("Main")
local Section = MainTab:NewSection("Player Controls")
-- Add a button
Section:NewButton("Reset Character", function()
    game.Players.LocalPlayer.Character:BreakJoints()
end)
-- Add a toggle
Section:NewToggle("Speed Boost", false, function(isOn)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = isOn and 32 or 16
end)
-- Add a slider
Section:NewSlider("Custom Speed", 16, 150, 16, function(value)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
end)
```
---
## 📖 Full Starter Example (With Config Saving & Themes)
```lua
-- 1. Load the Hub (Only 1 single line!)
local Kour6anHub = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/init.lua"))()
-- 2. Create the window
local Window = Kour6anHub.CreateLib("My Script Hub", "Midnight")
-- 3. Create tabs
local MainTab     = Window:NewTab("Main")
local SettingsTab = Window:NewTab("Settings")
-- 4. Main Tab elements
local Section = MainTab:NewSection("Player Controls")
Section:NewButton("Reset Character", function()
    local player = game:GetService("Players").LocalPlayer
    if player and player.Character then
        player.Character:BreakJoints()
    end
end)
local SpeedToggle = Section:NewToggle("Speed Boost", false, function(isOn)
    local player = game:GetService("Players").LocalPlayer
    local hum = player and player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = isOn and 32 or 16
    end
end)
local SpeedSlider = Section:NewSlider("Custom Speed", 16, 150, 16, function(value)
    local player = game:GetService("Players").LocalPlayer
    local hum = player and player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = value
    end
end)
-- 5. InterfaceManager (Theme Switcher & Keybind Settings)
local IM = Kour6anHub.InterfaceManager:New()
IM:SetLibrary(Window)
IM:SetFolder("MyHubConfigs")
IM:BuildInterfaceSection(SettingsTab)
-- 6. SaveManager (Config Saving & Loading)
local SM = Kour6anHub.SaveManager:New("MyHubConfigs")
SM:SetLibrary(Window)
-- Register which toggles and sliders should save to config
SM:RegisterElement("SpeedToggle", SpeedToggle, "Toggle")
SM:RegisterElement("SpeedSlider", SpeedSlider, "Slider")
-- Build the Config Save/Load buttons inside Settings tab
SM:BuildConfigSection(SettingsTab)
-- Auto-load the player's saved config on join
pcall(function()
    SM:LoadAutoloadConfig()
end)
```
---
## 🛠️ Component API Reference
### Window
| Method | Description |
| :--- | :--- |
| `Kour6anHub.CreateLib(title, themeName)` | Creates the main UI window. |
| `Window:NewTab(tabName, [icon])` | Adds a new tab to the sidebar. |
| `Window:Notify(title, text, duration)` | Displays an animated popup notification. |
| `Window:SetToggleKey(KeyCode)` | Changes the keyboard shortcut to hide/show the UI (Default: `RightControl`). |
| `Window:SetTheme(themeName)` | Changes the active color theme. |
| `Window:Destroy()` | Removes the UI and disconnects event listeners. |
### Sections & Elements
Call these on any section created via `local Section = Tab:NewSection("Section Title")`:
| Component | Usage Example |
| :--- | :--- |
| **Label** | `Section:NewLabel("Information text here")` |
| **Separator** | `Section:NewSeparator()` |
| **Button** | `Section:NewButton("Click Me", function() print("Clicked!") end)` |
| **Button with Note** | `Section:NewButton("Click Me", "Help text", function() ... end)` |
| **Toggle** | `Section:NewToggle("Auto Farm", false, function(state) print(state) end)` |
| **Slider** | `Section:NewSlider("Speed", 16, 200, 16, function(val) print(val) end)` |
| **Dropdown** | `Section:NewDropdown("Mode", {"Option 1", "Option 2"}, "Option 1", function(opt) end)` |
| **Multi-Dropdown** | `Section:NewMultiDropdown("Filters", {"A", "B", "C"}, {"A"}, function(selectedTable) end)` |
| **Color Picker** | `Section:NewColorpicker("ESP Color", Color3.fromRGB(0, 170, 255), function(color) end)` |
| **Textbox** | `Section:NewTextbox("Placeholder...", "", function(text) print(text) end)` |
| **Keybind** | `Section:NewKeybind("Fly Key", Enum.KeyCode.F, function() print("Pressed!") end)` |
---
## 🎨 Themes Available
| Theme | Background | Accent Color | Style |
| :--- | :--- | :--- | :--- |
| **`Midnight`** *(Default)* | Deep Dark Navy (`#0A0C14`) | Purple Glow (`#785AFF`) | Modern cyber dark |
| **`Dark`** | Neutral Charcoal (`#202020`) | Electric Blue (`#60A0FF`) | Classic dark mode |
| **`Modern`** | Clean Off-White (`#F3F3F3`) | Windows Blue (`#0078D4`) | Crisp light mode |
| **`Ocean`** | Deep Sea (`#051423`) | Cyan Sky (`#008CFF`) | Aquatic blue |
| **`Crimson`** | Dark Ruby (`#190A0F`) | Vivid Rose (`#DC2850`) | Sleek dark red |
---

## 📄 License
This project is open-source and free to use for personal Roblox scripts and projects.
