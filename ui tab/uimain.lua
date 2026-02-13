--[[
    VergiHub - UI Dashboard v2.0
    Modern dark palette, emoji-free, clean typography
    Tab sistemi, toggle/slider/dropdown kontrolleri
    
    Tablar: Aimbot, ESP, HardLock, Bypass, Settings
]]

local Settings = getgenv().VergiHub

-- Yeni palette'i Theme'e yaz
Settings.UI.Theme = {
    Background    = Color3.fromRGB(13, 14, 22),
    Surface       = Color3.fromRGB(21, 23, 34),
    Surface2      = Color3.fromRGB(28, 31, 46),
    TopBar        = Color3.fromRGB(18, 19, 30),
    Primary       = Color3.fromRGB(124, 58, 237),
    Accent        = Color3.fromRGB(167, 139, 250),
    AccentGlow    = Color3.fromRGB(196, 181, 253),
    Success       = Color3.fromRGB(52, 211, 153),
    Error         = Color3.fromRGB(248, 113, 113),
    Warning       = Color3.fromRGB(251, 191, 36),
    Text          = Color3.fromRGB(226, 232, 240),
    TextDim       = Color3.fromRGB(148, 163, 184),
    TextMuted     = Color3.fromRGB(100, 116, 139),
    ToggleOn      = Color3.fromRGB(124, 58, 237),
    ToggleOff     = Color3.fromRGB(51, 65, 85),
    SliderFill    = Color3.fromRGB(124, 58, 237),
    SliderTrack   = Color3.fromRGB(30, 41, 59),
    Border        = Color3.fromRGB(30, 41, 59),
    TabActive     = Color3.fromRGB(124, 58, 237),
    TabInactive   = Color3.fromRGB(28, 31, 46),
}

local Theme = Settings.UI.Theme

-- Servisler
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Eski UI varsa kaldır
if game.CoreGui:FindFirstChild("VergiHubUI") then
    game.CoreGui:FindFirstChild("VergiHubUI"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VergiHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game.CoreGui

-- ==========================================
-- YARDIMCI FONKSİYONLAR
-- ==========================================

local function tween(obj, props, duration)
    local t = TweenService:Create(obj, TweenInfo.new(duration or 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

-- ==========================================
-- ANA PENCERE
-- ==========================================

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 540, 0, 440)
MainFrame.Position = UDim2.new(0.5, -270, 0.5, -220)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.Visible = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 12)
mainCorner.Parent = MainFrame

-- Dış kenarlık (ince glow efekti)
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Theme.Primary
mainStroke.Thickness = 1
mainStroke.Transparency = 0.7
mainStroke.Parent = MainFrame

-- ==========================================
-- ÜST BAR
-- ==========================================

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 44)
TopBar.BackgroundColor3 = Theme.TopBar
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

-- Üst bar alt kenarı düzleştir
local topBarFix = Instance.new("Frame")
topBarFix.Size = UDim2.new(1, 0, 0, 14)
topBarFix.Position = UDim2.new(0, 0, 1, -14)
topBarFix.BackgroundColor3 = Theme.TopBar
topBarFix.BorderSizePixel = 0
topBarFix.Parent = TopBar

-- Üst bar alt çizgi (accent)
local topAccentLine = Instance.new("Frame")
topAccentLine.Size = UDim2.new(1, 0, 0, 1)
topAccentLine.Position = UDim2.new(0, 0, 1, 0)
topAccentLine.BackgroundColor3 = Theme.Primary
topAccentLine.BackgroundTransparency = 0.6
topAccentLine.BorderSizePixel = 0
topAccentLine.Parent = TopBar

-- Logo ikonu (V harfi - daire içinde)
local logoFrame = Instance.new("Frame")
logoFrame.Size = UDim2.new(0, 28, 0, 28)
logoFrame.Position = UDim2.new(0, 12, 0.5, -14)
logoFrame.BackgroundColor3 = Theme.Primary
logoFrame.BorderSizePixel = 0
logoFrame.Parent = TopBar

local logoCorner = Instance.new("UICorner")
logoCorner.CornerRadius = UDim.new(0, 6)
logoCorner.Parent = logoFrame

local logoText = Instance.new("TextLabel")
logoText.Text = "V"
logoText.Size = UDim2.new(1, 0, 1, 0)
logoText.BackgroundTransparency = 1
logoText.TextColor3 = Color3.fromRGB(255, 255, 255)
logoText.TextSize = 16
logoText.Font = Enum.Font.GothamBold
logoText.Parent = logoFrame

-- Başlık
local titleLabel = Instance.new("TextLabel")
titleLabel.Text = "VergiHub"
titleLabel.Size = UDim2.new(0, 100, 1, 0)
titleLabel.Position = UDim2.new(0, 48, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.TextColor3 = Theme.Text
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = TopBar

-- Versiyon badge
local versionBadge = Instance.new("Frame")
versionBadge.Size = UDim2.new(0, 40, 0, 18)
versionBadge.Position = UDim2.new(0, 148, 0.5, -9)
versionBadge.BackgroundColor3 = Theme.Surface2
versionBadge.BorderSizePixel = 0
versionBadge.Parent = TopBar

local vbCorner = Instance.new("UICorner")
vbCorner.CornerRadius = UDim.new(0, 4)
vbCorner.Parent = versionBadge

local versionText = Instance.new("TextLabel")
versionText.Text = Settings.Version
versionText.Size = UDim2.new(1, 0, 1, 0)
versionText.BackgroundTransparency = 1
versionText.TextColor3 = Theme.TextMuted
versionText.TextSize = 10
versionText.Font = Enum.Font.GothamSemibold
versionText.Parent = versionBadge

-- Kullanıcı bilgisi (sağ taraf)
local userFrame = Instance.new("Frame")
userFrame.Size = UDim2.new(0, 150, 0, 28)
userFrame.Position = UDim2.new(1, -200, 0.5, -14)
userFrame.BackgroundColor3 = Theme.Surface2
userFrame.BackgroundTransparency = 0.5
userFrame.BorderSizePixel = 0
userFrame.Parent = TopBar

local ufCorner = Instance.new("UICorner")
ufCorner.CornerRadius = UDim.new(0, 6)
ufCorner.Parent = userFrame

-- Kullanıcı durumu dairesi
local userDot = Instance.new("Frame")
userDot.Size = UDim2.new(0, 8, 0, 8)
userDot.Position = UDim2.new(0, 8, 0.5, -4)
userDot.BackgroundColor3 = Theme.Success
userDot.BorderSizePixel = 0
userDot.Parent = userFrame

local dotCorner = Instance.new("UICorner")
dotCorner.CornerRadius = UDim.new(1, 0)
dotCorner.Parent = userDot

local userName = Instance.new("TextLabel")
userName.Text = LocalPlayer.DisplayName
userName.Size = UDim2.new(1, -24, 1, 0)
userName.Position = UDim2.new(0, 22, 0, 0)
userName.BackgroundTransparency = 1
userName.TextColor3 = Theme.TextDim
userName.TextSize = 12
userName.Font = Enum.Font.Gotham
userName.TextXAlignment = Enum.TextXAlignment.Left
userName.TextTruncate = Enum.TextTruncate.AtEnd
userName.Parent = userFrame

-- Kapat butonu
local closeBtn = Instance.new("TextButton")
closeBtn.Text = "×"
closeBtn.Size = UDim2.new(0, 44, 0, 44)
closeBtn.Position = UDim2.new(1, -44, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.TextColor3 = Theme.TextMuted
closeBtn.TextSize = 22
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = TopBar

closeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

closeBtn.MouseEnter:Connect(function()
    tween(closeBtn, {TextColor3 = Theme.Error}, 0.15)
end)
closeBtn.MouseLeave:Connect(function()
    tween(closeBtn, {TextColor3 = Theme.TextMuted}, 0.15)
end)

-- Minimize butonu
local minBtn = Instance.new("TextButton")
minBtn.Text = "–"
minBtn.Size = UDim2.new(0, 44, 0, 44)
minBtn.Position = UDim2.new(1, -82, 0, 0)
minBtn.BackgroundTransparency = 1
minBtn.TextColor3 = Theme.TextMuted
minBtn.TextSize = 20
minBtn.Font = Enum.Font.GothamBold
minBtn.Parent = TopBar

minBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

minBtn.MouseEnter:Connect(function()
    tween(minBtn, {TextColor3 = Theme.TextDim}, 0.15)
end)
minBtn.MouseLeave:Connect(function()
    tween(minBtn, {TextColor3 = Theme.TextMuted}, 0.15)
end)

-- Sürükleme
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
-- SOL PANEL (Tab Navigasyonu)
-- ==========================================

local SideBar = Instance.new("Frame")
SideBar.Name = "SideBar"
SideBar.Size = UDim2.new(0, 130, 1, -44)
SideBar.Position = UDim2.new(0, 0, 0, 44)
SideBar.BackgroundColor3 = Theme.TopBar
SideBar.BorderSizePixel = 0
SideBar.Parent = MainFrame

-- Sol panel sağ kenar çizgisi
local sideBarLine = Instance.new("Frame")
sideBarLine.Size = UDim2.new(0, 1, 1, 0)
sideBarLine.Position = UDim2.new(1, 0, 0, 0)
sideBarLine.BackgroundColor3 = Theme.Border
sideBarLine.BorderSizePixel = 0
sideBarLine.Parent = SideBar

-- Tab butonları alanı
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -12, 1, -16)
tabContainer.Position = UDim2.new(0, 6, 0, 8)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = SideBar

local tabLayout = Instance.new("UIListLayout")
tabLayout.Padding = UDim.new(0, 4)
tabLayout.Parent = tabContainer

-- İçerik alanı (sağ taraf)
local ContentArea = Instance.new("ScrollingFrame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -144, 1, -56)
ContentArea.Position = UDim2.new(0, 138, 0, 50)
ContentArea.BackgroundColor3 = Theme.Background
ContentArea.BackgroundTransparency = 1
ContentArea.BorderSizePixel = 0
ContentArea.ScrollBarThickness = 3
ContentArea.ScrollBarImageColor3 = Theme.Primary
ContentArea.ScrollBarImageTransparency = 0.3
ContentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentArea.Parent = MainFrame

local contentPadding = Instance.new("UIPadding")
contentPadding.PaddingTop = UDim.new(0, 6)
contentPadding.PaddingBottom = UDim.new(0, 12)
contentPadding.PaddingLeft = UDim.new(0, 6)
contentPadding.PaddingRight = UDim.new(0, 8)
contentPadding.Parent = ContentArea

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 6)
contentLayout.Parent = ContentArea

-- ==========================================
-- TAB SİSTEMİ (Sol panel butonları)
-- ==========================================

local tabs = {}
local tabPages = {}
local currentTab = nil

-- Tab ikonları (Unicode - emoji değil)
local TAB_ICONS = {
    Aimbot   = "◎",
    ESP      = "◈",
    HardLock = "⊕",
    Bypass   = "◆",
    Settings = "⚙",
}

local function createTab(name, icon)
    -- Sol panel butonu
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = "Tab_" .. name
    tabBtn.Text = ""
    tabBtn.Size = UDim2.new(1, 0, 0, 36)
    tabBtn.BackgroundColor3 = Theme.TabInactive
    tabBtn.BackgroundTransparency = 1
    tabBtn.BorderSizePixel = 0
    tabBtn.AutoButtonColor = false
    tabBtn.Parent = tabContainer

    local tabBtnCorner = Instance.new("UICorner")
    tabBtnCorner.CornerRadius = UDim.new(0, 8)
    tabBtnCorner.Parent = tabBtn

    -- Aktif gösterge çizgisi (sol kenar)
    local activeBar = Instance.new("Frame")
    activeBar.Name = "ActiveBar"
    activeBar.Size = UDim2.new(0, 3, 0.6, 0)
    activeBar.Position = UDim2.new(0, 0, 0.2, 0)
    activeBar.BackgroundColor3 = Theme.Primary
    activeBar.BackgroundTransparency = 1
    activeBar.BorderSizePixel = 0
    activeBar.Parent = tabBtn

    local abCorner = Instance.new("UICorner")
    abCorner.CornerRadius = UDim.new(0, 2)
    abCorner.Parent = activeBar

    -- İkon
    local iconLbl = Instance.new("TextLabel")
    iconLbl.Text = icon or ""
    iconLbl.Size = UDim2.new(0, 28, 1, 0)
    iconLbl.Position = UDim2.new(0, 8, 0, 0)
    iconLbl.BackgroundTransparency = 1
    iconLbl.TextColor3 = Theme.TextMuted
    iconLbl.TextSize = 16
    iconLbl.Font = Enum.Font.GothamBold
    iconLbl.Parent = tabBtn

    -- Tab adı
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Text = name
    nameLbl.Size = UDim2.new(1, -40, 1, 0)
    nameLbl.Position = UDim2.new(0, 36, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.TextColor3 = Theme.TextMuted
    nameLbl.TextSize = 13
    nameLbl.Font = Enum.Font.GothamSemibold
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.Parent = tabBtn

    -- İçerik sayfası
    local page = Instance.new("Frame")
    page.Name = "Page_" .. name
    page.Size = UDim2.new(1, 0, 0, 0)
    page.AutomaticSize = Enum.AutomaticSize.Y
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = ContentArea

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.Padding = UDim.new(0, 6)
    pageLayout.Parent = page

    tabs[name] = {Button = tabBtn, ActiveBar = activeBar, Icon = iconLbl, Name = nameLbl}
    tabPages[name] = page

    -- Hover efekti
    tabBtn.MouseEnter:Connect(function()
        if currentTab ~= name then
            tween(tabBtn, {BackgroundTransparency = 0.5, BackgroundColor3 = Theme.Surface2}, 0.15)
            tween(iconLbl, {TextColor3 = Theme.TextDim}, 0.15)
        end
    end)

    tabBtn.MouseLeave:Connect(function()
        if currentTab ~= name then
            tween(tabBtn, {BackgroundTransparency = 1}, 0.15)
            tween(iconLbl, {TextColor3 = Theme.TextMuted}, 0.15)
        end
    end)

    -- Tıklama
    tabBtn.MouseButton1Click:Connect(function()
        -- Tüm tabları deaktif et
        for tName, tData in pairs(tabs) do
            tween(tData.Button, {BackgroundTransparency = 1}, 0.2)
            tween(tData.ActiveBar, {BackgroundTransparency = 1}, 0.2)
            tween(tData.Icon, {TextColor3 = Theme.TextMuted}, 0.2)
            tween(tData.Name, {TextColor3 = Theme.TextMuted}, 0.2)
            tabPages[tName].Visible = false
        end

        -- Seçili tabı aktif et
        tween(tabBtn, {BackgroundTransparency = 0.3, BackgroundColor3 = Theme.Surface2}, 0.2)
        tween(activeBar, {BackgroundTransparency = 0}, 0.2)
        tween(iconLbl, {TextColor3 = Theme.Accent}, 0.2)
        tween(nameLbl, {TextColor3 = Theme.Text}, 0.2)
        page.Visible = true
        currentTab = name

        -- Scroll'u sıfırla
        ContentArea.CanvasPosition = Vector2.new(0, 0)
    end)

    return page
end

-- ==========================================
-- KONTROL ELEMANLARI
-- ==========================================

-- Bölüm başlığı
local function createSection(parent, title)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 26)
    holder.BackgroundTransparency = 1
    holder.Parent = parent

    local leftLine = Instance.new("Frame")
    leftLine.Size = UDim2.new(0, 16, 0, 1)
    leftLine.Position = UDim2.new(0, 0, 0.5, 0)
    leftLine.BackgroundColor3 = Theme.Border
    leftLine.BorderSizePixel = 0
    leftLine.Parent = holder

    local label = Instance.new("TextLabel")
    label.Text = string.upper(title)
    label.Size = UDim2.new(1, -24, 1, 0)
    label.Position = UDim2.new(0, 22, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Theme.TextMuted
    label.TextSize = 11
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = holder

    return holder
end

-- Toggle
local function createToggle(parent, label, default, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 38)
    holder.BackgroundColor3 = Theme.Surface
    holder.BorderSizePixel = 0
    holder.Parent = parent

    local hCorner = Instance.new("UICorner")
    hCorner.CornerRadius = UDim.new(0, 8)
    hCorner.Parent = holder

    -- Hover efekti
    local hoverFrame = Instance.new("Frame")
    hoverFrame.Size = UDim2.new(1, 0, 1, 0)
    hoverFrame.BackgroundColor3 = Theme.Surface2
    hoverFrame.BackgroundTransparency = 1
    hoverFrame.BorderSizePixel = 0
    hoverFrame.ZIndex = 0
    hoverFrame.Parent = holder

    local hvCorner = Instance.new("UICorner")
    hvCorner.CornerRadius = UDim.new(0, 8)
    hvCorner.Parent = hoverFrame

    -- İsim
    local text = Instance.new("TextLabel")
    text.Text = label
    text.Size = UDim2.new(1, -70, 1, 0)
    text.Position = UDim2.new(0, 14, 0, 0)
    text.BackgroundTransparency = 1
    text.TextColor3 = Theme.Text
    text.TextSize = 13
    text.Font = Enum.Font.Gotham
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.ZIndex = 2
    text.Parent = holder

    -- Toggle switch arka planı
    local toggleBG = Instance.new("Frame")
    toggleBG.Size = UDim2.new(0, 40, 0, 20)
    toggleBG.Position = UDim2.new(1, -52, 0.5, -10)
    toggleBG.BackgroundColor3 = default and Theme.ToggleOn or Theme.ToggleOff
    toggleBG.BorderSizePixel = 0
    toggleBG.ZIndex = 2
    toggleBG.Parent = holder

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBG

    -- Toggle daire
    local toggleCircle = Instance.new("Frame")
    toggleCircle.Size = UDim2.new(0, 16, 0, 16)
    toggleCircle.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggleCircle.BorderSizePixel = 0
    toggleCircle.ZIndex = 3
    toggleCircle.Parent = toggleBG

    local circleCorner = Instance.new("UICorner")
    circleCorner.CornerRadius = UDim.new(1, 0)
    circleCorner.Parent = toggleCircle

    -- Aktifken dairede hafif glow
    local circleStroke = Instance.new("UIStroke")
    circleStroke.Color = Theme.AccentGlow
    circleStroke.Thickness = default and 1 or 0
    circleStroke.Transparency = 0.5
    circleStroke.Parent = toggleCircle

    local state = default

    -- Tıklama alanı
    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.ZIndex = 4
    clickBtn.Parent = holder

    clickBtn.MouseEnter:Connect(function()
        tween(hoverFrame, {BackgroundTransparency = 0.5}, 0.12)
    end)
    clickBtn.MouseLeave:Connect(function()
        tween(hoverFrame, {BackgroundTransparency = 1}, 0.12)
    end)

    clickBtn.MouseButton1Click:Connect(function()
        state = not state

        if state then
            tween(toggleBG, {BackgroundColor3 = Theme.ToggleOn}, 0.2)
            tween(toggleCircle, {Position = UDim2.new(1, -18, 0.5, -8)}, 0.2)
            circleStroke.Thickness = 1
        else
            tween(toggleBG, {BackgroundColor3 = Theme.ToggleOff}, 0.2)
            tween(toggleCircle, {Position = UDim2.new(0, 2, 0.5, -8)}, 0.2)
            circleStroke.Thickness = 0
        end

        if callback then callback(state) end
    end)

    return holder
end

-- Slider
local function createSlider(parent, label, min, max, default, callback)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 54)
    holder.BackgroundColor3 = Theme.Surface
    holder.BorderSizePixel = 0
    holder.Parent = parent

    local hCorner = Instance.new("UICorner")
    hCorner.CornerRadius = UDim.new(0, 8)
    hCorner.Parent = holder

    -- Etiket
    local text = Instance.new("TextLabel")
    text.Text = label
    text.Size = UDim2.new(0.65, 0, 0, 24)
    text.Position = UDim2.new(0, 14, 0, 4)
    text.BackgroundTransparency = 1
    text.TextColor3 = Theme.Text
    text.TextSize = 13
    text.Font = Enum.Font.Gotham
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.Parent = holder

    -- Değer badge
    local valueBadge = Instance.new("Frame")
    valueBadge.Size = UDim2.new(0, 44, 0, 20)
    valueBadge.Position = UDim2.new(1, -56, 0, 6)
    valueBadge.BackgroundColor3 = Theme.Surface2
    valueBadge.BorderSizePixel = 0
    valueBadge.Parent = holder

    local vbCnr = Instance.new("UICorner")
    vbCnr.CornerRadius = UDim.new(0, 4)
    vbCnr.Parent = valueBadge

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Text = tostring(default)
    valueLabel.Size = UDim2.new(1, 0, 1, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = Theme.Accent
    valueLabel.TextSize = 11
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Parent = valueBadge

    -- Slider track
    local sliderBG = Instance.new("Frame")
    sliderBG.Size = UDim2.new(1, -28, 0, 6)
    sliderBG.Position = UDim2.new(0, 14, 0, 37)
    sliderBG.BackgroundColor3 = Theme.SliderTrack
    sliderBG.BorderSizePixel = 0
    sliderBG.Parent = holder

    local sliderBGCorner = Instance.new("UICorner")
    sliderBGCorner.CornerRadius = UDim.new(1, 0)
    sliderBGCorner.Parent = sliderBG

    -- Slider fill
    local percent = (default - min) / (max - min)

    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new(math.clamp(percent, 0, 1), 0, 1, 0)
    sliderFill.BackgroundColor3 = Theme.SliderFill
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderBG

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = sliderFill

    -- Slider knob
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = UDim2.new(math.clamp(percent, 0, 1), -7, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.ZIndex = 2
    knob.Parent = sliderBG

    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob

    local knobStroke = Instance.new("UIStroke")
    knobStroke.Color = Theme.Primary
    knobStroke.Thickness = 2
    knobStroke.Parent = knob

    -- Slider etkileşimi
    local sliding = false

    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(1, 10, 0, 24)
    sliderBtn.Position = UDim2.new(0, -5, 0, 28)
    sliderBtn.BackgroundTransparency = 1
    sliderBtn.Text = ""
    sliderBtn.ZIndex = 3
    sliderBtn.Parent = holder

    sliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true
            tween(knob, {Size = UDim2.new(0, 18, 0, 18)}, 0.1)
        end
    end)

    sliderBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = false
            local currentScale = sliderFill.Size.X.Scale
            tween(knob, {Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(currentScale, -7, 0.5, -7)}, 0.1)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = (input.Position.X - sliderBG.AbsolutePosition.X) / sliderBG.AbsoluteSize.X
            rel = math.clamp(rel, 0, 1)

            local value = math.floor(min + (max - min) * rel)
            valueLabel.Text = tostring(value)
            sliderFill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, -9, 0.5, -9)

            if callback then callback(value) end
        end
    end)

    return holder
end

-- Dropdown
local function createDropdown(parent, label, options, default, callback)
    local isOpen = false

    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 38)
    holder.BackgroundColor3 = Theme.Surface
    holder.BorderSizePixel = 0
    holder.ClipsDescendants = true
    holder.Parent = parent

    local hCorner = Instance.new("UICorner")
    hCorner.CornerRadius = UDim.new(0, 8)
    hCorner.Parent = holder

    -- Etiket
    local text = Instance.new("TextLabel")
    text.Text = label
    text.Size = UDim2.new(0.5, 0, 0, 38)
    text.Position = UDim2.new(0, 14, 0, 0)
    text.BackgroundTransparency = 1
    text.TextColor3 = Theme.Text
    text.TextSize = 13
    text.Font = Enum.Font.Gotham
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.Parent = holder

    -- Seçili değer butonu
    local selectedBtn = Instance.new("TextButton")
    selectedBtn.Text = tostring(default) .. "  ▾"
    selectedBtn.Size = UDim2.new(0.42, -12, 0, 28)
    selectedBtn.Position = UDim2.new(0.58, 0, 0, 5)
    selectedBtn.BackgroundColor3 = Theme.Surface2
    selectedBtn.TextColor3 = Theme.Accent
    selectedBtn.TextSize = 12
    selectedBtn.Font = Enum.Font.GothamSemibold
    selectedBtn.BorderSizePixel = 0
    selectedBtn.AutoButtonColor = false
    selectedBtn.Parent = holder

    local selCorner = Instance.new("UICorner")
    selCorner.CornerRadius = UDim.new(0, 6)
    selCorner.Parent = selectedBtn

    -- Seçenek butonları
    local optionButtons = {}
    for i, option in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Text = tostring(option)
        optBtn.Size = UDim2.new(0.42, -12, 0, 26)
        optBtn.Position = UDim2.new(0.58, 0, 0, 5 + i * 30)
        optBtn.BackgroundColor3 = Theme.Surface2
        optBtn.TextColor3 = Theme.TextDim
        optBtn.TextSize = 11
        optBtn.Font = Enum.Font.Gotham
        optBtn.BorderSizePixel = 0
        optBtn.AutoButtonColor = false
        optBtn.Visible = false
        optBtn.Parent = holder

        local optCorner = Instance.new("UICorner")
        optCorner.CornerRadius = UDim.new(0, 5)
        optCorner.Parent = optBtn

        optBtn.MouseEnter:Connect(function()
            tween(optBtn, {BackgroundColor3 = Theme.Primary, TextColor3 = Theme.Text}, 0.12)
        end)
        optBtn.MouseLeave:Connect(function()
            tween(optBtn, {BackgroundColor3 = Theme.Surface2, TextColor3 = Theme.TextDim}, 0.12)
        end)

        optBtn.MouseButton1Click:Connect(function()
            selectedBtn.Text = tostring(option) .. "  ▾"
            isOpen = false
            tween(holder, {Size = UDim2.new(1, 0, 0, 38)}, 0.2)

            for _, btn in pairs(optionButtons) do
                btn.Visible = false
            end

            if callback then callback(option) end
        end)

        table.insert(optionButtons, optBtn)
    end

    selectedBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen

        if isOpen then
            local expandedHeight = 38 + #options * 30 + 4
            tween(holder, {Size = UDim2.new(1, 0, 0, expandedHeight)}, 0.2)
            for _, btn in pairs(optionButtons) do
                btn.Visible = true
            end
        else
            tween(holder, {Size = UDim2.new(1, 0, 0, 38)}, 0.2)
            for _, btn in pairs(optionButtons) do
                btn.Visible = false
            end
        end
    end)

    return holder
end

-- ==========================================
-- TAB 1: AIMBOT
-- ==========================================

local aimbotPage = createTab("Aimbot", TAB_ICONS.Aimbot)

createSection(aimbotPage, "General")

createToggle(aimbotPage, "Aimbot", false, function(s)
    Settings.Aimbot.Enabled = s
end)

createToggle(aimbotPage, "Team Check", false, function(s)
    Settings.Aimbot.TeamCheck = s
end)

createToggle(aimbotPage, "Visibility Check", false, function(s)
    Settings.Aimbot.VisibleCheck = s
end)

createToggle(aimbotPage, "Show FOV Circle", false, function(s)
    Settings.Aimbot.FOVEnabled = s
end)

createToggle(aimbotPage, "Sticky Aim", false, function(s)
    Settings.Aimbot.StickyAim = s
end)

createSection(aimbotPage, "Precision")

createSlider(aimbotPage, "FOV Size", 50, 500, 150, function(v)
    Settings.Aimbot.FOVSize = v
end)

createSlider(aimbotPage, "Smoothness", 1, 20, 5, function(v)
    Settings.Aimbot.Smoothness = v
end)

createSlider(aimbotPage, "Max Distance", 100, 2000, 500, function(v)
    Settings.Aimbot.MaxDistance = v
end)

createSection(aimbotPage, "Prediction")

createToggle(aimbotPage, "Movement Prediction", false, function(s)
    Settings.Aimbot.Prediction = s
end)

createSlider(aimbotPage, "Prediction Amount (x1000)", 50, 500, 165, function(v)
    Settings.Aimbot.PredictionAmount = v / 1000
end)

createDropdown(aimbotPage, "Target Part", {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}, "Head", function(v)
    Settings.Aimbot.TargetPart = v
end)

-- ==========================================
-- TAB 2: ESP
-- ==========================================

local espPage = createTab("ESP", TAB_ICONS.ESP)

createSection(espPage, "General")

createToggle(espPage, "ESP", false, function(s)
    Settings.ESP.Enabled = s
end)

createToggle(espPage, "Team Check", false, function(s)
    Settings.ESP.TeamCheck = s
end)

createToggle(espPage, "Use Team Color", false, function(s)
    Settings.ESP.TeamColor = s
end)

createSection(espPage, "Visuals")

createToggle(espPage, "Box ESP", false, function(s)
    Settings.ESP.Boxes = s
end)

createDropdown(espPage, "Box Type", {"2D", "Corner"}, "2D", function(v)
    Settings.ESP.BoxType = v
end)

createToggle(espPage, "Names", false, function(s)
    Settings.ESP.Names = s
end)

createToggle(espPage, "Health Bar", false, function(s)
    Settings.ESP.Health = s
end)

createToggle(espPage, "Distance", false, function(s)
    Settings.ESP.Distance = s
end)

createSection(espPage, "Extra")

createToggle(espPage, "Tracers", false, function(s)
    Settings.ESP.Tracers = s
end)

createDropdown(espPage, "Tracer Origin", {"Bottom", "Center", "Mouse"}, "Bottom", function(v)
    Settings.ESP.TracerOrigin = v
end)

createToggle(espPage, "Chams / Highlight", false, function(s)
    Settings.ESP.Chams = s
end)

createSlider(espPage, "Chams Opacity (x100)", 0, 100, 50, function(v)
    Settings.ESP.ChamsTransparency = v / 100
end)

createSlider(espPage, "Max ESP Distance", 100, 3000, 1000, function(v)
    Settings.ESP.MaxDistance = v
end)

-- ==========================================
-- TAB 3: HARDLOCK
-- ==========================================

local hardlockPage = createTab("HardLock", TAB_ICONS.HardLock)

createSection(hardlockPage, "General")

createToggle(hardlockPage, "HardLock", false, function(s)
    Settings.HardLock.Enabled = s
end)

createToggle(hardlockPage, "Lock Indicator", false, function(s)
    Settings.HardLock.Indicator = s
end)

createToggle(hardlockPage, "Override Target Part", false, function(s)
    Settings.HardLock.OverrideTarget = s
end)

createSection(hardlockPage, "Lock Mode")

createDropdown(hardlockPage, "Mode", {"Snap", "Flick", "Rage", "Silent"}, "Snap", function(v)
    Settings.HardLock.Mode = v
end)

createDropdown(hardlockPage, "Target Part", {"Head", "HumanoidRootPart", "UpperTorso"}, "Head", function(v)
    Settings.HardLock.TargetPart = v
end)

createSection(hardlockPage, "Flick Settings")

createSlider(hardlockPage, "Flick Speed (ms)", 20, 200, 80, function(v)
    Settings.HardLock.FlickSpeed = v / 1000
end)

createSlider(hardlockPage, "Flick Return Speed (%)", 10, 80, 30, function(v)
    Settings.HardLock.FlickReturn = v / 100
end)

createSection(hardlockPage, "Rage Settings")

createToggle(hardlockPage, "Auto Fire", false, function(s)
    Settings.HardLock.AutoFire = s
end)

createSlider(hardlockPage, "Rage Prediction (x1000)", 50, 400, 200, function(v)
    Settings.HardLock.RagePrediction = v / 1000
end)

-- Mode bilgi kartı
createSection(hardlockPage, "Mode Info")

local modeInfoCard = Instance.new("Frame")
modeInfoCard.Size = UDim2.new(1, 0, 0, 108)
modeInfoCard.BackgroundColor3 = Theme.Surface
modeInfoCard.BorderSizePixel = 0
modeInfoCard.Parent = hardlockPage

local miCorner = Instance.new("UICorner")
miCorner.CornerRadius = UDim.new(0, 8)
miCorner.Parent = modeInfoCard

local modeLines = {
    {label = "Snap", desc = "Instant lock, release to free aim", color = Theme.Success},
    {label = "Flick", desc = "Fast flick then smooth tracking", color = Theme.Warning},
    {label = "Rage", desc = "Full override every frame, auto-fire", color = Theme.Error},
    {label = "Silent", desc = "Camera stays, server gets aim angle", color = Theme.Accent},
}

for i, info in ipairs(modeLines) do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -20, 0, 22)
    row.Position = UDim2.new(0, 10, 0, 6 + (i - 1) * 25)
    row.BackgroundTransparency = 1
    row.Parent = modeInfoCard

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 6, 0, 6)
    dot.Position = UDim2.new(0, 0, 0.5, -3)
    dot.BackgroundColor3 = info.color
    dot.BorderSizePixel = 0
    dot.Parent = row

    local dc = Instance.new("UICorner")
    dc.CornerRadius = UDim.new(1, 0)
    dc.Parent = dot

    local lbl = Instance.new("TextLabel")
    lbl.Text = info.label
    lbl.Size = UDim2.new(0, 45, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = info.color
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local desc = Instance.new("TextLabel")
    desc.Text = info.desc
    desc.Size = UDim2.new(1, -65, 1, 0)
    desc.Position = UDim2.new(0, 62, 0, 0)
    desc.BackgroundTransparency = 1
    desc.TextColor3 = Theme.TextDim
    desc.TextSize = 10
    desc.Font = Enum.Font.Gotham
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.Parent = row
end

-- ==========================================
-- TAB 4: BYPASS
-- ==========================================

local bypassPage = createTab("Bypass", TAB_ICONS.Bypass)

createSection(bypassPage, "Protection Layers")

createToggle(bypassPage, "Ring 1 — Byfron / Hyperion", false, function(s)
    Settings.Bypass.Ring1 = s
end)

createToggle(bypassPage, "Ring 2 — Anti-Cheat Systems", false, function(s)
    Settings.Bypass.Ring2 = s
end)

createToggle(bypassPage, "Ring 3 — ESP / Aimbot Stealth", false, function(s)
    Settings.Bypass.Ring3 = s
end)

createToggle(bypassPage, "Ring 4 — Basic Protection", false, function(s)
    Settings.Bypass.Ring4 = s
end)

-- Bypass bilgi kartı
createSection(bypassPage, "Layer Info")

local bypassInfoCard = Instance.new("Frame")
bypassInfoCard.Size = UDim2.new(1, 0, 0, 120)
bypassInfoCard.BackgroundColor3 = Theme.Surface
bypassInfoCard.BorderSizePixel = 0
bypassInfoCard.Parent = bypassPage

local biCorner2 = Instance.new("UICorner")
biCorner2.CornerRadius = UDim.new(0, 8)
biCorner2.Parent = bypassInfoCard

local bypassLines = {
    {label = "Ring 1", desc = "Byfron memory scan, heartbeat, environment", color = Theme.Error},
    {label = "Ring 2", desc = "Remote throttle, camera guard, input humanize", color = Theme.Warning},
    {label = "Ring 3", desc = "Aim noise, drawing stealth, raycast budget", color = Theme.Accent},
    {label = "Ring 4", desc = "Speed guard, teleport, FPS stable, anti-idle", color = Theme.Success},
}

for i, info in ipairs(bypassLines) do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -20, 0, 24)
    row.Position = UDim2.new(0, 10, 0, 6 + (i - 1) * 28)
    row.BackgroundTransparency = 1
    row.Parent = bypassInfoCard

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 6, 0, 6)
    dot.Position = UDim2.new(0, 0, 0.5, -3)
    dot.BackgroundColor3 = info.color
    dot.BorderSizePixel = 0
    dot.Parent = row

    local dc = Instance.new("UICorner")
    dc.CornerRadius = UDim.new(1, 0)
    dc.Parent = dot

    local lbl = Instance.new("TextLabel")
    lbl.Text = info.label
    lbl.Size = UDim2.new(0, 45, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = info.color
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local desc = Instance.new("TextLabel")
    desc.Text = info.desc
    desc.Size = UDim2.new(1, -65, 1, 0)
    desc.Position = UDim2.new(0, 62, 0, 0)
    desc.BackgroundTransparency = 1
    desc.TextColor3 = Theme.TextDim
    desc.TextSize = 10
    desc.Font = Enum.Font.Gotham
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.Parent = row
end

-- Risk uyarısı
createSection(bypassPage, "Notice")

local warningCard = Instance.new("Frame")
warningCard.Size = UDim2.new(1, 0, 0, 50)
warningCard.BackgroundColor3 = Color3.fromRGB(28, 22, 10)
warningCard.BorderSizePixel = 0
warningCard.Parent = bypassPage

local wcCorner = Instance.new("UICorner")
wcCorner.CornerRadius = UDim.new(0, 8)
wcCorner.Parent = warningCard

local wcStroke = Instance.new("UIStroke")
wcStroke.Color = Theme.Warning
wcStroke.Thickness = 1
wcStroke.Transparency = 0.7
wcStroke.Parent = warningCard

local warningDot = Instance.new("Frame")
warningDot.Size = UDim2.new(0, 3, 1, -12)
warningDot.Position = UDim2.new(0, 5, 0, 6)
warningDot.BackgroundColor3 = Theme.Warning
warningDot.BorderSizePixel = 0
warningDot.Parent = warningCard

local wdCorner = Instance.new("UICorner")
wdCorner.CornerRadius = UDim.new(0, 2)
wdCorner.Parent = warningDot

local warningText = Instance.new("TextLabel")
warningText.Text = "Higher rings provide more protection but may impact performance. Enable only what you need. Ring 1 requires compatible executor."
warningText.Size = UDim2.new(1, -24, 1, -8)
warningText.Position = UDim2.new(0, 16, 0, 4)
warningText.BackgroundTransparency = 1
warningText.TextColor3 = Color3.fromRGB(220, 200, 150)
warningText.TextSize = 11
warningText.Font = Enum.Font.Gotham
warningText.TextWrapped = true
warningText.TextXAlignment = Enum.TextXAlignment.Left
warningText.TextYAlignment = Enum.TextYAlignment.Top
warningText.Parent = warningCard

-- ==========================================
-- TAB 5: SETTINGS
-- ==========================================

local settingsPage = createTab("Settings", TAB_ICONS.Settings)

createSection(settingsPage, "Information")

-- Bilgi kartı
local infoCard = Instance.new("Frame")
infoCard.Size = UDim2.new(1, 0, 0, 100)
infoCard.BackgroundColor3 = Theme.Surface
infoCard.BorderSizePixel = 0
infoCard.Parent = settingsPage

local icCorner = Instance.new("UICorner")
icCorner.CornerRadius = UDim.new(0, 8)
icCorner.Parent = infoCard

-- Bilgi satırları
local infoLines = {
    {label = "Version", value = Settings.Version, color = Theme.Accent},
    {label = "User", value = LocalPlayer.DisplayName, color = Theme.Text},
    {label = "Toggle Key", value = "RightShift", color = Theme.TextDim},
}

-- Oyun adını güvenli şekilde al
local gameName = "Unknown"
pcall(function()
    gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
end)
table.insert(infoLines, 3, {label = "Game", value = gameName, color = Theme.TextDim})

for i, info in ipairs(infoLines) do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -24, 0, 20)
    row.Position = UDim2.new(0, 12, 0, 8 + (i - 1) * 22)
    row.BackgroundTransparency = 1
    row.Parent = infoCard

    local lbl = Instance.new("TextLabel")
    lbl.Text = info.label
    lbl.Size = UDim2.new(0.4, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Theme.TextMuted
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    local val = Instance.new("TextLabel")
    val.Text = info.value
    val.Size = UDim2.new(0.6, 0, 1, 0)
    val.BackgroundTransparency = 1
    val.TextColor3 = info.color
    val.TextSize = 12
    val.Font = Enum.Font.GothamSemibold
    val.TextXAlignment = Enum.TextXAlignment.Right
    val.Parent = row
end

-- Kredi kartı
createSection(settingsPage, "Credits")

local creditCard = Instance.new("Frame")
creditCard.Size = UDim2.new(1, 0, 0, 48)
creditCard.BackgroundColor3 = Theme.Surface
creditCard.BorderSizePixel = 0
creditCard.Parent = settingsPage

local ccCorner = Instance.new("UICorner")
ccCorner.CornerRadius = UDim.new(0, 8)
ccCorner.Parent = creditCard

local creditDot = Instance.new("Frame")
creditDot.Size = UDim2.new(0, 3, 1, -12)
creditDot.Position = UDim2.new(0, 5, 0, 6)
creditDot.BackgroundColor3 = Theme.Primary
creditDot.BorderSizePixel = 0
creditDot.Parent = creditCard

local cdCorner = Instance.new("UICorner")
cdCorner.CornerRadius = UDim.new(0, 2)
cdCorner.Parent = creditDot

local creditText = Instance.new("TextLabel")
creditText.Text = "Developed by Baran\nVergiHub — Private Use Only"
creditText.Size = UDim2.new(1, -24, 1, -8)
creditText.Position = UDim2.new(0, 16, 0, 4)
creditText.BackgroundTransparency = 1
creditText.TextColor3 = Theme.TextDim
creditText.TextSize = 12
creditText.Font = Enum.Font.Gotham
creditText.TextWrapped = true
creditText.TextXAlignment = Enum.TextXAlignment.Left
creditText.TextYAlignment = Enum.TextYAlignment.Top
creditText.Parent = creditCard

-- ==========================================
-- İLK TAB'I AKTİF ET
-- ==========================================

local firstTab = tabs["Aimbot"]
firstTab.Button.BackgroundTransparency = 0.3
firstTab.Button.BackgroundColor3 = Theme.Surface2
firstTab.ActiveBar.BackgroundTransparency = 0
firstTab.Icon.TextColor3 = Theme.Accent
firstTab.Name.TextColor3 = Theme.Text
tabPages["Aimbot"].Visible = true
currentTab = "Aimbot"

-- ==========================================
-- MENÜ TOGGLE TUŞU
-- ==========================================

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Settings.UI.ToggleKey then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("[VergiHub] UI Dashboard v2 hazir!")
return MainFrame
