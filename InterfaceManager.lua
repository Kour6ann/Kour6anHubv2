-- InterfaceManager for Kour6anHub
-- Handles theme management and interface settings

local InterfaceManager = {}
InterfaceManager.__index = InterfaceManager

function InterfaceManager:New()
    local self = setmetatable({}, InterfaceManager)
    
    self.Library = nil
    self.Folder = "Kour6anHub"
    
    return self
end

function InterfaceManager:SetLibrary(library)
    self.Library = library
    return self
end

function InterfaceManager:SetFolder(folder)
    self.Folder = folder
    
    if not isfolder(self.Folder) then
        makefolder(self.Folder)
    end
    
    return self
end

function InterfaceManager:BuildInterfaceSection(tab)
    assert(self.Library, "Library must be set using SetLibrary before building interface section")
    
    local section = tab:NewSection("Interface Settings")
    
    -- Theme selector
    local themes = self.Library:GetThemeList()
    local currentTheme = "Modern" -- Default theme
    
    section:NewDropdown("Theme", themes, currentTheme, function(value)
        self.Library:SetTheme(value)
        self:SaveInterfaceSettings("Theme", value)
    end)
    
    -- UI Toggle keybind
    section:NewKeybind("Toggle UI Keybind", Enum.KeyCode.RightControl, function()
        -- Keybind is handled by the library itself
    end)
    
    -- Reduced motion toggle
    section:NewToggle("Reduced Motion", "Disable animations for better performance", false, function(value)
        -- This would need to be implemented in your main library
        self:SaveInterfaceSettings("ReducedMotion", value)
    end)
    
    -- Notification duration slider
    section:NewSlider("Notification Duration", 1, 10, 4, function(value)
        if self.Library._notifConfig then
            self.Library._notifConfig.defaultDuration = value
            self:SaveInterfaceSettings("NotificationDuration", value)
        end
    end)
    
    -- Load saved settings
    self:LoadInterfaceSettings()
end

function InterfaceManager:SaveInterfaceSettings(key, value)
    local settingsPath = self.Folder .. "/interface_settings.json"
    local settings = {}
    
    if isfile(settingsPath) then
        local success, content = pcall(function()
            return readfile(settingsPath)
        end)
        
        if success then
            local decoded
            success, decoded = pcall(function()
                return game:GetService("HttpService"):JSONDecode(content)
            end)
            
            if success then
                settings = decoded
            end
        end
    end
    
    settings[key] = value
    
    local success, encoded = pcall(function()
        return game:GetService("HttpService"):JSONEncode(settings)
    end)
    
    if success then
        writefile(settingsPath, encoded)
    end
end

function InterfaceManager:LoadInterfaceSettings()
    local settingsPath = self.Folder .. "/interface_settings.json"
    
    if not isfile(settingsPath) then
        return
    end
    
    local success, content = pcall(function()
        return readfile(settingsPath)
    end)
    
    if not success then
        return
    end
    
    local settings
    success, settings = pcall(function()
        return game:GetService("HttpService"):JSONDecode(content)
    end)
    
    if not success or type(settings) ~= "table" then
        return
    end
    
    -- Apply saved theme
    if settings.Theme and self.Library then
        self.Library:SetTheme(settings.Theme)
    end
    
    -- Apply notification duration
    if settings.NotificationDuration and self.Library and self.Library._notifConfig then
        self.Library._notifConfig.defaultDuration = settings.NotificationDuration
    end
    
    return settings
end

return InterfaceManager
