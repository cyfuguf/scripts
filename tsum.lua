-- МИНИМАЛЬНЫЙ ТЕСТОВЫЙ СКРИПТ
print("СКРИПТ ЗАПУЩЕН!")

local function Test()
    print("F5 НАЖАТ!")
end

game:GetService("UserInputService").InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F5 then
        Test()
    end
end)

-- Создаём простую рамку для проверки
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0.5, -100, 0.5, -50)
frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
frame.BackgroundTransparency = 0.5
frame.Parent = LocalPlayer.PlayerGui

print("✅ ТЕСТОВЫЙ СКРИПТ ЗАПУЩЕН! Нажми F5")
