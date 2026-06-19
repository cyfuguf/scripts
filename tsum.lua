-- TSUM ESP - РАБОЧАЯ ВЕРСИЯ
-- НАЖМИ F5 ДЛЯ МЕНЮ

local Settings = {
    Enabled = true,
    PriceThreshold = 500,
    BoxColor = Color3.fromRGB(255, 215, 0),
    TextColor = Color3.fromRGB(255, 255, 255),
    FontSize = 16,
    ShowDistance = true,
    MaxRenderDistance = 300,
    ShowBoxes = true,
    ShowNames = true,
    Keybind = "F5",
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local EspObjects = {}
local Connection = nil
local MenuOpen = false
local EspGui = nil

-- МЕНЮ
local function CreateMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TsumMenu"
    screenGui.Parent = LocalPlayer.PlayerGui
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true

    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 320, 0, 350)
    mainFrame.Position = UDim2.new(0.5, -160, 0.5, -175)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = mainFrame

    -- Заголовок
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    title.Text = "✦ TSUM ESP ✦"
    title.TextColor3 = Color3.fromRGB(255, 215, 0)
    title.TextSize = 18
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = title

    -- Кнопка закрытия
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -30, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = mainFrame

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 4)
    closeCorner.Parent = closeBtn

    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        MenuOpen = false
    end)

    -- Контейнер
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 1, -45)
    container.Position = UDim2.new(0, 10, 0, 40)
    container.BackgroundTransparency = 1
    container.Parent = mainFrame

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.CanvasSize = UDim2.new(0, 0, 0, 320)
    scroll.Parent = container

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll

    local function CreateToggle(parent, name, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 30)
        frame.BackgroundTransparency = 1
        frame.Parent = parent

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.fromRGB(220, 220, 230)
        label.TextSize = 13
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame

        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0, 40, 0, 22)
        toggle.Position = UDim2.new(1, -40, 0.5, -11)
        toggle.BackgroundColor3 = default and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(50, 50, 65)
        toggle.Text = default and "ON" or "OFF"
        toggle.TextColor3 = default and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(200, 200, 200)
        toggle.TextSize = 11
        toggle.Font = Enum.Font.GothamBold
        toggle.BorderSizePixel = 0
        toggle.Parent = frame

        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 4)
        toggleCorner.Parent = toggle

        local state = default
        toggle.MouseButton1Click:Connect(function()
            state = not state
            toggle.BackgroundColor3 = state and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(50, 50, 65)
            toggle.Text = state and "ON" or "OFF"
            toggle.TextColor3 = state and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(200, 200, 200)
            callback(state)
        end)
        return frame
    end

    local function CreateSlider(parent, name, min, max, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 40)
        frame.BackgroundTransparency = 1
        frame.Parent = parent

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.6, 0, 0, 16)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.fromRGB(220, 220, 230)
        label.TextSize = 13
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame

        local valueDisplay = Instance.new("TextLabel")
        valueDisplay.Size = UDim2.new(0.3, 0, 0, 16)
        valueDisplay.Position = UDim2.new(0.7, 0, 0, 0)
        valueDisplay.BackgroundTransparency = 1
        valueDisplay.Text = tostring(default)
        valueDisplay.TextColor3 = Color3.fromRGB(255, 215, 0)
        valueDisplay.TextSize = 13
        valueDisplay.Font = Enum.Font.GothamBold
        valueDisplay.TextXAlignment = Enum.TextXAlignment.Right
        valueDisplay.Parent = frame

        local slider = Instance.new("Frame")
        slider.Size = UDim2.new(1, 0, 0, 5)
        slider.Position = UDim2.new(0, 0, 0, 22)
        slider.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
        slider.BorderSizePixel = 0
        slider.Parent = frame

        local sliderCorner = Instance.new("UICorner")
        sliderCorner.CornerRadius = UDim.new(0, 2)
        sliderCorner.Parent = slider

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
        fill.BorderSizePixel = 0
        fill.Parent = slider

        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(0, 2)
        fillCorner.Parent = fill

        local dragging = false
        local function updateSlider(input)
            local pos = math.clamp((input.Position.X - slider.AbsolutePosition.X) / slider.AbsoluteSize.X, 0, 1)
            local value = math.round(min + (max - min) * pos)
            fill.Size = UDim2.new(pos, 0, 1, 0)
            valueDisplay.Text = tostring(value)
            callback(value)
        end

        slider.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                updateSlider(input)
            end
        end)

        slider.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        slider.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(input)
            end
        end)
        return frame
    end

    CreateToggle(scroll, "ESP Enabled", Settings.Enabled, function(v) Settings.Enabled = v end)
    CreateSlider(scroll, "Price", 50, 5000, Settings.PriceThreshold, function(v) Settings.PriceThreshold = v end)
    CreateToggle(scroll, "Boxes", Settings.ShowBoxes, function(v) Settings.ShowBoxes = v end)
    CreateToggle(scroll, "Names", Settings.ShowNames, function(v) Settings.ShowNames = v end)
    CreateToggle(scroll, "Distance", Settings.ShowDistance, function(v) Settings.ShowDistance = v end)
    CreateSlider(scroll, "Max Dist", 50, 500, Settings.MaxRenderDistance, function(v) Settings.MaxRenderDistance = v end)

    -- Перетаскивание
    local dragging = false
    local dragStart, startPos

    title.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)

    title.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    title.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    return screenGui, mainFrame
end

-- СОЗДАНИЕ ESP
local function CreateEspGui()
    if EspGui then return EspGui end
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TsumESP"
    screenGui.Parent = LocalPlayer.PlayerGui
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    EspGui = screenGui
    return screenGui
end

-- ПОИСК ЦЕНЫ
local function GetItemPrice(part)
    local price = part:GetAttribute("Value") or part:GetAttribute("Price") or part:GetAttribute("Cost") or 0
    if type(price) == "number" and price > 0 then return price end

    for _, child in ipairs(part:GetChildren()) do
        if child:IsA("IntValue") or child:IsA("NumberValue") then
            local name = child.Name:lower()
            if name:find("price") or name:find("value") or name:find("cost") then
                if type(child.Value) == "number" and child.Value > 0 then
                    return child.Value
                end
            end
        end
    end
    return 0
end

-- ОСНОВНОЙ ЦИКЛ
local function UpdateEsp()
    if not Settings.Enabled then
        for _, data in pairs(EspObjects) do
            if data.label then data.label.Visible = false end
            if data.box then data.box.Visible = false end
        end
        return
    end

    local parts = workspace:GetDescendants()
    local processed = {}
    local count = 0

    for _, part in ipairs(parts) do
        if count >= 30 then break end
        if not part:IsA("BasePart") or not part.Parent then goto continue end

        local char = part.Parent
        if char and char:IsA("Model") and char:FindFirstChild("Humanoid") then
            goto continue
        end
        if LocalPlayer.Character and part:IsDescendantOf(LocalPlayer.Character) then
            goto continue
        end

        local price = GetItemPrice(part)
        if price >= Settings.PriceThreshold then
            count = count + 1
            local key = part

            if not EspObjects[key] then
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(0, 180, 0, 28)
                label.BackgroundTransparency = 1
                label.Text = "💰 " .. tostring(price)
                label.TextColor3 = Settings.TextColor
                label.TextSize = Settings.FontSize
                label.Font = Enum.Font.GothamBold
                label.TextStrokeTransparency = 0.2
                label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                label.TextXAlignment = Enum.TextXAlignment.Center
                label.TextYAlignment = Enum.TextYAlignment.Center
                label.Visible = true
                label.Parent = CreateEspGui()
                label.ZIndex = 10

                local box = Instance.new("Frame")
                box.Size = UDim2.new(0, 50, 0, 50)
                box.BackgroundTransparency = 0.5
                box.BackgroundColor3 = Settings.BoxColor
                box.BorderSizePixel = 2
                box.BorderColor3 = Settings.BoxColor
                box.Visible = true
                box.Parent = CreateEspGui()
                box.ZIndex = 9

                EspObjects[key] = { label = label, box = box, part = part }
            end
            processed[key] = true
        end
        ::continue::
    end

    for key, data in pairs(EspObjects) do
        if not processed[key] or not data.part or not data.part.Parent then
            if data.label then data.label:Destroy() end
            if data.box then data.box:Destroy() end
            EspObjects[key] = nil
        end
    end

    local camPos = Camera.CFrame.Position
    for _, data in pairs(EspObjects) do
        if data.part and data.part.Parent then
            local pos, vis = Camera:WorldToScreenPoint(data.part.Position)
            if not vis then
                data.label.Visible = false
                data.box.Visible = false
                goto next
            end

            local dist = (camPos - data.part.Position).Magnitude
            if dist > Settings.MaxRenderDistance then
                data.label.Visible = false
                data.box.Visible = false
                goto next
            end

            if Settings.ShowNames then
                local price = GetItemPrice(data.part)
                local text = "💰 " .. tostring(price)
                if Settings.ShowDistance then
                    text = text .. " [" .. math.floor(dist) .. "m]"
                end
                data.label.Text = text
                data.label.Position = UDim2.new(0, pos.X - 90, 0, pos.Y - 40)
                data.label.Visible = true
            else
                data.label.Visible = false
            end

            if Settings.ShowBoxes then
                local size = math.max(20, 45 / (dist / 30 + 1))
                data.box.Size = UDim2.new(0, size, 0, size)
                data.box.Position = UDim2.new(0, pos.X - size/2, 0, pos.Y - size/2)
                data.box.Visible = true
            else
                data.box.Visible = false
            end
        end
        ::next::
    end
end

-- ЗАПУСК
local MenuGui, MenuFrame = CreateMenu()

local function ToggleMenu()
    MenuOpen = not MenuOpen
    MenuFrame.Visible = MenuOpen
end

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode[Settings.Keybind] then
        ToggleMenu()
    end
end)

Mouse.KeyDown:Connect(function(key)
    if key == Settings.Keybind then
        ToggleMenu()
    end
end)

Connection = RunService.Heartbeat:Connect(function()
    UpdateEsp()
end)

print("✅ TSUM ESP ЗАПУЩЕН! Нажми F5")
