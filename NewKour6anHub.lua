-- Kour6anHub - Modern Redesign v9.0 - FULLY PATCHED

local Kour6anHub = {}
Kour6anHub.__index = Kour6anHub

-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Configuration
local ReducedMotion = false
local SHADOW_IMAGE = "rbxassetid://6014261993"
local GRADIENT_IMAGE = "rbxassetid://14204231522"

-- Active tweens tracker
local ActiveTweens = setmetatable({}, { __mode = "k" })
local _tweenTimestamps = setmetatable({}, { __mode = "k" })

-- Unicode arrow helper
local function getArrowChar(direction)
    return direction == "down" and "▼" or "▲"
end

-- Enhanced tween creation
local function safeTweenCreate(obj, props, options)
    if not obj or not props then return nil end
    options = options or {}
    local dur = options.duration or 0.15
    local easingStyle = options.easingStyle or Enum.EasingStyle.Quad
    local easingDirection = options.easingDirection or Enum.EasingDirection.Out

    if _G.ReducedMotion or ReducedMotion then
        for prop, value in pairs(props) do
            pcall(function() obj[prop] = value end)
        end
        return nil
    end

    if not ActiveTweens[obj] then ActiveTweens[obj] = {} end

    for prop, tweenObj in pairs(ActiveTweens[obj]) do
        if props[prop] ~= nil then
            if tweenObj and typeof(tweenObj) == "Tween" then
                pcall(function() 
                    if tweenObj.Cancel then tweenObj:Cancel() end
                end)
            end
            ActiveTweens[obj][prop] = nil
        end
    end

    local ti = TweenInfo.new(dur, easingStyle, easingDirection)
    local ok, t = pcall(function() return TweenService:Create(obj, ti, props) end)
    if not ok or not t then return nil end

    for prop in pairs(props) do
        ActiveTweens[obj][prop] = t
    end
    _tweenTimestamps[t] = tick()

    local conn
    conn = t.Completed:Connect(function()
        pcall(function()
            if ActiveTweens[obj] then
                for prop, tweenObj in pairs(ActiveTweens[obj]) do
                    if tweenObj == t then
                        ActiveTweens[obj][prop] = nil
                    end
                end
                if next(ActiveTweens[obj]) == nil then
                    ActiveTweens[obj] = nil
                end
            end
            if conn then
                conn:Disconnect()
                conn = nil
            end
            _tweenTimestamps[t] = nil
        end)
    end)

    local playSuccess = pcall(function() t:Play() end)
    if not playSuccess then
        for prop in pairs(props) do
            if ActiveTweens[obj] then
                ActiveTweens[obj][prop] = nil
            end
        end
        _tweenTimestamps[t] = nil
        if conn then
            pcall(function() conn:Disconnect() end)
        end
        return nil
    end

    return t
end

local function tween(obj, props, options)
    return safeTweenCreate(obj, props, options)
end

-- Connection tracker
local function makeConnectionTracker()
    local conns = {}
    local tweens = {}
    return {
        add = function(_, conn)
            if conn and typeof(conn) == "RBXScriptConnection" then
                table.insert(conns, conn)
            end
        end,
        addTween = function(_, tweenObj)
            if tweenObj and typeof(tweenObj) == "Tween" then
                table.insert(tweens, tweenObj)
            end
        end,
        disconnectAll = function()
            for _, c in ipairs(conns) do
                pcall(function() c:Disconnect() end)
            end
            conns = {}
            for _, t in ipairs(tweens) do
                pcall(function() t:Cancel() end)
            end
            tweens = {}
        end,
        list = function() return conns end,
        listTweens = function() return tweens end
    }
end

local _GLOBAL_CONN_REGISTRY = {}
local function trackGlobalConn(conn)
    if conn and typeof(conn) == "RBXScriptConnection" then
        table.insert(_GLOBAL_CONN_REGISTRY, conn)
    end
end

-- Hover helper
local HoverDebounce = {}
local function debouncedHover(obj, enterFunc, leaveFunc)
    if not obj then return end
    local key = tostring(obj)
    
    local ancConn
    ancConn = obj.AncestryChanged:Connect(function(_, parent)
        if not parent then
            HoverDebounce[key] = nil
            pcall(function() ancConn:Disconnect() end)
        end
    end)
    trackGlobalConn(ancConn)

    obj.MouseEnter:Connect(function()
        if HoverDebounce[key] then return end
        HoverDebounce[key] = true
        if enterFunc then pcall(enterFunc) end
    end)

    obj.MouseLeave:Connect(function()
        if not HoverDebounce[key] then return end
        HoverDebounce[key] = nil
        if leaveFunc then pcall(leaveFunc) end
    end)
end

-- Dragging helper (mobile compatible)
local function makeDraggable(frame, dragHandle)
    local connTracker = makeConnectionTracker()
    local dragging = false
    local dragInput
    local dragStart
    local startPos
    dragHandle = dragHandle or frame

    local ibConn = dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragInput = input
            dragStart = input.Position
            startPos = frame.Position
            
            local changedConn
            changedConn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    dragInput = nil
                    pcall(function() changedConn:Disconnect() end)
                end
            end)
            connTracker:add(changedConn)
        end
    end)
    connTracker:add(ibConn)

    local imConn = UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        
        if input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch then
            if input.UserInputType == Enum.UserInputType.Touch and input ~= dragInput then
                return
            end
            
            local delta = input.Position - dragStart
            pcall(function()
                frame.Position = UDim2.new(
                    startPos.X.Scale, 
                    startPos.X.Offset + delta.X, 
                    startPos.Y.Scale, 
                    startPos.Y.Offset + delta.Y
                )
            end)
        end
    end)
    connTracker:add(imConn)
    
    local ieConn = UserInputService.InputEnded:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or 
                        input.UserInputType == Enum.UserInputType.Touch) then
            if input == dragInput or input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
                dragInput = nil
            end
        end
    end)
    connTracker:add(ieConn)

    return {
        disconnect = function()
            connTracker.disconnectAll()
        end,
        list = function() return connTracker.list() end
    }
end

-- Modern Theme System
local Themes = {
    ["Modern"] = {
        Background = Color3.fromRGB(243, 243, 243),
        TabBackground = Color3.fromRGB(249, 249, 249),
        SectionBackground = Color3.fromRGB(255, 255, 255),
        ButtonBackground = Color3.fromRGB(251, 251, 251),
        ButtonHover = Color3.fromRGB(245, 245, 245),
        ButtonBorder = Color3.fromRGB(225, 225, 225),
        InputBackground = Color3.fromRGB(255, 255, 255),
        InputBorder = Color3.fromRGB(225, 225, 225),
        Text = Color3.fromRGB(32, 32, 32),
        SubText = Color3.fromRGB(96, 96, 96),
        Accent = Color3.fromRGB(0, 120, 212),
        AccentHover = Color3.fromRGB(16, 110, 190),
        Shadow = Color3.fromRGB(0, 0, 0)
    },
    ["Dark"] = {
        Background = Color3.fromRGB(32, 32, 32),
        TabBackground = Color3.fromRGB(43, 43, 43),
        SectionBackground = Color3.fromRGB(45, 45, 45),
        ButtonBackground = Color3.fromRGB(58, 58, 58),
        ButtonHover = Color3.fromRGB(68, 68, 68),
        ButtonBorder = Color3.fromRGB(70, 70, 70),
        InputBackground = Color3.fromRGB(51, 51, 51),
        InputBorder = Color3.fromRGB(70, 70, 70),
        Text = Color3.fromRGB(255, 255, 255),
        SubText = Color3.fromRGB(180, 180, 180),
        Accent = Color3.fromRGB(96, 160, 255),
        AccentHover = Color3.fromRGB(116, 180, 255),
        Shadow = Color3.fromRGB(0, 0, 0)
    },
    ["Midnight"] = {
        Background = Color3.fromRGB(10, 12, 20),
        TabBackground = Color3.fromRGB(18, 20, 30),
        SectionBackground = Color3.fromRGB(22, 24, 36),
        ButtonBackground = Color3.fromRGB(35, 37, 50),
        ButtonHover = Color3.fromRGB(45, 47, 60),
        ButtonBorder = Color3.fromRGB(50, 52, 65),
        InputBackground = Color3.fromRGB(28, 30, 42),
        InputBorder = Color3.fromRGB(50, 52, 65),
        Text = Color3.fromRGB(235, 235, 245),
        SubText = Color3.fromRGB(150, 150, 170),
        Accent = Color3.fromRGB(120, 90, 255),
        AccentHover = Color3.fromRGB(140, 110, 255),
        Shadow = Color3.fromRGB(0, 0, 0)
    },
    ["Ocean"] = {
        Background = Color3.fromRGB(5, 20, 35),
        TabBackground = Color3.fromRGB(10, 30, 50),
        SectionBackground = Color3.fromRGB(15, 40, 65),
        ButtonBackground = Color3.fromRGB(25, 55, 85),
        ButtonHover = Color3.fromRGB(35, 65, 95),
        ButtonBorder = Color3.fromRGB(40, 70, 100),
        InputBackground = Color3.fromRGB(20, 45, 70),
        InputBorder = Color3.fromRGB(40, 70, 100),
        Text = Color3.fromRGB(220, 235, 245),
        SubText = Color3.fromRGB(140, 170, 190),
        Accent = Color3.fromRGB(0, 140, 255),
        AccentHover = Color3.fromRGB(20, 160, 255),
        Shadow = Color3.fromRGB(0, 0, 0)
    },
    ["Crimson"] = {
        Background = Color3.fromRGB(25, 10, 15),
        TabBackground = Color3.fromRGB(35, 15, 20),
        SectionBackground = Color3.fromRGB(45, 20, 25),
        ButtonBackground = Color3.fromRGB(60, 30, 40),
        ButtonHover = Color3.fromRGB(70, 40, 50),
        ButtonBorder = Color3.fromRGB(80, 45, 55),
        InputBackground = Color3.fromRGB(50, 25, 35),
        InputBorder = Color3.fromRGB(80, 45, 55),
        Text = Color3.fromRGB(245, 225, 230),
        SubText = Color3.fromRGB(180, 150, 160),
        Accent = Color3.fromRGB(220, 40, 80),
        AccentHover = Color3.fromRGB(240, 60, 100),
        Shadow = Color3.fromRGB(0, 0, 0)
    }
}

-- Helper to resolve GUI parent
local function resolveGuiParent()
    local parent = game:GetService("CoreGui")
    local success, playerGui = pcall(function()
        local plr = Players.LocalPlayer
        if plr and plr:FindFirstChild("PlayerGui") then
            return plr.PlayerGui
        end
        return nil
    end)
    if success and playerGui then parent = playerGui end
    return parent
end

-- Safe callback wrapper
local function safeCallback(fn, ...)
    if type(fn) ~= "function" then return end
    local ok, err = pcall(fn, ...)
    if not ok then
        warn("[Kour6anHub] callback error:", err)
    end
end

-- Add shadow effect to element
local function addShadow(element, intensity)
    intensity = intensity or 0.7
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 30, 1, 30)
    shadow.Position = UDim2.new(0, -15, 0, -15)
    shadow.BackgroundTransparency = 1
    shadow.Image = SHADOW_IMAGE
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = intensity
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.ZIndex = element.ZIndex - 1
    shadow.Parent = element
    return shadow
end

-- Library creation
function Kour6anHub.CreateLib(title, themeName)
    local theme = Themes[themeName] or Themes["Modern"]
    local GuiParent = resolveGuiParent()

    -- Create or replace ScreenGui
    local ScreenGui = GuiParent:FindFirstChild("Kour6anHub")
    if ScreenGui then
        pcall(function() ScreenGui:Destroy() end)
    end
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Kour6anHub"
    ScreenGui.DisplayOrder = 999999999
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = GuiParent
    
    -- Main frame with shadow
    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 620, 0, 420)
    Main.Position = UDim2.new(0.5, -310, 0.5, -210)
    Main.BackgroundColor3 = theme.Background
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.ClipsDescendants = false
    Main.Parent = ScreenGui

    local mainScale = Instance.new("UIScale")
    mainScale.Scale = 1
    mainScale.Parent = Main

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = Main

    addShadow(Main, 0.65)

    -- Topbar with modern styling
    local Topbar = Instance.new("Frame")
    Topbar.Size = UDim2.new(1, 0, 0, 45)
    Topbar.BackgroundColor3 = theme.SectionBackground
    Topbar.Active = true
    Topbar.Parent = Main

    local TopbarCorner = Instance.new("UICorner")
    TopbarCorner.CornerRadius = UDim.new(0, 10)
    TopbarCorner.Parent = Topbar

    -- Subtle divider line under topbar
    local TopbarDivider = Instance.new("Frame")
    TopbarDivider.Size = UDim2.new(1, 0, 0, 1)
    TopbarDivider.Position = UDim2.new(0, 0, 1, -1)
    TopbarDivider.BackgroundColor3 = theme.ButtonBorder
    TopbarDivider.BackgroundTransparency = 0.7
    TopbarDivider.BorderSizePixel = 0
    TopbarDivider.Parent = Topbar

    -- Title with icon support
    local Title = Instance.new("TextLabel")
    Title.Text = title or "Kour6anHub"
    Title.Size = UDim2.new(1, -100, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = theme.Text
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.Parent = Topbar

    -- Window controls with better styling - FIXED CHARACTER ENCODING
    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.Size = UDim2.new(0, 35, 0, 35)
    MinimizeBtn.Position = UDim2.new(1, -80, 0.5, -17.5)
    MinimizeBtn.BackgroundColor3 = theme.ButtonBackground
    MinimizeBtn.TextColor3 = theme.Text
    MinimizeBtn.Font = Enum.Font.GothamBold
    MinimizeBtn.TextSize = 16
    MinimizeBtn.Text = "−"  -- FIXED: Proper minus sign (U+2212)
    MinimizeBtn.AutoButtonColor = false
    MinimizeBtn.Parent = Topbar

    local MinimizeBtnCorner = Instance.new("UICorner")
    MinimizeBtnCorner.CornerRadius = UDim.new(0, 6)
    MinimizeBtnCorner.Parent = MinimizeBtn

    local MinimizeBtnStroke = Instance.new("UIStroke")
    MinimizeBtnStroke.Color = theme.ButtonBorder
    MinimizeBtnStroke.Thickness = 1
    MinimizeBtnStroke.Transparency = 0.7
    MinimizeBtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MinimizeBtnStroke.Parent = MinimizeBtn

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 35, 0, 35)
    CloseBtn.Position = UDim2.new(1, -40, 0.5, -17.5)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(220, 53, 69)
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 16
    CloseBtn.Text = "×"  -- FIXED: Proper multiplication sign (U+00D7)
    CloseBtn.AutoButtonColor = false
    CloseBtn.Parent = Topbar

    local CloseBtnCorner = Instance.new("UICorner")
    CloseBtnCorner.CornerRadius = UDim.new(0, 6)
    CloseBtnCorner.Parent = CloseBtn

    local CloseBtnStroke = Instance.new("UIStroke")
    CloseBtnStroke.Color = Color3.fromRGB(180, 40, 55)
    CloseBtnStroke.Thickness = 1
    CloseBtnStroke.Transparency = 0.5
    CloseBtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    CloseBtnStroke.Parent = CloseBtn

    local globalConnTracker = makeConnectionTracker()

    local baseSize = Vector2.new(Main.Size.X.Offset, Main.Size.Y.Offset)

    local function updateMainScale()
        local camera = workspace.CurrentCamera
        if not camera then return end
        local viewport = camera.ViewportSize
        if not viewport then return end

        local scaleX = viewport.X / baseSize.X
        local scaleY = viewport.Y / baseSize.Y
        local targetScale = math.clamp(math.min(scaleX, scaleY), 0.65, 1)
        mainScale.Scale = targetScale
    end

    local viewportConn
    local function bindCamera()
        if viewportConn then
            pcall(function() viewportConn:Disconnect() end)
            viewportConn = nil
        end
        local camera = workspace.CurrentCamera
        if not camera then return end
        updateMainScale()
        viewportConn = camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateMainScale)
        globalConnTracker:add(viewportConn)
    end

    bindCamera()
    local cameraConn = workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCamera)
    globalConnTracker:add(cameraConn)

    -- Make draggable
    local dragTracker = makeDraggable(Main, Topbar)
    if dragTracker then
        for _, c in ipairs(dragTracker.list()) do globalConnTracker:add(c) end
    end
    
    for _, c in ipairs(_GLOBAL_CONN_REGISTRY) do
        globalConnTracker:add(c)
    end
    _GLOBAL_CONN_REGISTRY = {}

    -- Tab container with modern styling
    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(0, 160, 1, -45)
    TabContainer.Position = UDim2.new(0, 0, 0, 45)
    TabContainer.BackgroundColor3 = theme.TabBackground
    TabContainer.Active = true
    TabContainer.Parent = Main

    local TabContainerCorner = Instance.new("UICorner")
    TabContainerCorner.CornerRadius = UDim.new(0, 10)
    TabContainerCorner.Parent = TabContainer

    -- Subtle border for tab container
    local TabContainerStroke = Instance.new("UIStroke")
    TabContainerStroke.Color = theme.ButtonBorder
    TabContainerStroke.Thickness = 1
    TabContainerStroke.Transparency = 0.85
    TabContainerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    TabContainerStroke.Parent = TabContainer

    local TabList = Instance.new("UIListLayout")
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 8)
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabList.Parent = TabContainer

    local TabPadding = Instance.new("UIPadding")
    TabPadding.PaddingTop = UDim.new(0, 10)
    TabPadding.PaddingBottom = UDim.new(0, 10)
    TabPadding.PaddingLeft = UDim.new(0, 10)
    TabPadding.PaddingRight = UDim.new(0, 10)
    TabPadding.Parent = TabContainer

    -- Content area
    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -170, 1, -45)
    Content.Position = UDim2.new(0, 170, 0, 45)
    Content.BackgroundTransparency = 1
    Content.Active = true
    Content.Parent = Main

    local Tabs = {}
    local Window = {}
    Window.ScreenGui = ScreenGui
    Window.Main = Main
    Window._connTracker = globalConnTracker
    Window.theme = theme

    Window._uiVisible = true
    Window._uiMinimized = false
    Window._toggleKey = Enum.KeyCode.RightControl
    Window._storedPosition = Main.Position
    Window._storedSize = Main.Size

    -- Notification system
    Window._notifications = {}
    Window._notifConfig = {
        width = 320,
        height = 70,
        spacing = 10,
        margin = 20,
        defaultDuration = 4
    }

    local function createNotificationHolder()
        local holder = Instance.new("Frame")
        holder.Name = "_NotificationHolder"
        holder.Size = UDim2.new(0, Window._notifConfig.width, 0, 1000)
        holder.AnchorPoint = Vector2.new(1,1)
        holder.Position = UDim2.new(1, -Window._notifConfig.margin, 1, -Window._notifConfig.margin)
        holder.BackgroundTransparency = 1
        holder.Parent = ScreenGui
        return holder
    end

    Window._notificationHolder = createNotificationHolder()

    local function repositionNotifications()
        for i, notif in ipairs(Window._notifications) do
            local targetY = - ( (i-1) * (Window._notifConfig.height + Window._notifConfig.spacing) ) - Window._notifConfig.height
            local finalPos = UDim2.new(0, 0, 1, targetY)
            pcall(function()
                if notif and notif.Parent then
                    tween(notif, {Position = finalPos}, {duration = 0.2})
                end
            end)
        end
    end

    local _notif_lock = false
    local _notif_queue = {}
    local _repositionNotifications_original = repositionNotifications
    function repositionNotifications(...)
        if _notif_lock then
            _notif_queue[1] = true
            return
        end
        _notif_lock = true
        local ok, err = pcall(_repositionNotifications_original, ...)
        _notif_lock = false
        if not ok then warn('[Kour6anHub] repositionNotifications failed:', err) end
        if _notif_queue[1] then
            _notif_queue[1] = nil
            repositionNotifications(...)
        end
    end

    function Window:Notify(titleText, bodyText, duration)
        duration = duration or Window._notifConfig.defaultDuration
        if type(duration) ~= "number" or duration < 0 then 
            duration = Window._notifConfig.defaultDuration 
        end

        local width = Window._notifConfig.width
        local height = Window._notifConfig.height

        local notif = Instance.new("Frame")
        notif.Size = UDim2.new(0, width, 0, height)
        notif.BackgroundColor3 = theme.SectionBackground
        notif.BorderSizePixel = 0
        notif.AnchorPoint = Vector2.new(0,0)
        notif.Position = UDim2.new(0, 0, 1, 50)
        notif.Parent = Window._notificationHolder

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = notif

        -- Add border stroke
        local notifStroke = Instance.new("UIStroke")
        notifStroke.Color = theme.ButtonBorder
        notifStroke.Thickness = 1
        notifStroke.Transparency = 0.7
        notifStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        notifStroke.Parent = notif

        -- Add subtle shadow
        addShadow(notif, 0.8)

        local accent = Instance.new("Frame")
        accent.Size = UDim2.new(0, 4, 1, 0)
        accent.Position = UDim2.new(0, 0, 0, 0)
        accent.BackgroundColor3 = theme.Accent
        accent.BorderSizePixel = 0
        accent.Parent = notif
        
        local acorner = Instance.new("UICorner")
        acorner.CornerRadius = UDim.new(0, 10)
        acorner.Parent = accent

        local ttl = Instance.new("TextLabel")
        ttl.Size = UDim2.new(1, -16, 0, 22)
        ttl.Position = UDim2.new(0, 12, 0, 8)
        ttl.BackgroundTransparency = 1
        ttl.TextXAlignment = Enum.TextXAlignment.Left
        ttl.TextYAlignment = Enum.TextYAlignment.Top
        ttl.Font = Enum.Font.GothamBold
        ttl.TextSize = 14
        ttl.TextColor3 = theme.Text
        ttl.Text = tostring(titleText or "Notification")
        ttl.Parent = notif

        local body = Instance.new("TextLabel")
        body.Size = UDim2.new(1, -16, 0, 38)
        body.Position = UDim2.new(0, 12, 0, 30)
        body.BackgroundTransparency = 1
        body.TextXAlignment = Enum.TextXAlignment.Left
        body.TextYAlignment = Enum.TextYAlignment.Top
        body.Font = Enum.Font.Gotham
        body.TextSize = 12
        body.TextColor3 = theme.SubText
        body.Text = tostring(bodyText or "")
        body.TextWrapped = true
        body.Parent = notif

        table.insert(Window._notifications, 1, notif)
        repositionNotifications()

        notif.BackgroundTransparency = 1
        ttl.TextTransparency = 1
        body.TextTransparency = 1
        accent.BackgroundTransparency = 1
        notifStroke.Transparency = 1
        
        pcall(function()
            if notif and notif.Parent then
                tween(notif, {BackgroundTransparency = 0}, {duration = 0.2})
                tween(ttl, {TextTransparency = 0}, {duration = 0.2})
                tween(body, {TextTransparency = 0}, {duration = 0.2})
                tween(accent, {BackgroundTransparency = 0}, {duration = 0.2})
                tween(notifStroke, {Transparency = 0.7}, {duration = 0.2})
            end
        end)

        local removed = false
        local function removeNow()
            if removed then return end
            removed = true
            for i, v in ipairs(Window._notifications) do
                if v == notif then
                    table.remove(Window._notifications, i)
                    break
                end
            end
            if notif and notif.Parent then
                pcall(function() notif:Destroy() end)
            end
            repositionNotifications()
        end

        task.delay(duration, function()
            pcall(function()
                if notif and notif.Parent then
                    local t1 = tween(notif, {
                        BackgroundTransparency = 1, 
                        Position = UDim2.new(0,0,1,50)
                    }, {duration = 0.2})
                    tween(ttl, {TextTransparency = 1}, {duration = 0.2})
                    tween(body, {TextTransparency = 1}, {duration = 0.2})
                    tween(accent, {BackgroundTransparency = 1}, {duration = 0.2})
                    tween(notifStroke, {Transparency = 1}, {duration = 0.2})
                    
                    if t1 then
                        local c
                        c = t1.Completed:Connect(function()
                            pcall(function() c:Disconnect() end)
                            removeNow()
                        end)
                    else
                        task.delay(0.2, removeNow)
                    end
                end
            end)
        end)

        return notif
    end

    function Window:GetThemeList()
        local out = {}
        for k,_ in pairs(Themes) do
            table.insert(out, k)
        end
        table.sort(out)
        return out
    end

    function Window:SetTheme(newThemeName)
        if not newThemeName then return end
        local foundTheme = nil
        
        if Themes[newThemeName] then
            foundTheme = Themes[newThemeName]
        else
            local lowerTarget = string.lower(tostring(newThemeName))
            for k,v in pairs(Themes) do
                if string.lower(k) == lowerTarget then
                    foundTheme = v
                    break
                end
            end
        end
        
        if not foundTheme then 
            warn("Theme not found:", newThemeName)
            return 
        end
        
        theme = foundTheme
        Window.theme = theme

        pcall(function()
            if Main and Main.Parent then 
                Main.BackgroundColor3 = theme.Background 
            end
            if Topbar and Topbar.Parent then 
                Topbar.BackgroundColor3 = theme.SectionBackground
            end
            if TopbarDivider and TopbarDivider.Parent then
                TopbarDivider.BackgroundColor3 = theme.ButtonBorder
            end
            if Title and Title.Parent then 
                Title.TextColor3 = theme.Text 
            end
            if TabContainer and TabContainer.Parent then 
                TabContainer.BackgroundColor3 = theme.TabBackground
            end
            if TabContainerStroke and TabContainerStroke.Parent then
                TabContainerStroke.Color = theme.ButtonBorder
            end
            if MinimizeBtn and MinimizeBtn.Parent then
                MinimizeBtn.BackgroundColor3 = theme.ButtonBackground
                MinimizeBtn.TextColor3 = theme.Text
            end
            if MinimizeBtnStroke and MinimizeBtnStroke.Parent then
                MinimizeBtnStroke.Color = theme.ButtonBorder
            end
        end)

        for _, entry in ipairs(Tabs) do
            local btn = entry.Button
            local frame = entry.Frame
            
            if btn and btn.Parent then
                local active = btn:GetAttribute("active") or false
                btn.BackgroundColor3 = active and theme.Accent or theme.ButtonBackground
                btn.TextColor3 = active and Color3.fromRGB(255,255,255) or theme.Text
                
                local stroke = btn:FindFirstChild("UIStroke")
                if stroke then
                    stroke.Color = active and theme.Accent or theme.ButtonBorder
                end
            end

            if frame and frame.Parent then
                if frame:IsA("ScrollingFrame") then
                    frame.ScrollBarImageColor3 = theme.Accent
                end
                
                for _, child in ipairs(frame:GetDescendants()) do
                    if not child or not child.Parent then continue end
                    
                    if child:IsA("Frame") then
                        if child.Name == "_section" then
                            child.BackgroundColor3 = theme.SectionBackground
                            local stroke = child:FindFirstChild("UIStroke")
                            if stroke then
                                stroke.Color = theme.ButtonBorder
                            end
                        elseif child.Name == "_dropdownOptions" then
                            child.BackgroundColor3 = theme.SectionBackground
                        end
                    elseif child:IsA("TextLabel") then
                        if child.Font == Enum.Font.GothamBold then
                            child.TextColor3 = theme.SubText
                        else
                            child.TextColor3 = theme.Text
                        end
                    elseif child:IsA("TextButton") then
                        if not child:GetAttribute("_isToggleState") then
                            child.BackgroundColor3 = theme.ButtonBackground
                            child.TextColor3 = theme.Text
                        else
                            local tog = child:GetAttribute("_toggle")
                            child.BackgroundColor3 = tog and theme.Accent or theme.ButtonBackground
                            child.TextColor3 = tog and Color3.fromRGB(255,255,255) or theme.Text
                        end
                        
                        local stroke = child:FindFirstChild("UIStroke")
                        if stroke then
                            stroke.Color = theme.ButtonBorder
                        end
                    elseif child:IsA("TextBox") then
                        child.BackgroundColor3 = theme.InputBackground
                        child.TextColor3 = theme.Text
                        
                        local stroke = child:FindFirstChild("UIStroke")
                        if stroke then
                            stroke.Color = theme.InputBorder
                        end
                    elseif child:IsA("UIStroke") then
                        if child.Parent and child.Parent:IsA("Frame") then
                            child.Color = theme.ButtonBorder
                        end
                    end
                end
            end
        end

        for _, notif in ipairs(Window._notifications) do
            if notif and notif.Parent then
                notif.BackgroundColor3 = theme.SectionBackground
                
                for _, c in ipairs(notif:GetChildren()) do
                    if c:IsA("Frame") and c.Size and c.Size.X.Offset == 4 then
                        c.BackgroundColor3 = theme.Accent
                    elseif c:IsA("TextLabel") then
                        if c.Font == Enum.Font.GothamBold then
                            c.TextColor3 = theme.Text
                        else
                            c.TextColor3 = theme.SubText
                        end
                    elseif c:IsA("UIStroke") then
                        c.Color = theme.ButtonBorder
                    end
                end
            end
        end
        
        -- Theme applied directly, no flicker hack needed
    end

    -- UI Toggle methods
    function Window:Hide()
        if not Window._uiVisible then return end
        Window._storedPosition = Main.Position
        tween(Main, {Position = UDim2.new(0.5, -310, 0.5, -800)}, {duration = 0.2})
        task.delay(0.2, function()
            if ScreenGui then
                ScreenGui.Enabled = false
            end
        end)
        Window._uiVisible = false
    end

    function Window:Show()
        if Window._uiVisible then return end
        if ScreenGui then ScreenGui.Enabled = true end

        if Window._uiMinimized then
            Window:Restore()
        end

        local target = Window._storedPosition or UDim2.new(0.5, -310, 0.5, -210)
        tween(Main, {Position = target}, {duration = 0.2})
        Window._uiVisible = true
    end

    function Window:ToggleUI()
        if Window._uiVisible then
            Window:Hide()
        else
            Window:Show()
        end
    end

    function Window:SetToggleKey(keyEnum)
        if typeof(keyEnum) == "EnumItem" and keyEnum.EnumType == Enum.KeyCode then
            Window._toggleKey = keyEnum
            
            if Window._inputConn then
                pcall(function() Window._inputConn:Disconnect() end)
            end
            
            Window._inputConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed then return end
                if input.UserInputType == Enum.UserInputType.Keyboard and 
                   input.KeyCode == Window._toggleKey then
                    Window:ToggleUI()
                end
            end)
            globalConnTracker:add(Window._inputConn)
        end
    end

    function Window:Minimize()
        if self._uiMinimized then return end
        self._uiMinimized = true

        local header = (self.Topbar or Topbar)
        local headerHeight = (header and header.Size and header.Size.Y and header.Size.Y.Offset) or 45

        if self.Main then
            pcall(function()
                tween(self.Main, {
                    Size = UDim2.new(self._storedSize.X.Scale, self._storedSize.X.Offset, 0, headerHeight)
                }, {duration = 0.2})
            end)
        end

        if TabContainer then pcall(function() TabContainer.Visible = false end) end
        if Content then pcall(function() Content.Visible = false end) end

        if Tabs and type(Tabs) == "table" then
            for _, tab in ipairs(Tabs) do
                pcall(function() if tab and tab.Button then tab.Button.Visible = false end end)
            end
        end
    end

    function Window:Restore()
        if not self._uiMinimized then return end
        self._uiMinimized = false

        if self._storedSize and self.Main then
            pcall(function()
                tween(self.Main, {Size = self._storedSize}, {duration = 0.2})
            end)
        end

        if TabContainer then pcall(function() TabContainer.Visible = true end) end
        if Content then pcall(function() Content.Visible = true end) end

        if Tabs and type(Tabs) == "table" then
            for _, tab in ipairs(Tabs) do
                pcall(function() if tab and tab.Button then tab.Button.Visible = true end end)
            end
        end
    end

    function Window:ToggleMinimize()
        if self._uiMinimized then
            self:Restore()
        else
            self:Minimize()
        end
    end

    function Window:Destroy()
        if self._maintConn then
            pcall(function() self._maintConn:Disconnect() end)
            self._maintConn = nil
        end

        for obj, props in pairs(ActiveTweens) do
            if not obj or (type(obj) == "userdata" and not obj.Parent) then
                ActiveTweens[obj] = nil
            else
                if type(props) == "table" then
                    for prop, tweenObj in pairs(props) do
                        pcall(function() 
                            if tweenObj and typeof(tweenObj) == "Tween" then
                                tweenObj:Cancel() 
                            end
                        end)
                    end
                end
                ActiveTweens[obj] = nil
            end
        end

        if self._inputConn then
            pcall(function() self._inputConn:Disconnect() end)
            self._inputConn = nil
        end

        if Window._currentOpenDropdown and type(Window._currentOpenDropdown) == "function" then
            pcall(function() Window._currentOpenDropdown() end)
            Window._currentOpenDropdown = nil
        end

        if self._connTracker then
            pcall(function() self._connTracker.disconnectAll() end)
            self._connTracker = nil
        end

        for k in pairs(HoverDebounce) do
            HoverDebounce[k] = nil
        end

        if self.ScreenGui then
            pcall(function() self.ScreenGui:Destroy() end)
            self.ScreenGui = nil
        end

        self._notifications = {}
        Tabs = {}

        setmetatable(self, nil)
        for k in pairs(self) do
            self[k] = nil
        end
    end

    -- Tab creation
    function Window:NewTab(tabName, icon)
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, -20, 0, 42)
        TabButton.BackgroundColor3 = theme.ButtonBackground
        TabButton.TextColor3 = theme.Text
        TabButton.Font = Enum.Font.Gotham
        TabButton.TextSize = 14
        TabButton.Text = tabName or "Tab"
        TabButton.AutoButtonColor = false
        TabButton.Parent = TabContainer

        local TabButtonCorner = Instance.new("UICorner")
        TabButtonCorner.CornerRadius = UDim.new(0, 8)
        TabButtonCorner.Parent = TabButton

        local TabButtonStroke = Instance.new("UIStroke")
        TabButtonStroke.Color = theme.ButtonBorder
        TabButtonStroke.Thickness = 1
        TabButtonStroke.Transparency = 0.7
        TabButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        TabButtonStroke.Parent = TabButton

        local TabButtonPadding = Instance.new("UIPadding")
        TabButtonPadding.PaddingTop = UDim.new(0, 10)
        TabButtonPadding.PaddingBottom = UDim.new(0, 10)
        TabButtonPadding.PaddingLeft = UDim.new(0, 12)
        TabButtonPadding.PaddingRight = UDim.new(0, 12)
        TabButtonPadding.Parent = TabButton

        debouncedHover(TabButton,
            function()
                if not TabButton:GetAttribute("active") then
                    tween(TabButton, {
                        BackgroundColor3 = theme.ButtonHover
                    }, {duration = 0.12})
                    tween(TabButtonStroke, {Transparency = 0.5}, {duration = 0.12})
                end
            end,
            function()
                if TabButton:GetAttribute("active") then
                    tween(TabButton, {
                        BackgroundColor3 = theme.Accent
                    }, {duration = 0.12})
                else
                    tween(TabButton, {
                        BackgroundColor3 = theme.ButtonBackground
                    }, {duration = 0.12})
                    tween(TabButtonStroke, {Transparency = 0.7}, {duration = 0.12})
                end
            end
        )

        local TabFrame = Instance.new("ScrollingFrame")
        TabFrame.Size = UDim2.new(1, 0, 1, 0)
        TabFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabFrame.ScrollBarThickness = 6
        TabFrame.ScrollBarImageColor3 = theme.Accent
        TabFrame.BackgroundTransparency = 1
        TabFrame.BorderSizePixel = 0
        TabFrame.Visible = false
        TabFrame.Parent = Content

        local TabLayout = Instance.new("UIListLayout")
        TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabLayout.Padding = UDim.new(0, 12)
        TabLayout.Parent = TabFrame

        local TabFramePadding = Instance.new("UIPadding")
        TabFramePadding.PaddingTop = UDim.new(0, 10)
        TabFramePadding.PaddingLeft = UDim.new(0, 10)
        TabFramePadding.PaddingRight = UDim.new(0, 10)
        TabFramePadding.PaddingBottom = UDim.new(0, 10)
        TabFramePadding.Parent = TabFrame

        TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            local s = TabLayout.AbsoluteContentSize
            TabFrame.CanvasSize = UDim2.new(0, 0, 0, s.Y + 20)
        end)

        TabButton.MouseButton1Click:Connect(function()
            for _, t in ipairs(Tabs) do
                t.Button:SetAttribute("active", false)
                tween(t.Button, {BackgroundColor3 = theme.ButtonBackground}, {duration = 0.15})
                t.Button.TextColor3 = theme.Text
                t.Frame.Visible = false
                
                local stroke = t.Button:FindFirstChild("UIStroke")
                if stroke then
                    tween(stroke, {
                        Color = theme.ButtonBorder, 
                        Transparency = 0.7
                    }, {duration = 0.15})
                end
            end
            
            TabButton:SetAttribute("active", true)
            tween(TabButton, {BackgroundColor3 = theme.Accent}, {duration = 0.15})
            TabButton.TextColor3 = Color3.fromRGB(255,255,255)
            TabFrame.Visible = true
            
            tween(TabButtonStroke, {
                Color = theme.Accent, 
                Transparency = 0
            }, {duration = 0.15})
        end)

        table.insert(Tabs, {Button = TabButton, Frame = TabFrame})

        if not Window._currentTab then
            Window._currentTab = TabButton
            for _, t in ipairs(Tabs) do
                t.Button:SetAttribute("active", false)
                t.Button.BackgroundColor3 = theme.ButtonBackground
                t.Button.TextColor3 = theme.Text
                t.Frame.Visible = false
            end
            TabButton:SetAttribute("active", true)
            TabButton.BackgroundColor3 = theme.Accent
            TabButton.TextColor3 = Color3.fromRGB(255,255,255)
            TabButtonStroke.Color = theme.Accent
            TabButtonStroke.Transparency = 0
            TabFrame.Visible = true
        end

        local TabObj = {}

        function TabObj:NewSection(sectionName)
            local Section = Instance.new("Frame")
            Section.Size = UDim2.new(1, -10, 0, 50)
            Section.BackgroundColor3 = theme.SectionBackground
            Section.Parent = TabFrame
            Section.AutomaticSize = Enum.AutomaticSize.Y
            Section.Name = "_section"

            local SectionCorner = Instance.new("UICorner")
            SectionCorner.CornerRadius = UDim.new(0, 10)
            SectionCorner.Parent = Section

            local SectionStroke = Instance.new("UIStroke")
            SectionStroke.Color = theme.ButtonBorder
            SectionStroke.Thickness = 1
            SectionStroke.Transparency = 0.8
            SectionStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            SectionStroke.Parent = Section

            local SectionLayout = Instance.new("UIListLayout")
            SectionLayout.SortOrder = Enum.SortOrder.LayoutOrder
            SectionLayout.Padding = UDim.new(0, 8)
            SectionLayout.Parent = Section

            local SectionPadding = Instance.new("UIPadding")
            SectionPadding.PaddingTop = UDim.new(0, 12)
            SectionPadding.PaddingBottom = UDim.new(0, 12)
            SectionPadding.PaddingLeft = UDim.new(0, 12)
            SectionPadding.PaddingRight = UDim.new(0, 12)
            SectionPadding.Parent = Section

            local Label = Instance.new("TextLabel")
            Label.Text = sectionName
            Label.Size = UDim2.new(1, 0, 0, 20)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = theme.SubText
            Label.Font = Enum.Font.GothamBold
            Label.TextSize = 14
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Section

            local SectionObj = {}

            function SectionObj:NewLabel(text)
                local lbl = Instance.new("TextLabel")
                lbl.Text = text or ""
                lbl.Size = UDim2.new(1, 0, 0, 18)
                lbl.BackgroundTransparency = 1
                lbl.TextColor3 = theme.Text
                lbl.Font = Enum.Font.Gotham
                lbl.TextSize = 13
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Parent = Section
                return lbl
            end

            function SectionObj:NewSeparator()
                local sep = Instance.new("Frame")
                sep.Size = UDim2.new(1, 0, 0, 10)
                sep.BackgroundTransparency = 1
                sep.Parent = Section
                
                local line = Instance.new("Frame")
                line.Size = UDim2.new(1, -8, 0, 1)
                line.Position = UDim2.new(0, 4, 0, 5)
                line.BackgroundColor3 = theme.ButtonBorder
                line.BackgroundTransparency = 0.7
                line.BorderSizePixel = 0
                line.Parent = sep
                
                return line
            end

            -- Inject UI Elements
            if Kour6anHub.Elements then
                Kour6anHub.Elements.Inject(SectionObj, Section, {
                    theme = theme,
                    tween = tween,
                    debouncedHover = debouncedHover,
                    safeCallback = safeCallback,
                    globalConnTracker = globalConnTracker,
                    UserInputService = UserInputService,
                    getArrowChar = getArrowChar,
                    roundValue = roundValue,
                    Window = Window,
                    addShadow = addShadow,
                    Players = Players,
                    GRADIENT_IMAGE = GRADIENT_IMAGE
                })
            else
                warn("[Kour6anHub] Elements module not loaded! UI components will be missing.")
            end

            return SectionObj
        end

        return TabObj
    end

    Window:SetTheme(themeName or "Modern")

    -- Periodic maintenance
    local MAINTENANCE_INTERVAL = 5
    local accumDt = 0
    local maintConn = RunService.Heartbeat:Connect(function(dt)
        accumDt = accumDt + dt
        if accumDt >= MAINTENANCE_INTERVAL then
            accumDt = 0
            for obj, props in pairs(ActiveTweens) do
                if not obj or (type(obj) == "userdata" and not pcall(function() return obj.Parent end)) then
                    ActiveTweens[obj] = nil
                else
                    if type(props) == "table" and next(props) == nil then
                        ActiveTweens[obj] = nil
                    end
                end
            end
            for t,_ in pairs(_tweenTimestamps) do
                if _tweenTimestamps[t] and (tick() - _tweenTimestamps[t]) > 30 then
                    _tweenTimestamps[t] = nil
                end
            end
        end
    end)

    Window._maintConn = maintConn

    -- Window controls setup
    Window._minimizeBtn = MinimizeBtn
    Window._closeBtn = CloseBtn
    Window._topbar = Topbar
    Window._title = Title

    local minimizeConn = MinimizeBtn.MouseButton1Click:Connect(function()
        pcall(function()
            Window:ToggleMinimize()
        end)
    end)
    globalConnTracker:add(minimizeConn)

    local closeConn = CloseBtn.MouseButton1Click:Connect(function()
        local pressTween = tween(CloseBtn, {
            Size = UDim2.new(0, 32, 0, 32),
            BackgroundColor3 = Color3.fromRGB(200, 35, 51)
        }, {duration = 0.08})
        
        if pressTween then
            local conn
            conn = pressTween.Completed:Connect(function()
                pcall(function() conn:Disconnect() end)
                Window:Destroy()
            end)
        else
            task.delay(0.08, function()
                Window:Destroy()
            end)
        end
    end)
    globalConnTracker:add(closeConn)

    debouncedHover(MinimizeBtn,
        function()
            tween(MinimizeBtn, {
                BackgroundColor3 = theme.ButtonHover
            }, {duration = 0.1})
            tween(MinimizeBtnStroke, {Transparency = 0.5}, {duration = 0.1})
        end,
        function()
            tween(MinimizeBtn, {
                BackgroundColor3 = theme.ButtonBackground
            }, {duration = 0.1})
            tween(MinimizeBtnStroke, {Transparency = 0.7}, {duration = 0.1})
        end
    )

    debouncedHover(CloseBtn,
        function()
            tween(CloseBtn, {
                BackgroundColor3 = Color3.fromRGB(240, 73, 89)
            }, {duration = 0.1})
        end,
        function()
            tween(CloseBtn, {
                BackgroundColor3 = Color3.fromRGB(220, 53, 69)
            }, {duration = 0.1})
        end
    )

    Window:SetToggleKey(Enum.KeyCode.RightControl)

    return Window
end

return Kour6anHub
