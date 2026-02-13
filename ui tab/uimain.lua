--[[
    VergiHub - UI Dashboard v1.0
    Tab sistemi ile aimbot ve ESP ayarları
    Modern, sürüklenebilir arayüz
]]

local Settings = getgenv().VergiHub
local Theme = Settings.UI.Theme

-- Servisler
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- UI kaldır (varsa)
if game.CoreGui:FindFirstChild("VergiHubUI") then
    game.CoreGui:FindFirstChild("VergiHubUI"):Destroy()
end

-- Ana ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VergiHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game.CoreGui

-- ==========================================
-- YARDIMCI FONKSİYONLAR
-- ==========================================

-- Yumuşak geçiş animasyonu
local function tween(obj, props, duration)
    local t = TweenService:Create(obj, TweenInfo.new(duration or 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

-- Köşeleri yuvarlatılmış frame oluştur
local function createRound(parent, props)
    local frame = Instance.new("Frame")
    frame.BackgroundColor3 = props.Color or Theme.Secondary
    frame.Size = props.Size or UDim2.new(1, 0, 1, 0)
    frame.Position = props.Position or UDim2.new(0, 0, 0, 0)
    frame.BorderSizePixel = 0
    frame.Name = props.Name or "Frame"
    frame.Parent = parent
    
    if props.Corner then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, props.Corner)
        corner.Parent = frame
    end
    
    return frame
end

-- ==========================================
-- ANA PENCERE
-- ==========================================

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 520, 0, 420)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -210)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.Parent = ScreenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = MainFrame

-- Ana çerçeve gölgesi
local shadow = Instance.new("ImageLabel")
shadow.Name = "Shadow"
shadow.BackgroundTransparency = 1
shadow.Position = UDim2.new(0, -15, 0, -15)
shadow.Size = UDim2.new(1, 30, 1, 30)
shadow.ZIndex = 0
shadow.Image = "rbxassetid://6014261993"
shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
shadow.ImageTransparency = 0.5
shadow.ScaleType = Enum.ScaleType.Slice
shadow.SliceCenter = Rect.new(49, 49, 450, 450)
shadow.Parent = MainFrame

-- ==========================================
-- ÜST BAR (Sürüklenebilir)
-- ==========================================

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Theme.TopBar
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 10)
topCorner.Parent = TopBar

-- Alt köşeleri düzelt
local topFix = Instance.new("Frame")
topFix.Size = UDim2.new(1, 0, 0, 12)
topFix.Position = UDim2.new(0, 0, 1, -12)
topFix.BackgroundColor3 = Theme.TopBar
topFix.BorderSizePixel = 0
topFix.Parent = TopBar

-- Logo ve başlık
local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "🔮 VergiHub"
titleLabel.Size = UDim2.new(0, 200, 1, 0)
titleLabel.Position = UDim2.new(0, 15, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Theme.Accent
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = TopBar

-- Versiyon
local versionLabel = Instance.new("TextLabel")
versionLabel.Text = "v" .. Settings.Version
versionLabel.Size = UDim2.new(0, 50, 1, 0)
versionLabel.Position = UDim2.new(0, 140, 0, 0)
versionLabel.BackgroundTransparency = 1
versionLabel.TextColor3 = Theme.DimText
versionLabel.TextSize = 12
versionLabel.Font = Enum.Font.Gotham
versionLabel.TextXAlignment = Enum.TextXAlignment.Left
versionLabel.Parent = TopBar

-- Kullanıcı adı
local userLabel = Instance.new("TextLabel")
userLabel.Text = "👤 " .. LocalPlayer.DisplayName
userLabel.Size = UDim2.new(0, 150, 1, 0)
userLabel.Position = UDim2.new(1, -200, 0, 0)
userLabel.BackgroundTransparency = 1
userLabel.TextColor3 = Theme.DimText
userLabel.TextSize = 13
userLabel.Font = Enum.Font.Gotham
userLabel.TextXAlignment = Enum.TextXAlignment.Right
userLabel.Parent = TopBar

-- Kapat butonu
local closeBtn = Instance.new("TextButton")
closeBtn.Text = "✕"
closeBtn.Size = UDim2.new(0, 40, 0, 40)
closeBtn.Position = UDim2.new(1, -40, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.TextColor3 = Theme.DimText
closeBtn.TextSize = 16
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = TopBar

closeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

closeBtn.MouseEnter:Connect(function()
    tween(closeBtn, {TextColor3 = Color3.fromRGB(255, 80, 80)}, 0.15)
end)
closeBtn.MouseLeave:Connect(function()
    tween(closeBtn, {TextColor3 = Theme.DimText}, 0.15)
end)

-- Sürükleme sistemi
local dragging, dragStart, startPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
    end
end)

TopBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ==========================================
-- TAB SİSTEMİ
-- ==========================================

local TabBar = Instance.new("Frame")
TabBar.Name = "TabBar"
TabBar.Size = UDim2.new(1, -20, 0, 35)
TabBar.Position = UDim2.new(0, 10, 0, 48)
TabBar.BackgroundTransparency = 1
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0, 6)
tabLayout.Parent = TabBar

-- İçerik alanı
local ContentArea = Instance.new("ScrollingFrame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -20, 1, -100)
ContentArea.Position = UDim2.new(0, 10, 0, 90)
ContentArea.BackgroundColor3 = Theme.Secondary
ContentArea.BorderSizePixel = 0
ContentArea.ScrollBarThickness = 4
ContentArea.ScrollBarImageColor3 = Theme.Primary
ContentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentArea.Parent = MainFrame

local contentCorner = Instance.new("UICorner")
contentCorner.CornerRadius = UDim.new(0, 8)
contentCorner.Parent = ContentArea

local contentPadding = Instance.new("UIPadding")
contentPadding.PaddingTop = UDim.new(0, 10)
contentPadding.PaddingBottom = UDim.new(0, 10)
contentPadding.PaddingLeft = UDim.new(0, 10)
contentPadding.PaddingRight = UDim.new(0, 10)
contentPadding.Parent = ContentArea

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 8)
contentLayout.Parent = ContentArea

-- Tab sayfaları ve butonları
local tabs = {}
local tabPages = {}
local currentTab = nil

-- Tab oluşturma fonksiyonu
local function createTab(name, icon)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = "Tab_" .. name
    tabBtn.Text = icon .. " " .. name
    tabBtn.Size = UDim2.new(0, 120, 0, 32)
    tabBtn.BackgroundColor3 = Theme.TabInactive
    tabBtn.TextColor3 = Theme.DimText
    tabBtn.TextSize = 13
    tabBtn.Font = Enum.Font.GothamSemibold
    tabBtn.BorderSizePixel = 0
    tabBtn.AutoButtonColor = false
    tabBtn.Parent = TabBar
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = tabBtn
    
    -- Tab sayfası (frame konteyneri)
    local page = Instance.new("Frame")
    page.Name = "Page_" .. name
    page.Size = UDim2.new(1, 0, 0, 0)
    page.AutomaticSize = Enum.AutomaticSize.Y
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = ContentArea
    
    local pageLayout = Instance.new("UIListLayout")
    pageLayout.Padding = UDim.new(0, 8)
    pageLayout.Parent = page
    
    tabs[name] = tabBtn
    tabPages[name] = page
    
    -- Tab tıklama
    tabBtn.MouseButton1Click:Connect(function()
        -- Tüm tabları deaktif et
        for tName, tBtn in pairs(tabs) do
            tween(tBtn, {BackgroundColor3 = Theme.TabInactive, TextColor3 = Theme.DimText}, 0.2)
            tabPages[tName].Visible = false
        end
        
        -- Seçili tabı aktif et
        tween(tabBtn, {BackgroundColor3 = Theme.TabActive, TextColor3 = Theme.Text}, 0.2)
        page.Visible = true
        currentTab = name
    end)
    
    return page
end

-- ==========================================
-- KONTROL ELEMANLARı OLUŞTURMA
-- ==========================================

-- Toggle (açma/kapama) oluşturma
local function createToggle(parent, label, default, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 36)
    holder.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    holder.BorderSizePixel = 0
    holder.Parent = parent
    
    local hCorner = Instance.new("UICorner")
    hCorner.CornerRadius = UDim.new(0, 6)
    hCorner.Parent = holder
    
    local text = Instance.new("TextLabel")
    text.Text = label
    text.Size = UDim2.new(1, -70, 1, 0)
    text.Position = UDim2.new(0, 12, 0, 0)
    text.BackgroundTransparency = 1
    text.TextColor3 = Theme.Text
    text.TextSize = 14
    text.Font = Enum.Font.Gotham
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.Parent = holder
    
    -- Toggle butonu
    local toggleBG = Instance.new("Frame")
    toggleBG.Size = UDim2.new(0, 44, 0, 22)
    toggleBG.Position = UDim2.new(1, -56, 0.5, -11)
    toggleBG.BackgroundColor3 = default and Theme.ToggleOn or Theme.ToggleOff
    toggleBG.BorderSizePixel = 0
    toggleBG.Parent = holder
    
    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBG
    
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.new(0, 18, 0, 18)
    toggleCircle.Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleCircle.BorderSizePixel = 0
    toggleCircle.Parent = toggleBG
    
    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = toggleCircle
    
    local state = default
    
    -- Tıklama alanı
    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.Parent = holder
    
    clickBtn.MouseButton1Click:Connect(function()
        state = not state
        
        if state then
            tween(toggleBG, {BackgroundColor3 = Theme.ToggleOn}, 0.2)
            tween(toggleCircle, {Position = UDim2.new(1, -20, 0.5, -9)}, 0.2)
        else
            tween(toggleBG, {BackgroundColor3 = Theme.ToggleOff}, 0.2)
            tween(toggleCircle, {Position = UDim2.new(0, 2, 0.5, -9)}, 0.2)
        end
        
        if callback then callback(state) end
    end)
    
    return holder
end

-- Slider oluşturma
local function createSlider(parent, label, min, max, default, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 52)
    holder.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    holder.BorderSizePixel = 0
    holder.Parent = parent
    
    local hCorner = Instance.new("UICorner")
    hCorner.CornerRadius = UDim.new(0, 6)
    hCorner.Parent = holder
    
    -- Etiket
    local text = Instance.new("TextLabel")
    text.Text = label
    text.Size = UDim2.new(0.6, 0, 0, 22)
    text.Position = UDim2.new(0, 12, 0, 4)
    text.BackgroundTransparency = 1
    text.TextColor3 = Theme.Text
    text.TextSize = 13
    text.Font = Enum.Font.Gotham
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.Parent = holder
    
    -- Değer göstergesi
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Text = tostring(default)
    valueLabel.Size = UDim2.new(0.3, 0, 0, 22)
    valueLabel.Position = UDim2.new(0.7, -12, 0, 4)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = Theme.Accent
    valueLabel.TextSize = 13
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = holder
    
    -- Slider arka planı
    local sliderBG = Instance.new("Frame")
    sliderBG.Size = UDim2.new(1, -24, 0, 8)
    sliderBG.Position = UDim2.new(0, 12, 0, 34)
    sliderBG.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    sliderBG.BorderSizePixel = 0
    sliderBG.Parent = holder
    
    local sliderBGCorner = Instance.new("UICorner")
    sliderBGCorner.CornerRadius = UDim.new(1, 0)
    sliderBGCorner.Parent = sliderBG
    
    -- Slider dolgu
    local percent = (default - min) / (max - min)
    
    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
    sliderFill.BackgroundColor3 = Theme.SliderFill
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBG
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = sliderFill
    
    -- Slider tıklama alanı
    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(1, 0, 0, 20)
    sliderBtn.Position = UDim2.new(0, 0, 0, 26)
    sliderBtn.BackgroundTransparency = 1
    sliderBtn.Text = ""
    sliderBtn.Parent = holder
    
    local sliding = false
    
    sliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true
        end
    end)
    
    sliderBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = (input.Position.X - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X
            rel = math.clamp(rel, 0, 1)
            
            local value = math.floor(min + (max - min) * rel)
            valueLabel.Text = tostring(value)
            sliderFill.Size = UDim2.new(rel, 0, 1, 0)
            
            if callback then callback(value) end
        end
    end)
    
    return holder
end

-- Dropdown (seçim) oluşturma
local function createDropdown(parent, label, options, default, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 36)
    holder.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    holder.BorderSizePixel = 0
    holder.ClipsDescendants = true
    holder.Parent = parent
    
    local hCorner = Instance.new("UICorner")
    hCorner.CornerRadius = UDim.new(0, 6)
    hCorner.Parent = holder
    
    local text = Instance.new("TextLabel")
    text.Text = label
    text.Size = UDim2.new(0.5, 0, 0, 36)
    text.Position = UDim2.new(0, 12, 0, 0)
    text.BackgroundTransparency = 1
    text.TextColor3 = Theme.Text
    text.TextSize = 13
    text.Font = Enum.Font.Gotham
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.Parent = holder
    
    local selectedBtn = Instance.new("TextButton")
    selectedBtn.Text = "▼ " .. tostring(default)
    selectedBtn.Size = UDim2.new(0.45, -12, 0, 28)
    selectedBtn.Position = UDim2.new(0.55, 0, 0, 4)
    selectedBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    selectedBtn.TextColor3 = Theme.Accent
    selectedBtn.TextSize = 12
    selectedBtn.Font = Enum.Font.GothamSemibold
    selectedBtn.BorderSizePixel = 0
    selectedBtn.Parent = holder
    
    local selCorner = Instance.new("UICorner")
    selCorner.CornerRadius = UDim.new(0, 5)
    selCorner.Parent = selectedBtn
    
    local isOpen = false
    
    -- Seçenek butonları oluştur
    for i, option in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Text = tostring(option)
        optBtn.Size = UDim2.new(0.45, -12, 0, 26)
        optBtn.Position = UDim2.new(0.55, 0, 0, 4 + i * 30)
        optBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        optBtn.TextColor3 = Theme.DimText
        optBtn.TextSize = 12
        optBtn.Font = Enum.Font.Gotham
        optBtn.BorderSizePixel = 0
        optBtn.Visible = false
        optBtn.Parent = holder
        
        local optCorner = Instance.new("UICorner")
        optCorner.CornerRadius = UDim.new(0, 5)
        optCorner.Parent = optBtn
        
        optBtn.MouseButton1Click:Connect(function()
            selectedBtn.Text = "▼ " .. tostring(option)
            isOpen = false
            holder.Size = UDim2.new(1, 0, 0, 36)
            
            for _, child in pairs(holder:GetChildren()) do
                if child:IsA("TextButton") and child ~= selectedBtn then
                    child.Visible = false
                end
            end
            
            if callback then callback(option) end
        end)
    end
    
    selectedBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        
        if isOpen then
            holder.Size = UDim2.new(1, 0, 0, 36 + #options * 30)
            for _, child in pairs(holder:GetChildren()) do
                if child:IsA("TextButton") and child ~= selectedBtn then
                    child.Visible = true
                end
            end
        else
            holder.Size = UDim2.new(1, 0, 0, 36)
            for _, child in pairs(holder:GetChildren()) do
                if child:IsA("TextButton") and child ~= selectedBtn then
                    child.Visible = false
                end
            end
        end
    end)
    
    return holder
end

-- Bölüm başlığı
local function createSection(parent, title)
    local label = Instance.new("TextLabel")
    label.Text = "━━ " .. title .. " ━━"
    label.Size = UDim2.new(1, 0, 0, 28)
    label.BackgroundTransparency = 1
    label.TextColor3 = Theme.Accent
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.Parent = parent
    return label
end

-- ==========================================
-- TABLAR VE İÇERİKLERİ
-- ==========================================

-- === AIMBOT TABI ===
local aimbotPage = createTab("Aimbot", "🎯")

createSection(aimbotPage, "Genel Ayarlar")

createToggle(aimbotPage, "Aimbot Aktif", false, function(state)
    Settings.Aimbot.Enabled = state
end)

createToggle(aimbotPage, "Takım Kontrolü", false, function(state)
    Settings.Aimbot.TeamCheck = state
end)

createToggle(aimbotPage, "Görünürlük Kontrolü", false, function(state)
    Settings.Aimbot.VisibleCheck = state
end)

createToggle(aimbotPage, "FOV Dairesi Göster", false, function(state)
    Settings.Aimbot.FOVEnabled = state
end)

createToggle(aimbotPage, "Yapışkan Aim", false, function(state)
    Settings.Aimbot.StickyAim = state
end)

createSection(aimbotPage, "Hassasiyet Ayarları")

createSlider(aimbotPage, "FOV Boyutu", 50, 500, 150, function(val)
    Settings.Aimbot.FOVSize = val
end)

createSlider(aimbotPage, "Yumuşaklık", 1, 20, 5, function(val)
    Settings.Aimbot.Smoothness = val
end)

createSlider(aimbotPage, "Maksimum Mesafe", 100, 2000, 500, function(val)
    Settings.Aimbot.MaxDistance = val
end)

createSection(aimbotPage, "Tahmin Sistemi")

createToggle(aimbotPage, "Hareket Tahmini", false, function(state)
    Settings.Aimbot.Prediction = state
end)

createSlider(aimbotPage, "Tahmin Miktarı (x1000)", 50, 500, 165, function(val)
    Settings.Aimbot.PredictionAmount = val / 1000
end)

createDropdown(aimbotPage, "Hedef Bölge", {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}, "Head", function(val)
    Settings.Aimbot.TargetPart = val
end)

-- === ESP TABI ===
local espPage = createTab("ESP", "👁️")

createSection(espPage, "Genel ESP")

createToggle(espPage, "ESP Aktif", false, function(state)
    Settings.ESP.Enabled = state
end)

createToggle(espPage, "Takım Kontrolü", false, function(state)
    Settings.ESP.TeamCheck = state
end)

createToggle(espPage, "Takım Rengi Kullan", false, function(state)
    Settings.ESP.TeamColor = state
end)

createSection(espPage, "Görsel Elemanlar")

createToggle(espPage, "Kutu (Box)", false, function(state)
    Settings.ESP.Boxes = state
end)

createDropdown(espPage, "Kutu Tipi", {"2D", "Corner"}, "2D", function(val)
    Settings.ESP.BoxType = val
end)

createToggle(espPage, "İsim Göster", false, function(state)
    Settings.ESP.Names = state
end)

createToggle(espPage, "Can Barı", false, function(state)
    Settings.ESP.Health = state
end)

createToggle(espPage, "Mesafe Göster", false, function(state)
    Settings.ESP.Distance = state
end)

createSection(espPage, "Ekstra Görsel")

createToggle(espPage, "Tracer (Çizgi)", false, function(state)
    Settings.ESP.Tracers = state
end)

createDropdown(espPage, "Tracer Başlangıcı", {"Bottom", "Center", "Mouse"}, "Bottom", function(val)
    Settings.ESP.TracerOrigin = val
end)

createToggle(espPage, "Chams (Highlight)", false, function(state)
    Settings.ESP.Chams = state
end)

createSlider(espPage, "Chams Şeffaflık (x100)", 0, 100, 50, function(val)
    Settings.ESP.ChamsTransparency = val / 100
end)

createSlider(espPage, "Maksimum ESP Mesafesi", 100, 3000, 1000, function(val)
    Settings.ESP.MaxDistance = val
end)

-- === AYARLAR TABI ===
local settingsPage = createTab("Ayarlar", "⚙️")

createSection(settingsPage, "Bilgi")

local infoLabel = Instance.new("TextLabel")
infoLabel.Text = "🔮 VergiHub v" .. Settings.Version .. "\n👤 Kullanıcı: " .. LocalPlayer.DisplayName .. "\n🎮 Oyun: " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name .. "\n⌨️ Menü Tuşu: RightShift"
infoLabel.Size = UDim2.new(1, 0, 0, 80)
infoLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
infoLabel.TextColor3 = Theme.DimText
infoLabel.TextSize = 13
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextWrapped = true
infoLabel.RichText = true
infoLabel.BorderSizePixel = 0
infoLabel.Parent = settingsPage

local infoCorner = Instance.new("UICorner")
infoCorner.CornerRadius = UDim.new(0, 6)
infoCorner.Parent = infoLabel

-- İlk tab'ı aktif yap (Aimbot)
tabs["Aimbot"].BackgroundColor3 = Theme.TabActive
tabs["Aimbot"].TextColor3 = Theme.Text
tabPages["Aimbot"].Visible = true
currentTab = "Aimbot"

-- Menü aç/kapat tuşu
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Settings.UI.ToggleKey then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("[VergiHub] 🖥️ UI Dashboard hazır!")
return MainFrame
