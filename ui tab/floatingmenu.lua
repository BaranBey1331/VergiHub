--[[
    VergiHub - Floating Menu Button v2.0
    Emoji yerine minimal ikon, yeni palette
    Sürüklenebilir tetik butonu
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

-- Dış halka (glow efekti)
local glowRing = Instance.new("Frame")
glowRing.Name = "GlowRing"
glowRing.Size = UDim2.new(0, 58, 0, 58)
glowRing.Position = UDim2.new(0, 16, 0.5, -29)
glowRing.BackgroundColor3 = Theme.Primary
glowRing.BackgroundTransparency = 0.7
glowRing.BorderSizePixel = 0
glowRing.Parent = FloatGui

local glowCorner = Instance.new("UICorner")
glowCorner.CornerRadius = UDim.new(1, 0)
glowCorner.Parent = glowRing

-- Ana buton
local FloatButton = Instance.new("TextButton")
FloatButton.Name = "FloatBtn"
FloatButton.Size = UDim2.new(0, 48, 0, 48)
FloatButton.Position = UDim2.new(0, 21, 0.5, -24)
FloatButton.BackgroundColor3 = Theme.Primary
FloatButton.Text = ""
FloatButton.BorderSizePixel = 0
FloatButton.AutoButtonColor = false
FloatButton.ZIndex = 2
FloatButton.Parent = FloatGui

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(1, 0)
btnCorner.Parent = FloatButton

-- İç ikon: "V" harfi (VergiHub)
local iconLabel = Instance.new("TextLabel")
iconLabel.Text = "V"
iconLabel.Size = UDim2.new(1, 0, 1, 0)
iconLabel.BackgroundTransparency = 1
iconLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
iconLabel.TextSize = 22
iconLabel.Font = Enum.Font.GothamBold
iconLabel.ZIndex = 3
iconLabel.Parent = FloatButton

-- İnce kenarlık
local btnStroke = Instance.new("UIStroke")
btnStroke.Color = Color3.fromRGB(196, 181, 253) -- AccentGlow
btnStroke.Thickness = 1.5
btnStroke.Transparency = 0.4
btnStroke.Parent = FloatButton

-- Sürükleme sistemi
local dragging = false
local dragStart = nil
local startPos = nil
local glowStartPos = nil
local hasMoved = false

FloatButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        hasMoved = false
        dragStart = input.Position
        startPos = FloatButton.Position
        glowStartPos = glowRing.Position

        -- Basma animasyonu
        TweenService:Create(FloatButton, TweenInfo.new(0.12, Enum.EasingStyle.Quart), {
            Size = UDim2.new(0, 44, 0, 44),
            BackgroundColor3 = Color3.fromRGB(167, 139, 250) -- Accent
        }):Play()
        TweenService:Create(glowRing, TweenInfo.new(0.12), {
            BackgroundTransparency = 0.4,
            Size = UDim2.new(0, 62, 0, 62)
        }):Play()
    end
end)

FloatButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false

        -- Bırakma animasyonu
        TweenService:Create(FloatButton, TweenInfo.new(0.2, Enum.EasingStyle.Quart), {
            Size = UDim2.new(0, 48, 0, 48),
            BackgroundColor3 = Theme.Primary
        }):Play()
        TweenService:Create(glowRing, TweenInfo.new(0.3), {
            BackgroundTransparency = 0.7,
            Size = UDim2.new(0, 58, 0, 58)
        }):Play()

        -- Sürüklenmemişse tıklama = menü aç/kapat
        if not hasMoved then
            local mainUI = game.CoreGui:FindFirstChild("VergiHubUI")
            if mainUI then
                local mainFrame = mainUI:FindFirstChild("MainFrame")
                if mainFrame then
                    mainFrame.Visible = not mainFrame.Visible

                    -- Tıklama pulse efekti
                    TweenService:Create(FloatButton, TweenInfo.new(0.08), {
                        Size = UDim2.new(0, 42, 0, 42)
                    }):Play()
                    task.wait(0.08)
                    TweenService:Create(FloatButton, TweenInfo.new(0.15, Enum.EasingStyle.Back), {
                        Size = UDim2.new(0, 48, 0, 48)
                    }):Play()
                end
            end
        end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart

        if delta.Magnitude > 5 then
            hasMoved = true
        end

        FloatButton.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
        glowRing.Position = UDim2.new(
            glowStartPos.X.Scale, glowStartPos.X.Offset + delta.X,
            glowStartPos.Y.Scale, glowStartPos.Y.Offset + delta.Y
        )
    end
end)

-- Nefes animasyonu (idle)
task.spawn(function()
    while FloatButton and FloatButton.Parent do
        if not dragging then
            TweenService:Create(btnStroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Transparency = 0.8
            }):Play()
            TweenService:Create(glowRing, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundTransparency = 0.85
            }):Play()
            task.wait(2)

            if not dragging and FloatButton and FloatButton.Parent then
                TweenService:Create(btnStroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    Transparency = 0.3
                }):Play()
                TweenService:Create(glowRing, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    BackgroundTransparency = 0.6
                }):Play()
                task.wait(2)
            end
        else
            task.wait(0.1)
        end
    end
end)

print("[VergiHub] Floating Menu v2 hazir!")
return FloatButton
