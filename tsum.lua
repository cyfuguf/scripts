--[[
    Название: Tsum ESP - Xeno Edition с меню
    Описание: ESP для дорогих вещей с графическим меню
    Версия: 3.1 (исправлена ошибка Bind)
--]]

-- Проверка наличия Xeno
local Xeno = syn and syn.xeno or (getgenv and getgenv().Xeno)
local IsXeno = Xeno ~= nil

-- НАСТРОЙКИ ПО УМОЛЧАНИЮ
local Settings = {
    Enabled = true,
    PriceThreshold = 500,
    BoxColor = Color3.fromRGB(255, 215, 0),
    TextColor = Color3.fromRGB(255, 255, 255),
    FontSize = 20,
    ShowDistance = true,
    MaxRenderDistance = 500,
    ShowBoxes = true,
    ShowLines = false,
    ShowNames = true,
    Keybind = "F5",
}

-- Служебные переменные
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Хранилище ESP
local EspObjects = {}
local Connection = nil
local MenuOpen = false

-- СОЗДАНИЕ GUI МЕНЮ
local function CreateMenu()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TsumMenu"
    screenGui.Parent = LocalPlayer.PlayerGui
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    if IsXeno then
        screenGui.DisplayOrder = 999
    end

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 350, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = mainFrame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    title.BackgroundTransparency = 0
    title.Text = "TSUM ESP MENU"
    title.TextColor3 = Color3.fromRGB(255, 215, 0)
    title.TextSize = 22
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = mainFrame

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 5)
    closeCorner.Parent = closeBtn

    local function CreateSlider(parent, name, min, max, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0.9, 0, 0, 40)
        frame.Position = UDim2.new(0.05, 0, 0, 0)
        frame.BackgroundTransparency = 1
        frame.Parent = parent

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.5, 0, 1, 0)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = name .. ": " .. tostring(default)
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.TextSize = 16
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame

        local slider = Instance.new("Frame")
        slider.Size = UDim2.new(0.4, 0, 0, 6)
        slider.Position = UDim2.new(0.5, 0, 0.5, -3)
        slider.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
        slider.BorderSizePixel = 0
        slider.Parent = frame

        local sliderCorner = Instance.new("UICorner")
        sliderCorner.CornerRadius = UDim.new(0, 3)
        sliderCorner.Parent = slider

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
        fill.BorderSizePixel = 0
        fill.Parent = slider

        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(0, 3)
        fillCorner.Parent = fill

        local dragging = false

        local function updateSlider(input)
            local pos = input.Position.X / slider.AbsoluteSize.X
            pos = math.clamp(pos, 0, 1)
            local value = min + (max - min) * pos
            value = math.round(value)
            fill.Size = UDim2.new(pos, 0, 1, 0)
            label.Text = name .. ": " .. tostring(value)
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

    local function CreateToggle(parent, name, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0.9, 0, 0, 35)
        frame.Position = UDim2.new(0.05, 0, 0, 0)
        frame.BackgroundTransparency = 1
        frame.Parent = parent

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.TextSize = 16
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame

        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0, 50, 0, 25)
        toggle.Position = UDim2.new(0.8, 0, 0.5, -12.5)
        toggle.BackgroundColor3 = default and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(60, 60, 70)
        toggle.Text = default and "ON" or "OFF"
        toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggle.TextSize = 14
        toggle.Font = Enum.Font.GothamBold
        toggle.BorderSizePixel = 0
        toggle.Parent = frame

        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 5)
        toggleCorner.Parent = toggle

        local state = default

        toggle.MouseButton1Click:Connect(function()
            state = not state
            toggle.BackgroundColor3 = state and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(60, 60, 70)
            toggle.Text = state and "ON" or "OFF"
            callback(state)
        end)

        return frame
    end

    local function CreateButton(parent, name, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.4, 0, 0, 35)
        btn.Position = UDim2.new(0.05, 0, 0, 0)
        btn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(0, 0, 0)
        btn.TextSize = 16
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        btn.Parent = parent

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 5)
        btnCorner.Parent = btn

        btn.MouseButton1Click:Connect(callback)

        return btn
    end

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 1, -40)
    container.Position = UDim2.new(0, 0, 0, 40)
    container.BackgroundTransparency = 1
    container.Parent = mainFrame

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.Position = UDim2.new(0, 0, 0, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 5
    scroll.CanvasSize = UDim2.new(0, 0, 0, 450)
    scroll.Parent = container

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 5)
    layout.Parent = scroll

    local y = 0

    local function addElement(element)
        element.Position = UDim2.new(0, 0, 0, y)
        y = y + 40
        element.Parent = scroll
        scroll.CanvasSize = UDim2.new(0, 0, 0, y + 10)
        return element
    end

    addElement(CreateToggle(scroll, "ESP Enabled", Settings.Enabled, function(val)
        Settings.Enabled = val
        print("[ESP] " .. (val and "Включён" or "Выключен"))
    end))

    addElement(CreateSlider(scroll, "Price Threshold", 100, 5000, Settings.PriceThreshold, function(val)
        Settings.PriceThreshold = val
        print("[ESP] Порог цены: " .. val)
    end))

    addElement(CreateToggle(scroll, "Show Boxes", Settings.ShowBoxes, function(val)
        Settings.ShowBoxes = val
    end))

    addElement(CreateToggle(scroll, "Show Lines", Settings.ShowLines, function(val)
        Settings.ShowLines = val
    end))

    addElement(CreateToggle(scroll, "Show Names", Settings.ShowNames, function(val)
        Settings.ShowNames = val
    end))

    addElement(CreateToggle(scroll, "Show Distance", Settings.ShowDistance, function(val)
        Settings.ShowDistance = val
    end))

    addElement(CreateSlider(scroll, "Max Distance", 100, 1000, Settings.MaxRenderDistance, function(val)
        Settings.MaxRenderDistance = val
    end))

    local resetBtn = CreateButton(scroll, "Reset Settings", function()
        Settings.PriceThreshold = 500
        Settings.MaxRenderDistance = 500
        Settings.ShowDistance = true
        Settings.ShowBoxes = true
        Settings.ShowLines = false
        Settings.ShowNames = true
        print("[ESP] Настройки сброшены")
    end)
    resetBtn.Size = UDim2.new(0.4, 0, 0, 35)
    resetBtn.Position = UDim2.new(0.55, 0, 0, 0)
    resetBtn.Parent = scroll

    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        MenuOpen = false
    end)

    local dragging = false
    local dragStart
    local startPos

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
            mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    return screenGui, mainFrame
end

-- СОЗДАНИЕ ESP GUI
local EspGui = nil
local MenuGui, MenuFrame = CreateMenu()

local function CreateEspGui()
    if EspGui then return EspGui end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "TsumESP"
    screenGui.Parent = LocalPlayer.PlayerGui
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    if IsXeno then
        screenGui.DisplayOrder = 998
    end
    EspGui = screenGui
    return screenGui
end

local function CreateTextLabel(text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 250, 0, 35)
    label.BackgroundTransparency = 1
    label.Text = text
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
    return label
end

local function CreateBox()
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 100, 0, 100)
    frame.BackgroundTransparency = 0.5
    frame.BackgroundColor3 = Settings.BoxColor
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Settings.BoxColor
    frame.Visible = true
    frame.Parent = CreateEspGui()
    frame.ZIndex = 9
    return frame
end

local function CreateLine()
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 2, 0, 100)
    line.BackgroundColor3 = Settings.BoxColor
    line.BackgroundTransparency = 0.5
    line.BorderSizePixel = 0
    line.Visible = true
    line.Parent = CreateEspGui()
    line.ZIndex = 8
    return line
end

-- ПОИСК ЦЕНЫ (РАСШИРЕННАЯ ВЕРСИЯ)
local function GetItemPrice(part)
    -- 1. Проверка атрибутов
    local price = part:GetAttribute("Value") or part:GetAttribute("Price") or part:GetAttribute("Cost") or 0
    if price > 0 then return price end

    -- 2. Проверка всех дочерних объектов
    for _, child in ipairs(part:GetChildren()) do
        if child:IsA("IntValue") or child:IsA("NumberValue") then
            local name = child.Name:lower()
            if name:find("price") or name:find("value") or name:find("cost") or name:find("money") then
                if child.Value > 0 then
                    return child.Value
                end
            end
        end
    end

    -- 3. Проверка родителя
    local parent = part.Parent
    if parent then
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("IntValue") or child:IsA("NumberValue") then
                local name = child.Name:lower()
                if name:find("price") or name:find("value") or name:find("cost") or name:find("money") then
                    if child.Value > 0 then
                        return child.Value
                    end
                end
            end
        end
    end

    -- 4. Проверка названия части
    local name = part.Name
    local num = tonumber(name:match("[%d,]+"):gsub(",", ""))
    if num and num > 0 then
        return num
    end

    return 0
end

local function IsValuableItem(part)
    if not part or not part.Parent then return false end
    local price = GetItemPrice(part)
    return price >= Settings.PriceThreshold
end

local function UpdateEspPosition(part, label, box, line)
    if not part or not part.Parent then
        label.Visible = false
        if box then box.Visible = false end
        if line then line.Visible = false end
        return
    end

    local position, visible = Camera:WorldToScreenPoint(part.Position)
    if not visible then
        label.Visible = false
        if box then box.Visible = false end
        if line then line.Visible = false end
        return
    end

    local distance = (Camera.CFrame.Position - part.Position).Magnitude

    if distance > Settings.MaxRenderDistance then
        label.Visible = false
        if box then box.Visible = false end
        if line then line.Visible = false end
        return
    end

    if Settings.ShowNames then
        local price = GetItemPrice(part)
        local text = string.format("💰 %s", tostring(price))
        if Settings.ShowDistance then
            text = text .. string.format(" [%dm]", math.floor(distance))
        end
        label.Text = text
        label.Position = UDim2.new(0, position.X - 125, 0, position.Y - 50)
        label.Visible = true
    else
        label.Visible = false
    end

    if Settings.ShowBoxes and box then
        local size = math.max(30, 80 / (distance / 50 + 1))
        box.Size = UDim2.new(0, size, 0, size)
        box.Position = UDim2.new(0, position.X - size/2, 0, position.Y - size/2)
        box.Visible = true
    elseif box then
        box.Visible = false
    end

    if Settings.ShowLines and line then
        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local lineLength = (position - screenCenter).Magnitude
        local angle = math.atan2(position.Y - screenCenter.Y, position.X - screenCenter.X)

        line.Size = UDim2.new(0, 2, 0, math.min(lineLength, 200))
        line.Position = UDim2.new(0, screenCenter.X, 0, screenCenter.Y)
        line.Rotation = math.deg(angle)
        line.Visible = true
    elseif line then
        line.Visible = false
    end
end

local function UpdateEsp()
    if not Settings.Enabled then
        for _, data in pairs(EspObjects) do
            if data.label then data.label.Visible = false end
            if data.box then data.box.Visible = false end
            if data.line then data.line.Visible = false end
        end
        return
    end

    local parts = workspace:GetDescendants()
    local processed = {}

    for _, part in ipairs(parts) do
        if part:IsA("BasePart") and part.Parent then
            local price = GetItemPrice(part)
            if price >= Settings.PriceThreshold then
                local key = part

                if not EspObjects[key] then
                    local label = CreateTextLabel("💰 " .. tostring(price))
                    local box = CreateBox()
                    local line = CreateLine()
                    EspObjects[key] = {
                        label = label,
                        box = box,
                        line = line,
                        part = part
                    }
                end
                processed[key] = true
            end
        end
    end

    for key, data in pairs(EspObjects) do
        if not processed[key] or not data.part or not data.part.Parent then
            if data.label then data.label:Destroy() end
            if data.box then data.box:Destroy() end
            if data.line then data.line:Destroy() end
            EspObjects[key] = nil
        end
    end

    for _, data in pairs(EspObjects) do
        if data.part and data.part.Parent then
            UpdateEspPosition(data.part, data.label, data.box, data.line)
        end
    end
end

local function StartEsp()
    if Connection then
        Connection:Disconnect()
        Connection = nil
    end

    Connection = RunService.Heartbeat:Connect(function()
        UpdateEsp()
    end)

    print("[ESP] Запущен!")
    print("[ESP] Нажмите " .. Settings.Keybind .. " для открытия меню")

    if IsXeno and Xeno.Notify then
        Xeno:Notify("[ESP] Запущен! Нажмите " .. Settings.Keybind .. " для меню", 3)
    end

    task.wait(1)
    UpdateEsp()
end

-- ===== ИСПРАВЛЕННАЯ ОБРАБОТКА КЛАВИШ =====
local function ToggleMenu()
    MenuOpen = not MenuOpen
    MenuFrame.Visible = MenuOpen
    if MenuOpen then
        print("[ESP] Меню открыто")
    else
        print("[ESP] Меню закрыто")
    end
end

-- Используем стандартный UserInputService вместо Xeno:Bind
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode[Settings.Keybind] then
        ToggleMenu()
    end
end)

-- Дополнительно: обработка через Mouse для совместимости
Mouse.KeyDown:Connect(function(key)
    if key == Settings.Keybind then
        ToggleMenu()
    end
end)

-- Очистка
game:GetService("Players").LocalPlayer.OnTeleport:Connect(function()
    if Connection then
        Connection:Disconnect()
        Connection = nil
    end
    if EspGui then
        EspGui:Destroy()
    end
    if MenuGui then
        MenuGui:Destroy()
    end
end)

-- Запуск
StartEsp()

--[[
    ИЗМЕНЕНИЯ:
    1. Удалён Xeno:Bind() - заменён на стандартный UserInputService
    2. Добавлен Mouse.KeyDown как запасной вариант
    3. Добавлена проверка Xeno.Notify перед вызовом
    4. Расширен поиск цены (добавлен Cost, Money)
    5. Теперь работает без Xeno

    УПРАВЛЕНИЕ:
    - F5: Открыть/закрыть меню
    - Перетаскивание: зажми заголовок меню
--]]
