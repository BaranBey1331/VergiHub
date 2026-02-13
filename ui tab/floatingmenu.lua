--[[
    VergiHub - Floating Menu Button v1.0
    Sürüklenebilir tetik butonu - menüyü açıp kapatır
    Mobil ve PC uyumlu
]]

local Settings = getgenv().VergiHub
local Theme = Settings.UI.Theme

-- Servisler
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

-- Eski varsa kaldır
if game.CoreGui:FindFirstChild("VergiHubFloat") then
    game.CoreGui:FindFirstChild("VergiHubFloat"):Destroy()
end

-- ScreenGui
local FloatGui = Instance.new("ScreenGui")
FloatGui.Name = "VergiHubFloat"
FloatGui.ResetOnSpawn = false
FloatGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
FloatGui.Parent = game.CoreGui

-- Ana buton
local FloatButton = Instance.new("TextButton")
FloatButton.Name = "FloatBtn"
FloatButton.Size = UDim2.new(0, 50, 0, 50)
FloatButton.Position = UDim2.new(0, 20, 0.5, -25)
FloatButton.BackgroundColor3 = Theme.Primary
FloatButton.Text = "🔮"
FloatButton.TextSize = 22
FloatButton.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatButton.Font = Enum.Font.GothamBold
FloatButton.BorderSizePixel = 0
FloatButton.AutoButtonColor = false
FloatButton.Parent = FloatGui

-- Yuvarlak köşe
local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(1, 0)
btnCorner.Parent = FloatButton

-- Parlama efekti
local stroke = Instance.new("UIStroke")
stroke.Color = Theme.Accent
stroke.Thickness = 2
stroke.Transparency = 0.3
stroke.Parent = FloatButton

-- Sürükleme sistemi
local dragging = false
local dragStart = nil
local startPos = nil
local hasMoved = false

FloatButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        hasMoved = false
        dragStart = input.Position
        startPos = FloatButton.Position
        
        -- Basılı tutma animasyonu
        TweenService:Create(FloatButton, TweenInfo.new(0.15), {
            Size = UDim2.new(0, 55, 0, 55),
            BackgroundColor3 = Theme.Accent
        }):Play()
    end
end)

FloatButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
        
        -- Bırakma animasyonu
        TweenService:Create(FloatButton, TweenInfo.new(0.15), {
            Size = UDim2.new(0, 50, 0, 50),
            BackgroundColor3 = Theme.Primary
        }):Play()
        
        -- Sürüklenmediyse tıklama olarak kabul et (menüyü aç/kapat)
        if not hasMoved then
            local mainUI = game.CoreGui:FindFirstChild("VergiHubUI")
            if mainUI then
                local mainFrame = mainUI:FindFirstChild("MainFrame")
                if mainFrame then
                    mainFrame.Visible = not mainFrame.Visible
                    
                    -- Tıklama geri bildirimi
                    TweenService:Create(FloatButton, TweenInfo.new(0.1), {
                        Size = UDim2.new(0, 45, 0, 45)
                    }):Play()
                    task.wait(0.1)
                    TweenService:Create(FloatButton, TweenInfo.new(0.1), {
                        Size = UDim2.new(0, 50, 0, 50)
                    }):Play()
                end
            end
        end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        
        -- 5 pikselden fazla hareket ettiyse sürükleme sayılır
        if delta.Magnitude > 5 then
            hasMoved = true
        end
        
        FloatButton.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- Nefes alma animasyonu (idle durumunda)
task.spawn(function()
    while FloatButton and FloatButton.Parent do
        if not dragging then
            TweenService:Create(stroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Transparency = 0.7
            }):Play()
            task.wait(1.5)
            
            if not dragging and FloatButton and FloatButton.Parent then
                TweenService:Create(stroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    Transparency = 0.2
                }):Play()
                task.wait(1.5)
            end
        else
            task.wait(0.1)
        end
    end
end)

print("[VergiHub] 🟣 Floating Menu hazır!")
return FloatButton
