--[[
    Название: Tsum ESP - Оптимизированная версия
    Описание: ESP для дорогих ВЕЩЕЙ (не игроков) с меню
    Версия: 4.2 (Исправлена ошибка HttpGet)
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
    FontSize = 16,
    ShowDistance = true,
    MaxRenderDistance = 250,
    ShowBoxes = true,
    ShowLines = false,
    ShowNames = true,
    Keybind = "F5",
    UpdateRate = 0.2,
    MaxItems = 30,
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
local UpdateTimer = 0
local EspGui = nil

-- ===== ОПТИМИЗИРОВАННОЕ МЕНЮ =====
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
    mainFrame.Size = UDim2.new(0, 350, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -175, 0.5, -200)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.BorderSizePixel = 1
    mainFrame.BorderColor3 = Color3.fromRGB(60, 60, 70)
    mainFrame.Visible = false
    mainFrame.Parent = screenGui
    mainFrame.ClipsDescendants = true

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = mainFrame

    -- Заголовок
    local title = Instance.new("Frame")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    title.BackgroundTransparency = 0
    title.BorderSizePixel = 0
    title.Parent = mainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 10)
    titleCorner.Parent = title

    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -40, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "✦ TSUM ESP ✦"
    titleText.TextColor3 = Color3.fromRGB(255, 215, 0)
    titleText.TextSize = 18
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = title

    -- Кнопка закрытия
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -34, 0, 6)
    closeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    closeBtn.BackgroundTransparency = 0
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = mainFrame

    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 5)
    closeCorner.Parent = closeBtn

    closeBtn.MouseButton1Click:Connect(function()
        mainFrame.Visible = false
        MenuOpen = false
    end)

    closeBtn.MouseEnter:Connect(function()
        closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end)

    closeBtn.MouseLeave:Connect(function()
        closeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
    end)

    -- Контейнер
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 1, -50)
    container.Position = UDim2.new(0, 10, 0, 45)
    container.BackgroundTransparency = 1
    container.Parent = mainFrame

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.Position = UDim2.new(0, 0, 0, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.CanvasSize = UDim2.new(0, 0, 0, 350)
    scroll.Parent = container

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll

    -- Функции создания элементов
    local function CreateSlider(parent, name, min, max, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 45)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        frame.LayoutOrder = #parent:GetChildren() + 1

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.6, 0, 0, 18)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.fromRGB(220, 220, 230)
        label.TextSize = 14
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame

        local valueDisplay = Instance.new("TextLabel")
        valueDisplay.Size = UDim2.new(0.3, 0, 0, 18)
        valueDisplay.Position = UDim2.new(0.7, 0, 0, 0)
        valueDisplay.BackgroundTransparency = 1
        valueDisplay.Text = tostring(default)
        valueDisplay.TextColor3 = Color3.fromRGB(255, 215, 0)
        valueDisplay.TextSize = 14
        valueDisplay.Font = Enum.Font.GothamBold
        valueDisplay.TextXAlignment = Enum.TextXAlignment.Right
        valueDisplay.Parent = frame

        local slider = Instance.new("Frame")
        slider.Size = UDim2.new(1, 0, 0, 6)
        slider.Position = UDim2.new(0, 0, 0, 24)
        slider.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
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

    local function CreateToggle(parent, name, default, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 32)
        frame.BackgroundTransparency = 1
        frame.Parent = parent
        frame.LayoutOrder = #parent:GetChildren() + 1

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.Position = UDim2.new(0, 0, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.fromRGB(220, 220, 230)
        label.TextSize = 14
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame

        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0, 45, 0, 24)
        toggle.Position = UDim2.new(1, -45, 0.5, -12)
        toggle.BackgroundColor3 = default and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(50, 50, 65)
        toggle.Text = default and "ON" or "OFF"
        toggle.TextColor3 = default and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(200, 200, 200)
        toggle.TextSize = 12
        toggle.Font = Enum.Font.GothamBold
        toggle.BorderSizePixel = 0
        toggle.Parent = frame

        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(0, 5)
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

    -- Элементы меню
    CreateToggle(scroll, "ESP Enabled", Settings.Enabled, function(val)
        Settings.Enabled = val
    end)

    CreateSlider(scroll, "Price Threshold", 50, 5000, Settings.PriceThreshold, function(val)
        Settings.PriceThreshold = val
    end)

    CreateToggle(scroll, "Show Boxes", Settings.ShowBoxes, function(val)
        Settings.ShowBoxes = val
    end)

    CreateToggle(scroll, "Show Names", Settings.ShowNames, function(val)
        Settings.ShowNames = val
    end)

    CreateToggle(scroll, "Show Distance", Settings.ShowDistance, function(val)
        Settings.ShowDistance = val
    end)

    CreateSlider(scroll, "Max Distance", 50, 500, Settings.MaxRenderDistance, function(val)
        Settings.MaxRenderDistance = val
    end)

    -- Перетаскивание
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

-- ===== ОПТИМИЗИРОВАННАЯ ФУНКЦИЯ ПОИСКА ЦЕНЫ =====
local function GetItemPrice(part)
    -- Быстрая проверка атрибутов
    local price = part:GetAttribute("Value") or part:GetAttribute("Price") or part:GetAttribute("Cost") or 0
    if type(price) == "number" and price > 0 then 
        return price 
    end

    -- Проверка дочерних объектов (только первый уровень для скорости)
    local children = part:GetChildren()
    for i = 1, #children do
        local child = children[i]
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

-- ===== ОСНОВНОЙ ЦИКЛ ESP (ОПТИМИЗИРОВАННЫЙ) =====
local function UpdateEsp()
    if not Settings.Enabled then
        for _, data in pairs(EspObjects) do
            if data.label then data.label.Visible = false end
            if data.box then data.box.Visible = false end
        end
        return
    end

    -- Получаем все части в мире
    local parts = workspace:GetDescendants()
    local processed = {}
    local count = 0

    for i = 1, #parts do
        local part = parts[i]
        
        if count >= Settings.MaxItems then break end
        
        if part:IsA("BasePart") and part.Parent then
            -- Пропускаем части игроков
            local character = part.Parent
            if character and character:IsA("Model") and character:FindFirstChild("Humanoid") then
                goto continue
            end
            
            -- Проверяем, что это не часть игрока (дополнительная проверка)
            if LocalPlayer.Character and part:IsDescendantOf(LocalPlayer.Character) then
                goto continue
            end
            
            local price = GetItemPrice(part)
            if price >= Settings.PriceThreshold then
                count = count + 1
                local key = part

                if not EspObjects[key] then
                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(0, 200, 0, 30)
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
                    box.Size = UDim2.new(0, 60, 0, 60)
                    box.BackgroundTransparency = 0.5
                    box.BackgroundColor3 = Settings.BoxColor
                    box.BorderSizePixel = 2
                    box.BorderColor3 = Settings.BoxColor
                    box.Visible = true
                    box.Parent = CreateEspGui()
                    box.ZIndex = 9

                    EspObjects[key] = {
                        label = label,
                        box = box,
                        part = part,
                        lastUpdate = tick()
                    }
                end
                processed[key] = true
            end
        end
        ::continue::
    end

    -- Удаляем старые ESP
    for key, data in pairs(EspObjects) do
        if not processed[key] or not data.part or not data.part.Parent then
            if data.label then data.label:Destroy() end
            if data.box then data.box:Destroy() end
            EspObjects[key] = nil
        end
    end

    -- Обновляем позиции
    local cameraPos = Camera.CFrame.Position
    for _, data in pairs(EspObjects) do
        if data.part and data.part.Parent then
            local position, visible = Camera:WorldToScreenPoint(data.part.Position)
            if not visible then
                data.label.Visible = false
                data.box.Visible = false
                goto continue2
            end

            local distance = (cameraPos - data.part.Position).Magnitude

            if distance > Settings.MaxRenderDistance then
                data.label.Visible = false
                data.box.Visible = false
                goto continue2
            end

            -- Обновляем текст
            if Settings.ShowNames then
                local price = GetItemPrice(data.part)
                local text = "💰 " .. tostring(price)
                if Settings.ShowDistance then
                    text = text .. " [" .. math.floor(distance) .. "m]"
                end
                data.label.Text = text
                data.label.Position = UDim2.new(0, position.X - 100, 0, position.Y - 45)
                data.label.Visible = true
            else
                data.label.Visible = false
            end

            -- Обновляем рамку
            if Settings.ShowBoxes then
                local size = math.max(20, 50 / (distance / 30 + 1))
                data.box.Size = UDim2.new(0, size, 0, size)
                data.box.Position = UDim2.new(0, position.X - size/2, 0, position.Y - size/2)
                data.box.Visible = true
            else
                data.box.Visible = false
            end
        end
        ::continue2::
    end
end

-- ===== ЗАПУСК =====
local MenuGui, MenuFrame = CreateMenu()

local function ToggleMenu()
    MenuOpen = not MenuOpen
    MenuFrame.Visible = MenuOpen
end

-- Обработка клавиш
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode[Settings.Keybind] then
        ToggleMenu()
    end
end)

Mouse.KeyDown:Connect(function(key)
    if key == Settings.Keybind then
        ToggleMenu()
    end
end)

-- Запуск ESP с оптимизацией
Connection = RunService.Heartbeat:Connect(function(delta)
    UpdateTimer = UpdateTimer + delta
    if UpdateTimer >= Settings.UpdateRate then
        UpdateTimer = 0
        UpdateEsp()
    end
end)

print("[ESP] Оптимизированная версия запущена!")
print("[ESP] Нажмите F5 для открытия меню")
print("[ESP] ESP работает ТОЛЬКО на вещи, НЕ на игроков")

if IsXeno and Xeno.Notify then
    Xeno:Notify("[ESP] Запущен! (оптимизированная версия)", 3)
end

-- Очистка
LocalPlayer.OnTeleport:Connect(function()
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

--[[
    ИСПРАВЛЕНИЯ:
    1. Убрана зависимость от game:HttpGet (ошибка на строке 1)
    2. Оптимизирован цикл обновления
    3. Добавлена проверка на части игрока
    4. Уменьшено потребление ресурсов
    
    ТЕПЕРЬ СКРИПТ ДОЛЖЕН РАБОТАТЬ БЕЗ ОШИБОК!
--]]
