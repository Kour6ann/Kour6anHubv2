local Elements = {}

function Elements.Inject(SectionObj, Section, env)
    local theme = env.theme
    local tween = env.tween
    local debouncedHover = env.debouncedHover
    local safeCallback = env.safeCallback
    local globalConnTracker = env.globalConnTracker
    local UserInputService = env.UserInputService
    local getArrowChar = env.getArrowChar
    local roundValue = env.roundValue
    local Window = env.Window
    local addShadow = env.addShadow
    local Players = env.Players
    local GRADIENT_IMAGE = env.GRADIENT_IMAGE

            function SectionObj:NewButton(text, desc, callback)
                if type(text) ~= "string" then text = tostring(text or "Button") end
                if callback ~= nil and type(callback) ~= "function" then 
                    warn("NewButton: callback is not a function") 
                end

                local Btn = Instance.new("TextButton")
                Btn.Text = text
                Btn.Size = UDim2.new(1, 0, 0, 36)
                Btn.BackgroundColor3 = theme.ButtonBackground
                Btn.TextColor3 = theme.Text
                Btn.Font = Enum.Font.Gotham
                Btn.TextSize = 13
                Btn.AutoButtonColor = false
                Btn.Parent = Section

                local BtnCorner = Instance.new("UICorner")
                BtnCorner.CornerRadius = UDim.new(0, 8)
                BtnCorner.Parent = Btn

                local BtnStroke = Instance.new("UIStroke")
                BtnStroke.Color = theme.ButtonBorder
                BtnStroke.Thickness = 1
                BtnStroke.Transparency = 0.7
                BtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                BtnStroke.Parent = Btn

                debouncedHover(Btn,
                    function()
                        tween(Btn, {
                            BackgroundColor3 = theme.ButtonHover
                        }, {duration = 0.1})
                        tween(BtnStroke, {Transparency = 0.5}, {duration = 0.1})
                    end,
                    function()
                        tween(Btn, {
                            BackgroundColor3 = theme.ButtonBackground
                        }, {duration = 0.1})
                        tween(BtnStroke, {Transparency = 0.7}, {duration = 0.1})
                    end
                )

                Btn.MouseButton1Click:Connect(function()
                    local t1 = tween(Btn, {
                        BackgroundColor3 = theme.Accent
                    }, {duration = 0.08})
                    tween(BtnStroke, {
                        Color = theme.Accent, 
                        Transparency = 0
                    }, {duration = 0.08})
                    tween(Btn, {TextColor3 = Color3.fromRGB(255,255,255)}, {duration = 0.08})
                    
                    if t1 then
                        local c
                        c = t1.Completed:Connect(function()
                            pcall(function() c:Disconnect() end)
                            tween(Btn, {
                                BackgroundColor3 = theme.ButtonBackground
                            }, {duration = 0.15})
                            tween(BtnStroke, {
                                Color = theme.ButtonBorder, 
                                Transparency = 0.7
                            }, {duration = 0.15})
                            tween(Btn, {TextColor3 = theme.Text}, {duration = 0.15})
                        end)
                    else
                        task.delay(0.09, function() 
                            tween(Btn, {
                                BackgroundColor3 = theme.ButtonBackground
                            }, {duration = 0.15})
                            tween(BtnStroke, {
                                Color = theme.ButtonBorder, 
                                Transparency = 0.7
                            }, {duration = 0.15})
                            tween(Btn, {TextColor3 = theme.Text}, {duration = 0.15})
                        end)
                    end
                    safeCallback(callback)
                end)

                return Btn
            end

            function SectionObj:NewToggle(text, desc, default, callback)
                if type(text) ~= "string" then text = tostring(text or "Toggle") end
                if callback ~= nil and type(callback) ~= "function" then 
                    warn("NewToggle: callback is not a function") 
                end

                local state = default == true

                local ToggleBtn = Instance.new("TextButton")
                ToggleBtn.Text = text .. (state and " [ON]" or " [OFF]")
                ToggleBtn.Size = UDim2.new(1, 0, 0, 36)
                ToggleBtn.BackgroundColor3 = state and theme.Accent or theme.ButtonBackground
                ToggleBtn.TextColor3 = state and Color3.fromRGB(255,255,255) or theme.Text
                ToggleBtn.Font = Enum.Font.Gotham
                ToggleBtn.TextSize = 13
                ToggleBtn.AutoButtonColor = false
                ToggleBtn.Parent = Section

                local ToggleCorner = Instance.new("UICorner")
                ToggleCorner.CornerRadius = UDim.new(0, 8)
                ToggleCorner.Parent = ToggleBtn

                local ToggleStroke = Instance.new("UIStroke")
                ToggleStroke.Color = state and theme.Accent or theme.ButtonBorder
                ToggleStroke.Thickness = 1
                ToggleStroke.Transparency = state and 0 or 0.7
                ToggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                ToggleStroke.Parent = ToggleBtn

                ToggleBtn:SetAttribute("_isToggleState", true)
                ToggleBtn:SetAttribute("_toggle", state)

                debouncedHover(ToggleBtn,
                    function()
                        if not state then
                            tween(ToggleBtn, {
                                BackgroundColor3 = theme.ButtonHover
                            }, {duration = 0.1})
                            tween(ToggleStroke, {Transparency = 0.5}, {duration = 0.1})
                        end
                    end,
                    function()
                        if not state then
                            tween(ToggleBtn, {
                                BackgroundColor3 = theme.ButtonBackground
                            }, {duration = 0.1})
                            tween(ToggleStroke, {Transparency = 0.7}, {duration = 0.1})
                        end
                    end
                )

                ToggleBtn.MouseButton1Click:Connect(function()
                    state = not state
                    ToggleBtn.Text = text .. (state and " [ON]" or " [OFF]")
                    
                    if state then
                        tween(ToggleBtn, {BackgroundColor3 = theme.Accent}, {duration = 0.15})
                        tween(ToggleBtn, {TextColor3 = Color3.fromRGB(255,255,255)}, {duration = 0.15})
                        tween(ToggleStroke, {
                            Color = theme.Accent, 
                            Transparency = 0
                        }, {duration = 0.15})
                    else
                        tween(ToggleBtn, {BackgroundColor3 = theme.ButtonBackground}, {duration = 0.15})
                        tween(ToggleBtn, {TextColor3 = theme.Text}, {duration = 0.15})
                        tween(ToggleStroke, {
                            Color = theme.ButtonBorder, 
                            Transparency = 0.7
                        }, {duration = 0.15})
                    end
                    
                    ToggleBtn:SetAttribute("_toggle", state)
                    safeCallback(callback, state)
                end)

                return {
                    Button = ToggleBtn,
                    GetState = function() return state end,
                    SetState = function(_, v)
                        state = not not v
                        ToggleBtn.Text = text .. (state and " [ON]" or " [OFF]")
                        
                        if state then
                            ToggleBtn.BackgroundColor3 = theme.Accent
                            ToggleBtn.TextColor3 = Color3.fromRGB(255,255,255)
                            ToggleStroke.Color = theme.Accent
                            ToggleStroke.Transparency = 0
                        else
                            ToggleBtn.BackgroundColor3 = theme.ButtonBackground
                            ToggleBtn.TextColor3 = theme.Text
                            ToggleStroke.Color = theme.ButtonBorder
                            ToggleStroke.Transparency = 0.7
                        end
                        
                        ToggleBtn:SetAttribute("_toggle", state)
                        safeCallback(callback, state)
                    end
                }
            end

            function SectionObj:NewSlider(text, min, max, default, callback)
                if type(min) ~= "number" then min = 0 end
                if type(max) ~= "number" then max = 100 end
                if min > max then local t = min; min = max; max = t end
                if default == nil then default = min end
                if type(default) ~= "number" then default = tonumber(default) or min end
                if default < min then default = min end
                if default > max then default = max end

                local currentValue = default
                local precision = 0
                
                local range = max - min
                if range <= 1 then
                    precision = 2
                elseif range <= 10 then
                    precision = 1
                else
                    precision = 0
                end

                local function roundValue(value)
                    local mult = 10 ^ precision
                    return math.floor(value * mult + 0.5) / mult
                end

                local wrap = Instance.new("Frame")
                wrap.Size = UDim2.new(1, 0, 0, 64)
                wrap.BackgroundTransparency = 1
                wrap.Parent = Section

                local lbl = Instance.new("TextLabel")
                lbl.Text = text
                lbl.Size = UDim2.new(0.7, -8, 0, 20)
                lbl.Position = UDim2.new(0, 0, 0, 0)
                lbl.BackgroundTransparency = 1
                lbl.TextColor3 = theme.SubText
                lbl.Font = Enum.Font.Gotham
                lbl.TextSize = 13
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Parent = wrap

                local valueLbl = Instance.new("TextLabel")
                valueLbl.Text = tostring(roundValue(currentValue))
                valueLbl.Size = UDim2.new(0.3, -8, 0, 20)
                valueLbl.Position = UDim2.new(0.7, 0, 0, 0)
                valueLbl.BackgroundTransparency = 1
                valueLbl.TextColor3 = theme.Accent
                valueLbl.Font = Enum.Font.GothamBold
                valueLbl.TextSize = 13
                valueLbl.TextXAlignment = Enum.TextXAlignment.Right
                valueLbl.Parent = wrap

                local sliderBg = Instance.new("Frame")
                sliderBg.Size = UDim2.new(1, -8, 0, 24)
                sliderBg.Position = UDim2.new(0, 4, 0, 36)
                sliderBg.BackgroundColor3 = theme.InputBackground
                sliderBg.Parent = wrap

                local bgCorner = Instance.new("UICorner")
                bgCorner.CornerRadius = UDim.new(0, 12)
                bgCorner.Parent = sliderBg

                local bgStroke = Instance.new("UIStroke")
                bgStroke.Color = theme.InputBorder
                bgStroke.Thickness = 1
                bgStroke.Transparency = 0.7
                bgStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                bgStroke.Parent = sliderBg

                local fill = Instance.new("Frame")
                local initialRel = 0
                if max > min then
                    initialRel = (currentValue - min) / (max - min)
                end
                fill.Size = UDim2.new(initialRel, 0, 1, 0)
                fill.BackgroundColor3 = theme.Accent
                fill.BorderSizePixel = 0
                fill.Parent = sliderBg
                fill.ZIndex = 2

                local fillCorner = Instance.new("UICorner")
                fillCorner.CornerRadius = UDim.new(0, 12)
                fillCorner.Parent = fill

                local knob = Instance.new("Frame")
                knob.Size = UDim2.new(0, 18, 0, 18)
                knob.Position = UDim2.new(initialRel, -9, 0.5, -9)
                knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
                knob.BorderSizePixel = 0
                knob.Parent = sliderBg
                knob.ZIndex = 3

                local knobCorner = Instance.new("UICorner")
                knobCorner.CornerRadius = UDim.new(1, 0)
                knobCorner.Parent = knob

                local knobStroke = Instance.new("UIStroke")
                knobStroke.Color = theme.Accent
                knobStroke.Thickness = 2
                knobStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                knobStroke.Parent = knob

                local dragging = false

                local function updateSlider(inputPos)
                    local relativeX = inputPos.X - sliderBg.AbsolutePosition.X
                    local relativePos = math.clamp(relativeX / sliderBg.AbsoluteSize.X, 0, 1)
                    
                    local newValue = min + (max - min) * relativePos
                    newValue = roundValue(newValue)
                    newValue = math.clamp(newValue, min, max)
                    currentValue = newValue

                    local finalRel = (max > min) and ((newValue - min) / (max - min)) or 0
                    tween(fill, {Size = UDim2.new(finalRel, 0, 1, 0)}, {duration = 0.05})
                    tween(knob, {Position = UDim2.new(finalRel, -9, 0.5, -9)}, {duration = 0.05})
                    valueLbl.Text = tostring(newValue)

                    if callback and type(callback) == "function" then
                        safeCallback(callback, newValue)
                    end
                end

                local beganConn = sliderBg.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or 
                       input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        updateSlider(input.Position)
                        
                        tween(knob, {
                            Size = UDim2.new(0, 22, 0, 22), 
                            Position = UDim2.new((max > min) and ((currentValue - min) / (max - min)) or 0, -11, 0.5, -11)
                        }, {duration = 0.1})
                        tween(knobStroke, {Thickness = 3}, {duration = 0.1})
                    end
                end)

                local changedConn = UserInputService.InputChanged:Connect(function(input)
                    if not dragging then return end
                    
                    if input.UserInputType == Enum.UserInputType.MouseMovement or
                       input.UserInputType == Enum.UserInputType.Touch then
                        updateSlider(input.Position)
                    end
                end)

                local endedConn = UserInputService.InputEnded:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or 
                                    input.UserInputType == Enum.UserInputType.Touch) then
                        dragging = false
                        
                        tween(knob, {
                            Size = UDim2.new(0, 18, 0, 18), 
                            Position = UDim2.new((max > min) and ((currentValue - min) / (max - min)) or 0, -9, 0.5, -9)
                        }, {duration = 0.1})
                        tween(knobStroke, {Thickness = 2}, {duration = 0.1})
                    end
                end)

                local hoverConn1 = sliderBg.MouseEnter:Connect(function()
                    if not dragging then
                        tween(bgStroke, {Transparency = 0.5}, {duration = 0.1})
                        tween(knobStroke, {Thickness = 3}, {duration = 0.1})
                    end
                end)

                local hoverConn2 = sliderBg.MouseLeave:Connect(function()
                    if not dragging then
                        tween(bgStroke, {Transparency = 0.7}, {duration = 0.1})
                        tween(knobStroke, {Thickness = 2}, {duration = 0.1})
                    end
                end)

                globalConnTracker:add(beganConn)
                globalConnTracker:add(changedConn) 
                globalConnTracker:add(endedConn)
                globalConnTracker:add(hoverConn1)
                globalConnTracker:add(hoverConn2)

                return {
                    Set = function(_, value)
                        if type(value) ~= "number" then
                            value = tonumber(value)
                            if not value then return end
                        end
                        
                        value = math.clamp(value, min, max)
                        currentValue = roundValue(value)
                        
                        local rel = (max > min) and ((currentValue - min) / (max - min)) or 0
                        fill.Size = UDim2.new(rel, 0, 1, 0)
                        knob.Position = UDim2.new(rel, -9, 0.5, -9)
                        valueLbl.Text = tostring(currentValue)
                        
                        if callback and type(callback) == "function" then
                            safeCallback(callback, currentValue)
                        end
                    end,
                    Get = function()
                        return currentValue
                    end,
                    SetMin = function(_, newMin)
                        min = newMin
                        if currentValue < min then
                            currentValue = min
                        end
                        local rel = (max > min) and ((currentValue - min) / (max - min)) or 0
                        fill.Size = UDim2.new(rel, 0, 1, 0)
                        knob.Position = UDim2.new(rel, -9, 0.5, -9)
                        valueLbl.Text = tostring(currentValue)
                    end,
                    SetMax = function(_, newMax)
                        max = newMax
                        if currentValue > max then
                            currentValue = max
                        end
                        local rel = (max > min) and ((currentValue - min) / (max - min)) or 0
                        fill.Size = UDim2.new(rel, 0, 1, 0)
                        knob.Position = UDim2.new(rel, -9, 0.5, -9)
                        valueLbl.Text = tostring(currentValue)
                    end
                }
            end

            function SectionObj:NewTextbox(placeholder, defaultText, callback)
                local wrap = Instance.new("Frame")
                wrap.Size = UDim2.new(1, 0, 0, 36)
                wrap.BackgroundTransparency = 1
                wrap.Parent = Section

                local box = Instance.new("TextBox")
                box.Size = UDim2.new(1, 0, 1, 0)
                box.BackgroundColor3 = theme.InputBackground
                box.TextColor3 = theme.Text
                box.PlaceholderColor3 = theme.SubText
                box.ClearTextOnFocus = false
                box.Text = defaultText or ""
                box.PlaceholderText = placeholder or ""
                box.Font = Enum.Font.Gotham
                box.TextSize = 13
                box.TextXAlignment = Enum.TextXAlignment.Left
                box.Parent = wrap

                local boxCorner = Instance.new("UICorner")
                boxCorner.CornerRadius = UDim.new(0, 8)
                boxCorner.Parent = box

                local boxStroke = Instance.new("UIStroke")
                boxStroke.Color = theme.InputBorder
                boxStroke.Thickness = 1
                boxStroke.Transparency = 0.7
                boxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                boxStroke.Parent = box

                local boxPadding = Instance.new("UIPadding")
                boxPadding.PaddingLeft = UDim.new(0, 10)
                boxPadding.PaddingRight = UDim.new(0, 10)
                boxPadding.Parent = box

                box.Focused:Connect(function()
                    tween(boxStroke, {
                        Color = theme.Accent, 
                        Transparency = 0
                    }, {duration = 0.15})
                end)

                box.FocusLost:Connect(function(enterPressed)
                    tween(boxStroke, {
                        Color = theme.InputBorder, 
                        Transparency = 0.7
                    }, {duration = 0.15})
                    
                    if enterPressed and type(callback) == "function" then
                        safeCallback(callback, box.Text)
                    end
                end)

                return {
                    TextBox = box,
                    Get = function() return box.Text end,
                    Set = function(_, v) box.Text = tostring(v) end,
                    Focus = function() box:CaptureFocus() end
                }
            end

            function SectionObj:NewKeybind(desc, defaultKey, callback)
                local wrap = Instance.new("Frame")
                wrap.Size = UDim2.new(1, 0, 0, 36)
                wrap.BackgroundTransparency = 1
                wrap.Parent = Section

                local btn = Instance.new("TextButton")
                local curKey = defaultKey and (tostring(defaultKey):gsub("^Enum.KeyCode%.","")) or "None"
                btn.Text = (desc and desc .. " : " or "") .. "[" .. curKey .. "]"
                btn.Size = UDim2.new(1, 0, 1, 0)
                btn.BackgroundColor3 = theme.InputBackground
                btn.TextColor3 = theme.Text
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 13
                btn.AutoButtonColor = false
                btn.Parent = wrap

                local btnCorner = Instance.new("UICorner")
                btnCorner.CornerRadius = UDim.new(0, 8)
                btnCorner.Parent = btn

                local btnStroke = Instance.new("UIStroke")
                btnStroke.Color = theme.InputBorder
                btnStroke.Thickness = 1
                btnStroke.Transparency = 0.7
                btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                btnStroke.Parent = btn

                local capturing = false
                local boundKey = defaultKey

                local function updateDisplay()
                    local kName = boundKey and (tostring(boundKey):gsub("^Enum.KeyCode%.","")) or "None"
                    btn.Text = (desc and desc .. " : " or "") .. "[" .. kName .. "]"
                end

                btn.MouseButton1Click:Connect(function()
                    capturing = true
                    btn.Text = (desc and desc .. " : " or "") .. "[Press a key...]"
                    tween(btnStroke, {
                        Color = theme.Accent, 
                        Transparency = 0
                    }, {duration = 0.15})
                end)

                local listenerConn
                listenerConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if gameProcessed then return end
                    if capturing then
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            if input.KeyCode == Enum.KeyCode.Escape then
                                capturing = false
                                updateDisplay()
                                tween(btnStroke, {
                                    Color = theme.InputBorder, 
                                    Transparency = 0.7
                                }, {duration = 0.15})
                            else
                                boundKey = input.KeyCode
                                capturing = false
                                updateDisplay()
                                tween(btnStroke, {
                                    Color = theme.InputBorder, 
                                    Transparency = 0.7
                                }, {duration = 0.15})
                            end
                        end
                        return
                    end

                    if boundKey and input.UserInputType == Enum.UserInputType.Keyboard and 
                       input.KeyCode == boundKey then
                        safeCallback(callback)
                    end
                end)

                globalConnTracker:add(listenerConn)

                return {
                    Button = btn,
                    GetKey = function() return boundKey end,
                    SetKey = function(_, k) boundKey = k; updateDisplay() end,
                    Disconnect = function() 
                        if listenerConn then 
                            pcall(function() listenerConn:Disconnect() end) 
                        end 
                    end
                }
            end

            function SectionObj:NewDropdown(name, options, default, callback)
                options = options or {}
                if type(options) ~= "table" then 
                    options = {} 
                end
                
                local validOptions = {}
                for _, opt in ipairs(options) do
                    if opt ~= nil then
                        table.insert(validOptions, tostring(opt))
                    end
                end
                options = validOptions
                
                local current = default and tostring(default) or (options[1] or nil)
                local open = false
                local optionsFrame = nil
                local scrollFrame = nil
                local optionButtons = {}
                local selectedIndex = nil
                
                if current then
                    for i, opt in ipairs(options) do
                        if tostring(opt) == current then
                            selectedIndex = i
                            break
                        end
                    end
                end

                local wrap = Instance.new("Frame")
                wrap.Size = UDim2.new(1, 0, 0, 36)
                wrap.BackgroundTransparency = 1
                wrap.AutomaticSize = Enum.AutomaticSize.Y
                wrap.ClipsDescendants = false
                wrap.Parent = Section

                local wrapList = Instance.new("UIListLayout")
                wrapList.SortOrder = Enum.SortOrder.LayoutOrder
                wrapList.Padding = UDim.new(0, 0)
                wrapList.Parent = wrap

                local btn = Instance.new("TextButton")
                local displayText = current or "Select..."
                btn.Text = (name and name .. ": " or "") .. displayText
                btn.Size = UDim2.new(1, 0, 0, 36)
                btn.BackgroundColor3 = theme.ButtonBackground
                btn.TextColor3 = theme.Text
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 13
                btn.AutoButtonColor = false
                btn.TextXAlignment = Enum.TextXAlignment.Left
                btn.LayoutOrder = 1
                btn.Parent = wrap

                local btnCorner = Instance.new("UICorner")
                btnCorner.CornerRadius = UDim.new(0, 8)
                btnCorner.Parent = btn

                local btnStroke = Instance.new("UIStroke")
                btnStroke.Color = theme.ButtonBorder
                btnStroke.Thickness = 1
                btnStroke.Transparency = 0.7
                btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                btnStroke.Parent = btn

                local btnPadding = Instance.new("UIPadding")
                btnPadding.PaddingLeft = UDim.new(0, 10)
                btnPadding.PaddingRight = UDim.new(0, 32)
                btnPadding.Parent = btn

                local arrow = Instance.new("TextLabel")
                arrow.Text = getArrowChar("down")
                arrow.Size = UDim2.new(0, 20, 1, 0)
                arrow.Position = UDim2.new(1, -24, 0, 0)
                arrow.BackgroundTransparency = 1
                arrow.TextColor3 = theme.SubText
                arrow.Font = Enum.Font.Gotham
                arrow.TextSize = 12
                arrow.TextXAlignment = Enum.TextXAlignment.Center
                arrow.Parent = btn

                local function getMaxDropdownHeight()
                    local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or 
                                     Vector2.new(800, 600)
                    return math.min(220, math.floor(viewport.Y * 0.3))
                end
                
                local function closeOptions()
                    if optionsFrame and optionsFrame.Parent and optionsFrame.Visible then
                        arrow.Text = getArrowChar("down")
                        tween(arrow, {Rotation = 0}, {duration = 0.15})
                        
                        local closeTween = tween(optionsFrame, {
                            Size = UDim2.new(1, 0, 0, 0),
                            BackgroundTransparency = 1
                        }, {duration = 0.15})
                        
                        if scrollFrame then
                            tween(scrollFrame, {ScrollBarImageTransparency = 1}, {duration = 0.1})
                        end
                        
                        for _, optBtn in pairs(optionButtons) do
                            if optBtn and optBtn.Parent then
                                tween(optBtn, {
                                    BackgroundTransparency = 1, 
                                    TextTransparency = 1
                                }, {duration = 0.1})
                            end
                        end
                        
                        if closeTween then
                            local conn
                            conn = closeTween.Completed:Connect(function()
                                pcall(function() conn:Disconnect() end)
                                if optionsFrame then optionsFrame.Visible = false end
                            end)
                        else
                            task.wait(0.15)
                            if optionsFrame then optionsFrame.Visible = false end
                        end
                    end
                    open = false
                    
                    if Window._currentOpenDropdown == closeOptions then
                        Window._currentOpenDropdown = nil
                    end
                end

                local function createOptionsFrame()
                    if optionsFrame then
                        pcall(function() optionsFrame:Destroy() end)
                    end
                    
                    optionsFrame = Instance.new("Frame")
                    optionsFrame.Name = "_dropdownOptions"
                    optionsFrame.BackgroundColor3 = theme.SectionBackground
                    optionsFrame.BorderSizePixel = 0
                    optionsFrame.Size = UDim2.new(1, 0, 0, 0)
                    optionsFrame.Visible = false
                    optionsFrame.ClipsDescendants = true
                    optionsFrame.ZIndex = 100
                    optionsFrame.LayoutOrder = 2
                    optionsFrame.Parent = wrap

                    local corner = Instance.new("UICorner")
                    corner.CornerRadius = UDim.new(0, 8)
                    corner.Parent = optionsFrame

                    local border = Instance.new("UIStroke")
                    border.Color = theme.ButtonBorder
                    border.Thickness = 1
                    border.Transparency = 0.7
                    border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    border.Parent = optionsFrame

                    scrollFrame = Instance.new("ScrollingFrame")
                    scrollFrame.Name = "_optionsScroll"
                    scrollFrame.Size = UDim2.new(1, -4, 1, -4)
                    scrollFrame.Position = UDim2.new(0, 2, 0, 2)
                    scrollFrame.BackgroundTransparency = 1
                    scrollFrame.BorderSizePixel = 0
                    scrollFrame.ScrollBarThickness = 4
                    scrollFrame.ScrollBarImageColor3 = theme.Accent
                    scrollFrame.ScrollBarImageTransparency = 0.3
                    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
                    scrollFrame.ZIndex = 101
                    scrollFrame.Parent = optionsFrame

                    return optionsFrame, scrollFrame
                end

                local function openOptions()
                    if #options == 0 then
                        Window:Notify("Dropdown Error", "No options available", 2)
                        return
                    end

                    if Window._currentOpenDropdown and Window._currentOpenDropdown ~= closeOptions then
                        pcall(function() Window._currentOpenDropdown() end)
                    end

                    createOptionsFrame()
                    open = true
                    arrow.Text = getArrowChar("up")
                    tween(arrow, {Rotation = 180}, {duration = 0.15})

                    optionButtons = {}

                    local itemHeight = 32
                    local maxHeight = getMaxDropdownHeight()
                    local totalContentHeight = #options * itemHeight
                    local frameHeight = math.min(maxHeight, totalContentHeight)

                    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalContentHeight)

                    for i, opt in ipairs(options) do
                        local optBtn = Instance.new("TextButton")
                        optBtn.Size = UDim2.new(1, -8, 0, itemHeight - 4)
                        optBtn.Position = UDim2.new(0, 4, 0, (i-1) * itemHeight + 2)
                        optBtn.BackgroundColor3 = theme.ButtonBackground
                        optBtn.Font = Enum.Font.Gotham
                        optBtn.TextSize = 12
                        optBtn.TextColor3 = theme.Text
                        optBtn.AutoButtonColor = false
                        optBtn.Text = tostring(opt)
                        optBtn.TextXAlignment = Enum.TextXAlignment.Left
                        optBtn.BackgroundTransparency = 1
                        optBtn.TextTransparency = 1
                        optBtn.ZIndex = 102
                        optBtn.Parent = scrollFrame

                        local optCorner = Instance.new("UICorner")
                        optCorner.CornerRadius = UDim.new(0, 6)
                        optCorner.Parent = optBtn

                        local optPadding = Instance.new("UIPadding")
                        optPadding.PaddingLeft = UDim.new(0, 10)
                        optPadding.PaddingRight = UDim.new(0, 10)
                        optPadding.Parent = optBtn

                        if current and tostring(opt) == tostring(current) then
                            selectedIndex = i
                            optBtn.BackgroundColor3 = theme.Accent
                            optBtn.TextColor3 = Color3.fromRGB(255,255,255)
                        end

                        local hoverConn1 = optBtn.MouseEnter:Connect(function()
                            if selectedIndex ~= i then
                                tween(optBtn, {
                                    BackgroundColor3 = theme.ButtonHover
                                }, {duration = 0.1})
                            end
                        end)

                        local hoverConn2 = optBtn.MouseLeave:Connect(function()
                            if selectedIndex ~= i then
                                tween(optBtn, {
                                    BackgroundColor3 = theme.ButtonBackground
                                }, {duration = 0.1})
                            end
                        end)

                        local clickConn = optBtn.MouseButton1Click:Connect(function()
                            selectedIndex = i
                            current = options[i]
                            btn.Text = (name and name .. ": " or "") .. tostring(current)
                            
                            for idx, button in pairs(optionButtons) do
                                if button and button.Parent then
                                    if idx == selectedIndex then
                                        tween(button, {
                                            BackgroundColor3 = theme.Accent
                                        }, {duration = 0.15})
                                        button.TextColor3 = Color3.fromRGB(255,255,255)
                                    else
                                        tween(button, {
                                            BackgroundColor3 = theme.ButtonBackground
                                        }, {duration = 0.15})
                                        button.TextColor3 = theme.Text
                                    end
                                end
                            end
                            
                            if callback and type(callback) == "function" then
                                safeCallback(callback, current)
                            end
                            
                            task.wait(0.1)
                            closeOptions()
                        end)

                        optionButtons[i] = optBtn
                    end

                    optionsFrame.Visible = true
                    optionsFrame.BackgroundTransparency = 1
                    scrollFrame.ScrollBarImageTransparency = 1

                    tween(optionsFrame, {
                        Size = UDim2.new(1, 0, 0, frameHeight + 4),
                        BackgroundTransparency = 0
                    }, {duration = 0.18})

                    tween(scrollFrame, {ScrollBarImageTransparency = 0.3}, {duration = 0.18})

                    for i, optBtn in pairs(optionButtons) do
                        task.delay(i * 0.02, function()
                            if optBtn and optBtn.Parent then
                                tween(optBtn, {
                                    BackgroundTransparency = 0,
                                    TextTransparency = 0
                                }, {duration = 0.12})
                            end
                        end)
                    end
                    Window._currentOpenDropdown = closeOptions
                end

                btn.MouseButton1Click:Connect(function()
                    if open then
                        closeOptions()
                    else
                        openOptions()
                    end
                end)

                debouncedHover(btn,
                    function()
                        if not open then
                            tween(btnStroke, {Transparency = 0.5}, {duration = 0.1})
                        end
                    end,
                    function()
                        if not open then
                            tween(btnStroke, {Transparency = 0.7}, {duration = 0.1})
                        end
                    end
                )

                local outsideClickConn
                outsideClickConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if gameProcessed or not open then return end
                    
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local mouse = UserInputService:GetMouseLocation()
                        local wrapPos = wrap.AbsolutePosition
                        local wrapSize = wrap.AbsoluteSize
                        
                        if mouse.X < wrapPos.X or mouse.X > wrapPos.X + wrapSize.X or
                           mouse.Y < wrapPos.Y or mouse.Y > wrapPos.Y + wrapSize.Y then
                            closeOptions()
                        end
                    end
                end)

                globalConnTracker:add(outsideClickConn)

                local ancestryConn
                ancestryConn = wrap.AncestryChanged:Connect(function()
                    if not wrap.Parent then
                        pcall(function() 
                            outsideClickConn:Disconnect()
                            ancestryConn:Disconnect()
                        end)
                    end
                end)
                globalConnTracker:add(ancestryConn)

                return {
                    Set = function(_, value)
                        local stringValue = tostring(value)
                        for i, opt in ipairs(options) do
                            if tostring(opt) == stringValue then
                                current = stringValue
                                selectedIndex = i
                                btn.Text = (name and name .. ": " or "") .. stringValue
                                if callback and type(callback) == "function" then
                                    safeCallback(callback, stringValue)
                                end
                                return true
                            end
                        end
                        current = stringValue
                        btn.Text = (name and name .. ": " or "") .. stringValue
                        if callback and type(callback) == "function" then
                            safeCallback(callback, stringValue)
                        end
                        return false
                    end,
                    Get = function()
                        return current
                    end,
                    SetOptions = function(_, newOptions)
                        newOptions = newOptions or {}
                        if type(newOptions) ~= "table" then
                            newOptions = {}
                        end
                        
                        local validNewOptions = {}
                        for _, opt in ipairs(newOptions) do
                            if opt ~= nil then
                                table.insert(validNewOptions, tostring(opt))
                            end
                        end
                        options = validNewOptions
                        
                        if #options > 0 then
                            current = options[1]
                            selectedIndex = 1
                            btn.Text = (name and name .. ": " or "") .. tostring(current)
                        else
                            current = nil
                            selectedIndex = nil
                            btn.Text = (name and name .. ": " or "") .. "Select..."
                        end
                        closeOptions()
                    end,
                    Close = closeOptions
                }
            end

            function SectionObj:NewMultiDropdown(name, options, defaults, callback)
                options = options or {}
                if type(options) ~= "table" then 
                    options = {} 
                end
                
                local validOptions = {}
                for i, opt in ipairs(options) do
                    if opt ~= nil then
                        validOptions[i] = tostring(opt)
                    end
                end
                options = validOptions
                
                -- Initialize selected items
                local selected = {}
                if defaults and type(defaults) == "table" then
                    for _, v in ipairs(defaults) do
                        selected[tostring(v)] = true
                    end
                end
                
                local open = false
                local optionsFrame = nil
                local scrollFrame = nil
                local optionButtons = {}

                local wrap = Instance.new("Frame")
                wrap.Size = UDim2.new(1, 0, 0, 36)
                wrap.BackgroundTransparency = 1
                wrap.AutomaticSize = Enum.AutomaticSize.Y
                wrap.ClipsDescendants = false
                wrap.Parent = Section

                local wrapList = Instance.new("UIListLayout")
                wrapList.SortOrder = Enum.SortOrder.LayoutOrder
                wrapList.Padding = UDim.new(0, 0)
                wrapList.Parent = wrap

                local function getDisplayText()
                    local selectedList = {}
                    for opt, isSelected in pairs(selected) do
                        if isSelected then
                            table.insert(selectedList, opt)
                        end
                    end
                    
                    table.sort(selectedList)
                    if #selectedList == 0 then
                        return "Select..."
                    elseif #selectedList == 1 then
                        return selectedList[1]
                    elseif #selectedList <= 3 then
                        return table.concat(selectedList, ", ")
                    else
                        return selectedList[1] .. ", " .. selectedList[2] .. " (+" .. (#selectedList - 2) .. " more)"
                    end
                end

                local btn = Instance.new("TextButton")
                btn.Text = (name and name .. ": " or "") .. getDisplayText()
                btn.Size = UDim2.new(1, 0, 0, 36)
                btn.BackgroundColor3 = theme.ButtonBackground
                btn.TextColor3 = theme.Text
                btn.Font = Enum.Font.Gotham
                btn.TextSize = 13
                btn.AutoButtonColor = false
                btn.TextXAlignment = Enum.TextXAlignment.Left
                btn.LayoutOrder = 1
                btn.Parent = wrap

                local btnCorner = Instance.new("UICorner")
                btnCorner.CornerRadius = UDim.new(0, 8)
                btnCorner.Parent = btn

                local btnStroke = Instance.new("UIStroke")
                btnStroke.Color = theme.ButtonBorder
                btnStroke.Thickness = 1
                btnStroke.Transparency = 0.7
                btnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                btnStroke.Parent = btn

                local btnPadding = Instance.new("UIPadding")
                btnPadding.PaddingLeft = UDim.new(0, 10)
                btnPadding.PaddingRight = UDim.new(0, 32)
                btnPadding.Parent = btn

                local arrow = Instance.new("TextLabel")
                arrow.Text = getArrowChar("down")
                arrow.Size = UDim2.new(0, 20, 1, 0)
                arrow.Position = UDim2.new(1, -24, 0, 0)
                arrow.BackgroundTransparency = 1
                arrow.TextColor3 = theme.SubText
                arrow.Font = Enum.Font.Gotham
                arrow.TextSize = 12
                arrow.TextXAlignment = Enum.TextXAlignment.Center
                arrow.Parent = btn

                local function getMaxDropdownHeight()
                    local viewport = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or 
                                     Vector2.new(800, 600)
                    return math.min(220, math.floor(viewport.Y * 0.3))
                end
                
                local function closeOptions()
                    if optionsFrame and optionsFrame.Parent and optionsFrame.Visible then
                        arrow.Text = getArrowChar("down")
                        tween(arrow, {Rotation = 0}, {duration = 0.15})
                        
                        local closeTween = tween(optionsFrame, {
                            Size = UDim2.new(1, 0, 0, 0),
                            BackgroundTransparency = 1
                        }, {duration = 0.15})
                        
                        if scrollFrame then
                            tween(scrollFrame, {ScrollBarImageTransparency = 1}, {duration = 0.1})
                        end
                        
                        for _, optBtn in pairs(optionButtons) do
                            if optBtn and optBtn.Parent then
                                tween(optBtn, {
                                    BackgroundTransparency = 1, 
                                    TextTransparency = 1
                                }, {duration = 0.1})
                            end
                        end
                        
                        if closeTween then
                            local conn
                            conn = closeTween.Completed:Connect(function()
                                pcall(function() conn:Disconnect() end)
                                if optionsFrame then optionsFrame.Visible = false end
                            end)
                        else
                            task.wait(0.15)
                            if optionsFrame then optionsFrame.Visible = false end
                        end
                    end
                    open = false
                    
                    if Window._currentOpenDropdown == closeOptions then
                        Window._currentOpenDropdown = nil
                    end
                end

                local function createOptionsFrame()
                    if optionsFrame then
                        pcall(function() optionsFrame:Destroy() end)
                    end
                    
                    optionsFrame = Instance.new("Frame")
                    optionsFrame.Name = "_dropdownOptions"
                    optionsFrame.BackgroundColor3 = theme.SectionBackground
                    optionsFrame.BorderSizePixel = 0
                    optionsFrame.Size = UDim2.new(1, 0, 0, 0)
                    optionsFrame.Visible = false
                    optionsFrame.ClipsDescendants = true
                    optionsFrame.ZIndex = 100
                    optionsFrame.LayoutOrder = 2
                    optionsFrame.Parent = wrap

                    local corner = Instance.new("UICorner")
                    corner.CornerRadius = UDim.new(0, 8)
                    corner.Parent = optionsFrame

                    local border = Instance.new("UIStroke")
                    border.Color = theme.ButtonBorder
                    border.Thickness = 1
                    border.Transparency = 0.7
                    border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    border.Parent = optionsFrame

                    scrollFrame = Instance.new("ScrollingFrame")
                    scrollFrame.Name = "_optionsScroll"
                    scrollFrame.Size = UDim2.new(1, -4, 1, -4)
                    scrollFrame.Position = UDim2.new(0, 2, 0, 2)
                    scrollFrame.BackgroundTransparency = 1
                    scrollFrame.BorderSizePixel = 0
                    scrollFrame.ScrollBarThickness = 4
                    scrollFrame.ScrollBarImageColor3 = theme.Accent
                    scrollFrame.ScrollBarImageTransparency = 0.3
                    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
                    scrollFrame.ZIndex = 101
                    scrollFrame.Parent = optionsFrame

                    return optionsFrame, scrollFrame
                end

                local function openOptions()
                    if #options == 0 then
                        Window:Notify("Dropdown Error", "No options available", 2)
                        return
                    end

                    if Window._currentOpenDropdown and Window._currentOpenDropdown ~= closeOptions then
                        pcall(function() Window._currentOpenDropdown() end)
                    end

                    createOptionsFrame()
                    open = true
                    arrow.Text = getArrowChar("up")
                    tween(arrow, {Rotation = 180}, {duration = 0.15})

                    optionButtons = {}

                    local itemHeight = 32
                    local maxHeight = getMaxDropdownHeight()
                    local totalContentHeight = #options * itemHeight
                    local frameHeight = math.min(maxHeight, totalContentHeight)

                    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalContentHeight)

                    for i, opt in ipairs(options) do
                        local optBtn = Instance.new("TextButton")
                        optBtn.Size = UDim2.new(1, -8, 0, itemHeight - 4)
                        optBtn.Position = UDim2.new(0, 4, 0, (i-1) * itemHeight + 2)
                        optBtn.BackgroundColor3 = theme.ButtonBackground
                        optBtn.Font = Enum.Font.Gotham
                        optBtn.TextSize = 12
                        optBtn.TextColor3 = theme.Text
                        optBtn.AutoButtonColor = false
                        optBtn.Text = tostring(opt)
                        optBtn.TextXAlignment = Enum.TextXAlignment.Left
                        optBtn.BackgroundTransparency = 1
                        optBtn.TextTransparency = 1
                        optBtn.ZIndex = 102
                        optBtn.Parent = scrollFrame

                        local optCorner = Instance.new("UICorner")
                        optCorner.CornerRadius = UDim.new(0, 6)
                        optCorner.Parent = optBtn

                        local optPadding = Instance.new("UIPadding")
                        optPadding.PaddingLeft = UDim.new(0, 10)
                        optPadding.PaddingRight = UDim.new(0, 30)
                        optPadding.Parent = optBtn

                        -- Checkbox indicator - FIXED CHECKMARK
                        local checkbox = Instance.new("TextLabel")
                        checkbox.Size = UDim2.new(0, 18, 0, 18)
                        checkbox.Position = UDim2.new(1, -22, 0.5, -9)
                        checkbox.BackgroundColor3 = theme.InputBackground
                        checkbox.TextColor3 = theme.Accent
                        checkbox.Font = Enum.Font.GothamBold
                        checkbox.TextSize = 14
                        checkbox.Text = selected[tostring(opt)] and "✓" or ""  -- FIXED: Proper checkmark (U+2713)
                        checkbox.ZIndex = 103
                        checkbox.Parent = optBtn

                        local checkCorner = Instance.new("UICorner")
                        checkCorner.CornerRadius = UDim.new(0, 4)
                        checkCorner.Parent = checkbox

                        local checkStroke = Instance.new("UIStroke")
                        checkStroke.Color = selected[tostring(opt)] and theme.Accent or theme.InputBorder
                        checkStroke.Thickness = 1
                        checkStroke.Transparency = 0.7
                        checkStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                        checkStroke.Parent = checkbox

                        if selected[tostring(opt)] then
                            optBtn.BackgroundColor3 = theme.ButtonHover
                        end

                        local hoverConn1 = optBtn.MouseEnter:Connect(function()
                            tween(optBtn, {
                                BackgroundColor3 = theme.ButtonHover
                            }, {duration = 0.1})
                        end)

                        local hoverConn2 = optBtn.MouseLeave:Connect(function()
                            if selected[tostring(opt)] then
                                tween(optBtn, {
                                    BackgroundColor3 = theme.ButtonHover
                                }, {duration = 0.1})
                            else
                                tween(optBtn, {
                                    BackgroundColor3 = theme.ButtonBackground
                                }, {duration = 0.1})
                            end
                        end)

                        local clickConn = optBtn.MouseButton1Click:Connect(function()
                            -- Toggle selection
                            selected[tostring(opt)] = not selected[tostring(opt)]
                            
                            if selected[tostring(opt)] then
                                checkbox.Text = "✓"
                                tween(checkbox, {BackgroundColor3 = theme.Accent}, {duration = 0.15})
                                tween(checkStroke, {
                                    Color = theme.Accent, 
                                    Transparency = 0
                                }, {duration = 0.15})
                                tween(optBtn, {
                                    BackgroundColor3 = theme.ButtonHover
                                }, {duration = 0.15})
                            else
                                checkbox.Text = ""
                                tween(checkbox, {BackgroundColor3 = theme.InputBackground}, {duration = 0.15})
                                tween(checkStroke, {
                                    Color = theme.InputBorder, 
                                    Transparency = 0.7
                                }, {duration = 0.15})
                                tween(optBtn, {
                                    BackgroundColor3 = theme.ButtonBackground
                                }, {duration = 0.15})
                            end
                            
                            -- Update button text
                            btn.Text = (name and name .. ": " or "") .. getDisplayText()
                            
                            -- Call callback with selected items
                            if callback and type(callback) == "function" then
                                local selectedList = {}
                                for o, isSelected in pairs(selected) do
                                    if isSelected then
                                        table.insert(selectedList, o)
                                    end
                                end
                                safeCallback(callback, selectedList)
                            end
                        end)

                        optionButtons[i] = optBtn
                    end

                    optionsFrame.Visible = true
                    optionsFrame.BackgroundTransparency = 1
                    scrollFrame.ScrollBarImageTransparency = 1

                    tween(optionsFrame, {
                        Size = UDim2.new(1, 0, 0, frameHeight + 4),
                        BackgroundTransparency = 0
                    }, {duration = 0.18})

                    tween(scrollFrame, {ScrollBarImageTransparency = 0.3}, {duration = 0.18})

                    for i, optBtn in pairs(optionButtons) do
                        task.delay(i * 0.02, function()
                            if optBtn and optBtn.Parent then
                                tween(optBtn, {
                                    BackgroundTransparency = 0,
                                    TextTransparency = 0
                                }, {duration = 0.12})
                            end
                        end)
                    end
                    Window._currentOpenDropdown = closeOptions
                end

                btn.MouseButton1Click:Connect(function()
                    if open then
                        closeOptions()
                    else
                        openOptions()
                    end
                end)

                debouncedHover(btn,
                    function()
                        if not open then
                            tween(btnStroke, {Transparency = 0.5}, {duration = 0.1})
                        end
                    end,
                    function()
                        if not open then
                            tween(btnStroke, {Transparency = 0.7}, {duration = 0.1})
                        end
                    end
                )

                local outsideClickConn
                outsideClickConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
                    if gameProcessed or not open then return end
                    
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        local mouse = UserInputService:GetMouseLocation()
                        local wrapPos = wrap.AbsolutePosition
                        local wrapSize = wrap.AbsoluteSize
                        
                        if mouse.X < wrapPos.X or mouse.X > wrapPos.X + wrapSize.X or
                           mouse.Y < wrapPos.Y or mouse.Y > wrapPos.Y + wrapSize.Y then
                            closeOptions()
                        end
                    end
                end)

                globalConnTracker:add(outsideClickConn)

                local ancestryConn
                ancestryConn = wrap.AncestryChanged:Connect(function()
                    if not wrap.Parent then
                        pcall(function() 
                            outsideClickConn:Disconnect()
                            ancestryConn:Disconnect()
                        end)
                    end
                end)
                globalConnTracker:add(ancestryConn)

                return {
                    Set = function(_, values)
                        if type(values) ~= "table" then
                            values = {values}
                        end
                        
                        selected = {}
                        for _, v in ipairs(values) do
                            selected[tostring(v)] = true
                        end
                        
                        btn.Text = (name and name .. ": " or "") .. getDisplayText()
                        
                        if callback and type(callback) == "function" then
                            local selectedList = {}
                            for o, isSelected in pairs(selected) do
                                if isSelected then
                                    table.insert(selectedList, o)
                                end
                            end
                            safeCallback(callback, selectedList)
                        end
                    end,
                    Get = function()
                        local selectedList = {}
                        for opt, isSelected in pairs(selected) do
                            if isSelected then
                                table.insert(selectedList, opt)
                            end
                        end
                        return selectedList
                    end,
                    SetOptions = function(_, newOptions)
                        newOptions = newOptions or {}
                        if type(newOptions) ~= "table" then
                            newOptions = {}
                        end
                        
                        local validNewOptions = {}
                        for _, opt in ipairs(newOptions) do
                            if opt ~= nil then
                                table.insert(validNewOptions, tostring(opt))
                            end
                        end
                        options = validNewOptions
                        selected = {}
                        btn.Text = (name and name .. ": " or "") .. getDisplayText()
                        closeOptions()
                    end,
                    Clear = function()
                        selected = {}
                        btn.Text = (name and name .. ": " or "") .. getDisplayText()
                        if callback and type(callback) == "function" then
                            safeCallback(callback, {})
                        end
                    end,
                    Close = closeOptions
                }
            end

            function SectionObj:NewColorpicker(name, defaultColor, callback)
                local currentColor = typeof(defaultColor) == "Color3" and defaultColor or 
                                     Color3.fromRGB(255, 255, 255)
                local currentH, currentS, currentV = Color3.toHSV(currentColor)

                
                local container = Instance.new("Frame")
                container.Size = UDim2.new(1, 0, 0, 36)
                container.BackgroundTransparency = 1
                container.Parent = Section

                local button = Instance.new("TextButton")
                button.Size = UDim2.new(1, 0, 1, 0)
                button.BackgroundColor3 = theme.ButtonBackground
                button.AutoButtonColor = false
                button.Font = Enum.Font.Gotham
                button.TextSize = 13
                button.TextColor3 = theme.Text
                button.Text = (name and name .. " " or "") .. "Color Picker"
                button.TextXAlignment = Enum.TextXAlignment.Left
                button.Parent = container

                local buttonCorner = Instance.new("UICorner")
                buttonCorner.CornerRadius = UDim.new(0, 8)
                buttonCorner.Parent = button

                local buttonStroke = Instance.new("UIStroke")
                buttonStroke.Color = theme.ButtonBorder
                buttonStroke.Thickness = 1
                buttonStroke.Transparency = 0.7
                buttonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                buttonStroke.Parent = button

                local buttonPadding = Instance.new("UIPadding")
                buttonPadding.PaddingLeft = UDim.new(0, 10)
                buttonPadding.PaddingRight = UDim.new(0, 40)
                buttonPadding.Parent = button

                local preview = Instance.new("Frame")
                preview.Size = UDim2.new(0, 26, 0, 26)
                preview.Position = UDim2.new(1, -32, 0.5, -13)
                preview.BackgroundColor3 = currentColor
                preview.BorderSizePixel = 0
                preview.Parent = container

                local previewCorner = Instance.new("UICorner")
                previewCorner.CornerRadius = UDim.new(0, 8)
                previewCorner.Parent = preview

                local previewStroke = Instance.new("UIStroke")
                previewStroke.Color = theme.ButtonBorder
                previewStroke.Thickness = 1
                previewStroke.Transparency = 0.5
                previewStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                previewStroke.Parent = preview

                local function createColorDialog()
                    local guiParent = game:GetService("CoreGui")
                    local success, playerGui = pcall(function()
                        local plr = game:GetService("Players").LocalPlayer
                        if plr and plr:FindFirstChild("PlayerGui") then
                            return plr.PlayerGui
                        end
                    end)
                    if success and playerGui then 
                        guiParent = playerGui 
                    end
                    
                    local colorPickerGui = Instance.new("ScreenGui")
                    colorPickerGui.Name = "ColorPickerOverlay"
                    colorPickerGui.DisplayOrder = 1000000000
                    colorPickerGui.ResetOnSpawn = false
                    colorPickerGui.IgnoreGuiInset = true
                    colorPickerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                    colorPickerGui.Parent = guiParent

                    local dialogOverlay = Instance.new("Frame")
                    dialogOverlay.Name = "ColorPickerDialog"
                    dialogOverlay.Size = UDim2.new(1, 0, 1, 0)
                    dialogOverlay.Position = UDim2.new(0, 0, 0, 0)
                    dialogOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    dialogOverlay.BackgroundTransparency = 0.5
                    dialogOverlay.ZIndex = 1
                    dialogOverlay.Active = true
                    dialogOverlay.Parent = colorPickerGui

                    local dialog = Instance.new("Frame")
                    dialog.Size = UDim2.new(0, 440, 0, 340)
                    dialog.Position = UDim2.new(0.5, -220, 0.5, -170)
                    dialog.BackgroundColor3 = theme.SectionBackground
                    dialog.ZIndex = 2
                    dialog.Active = true
                    dialog.Parent = dialogOverlay

                    local dialogCorner = Instance.new("UICorner")
                    dialogCorner.CornerRadius = UDim.new(0, 12)
                    dialogCorner.Parent = dialog

                    local dialogStroke = Instance.new("UIStroke")
                    dialogStroke.Color = theme.ButtonBorder
                    dialogStroke.Thickness = 1
                    dialogStroke.Transparency = 0.7
                    dialogStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    dialogStroke.Parent = dialog

                    addShadow(dialog, 0.6)

                    local title = Instance.new("TextLabel")
                    title.Text = name or "Color Picker"
                    title.Size = UDim2.new(1, -20, 0, 35)
                    title.Position = UDim2.new(0, 10, 0, 10)
                    title.BackgroundTransparency = 1
                    title.TextColor3 = theme.Text
                    title.Font = Enum.Font.GothamBold
                    title.TextSize = 16
                    title.TextXAlignment = Enum.TextXAlignment.Left
                    title.ZIndex = 3
                    title.Parent = dialog

                    local workingH, workingS, workingV = currentH, currentS, currentV

                    local satVibMap = Instance.new("ImageLabel")
                    satVibMap.Size = UDim2.new(0, 190, 0, 170)
                    satVibMap.Position = UDim2.new(0, 20, 0, 60)
                    satVibMap.Image = "rbxassetid://4155801252"
                    satVibMap.BackgroundColor3 = Color3.fromHSV(workingH, 1, 1)
                    satVibMap.ZIndex = 3
                    satVibMap.Active = true
                    satVibMap.Parent = dialog

                    local mapCorner = Instance.new("UICorner")
                    mapCorner.CornerRadius = UDim.new(0, 8)
                    mapCorner.Parent = satVibMap

                    local mapStroke = Instance.new("UIStroke")
                    mapStroke.Color = theme.ButtonBorder
                    mapStroke.Thickness = 1
                    mapStroke.Transparency = 0.7
                    mapStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    mapStroke.Parent = satVibMap

                    local satVibCursor = Instance.new("ImageLabel")
                    satVibCursor.Size = UDim2.new(0, 20, 0, 20)
                    satVibCursor.Position = UDim2.new(workingS, -10, 1 - workingV, -10)
                    satVibCursor.Image = "rbxassetid://4805639000"
                    satVibCursor.BackgroundTransparency = 1
                    satVibCursor.AnchorPoint = Vector2.new(0.5, 0.5)
                    satVibCursor.ZIndex = 4
                    satVibCursor.Parent = satVibMap

                    local hueSlider = Instance.new("Frame")
                    hueSlider.Size = UDim2.new(0, 14, 0, 200)
                    hueSlider.Position = UDim2.new(0, 220, 0, 60)
                    hueSlider.ZIndex = 3
                    hueSlider.Active = true
                    hueSlider.Parent = dialog

                    local hueCorner = Instance.new("UICorner")
                    hueCorner.CornerRadius = UDim.new(1, 0)
                    hueCorner.Parent = hueSlider

                    local hueStroke = Instance.new("UIStroke")
                    hueStroke.Color = theme.ButtonBorder
                    hueStroke.Thickness = 1
                    hueStroke.Transparency = 0.7
                    hueStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    hueStroke.Parent = hueSlider

                    local hueGradient = Instance.new("UIGradient")
                    hueGradient.Rotation = 90
                    local sequenceTable = {}
                    for i = 0, 1, 0.1 do
                        table.insert(sequenceTable, ColorSequenceKeypoint.new(i, Color3.fromHSV(i, 1, 1)))
                    end
                    hueGradient.Color = ColorSequence.new(sequenceTable)
                    hueGradient.Parent = hueSlider

                    local hueCursor = Instance.new("ImageLabel")
                    hueCursor.Size = UDim2.new(0, 16, 0, 16)
                    hueCursor.Position = UDim2.new(0, -1, workingH, -8)
                    hueCursor.Image = "rbxassetid://12266946128"
                    hueCursor.ImageColor3 = theme.InputBackground
                    hueCursor.BackgroundTransparency = 1
                    hueCursor.ZIndex = 4
                    hueCursor.Parent = hueSlider

                    local oldColorDisplay = Instance.new("ImageLabel")
                    oldColorDisplay.Size = UDim2.new(0, 94, 0, 28)
                    oldColorDisplay.Position = UDim2.new(0, 120, 0, 240)
                    oldColorDisplay.Image = GRADIENT_IMAGE
                    oldColorDisplay.ImageTransparency = 0.45
                    oldColorDisplay.ScaleType = Enum.ScaleType.Tile
                    oldColorDisplay.TileSize = UDim2.new(0, 40, 0, 40)
                    oldColorDisplay.ZIndex = 3
                    oldColorDisplay.Parent = dialog

                    local oldColorFrame = Instance.new("Frame")
                    oldColorFrame.Size = UDim2.new(1, 0, 1, 0)
                    oldColorFrame.BackgroundColor3 = currentColor
                    oldColorFrame.ZIndex = 4
                    oldColorFrame.Parent = oldColorDisplay

                    local oldCorner = Instance.new("UICorner")
                    oldCorner.CornerRadius = UDim.new(0, 6)
                    oldCorner.Parent = oldColorDisplay

                    local oldFrameCorner = Instance.new("UICorner")
                    oldFrameCorner.CornerRadius = UDim.new(0, 6)
                    oldFrameCorner.Parent = oldColorFrame

                    local oldStroke = Instance.new("UIStroke")
                    oldStroke.Color = theme.ButtonBorder
                    oldStroke.Thickness = 1
                    oldStroke.Transparency = 0.7
                    oldStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    oldStroke.Parent = oldColorDisplay

                    local newColorDisplay = Instance.new("ImageLabel")
                    newColorDisplay.Size = UDim2.new(0, 94, 0, 28)
                    newColorDisplay.Position = UDim2.new(0, 20, 0, 240)
                    newColorDisplay.Image = GRADIENT_IMAGE
                    newColorDisplay.ImageTransparency = 0.45
                    newColorDisplay.ScaleType = Enum.ScaleType.Tile
                    newColorDisplay.TileSize = UDim2.new(0, 40, 0, 40)
                    newColorDisplay.ZIndex = 3
                    newColorDisplay.Parent = dialog

                    local newColorFrame = Instance.new("Frame")
                    newColorFrame.Size = UDim2.new(1, 0, 1, 0)
                    newColorFrame.BackgroundColor3 = Color3.fromHSV(workingH, workingS, workingV)
                    newColorFrame.ZIndex = 4
                    newColorFrame.Parent = newColorDisplay

                    local newCorner = Instance.new("UICorner")
                    newCorner.CornerRadius = UDim.new(0, 6)
                    newCorner.Parent = newColorDisplay

                    local newFrameCorner = Instance.new("UICorner")
                    newFrameCorner.CornerRadius = UDim.new(0, 6)
                    newFrameCorner.Parent = newColorFrame

                    local newStroke = Instance.new("UIStroke")
                    newStroke.Color = theme.ButtonBorder
                    newStroke.Thickness = 1
                    newStroke.Transparency = 0.7
                    newStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    newStroke.Parent = newColorDisplay

                    local function createInput(pos, labelText, defaultValue)
                        local inputFrame = Instance.new("Frame")
                        inputFrame.Size = UDim2.new(0, 95, 0, 34)
                        inputFrame.Position = pos
                        inputFrame.BackgroundColor3 = theme.InputBackground
                        inputFrame.ZIndex = 3
                        inputFrame.Parent = dialog

                        local inputCorner = Instance.new("UICorner")
                        inputCorner.CornerRadius = UDim.new(0, 6)
                        inputCorner.Parent = inputFrame

                        local inputStroke = Instance.new("UIStroke")
                        inputStroke.Color = theme.InputBorder
                        inputStroke.Thickness = 1
                        inputStroke.Transparency = 0.7
                        inputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                        inputStroke.Parent = inputFrame

                        local input = Instance.new("TextBox")
                        input.Size = UDim2.new(1, -14, 1, 0)
                        input.Position = UDim2.new(0, 7, 0, 0)
                        input.BackgroundTransparency = 1
                        input.TextColor3 = theme.Text
                        input.Font = Enum.Font.Gotham
                        input.TextSize = 12
                        input.Text = defaultValue
                        input.ClearTextOnFocus = false
                        input.ZIndex = 4
                        input.Parent = inputFrame

                        local label = Instance.new("TextLabel")
                        label.Text = labelText
                        label.Size = UDim2.new(0, 35, 0, 34)
                        label.Position = UDim2.new(1, 5, 0, 0)
                        label.BackgroundTransparency = 1
                        label.TextColor3 = theme.SubText
                        label.Font = Enum.Font.Gotham
                        label.TextSize = 13
                        label.TextXAlignment = Enum.TextXAlignment.Left
                        label.ZIndex = 3
                        label.Parent = inputFrame

                        input.Focused:Connect(function()
                            tween(inputStroke, {
                                Color = theme.Accent,
                                Transparency = 0
                            }, {duration = 0.15})
                        end)

                        return input, inputStroke
                    end

                    local hexInput = createInput(UDim2.new(0, 250, 0, 60), "Hex", 
                                                  "#" .. Color3.fromHSV(workingH, workingS, workingV):ToHex())
                    local redInput = createInput(UDim2.new(0, 250, 0, 100), "Red", 
                                                  tostring(math.floor(Color3.fromHSV(workingH, workingS, workingV).r * 255)))
                    local greenInput = createInput(UDim2.new(0, 250, 0, 140), "Green", 
                                                    tostring(math.floor(Color3.fromHSV(workingH, workingS, workingV).g * 255)))
                    local blueInput = createInput(UDim2.new(0, 250, 0, 180), "Blue", 
                                                   tostring(math.floor(Color3.fromHSV(workingH, workingS, workingV).b * 255)))

                    local function updateDisplay()
                        local newColor = Color3.fromHSV(workingH, workingS, workingV)
                        
                        satVibMap.BackgroundColor3 = Color3.fromHSV(workingH, 1, 1)
                        satVibCursor.Position = UDim2.new(workingS, -10, 1 - workingV, -10)
                        hueCursor.Position = UDim2.new(0, -1, workingH, -8)
                        newColorFrame.BackgroundColor3 = newColor
                        
                        hexInput.Text = "#" .. newColor:ToHex()
                        redInput.Text = tostring(math.floor(newColor.r * 255))
                        greenInput.Text = tostring(math.floor(newColor.g * 255))
                        blueInput.Text = tostring(math.floor(newColor.b * 255))
                    end

                    -- Hex input handler
                    hexInput.FocusLost:Connect(function()
                        local hexStr = hexInput.Text:gsub("^#", "")
                        if #hexStr == 6 then
                            local r = tonumber(hexStr:sub(1,2), 16)
                            local g = tonumber(hexStr:sub(3,4), 16)
                            local b = tonumber(hexStr:sub(5,6), 16)
                            if r and g and b then
                                local newColor = Color3.fromRGB(r, g, b)
                                workingH, workingS, workingV = Color3.toHSV(newColor)
                                updateDisplay()
                            end
                        end
                    end)

                    -- Red input handler
                    redInput.FocusLost:Connect(function()
                        local val = tonumber(redInput.Text)
                        if val then
                            val = math.clamp(math.floor(val), 0, 255)
                            local curColor = Color3.fromHSV(workingH, workingS, workingV)
                            local newColor = Color3.fromRGB(val, math.floor(curColor.g * 255), math.floor(curColor.b * 255))
                            workingH, workingS, workingV = Color3.toHSV(newColor)
                            updateDisplay()
                        end
                    end)

                    -- Green input handler
                    greenInput.FocusLost:Connect(function()
                        local val = tonumber(greenInput.Text)
                        if val then
                            val = math.clamp(math.floor(val), 0, 255)
                            local curColor = Color3.fromHSV(workingH, workingS, workingV)
                            local newColor = Color3.fromRGB(math.floor(curColor.r * 255), val, math.floor(curColor.b * 255))
                            workingH, workingS, workingV = Color3.toHSV(newColor)
                            updateDisplay()
                        end
                    end)

                    -- Blue input handler
                    blueInput.FocusLost:Connect(function()
                        local val = tonumber(blueInput.Text)
                        if val then
                            val = math.clamp(math.floor(val), 0, 255)
                            local curColor = Color3.fromHSV(workingH, workingS, workingV)
                            local newColor = Color3.fromRGB(math.floor(curColor.r * 255), math.floor(curColor.g * 255), val)
                            workingH, workingS, workingV = Color3.toHSV(newColor)
                            updateDisplay()
                        end
                    end)

                    local satVibDragging = false
                    local hueDragging = false

                    local satVibConn = satVibMap.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            satVibDragging = true
                        end
                    end)

                    local satVibMoveConn = UserInputService.InputChanged:Connect(function(input)
                        if satVibDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                            local mouse = UserInputService:GetMouseLocation()
                            local mapPos = satVibMap.AbsolutePosition
                            local mapSize = satVibMap.AbsoluteSize
                            
                            local relX = math.clamp((mouse.X - mapPos.X) / mapSize.X, 0, 1)
                            local relY = math.clamp((mouse.Y - mapPos.Y) / mapSize.Y, 0, 1)
                            
                            workingS = relX
                            workingV = 1 - relY
                            updateDisplay()
                        end
                    end)

                    local satVibEndConn = UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            satVibDragging = false
                        end
                    end)

                    local hueConn = hueSlider.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            hueDragging = true
                        end
                    end)

                    local hueMoveConn = UserInputService.InputChanged:Connect(function(input)
                        if hueDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                            local mouse = UserInputService:GetMouseLocation()
                            local sliderPos = hueSlider.AbsolutePosition
                            local sliderSize = hueSlider.AbsoluteSize
                            
                            local relY = math.clamp((mouse.Y - sliderPos.Y) / sliderSize.Y, 0, 1)
                            workingH = relY
                            updateDisplay()
                        end
                    end)

                    local hueEndConn = UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            hueDragging = false
                        end
                    end)

                    local buttonContainer = Instance.new("Frame")
                    buttonContainer.Size = UDim2.new(0, 210, 0, 36)
                    buttonContainer.Position = UDim2.new(0, 20, 0, 290)
                    buttonContainer.BackgroundTransparency = 1
                    buttonContainer.ZIndex = 3
                    buttonContainer.Parent = dialog

                    local buttonLayout = Instance.new("UIListLayout")
                    buttonLayout.FillDirection = Enum.FillDirection.Horizontal
                    buttonLayout.Padding = UDim.new(0, 10)
                    buttonLayout.Parent = buttonContainer

                    local cancelBtn = Instance.new("TextButton")
                    cancelBtn.Size = UDim2.new(0, 100, 1, 0)
                    cancelBtn.BackgroundColor3 = theme.ButtonBackground
                    cancelBtn.TextColor3 = theme.Text
                    cancelBtn.Font = Enum.Font.Gotham
                    cancelBtn.TextSize = 14
                    cancelBtn.Text = "Cancel"
                    cancelBtn.AutoButtonColor = false
                    cancelBtn.ZIndex = 4
                    cancelBtn.Parent = buttonContainer

                    local cancelCorner = Instance.new("UICorner")
                    cancelCorner.CornerRadius = UDim.new(0, 8)
                    cancelCorner.Parent = cancelBtn

                    local cancelStroke = Instance.new("UIStroke")
                    cancelStroke.Color = theme.ButtonBorder
                    cancelStroke.Thickness = 1
                    cancelStroke.Transparency = 0.7
                    cancelStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    cancelStroke.Parent = cancelBtn

                    local doneBtn = Instance.new("TextButton")
                    doneBtn.Size = UDim2.new(0, 100, 1, 0)
                    doneBtn.BackgroundColor3 = theme.Accent
                    doneBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                    doneBtn.Font = Enum.Font.Gotham
                    doneBtn.TextSize = 14
                    doneBtn.Text = "Done"
                    doneBtn.AutoButtonColor = false
                    doneBtn.ZIndex = 4
                    doneBtn.Parent = buttonContainer

                    local doneCorner = Instance.new("UICorner")
                    doneCorner.CornerRadius = UDim.new(0, 8)
                    doneCorner.Parent = doneBtn

                    local doneStroke = Instance.new("UIStroke")
                    doneStroke.Color = theme.Accent
                    doneStroke.Thickness = 1
                    doneStroke.Transparency = 0
                    doneStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                    doneStroke.Parent = doneBtn

                    debouncedHover(cancelBtn,
                        function()
                            tween(cancelBtn, {BackgroundColor3 = theme.ButtonHover}, {duration = 0.1})
                            tween(cancelStroke, {Transparency = 0.5}, {duration = 0.1})
                        end,
                        function()
                            tween(cancelBtn, {BackgroundColor3 = theme.ButtonBackground}, {duration = 0.1})
                            tween(cancelStroke, {Transparency = 0.7}, {duration = 0.1})
                        end
                    )

                    debouncedHover(doneBtn,
                        function()
                            tween(doneBtn, {BackgroundColor3 = theme.AccentHover}, {duration = 0.1})
                        end,
                        function()
                            tween(doneBtn, {BackgroundColor3 = theme.Accent}, {duration = 0.1})
                        end
                    )

                    local function closeDialog()
                        pcall(function() satVibConn:Disconnect() end)
                        pcall(function() satVibMoveConn:Disconnect() end)
                        pcall(function() satVibEndConn:Disconnect() end)
                        pcall(function() hueConn:Disconnect() end)
                        pcall(function() hueMoveConn:Disconnect() end)
                        pcall(function() hueEndConn:Disconnect() end)
                        
                        tween(dialogOverlay, {BackgroundTransparency = 1}, {duration = 0.2})
                        tween(dialog, {
                            Size = UDim2.new(0, 0, 0, 0), 
                            Position = UDim2.new(0.5, 0, 0.5, 0)
                        }, {duration = 0.2})
                        
                        task.delay(0.2, function()
                            if colorPickerGui then
                                colorPickerGui:Destroy()
                            end
                        end)
                    end

                    cancelBtn.MouseButton1Click:Connect(closeDialog)

                    doneBtn.MouseButton1Click:Connect(function()
                        currentColor = Color3.fromHSV(workingH, workingS, workingV)
                        currentH, currentS, currentV = workingH, workingS, workingV
                        preview.BackgroundColor3 = currentColor
                        
                        if callback and type(callback) == "function" then
                            safeCallback(callback, currentColor)
                        end
                        
                        closeDialog()
                    end)

                    -- Prevent clicks on dialog from closing via overlay
                    dialog.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            -- Absorb click, prevent bubbling to overlay
                        end
                    end)

                    dialogOverlay.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            local mouse = UserInputService:GetMouseLocation()
                            local dPos = dialog.AbsolutePosition
                            local dSize = dialog.AbsoluteSize
                            if mouse.X < dPos.X or mouse.X > dPos.X + dSize.X or
                               mouse.Y < dPos.Y or mouse.Y > dPos.Y + dSize.Y then
                                closeDialog()
                            end
                        end
                    end)

                    dialog.Size = UDim2.new(0, 0, 0, 0)
                    dialog.Position = UDim2.new(0.5, 0, 0.5, 0)
                    dialogOverlay.BackgroundTransparency = 1
                    
                    tween(dialogOverlay, {BackgroundTransparency = 0.5}, {duration = 0.2})
                    tween(dialog, {
                        Size = UDim2.new(0, 440, 0, 340), 
                        Position = UDim2.new(0.5, -220, 0.5, -170)
                    }, {duration = 0.2})
                end

                local clickConn = button.MouseButton1Click:Connect(function()
                    createColorDialog()
                end)

                debouncedHover(button,
                    function()
                        tween(button, {BackgroundColor3 = theme.ButtonHover}, {duration = 0.1})
                        tween(buttonStroke, {Transparency = 0.5}, {duration = 0.1})
                    end,
                    function()
                        tween(button, {BackgroundColor3 = theme.ButtonBackground}, {duration = 0.1})
                        tween(buttonStroke, {Transparency = 0.7}, {duration = 0.1})
                    end
                )

                return {
                    Get = function() return currentColor end,
                    Set = function(_, color)
                        if typeof(color) == "Color3" then
                            currentColor = color
                            currentH, currentS, currentV = Color3.toHSV(color)
                            preview.BackgroundColor3 = color
                            if callback then safeCallback(callback, color) end
                        end
                    end
                }
            end

            SectionObj.NewColorPicker = SectionObj.NewColorpicker
            SectionObj.NewTextBox = SectionObj.NewTextbox
            SectionObj.NewKeyBind = SectionObj.NewKeybind

end

return Elements
