--[[
    VergiHub - Arsenal UI Panel v1.1
    Yeni palette ile Arsenal bilgi paneli
    Ana UI Settings tab'ına Arsenal bölümü ekler
]]

local Settings = getgenv().VergiHub
local Theme = Settings.UI.Theme

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Ana UI'yı bekle
local mainUI = nil
local attempts = 0

repeat
    mainUI = game.CoreGui:FindFirstChild("VergiHubUI")
    attempts = attempts + 1
    task.wait(0.2)
until mainUI or attempts > 25

if not mainUI then
    warn("[Arsenal UI] Main UI not found!")
    return
end

local MainFrame = mainUI:FindFirstChild("MainFrame")
if not MainFrame then return end

local ContentArea = MainFrame:FindFirstChild("ContentArea")
if not ContentArea then return end

local settingsPage = ContentArea:FindFirstChild("Page_Settings")
if not settingsPage then return end

-- ==========================================
-- ARSENAL DURUM KARTI
-- ==========================================

-- Bölüm başlığı
local sectionHeader = Instance.new("Frame")
sectionHeader.Size = UDim2.new(1, 0, 0, 26)
sectionHeader.BackgroundTransparency = 1
sectionHeader.LayoutOrder = 100
sectionHeader.Parent = settingsPage

local leftLine = Instance.new("Frame")
leftLine.Size = UDim2.new(0, 16, 0, 1)
leftLine.Position = UDim2.new(0, 0, 0.5, 0)
leftLine.BackgroundColor3 = Theme.Border
leftLine.BorderSizePixel = 0
leftLine.Parent = sectionHeader

local sectionLabel = Instance.new("TextLabel")
sectionLabel.Text = "GAME MODULE"
sectionLabel.Size = UDim2.new(1, -24, 1, 0)
sectionLabel.Position = UDim2.new(0, 22, 0, 0)
sectionLabel.BackgroundTransparency = 1
sectionLabel.TextColor3 = Color3.fromRGB(100, 116, 139)
sectionLabel.TextSize = 11
sectionLabel.Font = Enum.Font.GothamBold
sectionLabel.TextXAlignment = Enum.TextXAlignment.Left
sectionLabel.Parent = sectionHeader

-- Ana kart
local arsenalCard = Instance.new("Frame")
arsenalCard.Size = UDim2.new(1, 0, 0, 110)
arsenalCard.BackgroundColor3 = Color3.fromRGB(21, 23, 34)
arsenalCard.BorderSizePixel = 0
arsenalCard.LayoutOrder = 101
arsenalCard.Parent = settingsPage

local cardCorner = Instance.new("UICorner")
cardCorner.CornerRadius = UDim.new(0, 10)
cardCorner.Parent = arsenalCard

-- Kenarlık
local cardStroke = Instance.new("UIStroke")
cardStroke.Color = Theme.Success
cardStroke.Thickness = 1
cardStroke.Transparency = 0.6
cardStroke.Parent = arsenalCard

-- Sol accent bar
local accentBar = Instance.new("Frame")
accentBar.Size = UDim2.new(0, 3, 1, -12)
accentBar.Position = UDim2.new(0, 5, 0, 6)
accentBar.BackgroundColor3 = Theme.Success
accentBar.BorderSizePixel = 0
accentBar.Parent = arsenalCard

local abCorner = Instance.new("UICorner")
abCorner.CornerRadius = UDim.new(0, 2)
abCorner.Parent = accentBar

-- Durum ikonu (yeşil daire)
local statusCircle = Instance.new("Frame")
statusCircle.Size = UDim2.new(0, 10, 0, 10)
statusCircle.Position = UDim2.new(0, 16, 0, 14)
statusCircle.BackgroundColor3 = Theme.Success
statusCircle.BorderSizePixel = 0
statusCircle.Parent = arsenalCard

local scCorner = Instance.new("UICorner")
scCorner.CornerRadius = UDim.new(1, 0)
scCorner.Parent = statusCircle

-- Başlık
local gameTitle = Instance.new("TextLabel")
gameTitle.Text = "Arsenal — Active"
gameTitle.Size = UDim2.new(1, -40, 0, 20)
gameTitle.Position = UDim2.new(0, 32, 0, 10)
gameTitle.BackgroundTransparency = 1
gameTitle.TextColor3 = Theme.Success
gameTitle.TextSize = 14
gameTitle.Font = Enum.Font.GothamBold
gameTitle.TextXAlignment = Enum.TextXAlignment.Left
gameTitle.Parent = arsenalCard

-- Bilgi satırları
local infoData = {
    {label = "Aimbot", value = "Loaded", color = Theme.Success},
    {label = "ESP", value = "Universal", color = Color3.fromRGB(148, 163, 184)},
    {label = "Prediction", value = "Optimized", color = Theme.Accent},
}

for i, info in ipairs(infoData) do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -32, 0, 18)
    row.Position = UDim2.new(0, 16, 0, 34 + (i - 1) * 22)
    row.BackgroundTransparency = 1
    row.Parent = arsenalCard

    -- Küçük nokta
    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 4, 0, 4)
    dot.Position = UDim2.new(0, 2, 0.5, -2)
    dot.BackgroundColor3 = info.color
    dot.BorderSizePixel = 0
    dot.Parent = row

    local dCorner = Instance.new("UICorner")
    dCorner.CornerRadius = UDim.new(1, 0)
    dCorner.Parent = dot

    local lbl = Instance.new("TextLabel")
    lbl.Text = info.label
    lbl.Size = UDim2.new(0.5, -12, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(148, 163, 184)
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local val = Instance.new("TextLabel")
    val.Text = info.value
    val.Size = UDim2.new(0.5, 0, 1, 0)
    val.BackgroundTransparency = 1
    val.TextColor3 = info.color
    val.TextSize = 12
    val.Font = Enum.Font.GothamSemibold
    val.TextXAlignment = Enum.TextXAlignment.Right
    val.Parent = row
end

-- Durum noktası yanıp sönme animasyonu
task.spawn(function()
    while statusCircle and statusCircle.Parent do
        TweenService:Create(statusCircle, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            BackgroundTransparency = 0.5
        }):Play()
        task.wait(1.2)

        if statusCircle and statusCircle.Parent then
            TweenService:Create(statusCircle, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundTransparency = 0
            }):Play()
            task.wait(1.2)
        end
    end
end)

print("[VergiHub] Arsenal UI Panel v1.1 hazir!")
return true
