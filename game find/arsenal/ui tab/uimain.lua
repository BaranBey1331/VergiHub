--[[
    VergiHub - Arsenal UI Panel v1.0
    Arsenal'a özel ek ayar paneli
    Ana UI'daki Ayarlar tab'ına Arsenal bölümü ekler
]]

local Settings = getgenv().VergiHub
local Theme = Settings.UI.Theme

-- Servisler
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
    warn("[Arsenal UI] Ana UI bulunamadı!")
    return
end

-- Ana MainFrame'i bul
local MainFrame = mainUI:FindFirstChild("MainFrame")
if not MainFrame then
    warn("[Arsenal UI] MainFrame bulunamadı!")
    return
end

-- ContentArea'yı bul
local ContentArea = MainFrame:FindFirstChild("ContentArea")
if not ContentArea then
    warn("[Arsenal UI] ContentArea bulunamadı!")
    return
end

-- ==========================================
-- ARSENAL ÖZEL BİLGİ PANELİ
-- ==========================================

-- Arsenal bilgi frame'i oluştur (mevcut Ayarlar sayfasının altına)
-- Ayarlar sayfasını bul
local settingsPage = ContentArea:FindFirstChild("Page_Ayarlar")
if settingsPage then
    -- Arsenal bölüm başlığı
    local arsenalHeader = Instance.new("TextLabel")
    arsenalHeader.Text = "━━ 🎮 Arsenal Modu (Aktif) ━━"
    arsenalHeader.Size = UDim2.new(1, 0, 0, 28)
    arsenalHeader.BackgroundTransparency = 1
    arsenalHeader.TextColor3 = Color3.fromRGB(255, 165, 0) -- Turuncu
    arsenalHeader.TextSize = 14
    arsenalHeader.Font = Enum.Font.GothamBold
    arsenalHeader.LayoutOrder = 100
    arsenalHeader.Parent = settingsPage

    -- Arsenal bilgi kutusu
    local arsenalInfo = Instance.new("Frame")
    arsenalInfo.Size = UDim2.new(1, 0, 0, 90)
    arsenalInfo.BackgroundColor3 = Color3.fromRGB(30, 28, 18)
    arsenalInfo.BorderSizePixel = 0
    arsenalInfo.LayoutOrder = 101
    arsenalInfo.Parent = settingsPage

    local infoCorner = Instance.new("UICorner")
    infoCorner.CornerRadius = UDim.new(0, 8)
    infoCorner.Parent = arsenalInfo

    -- Sol accent
    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 4, 1, -8)
    accent.Position = UDim2.new(0, 4, 0, 4)
    accent.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
    accent.BorderSizePixel = 0
    accent.Parent = arsenalInfo

    local acCorner = Instance.new("UICorner")
    acCorner.CornerRadius = UDim.new(0, 2)
    acCorner.Parent = accent

    -- Bilgi yazısı
    local infoText = Instance.new("TextLabel")
    infoText.Text = "🎮 Arsenal Modu Aktif\n\n🎯 Arsenal Aimbot: Yüklendi\n👁️ Arsenal ESP: Evrensel ESP kullanılıyor\n⚡ Optimizasyon: Arsenal'a özel prediction aktif"
    infoText.Size = UDim2.new(1, -24, 1, -8)
    infoText.Position = UDim2.new(0, 16, 0, 4)
    infoText.BackgroundTransparency = 1
    infoText.TextColor3 = Color3.fromRGB(220, 200, 150)
    infoText.TextSize = 12
    infoText.Font = Enum.Font.Gotham
    infoText.TextWrapped = true
    infoText.TextXAlignment = Enum.TextXAlignment.Left
    infoText.TextYAlignment = Enum.TextYAlignment.Top
    infoText.Parent = arsenalInfo

    -- Durum göstergesi (yanıp sönen)
    local statusDot = Instance.new("Frame")
    statusDot.Size = UDim2.new(0, 10, 0, 10)
    statusDot.Position = UDim2.new(1, -20, 0, 8)
    statusDot.BackgroundColor3 = Color3.fromRGB(80, 220, 100)
    statusDot.BorderSizePixel = 0
    statusDot.Parent = arsenalInfo

    local dotCorner = Instance.new("UICorner")
    dotCorner.CornerRadius = UDim.new(1, 0)
    dotCorner.Parent = statusDot

    -- Yanıp sönme animasyonu
    task.spawn(function()
        while statusDot and statusDot.Parent do
            TweenService:Create(statusDot, TweenInfo.new(1, Enum.EasingStyle.Sine), {
                BackgroundTransparency = 0.6
            }):Play()
            task.wait(1)
            
            if statusDot and statusDot.Parent then
                TweenService:Create(statusDot, TweenInfo.new(1, Enum.EasingStyle.Sine), {
                    BackgroundTransparency = 0
                }):Play()
                task.wait(1)
            end
        end
    end)
end

print("[VergiHub] 🎮 Arsenal UI Panel hazır!")
return true
