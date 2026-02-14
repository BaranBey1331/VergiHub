--[[
    VergiHub - Floating Menu Button v3.0
    Glass UI ile tam entegrasyon
    Kapatinca/minimize'da floating menu geri gelir
]]

local Settings = getgenv().VergiHub

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

if game.CoreGui:FindFirstChild("VergiHubFloat") then
    game.CoreGui:FindFirstChild("VergiHubFloat"):Destroy()
end

local FloatGui = Instance.new("ScreenGui")
FloatGui.Name = "VergiHubFloat"
FloatGui.ResetOnSpawn = false
FloatGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
FloatGui.Parent = game.CoreGui

-- Glow ring
local glowRing = Instance.new("Frame")
glowRing.Size = UDim2.new(0, 58, 0, 58)
glowRing.Position = UDim2.new(0, 16, 0.5, -29)
glowRing.BackgroundColor3 = Color3.fromRGB(120, 80, 255)
glowRing.BackgroundTransparency = 0.65
glowRing.BorderSizePixel = 0
glowRing.Parent = FloatGui
Instance.new("UICorner", glowRing).CornerRadius = UDim.new(1, 0)

-- Ana buton
local FloatButton = Instance.new("TextButton")
FloatButton.Size = UDim2.new(0, 48, 0, 48)
FloatButton.Position = UDim2.new(0, 21, 0.5, -24)
FloatButton.BackgroundColor3 = Color3.fromRGB(120, 80, 255)
FloatButton.BackgroundTransparency = 0.15
FloatButton.Text = ""
FloatButton.BorderSizePixel = 0
FloatButton.AutoButtonColor = false
FloatButton.ZIndex = 2
FloatButton.Parent = FloatGui
Instance.new("UICorner", FloatButton).CornerRadius = UDim.new(1, 0)

local btnStroke = Instance.new("UIStroke")
btnStroke.Color = Color3.fromRGB(196, 181, 253)
btnStroke.Thickness = 1.5
btnStroke.Transparency = 0.35
btnStroke.Parent = FloatButton

-- V ikonu
local iconLbl = Instance.new("TextLabel")
iconLbl.Text = "V"
iconLbl.Size = UDim2.new(1, 0, 1, 0)
iconLbl.BackgroundTransparency = 1
iconLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
iconLbl.TextSize = 22
iconLbl.Font = Enum.Font.GothamBold
iconLbl.ZIndex = 3
iconLbl.Parent = FloatButton

-- Frost
local btnFrost = Instance.new("Frame")
btnFrost.Size = UDim2.new(1, -4, 0.45, 0)
btnFrost.Position = UDim2.new(0, 2, 0, 2)
btnFrost.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
btnFrost.BackgroundTransparency = 0.8
btnFrost.BorderSizePixel = 0
btnFrost.ZIndex = 2
btnFrost.Parent = FloatButton
Instance.new("UICorner", btnFrost).CornerRadius = UDim.new(1, 0)

local fGrad = Instance.new("UIGradient")
fGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.6),
    NumberSequenceKeypoint.new(1, 1),
})
fGrad.Rotation = 90
fGrad.Parent = btnFrost

-- Surükleme
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

        TweenService:Create(FloatButton, TweenInfo.new(0.1), {
            Size = UDim2.new(0, 44, 0, 44),
            BackgroundTransparency = 0.05,
        }):Play()
    end
end)

FloatButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false

        TweenService:Create(FloatButton, TweenInfo.new(0.15, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, 48, 0, 48),
            BackgroundTransparency = 0.15,
        }):Play()

        -- Tiklanma (suruklenmediyse) = menu toggle
        if not hasMoved then
            -- Glass UI'yi toggle et
            local glassUI = getgenv().VergiHub._GlassUI
            if glassUI and glassUI.setMenuVisible and glassUI.isMenuVisible then
                local currentlyVisible = glassUI.isMenuVisible()
                glassUI.setMenuVisible(not currentlyVisible)
            end

            -- Pulse efekti
            TweenService:Create(FloatButton, TweenInfo.new(0.06), {
                Size = UDim2.new(0, 42, 0, 42)
            }):Play()
            task.wait(0.06)
            TweenService:Create(FloatButton, TweenInfo.new(0.12, Enum.EasingStyle.Back), {
                Size = UDim2.new(0, 48, 0, 48)
            }):Play()
        end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        if delta.Magnitude > 5 then hasMoved = true end

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

-- Nefes animasyonu
task.spawn(function()
    while FloatButton and FloatButton.Parent do
        if not dragging then
            TweenService:Create(btnStroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                Transparency = 0.75
            }):Play()
            TweenService:Create(glowRing, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundTransparency = 0.82
            }):Play()
            task.wait(2)

            if not dragging and FloatButton and FloatButton.Parent then
                TweenService:Create(btnStroke, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    Transparency = 0.3
                }):Play()
                TweenService:Create(glowRing, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                    BackgroundTransparency = 0.55
                }):Play()
                task.wait(2)
            end
        else
            task.wait(0.1)
        end
    end
end)

print("[VergiHub] Floating Menu v3.0 hazir!")
return FloatButton
