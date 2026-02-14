--[[
    VergiHub - Arsenal UI Panel (Liquid Glass)
    Ana UI Settings tab'ına Arsenal cam kartı ekler
]]

local Settings = getgenv().VergiHub
local GE = getgenv().VergiHub.GlassEngine
local P = GE.Palette
local TweenService = game:GetService("TweenService")

-- Ana UI'yı bekle
local attempts = 0
local glassUI = nil

repeat
    glassUI = getgenv().VergiHub._GlassUI
    attempts = attempts + 1
    task.wait(0.2)
until glassUI or attempts > 30

if not glassUI then
    warn("[Arsenal UI] Glass UI bulunamadi!")
    return
end

local ContentArea = glassUI.ContentArea
if not ContentArea then return end

local settingsPage = ContentArea:FindFirstChild("Page_Settings")
if not settingsPage then return end

-- ==========================================
-- ARSENAL CAM KARTI
-- ==========================================

-- Section header
local sectionHolder = Instance.new("Frame")
sectionHolder.Size = UDim2.new(1, 0, 0, 28)
sectionHolder.BackgroundTransparency = 1
sectionHolder.LayoutOrder = 100
sectionHolder.ZIndex = 5
sectionHolder.Parent = settingsPage

local sLine = Instance.new("Frame")
sLine.Size = UDim2.new(0, 18, 0, 1)
sLine.Position = UDim2.new(0, 0, 0.5, 0)
sLine.BackgroundColor3 = P.Success
sLine.BackgroundTransparency = 0.4
sLine.BorderSizePixel = 0
sLine.ZIndex = 6
sLine.Parent = sectionHolder

local sLabel = Instance.new("TextLabel")
sLabel.Text = "GAME MODULE"
sLabel.Size = UDim2.new(1, -26, 1, 0)
sLabel.Position = UDim2.new(0, 24, 0, 0)
sLabel.BackgroundTransparency = 1
sLabel.TextColor3 = P.TextMuted
sLabel.TextSize = 10
sLabel.Font = Enum.Font.GothamBold
sLabel.TextXAlignment = Enum.TextXAlignment.Left
sLabel.ZIndex = 6
sLabel.Parent = sectionHolder

-- Arsenal cam kartı
local arsenalGlass = GE.createGlassPanel(settingsPage, {
    Size = UDim2.new(1, 0, 0, 115),
    Color = Color3.fromRGB(12, 25, 18),
    Transparency = 0.30,
    Corner = 14,
    ZIndex = 5,
    AccentGlow = P.Success,
})

arsenalGlass.Container.LayoutOrder = 101

-- Sol accent
local accentBar = Instance.new("Frame")
accentBar.Size = UDim2.new(0, 3, 1, -14)
accentBar.Position = UDim2.new(0, 6, 0, 7)
accentBar.BackgroundColor3 = P.Success
accentBar.BorderSizePixel = 0
accentBar.ZIndex = 7
accentBar.Parent = arsenalGlass.Container
Instance.new("UICorner", accentBar).CornerRadius = UDim.new(0, 2)

-- Status dot
local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.new(0, 10, 0, 10)
statusDot.Position = UDim2.new(0, 18, 0, 14)
statusDot.BackgroundColor3 = P.Success
statusDot.BorderSizePixel = 0
statusDot.ZIndex = 7
statusDot.Parent = arsenalGlass.Container
Instance.new("UICorner", statusDot).CornerRadius = UDim.new(1, 0)

-- Başlık
local titleLbl = Instance.new("TextLabel")
titleLbl.Text = "Arsenal — Active"
titleLbl.Size = UDim2.new(1, -44, 0, 20)
titleLbl.Position = UDim2.new(0, 34, 0, 10)
titleLbl.BackgroundTransparency = 1
titleLbl.TextColor3 = P.Success
titleLbl.TextSize = 14
titleLbl.Font = Enum.Font.GothamBold
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.ZIndex = 7
titleLbl.Parent = arsenalGlass.Container

-- Bilgi satırları
local arsenalInfo = {
    {label = "Aimbot", value = "Loaded", color = P.Success},
    {label = "ESP", value = "Universal", color = P.TextSecondary},
    {label = "Prediction", value = "Optimized", color = P.AccentSecondary},
}

for i, info in ipairs(arsenalInfo) do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -32, 0, 18)
    row.Position = UDim2.new(0, 18, 0, 36 + (i - 1) * 22)
    row.BackgroundTransparency = 1
    row.ZIndex = 7
    row.Parent = arsenalGlass.Container

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 4, 0, 4)
    dot.Position = UDim2.new(0, 2, 0.5, -2)
    dot.BackgroundColor3 = info.color
    dot.BorderSizePixel = 0
    dot.ZIndex = 8
    dot.Parent = row
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local lbl = Instance.new("TextLabel")
    lbl.Text = info.label
    lbl.Size = UDim2.new(0.5, -12, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = P.TextSecondary
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 8
    lbl.Parent = row

    local val = Instance.new("TextLabel")
    val.Text = info.value
    val.Size = UDim2.new(0.5, 0, 1, 0)
    val.BackgroundTransparency = 1
    val.TextColor3 = info.color
    val.TextSize = 12
    val.Font = Enum.Font.GothamSemibold
    val.TextXAlignment = Enum.TextXAlignment.Right
    val.ZIndex = 8
    val.Parent = row
end

-- Status dot yanıp sönme
task.spawn(function()
    while statusDot and statusDot.Parent do
        TweenService:Create(statusDot, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            BackgroundTransparency = 0.5
        }):Play()
        task.wait(1.2)
        if statusDot and statusDot.Parent then
            TweenService:Create(statusDot, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundTransparency = 0
            }):Play()
            task.wait(1.2)
        end
    end
end)

print("[VergiHub] Arsenal Glass UI hazir!")
return true
