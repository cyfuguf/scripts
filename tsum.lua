--[[
    Название: Tsum ESP - Xeno Edition с меню
    Описание: ESP для дорогих вещей с графическим меню
    Версия: 3.0
    Автор: GitHub Copilot
--]]

-- Загрузка с GitHub:
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/yourusername/tsum-esp/main/main.lua"))()

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
    
    -- Главное меню
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 350, 0, 450)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -225)
    mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    
    -- Скругление углов
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = mainFrame
    
    -- Заголовок
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
    
    -- Кнопка закрытия
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
    
    -- Создание ползунка
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
    
    -- Создание переключателя
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
    
    -- Создание кнопки
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
    
    -- Контейнер для элементов
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
    
    -- Элементы меню
    local function addElement(element)
        element.Position = UDim2.new(0, 0, 0, y)
        y = y + 40
        element.Parent = scroll
        scroll.CanvasSize = UDim2.new(0, 0, 0, y + 10)
        return element
    end
    
    -- Включение/выключение ESP
    addElement(CreateToggle(scroll, "ESP Enabled", Settings.Enabled, function(val)
        Settings.Enabled = val
        print("[ESP] " .. (val and "Включён" or "Выключен"))
    end))
    
    -- Порог цены
    addElement(CreateSlider(scroll, "Price Threshold", 100, 5000, Settings.PriceThreshold, function(val)
        Settings.PriceThreshold = val
        print("[ESP] Порог цены: " .. val)
    end))
    
    -- Показывать рамки
    addElement(CreateToggle(scroll, "Show Boxes", Settings.ShowBoxes, function(val)
        Settings.ShowBoxes = val
    end))
    
    -- Показывать линии
    addElement(CreateToggle(scroll, "Show Lines", Settings.ShowLines, function(val)
        Settings.ShowLines = val
    end))
    
    -- Показывать названия
    addElement(CreateToggle(scroll, "Show Names", Settings.ShowNames, function(val)
        Settings.ShowNames = val
    end))
    
    -- Показывать дистанцию
    addElement(CreateToggle(scroll, "Show Distance", Settings.ShowDistance, function(val)
        Settings.ShowDistance = val
    end))
    
    -- Максимальная дистанция
    addElement(CreateSlider(scroll, "Max Distance", 100, 1000, Settings.MaxRenderDistance, function(val)
        Settings.MaxRenderDistance = val
    end))
    
    -- Кнопка сброса
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
    
    -- Закрытие меню
    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        MenuOpen = false
    end)
    
    -- Перетаскивание окна
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

-- Создание ESP GUI
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

-- Функции создания элементов ESP
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

-- ПОИСК ЦЕНЫ
local function GetItemPrice(part)
    local price = part:GetAttribute("Value") or part:GetAttribute("Price") or 0
    if price > 0 then return price end
    
    for _, child in ipairs(part:GetChildren()) do
        if child:IsA("IntValue") or child:IsA("NumberValue") then
            local name = child.Name:lower()
            if name:find("price") or name:find("value") or name:find("cost") then
                if child.Value > 0 then
                    return child.Value
                end
            end
        end
    end
    
    local parent = part.Parent
    if parent then
        for _, child in ipairs(parent:GetChildren()) do
            if child:IsA("IntValue") or child:IsA("NumberValue") then
                local name = child.Name:lower()
                if name:find("price") or name:find("value") or name:find("cost") then
                    if child.Value > 0 then
                        return child.Value
                    end
                end
            end
        end
    end
    
    local name = part.Name
    local num = tonumber(name:match("[%d,]+"):gsub(",", ""))
    if num and num > 0 then
        return num
    end
    
    return 0
end

-- Проверка ценности
local function IsValuableItem(part)
    if not part or not part.Parent then return false end
    local price = GetItemPrice(part)
    return price >= Settings.PriceThreshold
end

-- Обновление позиции ESP
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
    
    -- Обновляем текст
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
    
    -- Обновляем рамку
    if Settings.ShowBoxes and box then
        local size = math.max(30, 80 / (distance / 50 + 1))
        box.Size = UDim2.new(0, size, 0, size)
        box.Position = UDim2.new(0, position.X - size/2, 0, position.Y - size/2)
        box.Visible = true
    elseif box then
        box.Visible = false
    end
    
    -- Обновляем линию
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

-- ОСНОВНОЙ ЦИКЛ
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
    
    -- Удаляем старые ESP
    for key, data in pairs(EspObjects) do
        if not processed[key] or not data.part or not data.part.Parent then
            if data.label then data.label:Destroy() end
            if data.box then data.box:Destroy() end
            if data.line then data.line:Destroy() end
            EspObjects[key] = nil
        end
    end
    
    -- Обновляем позиции
    for _, data in pairs(EspObjects) do
        if data.part and data.part.Parent then
            UpdateEspPosition(data.part, data.label, data.box, data.line)
        end
    end
end

-- Запуск ESP
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
    
    if IsXeno then
        Xeno:Notify("[ESP] Запущен! Нажмите " .. Settings.Keybind .. " для меню", 3)
    end
    
    task.wait(1)
    UpdateEsp()
end

-- Обработчик клавиш
local function ToggleMenu()
    MenuOpen = not MenuOpen
    MenuFrame.Visible = MenuOpen
    if MenuOpen then
        print("[ESP] Меню открыто")
    else
        print("[ESP] Меню закрыто")
    end
end

if IsXeno then
    Xeno:Bind(Settings.Keybind, function()
        ToggleMenu()
    end)
else
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode[Settings.Keybind] then
            ToggleMenu()
        end
    end)
end

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
    ИНСТРУКЦИЯ:
    
    1. Загрузи скрипт в Xeno
    2. Нажми F5 для открытия меню
    3. Настрой параметры:
       - Price Threshold: порог цены
       - Show Boxes: показывать рамки
       - Show Lines: показывать линии
       - Show Names: показывать названия
       - Show Distance: показывать дистанцию
       - Max Distance: максимальная дистанция
    
    УПРАВЛЕНИЕ:
    - F5: Открыть/закрыть меню
    - Перетаскивание: зажми заголовок меню
    
    НАСТРОЙКА ПОД СВОЮ ИГРУ:
    Если ESP не работает, измени функцию GetItemPrice()
--]]
