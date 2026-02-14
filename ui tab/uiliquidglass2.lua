--[[
    VergiHub - Liquid Glass UI Structure v1.0
    Ana pencere, TopBar, SideBar, ContentArea
    Tüm paneller frosted glass efektli
]]

local Settings = getgenv().VergiHub
local GE = getgenv().VergiHub.GlassEngine
local P = GE.Palette
local A = GE.Alpha

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Eski UI kaldır
if game.CoreGui:FindFirstChild("VergiHubUI") then
    game.CoreGui:FindFirstChild("VergiHubUI"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VergiHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game.CoreGui

-- ==========================================
-- ARKA PLAN BLUR SİMÜLASYONU
-- ==========================================
-- Roblox'ta gerçek blur yok, ama BlurEffect + karanlık overlay ile simüle ediyoruz

local blurEffect = Instance.new("BlurEffect")
blurEffect.Name = "VergiHubBlur"
blurEffect.Size = 6
blurEffect.Parent = game:GetService("Lighting")

-- ==========================================
-- ANA PENCERE (Glass Container)
-- ==========================================

-- Dış gölge frame
local shadowHost = Instance.new("Frame")
shadowHost.Name = "ShadowHost"
shadowHost.Size = UDim2.new(0, 580, 0, 460)
shadowHost.Position = UDim2.new(0.5, -290, 0.5, -230)
shadowHost.BackgroundTransparency = 1
shadowHost.Parent = ScreenGui

GE.addDepthShadow(shadowHost, {Offset = 12, Transparency = 0.45})

-- Ana cam pencere
local mainGlass = GE.createGlassPanel(shadowHost, {
    Name = "MainFrame",
    Size = UDim2.new(1, 0, 1, 0),
    Color = Color3.fromRGB(15, 15, 28),
    Transparency = A.GlassBackground,
    Corner = 16,
    AccentGlow = P.AccentPrimary,
})

local MainFrame = mainGlass.Container
MainFrame.ClipsDescendants = true

-- Refraction animasyonu (ana pencere)
GE.addRefractionAnimation(mainGlass.Background, {
    Speed = 12,
    Color1 = Color3.fromRGB(60, 120, 255),
    Color2 = Color3.fromRGB(200, 80, 255),
})

-- ==========================================
-- ÜST BAR (Frosted Glass)
-- ==========================================

local topBarGlass = GE.createGlassPanel(MainFrame, {
    Name = "TopBar",
    Size = UDim2.new(1, 0, 0, 48),
    Position = UDim2.new(0, 0, 0, 0),
    Color = Color3.fromRGB(18, 18, 32),
    Transparency = A.GlassTopBar,
    Corner = 0,
    ZIndex = 10,
})

local TopBar = topBarGlass.Container

-- Üst bar alt cam çizgisi
local topBarLine = Instance.new("Frame")
topBarLine.Size = UDim2.new(1, 0, 0, 1)
topBarLine.Position = UDim2.new(0, 0, 1, -1)
topBarLine.BackgroundColor3 = P.AccentPrimary
topBarLine.BackgroundTransparency = 0.6
topBarLine.BorderSizePixel = 0
topBarLine.ZIndex = 12
topBarLine.Parent = TopBar

-- Işık kırılma çizgisi (accent gradient)
local topLineGrad = Instance.new("UIGradient")
topLineGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, P.AccentCyan),
    ColorSequenceKeypoint.new(0.3, P.AccentPrimary),
    ColorSequenceKeypoint.new(0.7, P.AccentPink),
    ColorSequenceKeypoint.new(1, P.AccentCyan),
})
topLineGrad.Parent = topBarLine

-- Gradient animasyonu
task.spawn(function()
    local offset = 0
    while topLineGrad and topLineGrad.Parent do
        offset = (offset + 0.003) % 1
        topLineGrad.Offset = Vector2.new(offset, 0)
        task.wait(0.03)
    end
end)

-- Logo (cam içinde V)
local logoContainer = Instance.new("Frame")
logoContainer.Size = UDim2.new(0, 32, 0, 32)
logoContainer.Position = UDim2.new(0, 12, 0.5, -16)
logoContainer.BackgroundColor3 = P.AccentPrimary
logoContainer.BackgroundTransparency = 0.3
logoContainer.BorderSizePixel = 0
logoContainer.ZIndex = 11
logoContainer.Parent = TopBar

local logoCnr = Instance.new("UICorner")
logoCnr.CornerRadius = UDim.new(0, 8)
logoCnr.Parent = logoContainer

local logoStroke = Instance.new("UIStroke")
logoStroke.Color = P.AccentGlow
logoStroke.Thickness = 1
logoStroke.Transparency = 0.5
logoStroke.Parent = logoContainer

local logoLabel = Instance.new("TextLabel")
logoLabel.Text = "V"
logoLabel.Size = UDim2.new(1, 0, 1, 0)
logoLabel.BackgroundTransparency = 1
logoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
logoLabel.TextSize = 18
logoLabel.Font = Enum.Font.GothamBold
logoLabel.ZIndex = 12
logoLabel.Parent = logoContainer

-- Başlık
local titleLbl = Instance.new("TextLabel")
titleLbl.Text = "VergiHub"
titleLbl.Size = UDim2.new(0, 100, 1, 0)
titleLbl.Position = UDim2.new(0, 52, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.TextColor3 = P.TextPrimary
titleLbl.TextSize = 17
titleLbl.Font = Enum.Font.GothamBold
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.ZIndex = 11
titleLbl.Parent = TopBar

-- Versiyon cam badge
local verBadge = Instance.new("Frame")
verBadge.Size = UDim2.new(0, 42, 0, 20)
verBadge.Position = UDim2.new(0, 154, 0.5, -10)
verBadge.BackgroundColor3 = P.GlassElevated
verBadge.BackgroundTransparency = 0.4
verBadge.BorderSizePixel = 0
verBadge.ZIndex = 11
verBadge.Parent = TopBar

local vbCnr = Instance.new("UICorner")
vbCnr.CornerRadius = UDim.new(0, 6)
vbCnr.Parent = verBadge

local vbStroke = Instance.new("UIStroke")
vbStroke.Color = P.BorderGlass
vbStroke.Thickness = 1
vbStroke.Transparency = 0.7
vbStroke.Parent = verBadge

local verText = Instance.new("TextLabel")
verText.Text = Settings.Version
verText.Size = UDim2.new(1, 0, 1, 0)
verText.BackgroundTransparency = 1
verText.TextColor3 = P.TextMuted
verText.TextSize = 10
verText.Font = Enum.Font.GothamSemibold
verText.ZIndex = 12
verText.Parent = verBadge

-- Kullanıcı bilgisi (cam pill)
local userPill = Instance.new("Frame")
userPill.Size = UDim2.new(0, 140, 0, 28)
userPill.Position = UDim2.new(1, -230, 0.5, -14)
userPill.BackgroundColor3 = P.GlassInput
userPill.BackgroundTransparency = 0.5
userPill.BorderSizePixel = 0
userPill.ZIndex = 11
userPill.Parent = TopBar

local upCnr = Instance.new("UICorner")
upCnr.CornerRadius = UDim.new(1, 0)
upCnr.Parent = userPill

local upStroke = Instance.new("UIStroke")
upStroke.Color = P.BorderGlass
upStroke.Thickness = 1
upStroke.Transparency = 0.7
upStroke.Parent = userPill

-- Online nokta
local onlineDot = Instance.new("Frame")
onlineDot.Size = UDim2.new(0, 8, 0, 8)
onlineDot.Position = UDim2.new(0, 10, 0.5, -4)
onlineDot.BackgroundColor3 = P.Success
onlineDot.BorderSizePixel = 0
onlineDot.ZIndex = 12
onlineDot.Parent = userPill

local odCnr = Instance.new("UICorner")
odCnr.CornerRadius = UDim.new(1, 0)
odCnr.Parent = onlineDot

local userNameLbl = Instance.new("TextLabel")
userNameLbl.Text = LocalPlayer.DisplayName
userNameLbl.Size = UDim2.new(1, -30, 1, 0)
userNameLbl.Position = UDim2.new(0, 24, 0, 0)
userNameLbl.BackgroundTransparency = 1
userNameLbl.TextColor3 = P.TextSecondary
userNameLbl.TextSize = 12
userNameLbl.Font = Enum.Font.Gotham
userNameLbl.TextXAlignment = Enum.TextXAlignment.Left
userNameLbl.TextTruncate = Enum.TextTruncate.AtEnd
userNameLbl.ZIndex = 12
userNameLbl.Parent = userPill

-- Kapat ve minimize butonları
local closeBtn = Instance.new("TextButton")
closeBtn.Text = "×"
closeBtn.Size = UDim2.new(0, 36, 0, 36)
closeBtn.Position = UDim2.new(1, -42, 0.5, -18)
closeBtn.BackgroundColor3 = P.Error
closeBtn.BackgroundTransparency = 0.85
closeBtn.TextColor3 = P.TextMuted
closeBtn.TextSize = 20
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.AutoButtonColor = false
closeBtn.ZIndex = 11
closeBtn.Parent = TopBar

local closeCnr = Instance.new("UICorner")
closeCnr.CornerRadius = UDim.new(0, 8)
closeCnr.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    blurEffect.Size = 0
end)

closeBtn.MouseEnter:Connect(function()
    GE.tween(closeBtn, {BackgroundTransparency = 0.5, TextColor3 = P.Error}, 0.15)
end)
closeBtn.MouseLeave:Connect(function()
    GE.tween(closeBtn, {BackgroundTransparency = 0.85, TextColor3 = P.TextMuted}, 0.2)
end)

local minBtn = Instance.new("TextButton")
minBtn.Text = "–"
minBtn.Size = UDim2.new(0, 36, 0, 36)
minBtn.Position = UDim2.new(1, -80, 0.5, -18)
minBtn.BackgroundColor3 = P.GlassElevated
minBtn.BackgroundTransparency = 0.8
minBtn.TextColor3 = P.TextMuted
minBtn.TextSize = 18
minBtn.Font = Enum.Font.GothamBold
minBtn.BorderSizePixel = 0
minBtn.AutoButtonColor = false
minBtn.ZIndex = 11
minBtn.Parent = TopBar

local minCnr = Instance.new("UICorner")
minCnr.CornerRadius = UDim.new(0, 8)
minCnr.Parent = minBtn

minBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    blurEffect.Size = 0
end)

minBtn.MouseEnter:Connect(function()
    GE.tween(minBtn, {BackgroundTransparency = 0.5, TextColor3 = P.TextSecondary}, 0.15)
end)
minBtn.MouseLeave:Connect(function()
    GE.tween(minBtn, {BackgroundTransparency = 0.8, TextColor3 = P.TextMuted}, 0.2)
end)

-- ==========================================
-- SÜRÜKLEME SİSTEMİ
-- ==========================================

local dragging, dragStart, startPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = shadowHost.Position
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
        shadowHost.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- ==========================================
-- SOL PANEL (Glass Sidebar)
-- ==========================================

local sideBarGlass = GE.createGlassPanel(MainFrame, {
    Name = "SideBar",
    Size = UDim2.new(0, 135, 1, -48),
    Position = UDim2.new(0, 0, 0, 48),
    Color = Color3.fromRGB(12, 12, 25),
    Transparency = A.GlassSideBar,
    Corner = 0,
    ZIndex = 5,
})

local SideBar = sideBarGlass.Container

-- Sağ kenar cam çizgisi
local sideBarLine = Instance.new("Frame")
sideBarLine.Size = UDim2.new(0, 1, 1, 0)
sideBarLine.Position = UDim2.new(1, 0, 0, 0)
sideBarLine.BackgroundColor3 = P.BorderGlass
sideBarLine.BackgroundTransparency = 0.8
sideBarLine.BorderSizePixel = 0
sideBarLine.ZIndex = 6
sideBarLine.Parent = SideBar

-- Tab butonları container
local tabContainer = Instance.new("Frame")
tabContainer.Name = "TabContainer"
tabContainer.Size = UDim2.new(1, -12, 1, -16)
tabContainer.Position = UDim2.new(0, 6, 0, 8)
tabContainer.BackgroundTransparency = 1
tabContainer.ZIndex = 6
tabContainer.Parent = SideBar

local tabLayout = Instance.new("UIListLayout")
tabLayout.Padding = UDim.new(0, 4)
tabLayout.Parent = tabContainer

-- ==========================================
-- İÇERİK ALANI (Glass Content)
-- ==========================================

local ContentArea = Instance.new("ScrollingFrame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -149, 1, -58)
ContentArea.Position = UDim2.new(0, 141, 0, 54)
ContentArea.BackgroundTransparency = 1
ContentArea.BorderSizePixel = 0
ContentArea.ScrollBarThickness = 3
ContentArea.ScrollBarImageColor3 = P.AccentPrimary
ContentArea.ScrollBarImageTransparency = 0.3
ContentArea.CanvasSize = UDim2.new(0, 0, 0, 0)
ContentArea.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentArea.ZIndex = 5
ContentArea.Parent = MainFrame

local contentPad = Instance.new("UIPadding")
contentPad.PaddingTop = UDim.new(0, 6)
contentPad.PaddingBottom = UDim.new(0, 12)
contentPad.PaddingLeft = UDim.new(0, 6)
contentPad.PaddingRight = UDim.new(0, 8)
contentPad.Parent = ContentArea

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 6)
contentLayout.Parent = ContentArea

-- ==========================================
-- TAB SİSTEMİ (Glass Tabs)
-- ==========================================

local tabs = {}
local tabPages = {}
local currentTab = nil

local TAB_ICONS = {
    Aimbot   = "◎",
    ESP      = "◈",
    HardLock = "⊕",
    Bypass   = "◆",
    Settings = "⚙",
}

local function createTab(name, icon)
    -- Cam tab butonu
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = "Tab_" .. name
    tabBtn.Text = ""
    tabBtn.Size = UDim2.new(1, 0, 0, 38)
    tabBtn.BackgroundColor3 = P.GlassInput
    tabBtn.BackgroundTransparency = 1
    tabBtn.BorderSizePixel = 0
    tabBtn.AutoButtonColor = false
    tabBtn.ZIndex = 7
    tabBtn.Parent = tabContainer

    local tabCnr = Instance.new("UICorner")
    tabCnr.CornerRadius = UDim.new(0, 10)
    tabCnr.Parent = tabBtn

    -- Aktif gösterge (sol cam bar)
    local activeBar = Instance.new("Frame")
    activeBar.Name = "ActiveBar"
    activeBar.Size = UDim2.new(0, 3, 0.55, 0)
    activeBar.Position = UDim2.new(0, 2, 0.225, 0)
    activeBar.BackgroundColor3 = P.AccentPrimary
    activeBar.BackgroundTransparency = 1
    activeBar.BorderSizePixel = 0
    activeBar.ZIndex = 8
    activeBar.Parent = tabBtn

    local abCnr = Instance.new("UICorner")
    abCnr.CornerRadius = UDim.new(0, 2)
    abCnr.Parent = activeBar

    -- İkon
    local iconLbl = Instance.new("TextLabel")
    iconLbl.Text = icon or ""
    iconLbl.Size = UDim2.new(0, 28, 1, 0)
    iconLbl.Position = UDim2.new(0, 10, 0, 0)
    iconLbl.BackgroundTransparency = 1
    iconLbl.TextColor3 = P.TextMuted
    iconLbl.TextSize = 15
    iconLbl.Font = Enum.Font.GothamBold
    iconLbl.ZIndex = 8
    iconLbl.Parent = tabBtn

    -- Ad
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Text = name
    nameLbl.Size = UDim2.new(1, -42, 1, 0)
    nameLbl.Position = UDim2.new(0, 38, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.TextColor3 = P.TextMuted
    nameLbl.TextSize = 13
    nameLbl.Font = Enum.Font.GothamSemibold
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.ZIndex = 8
    nameLbl.Parent = tabBtn

    -- Sayfa
    local page = Instance.new("Frame")
    page.Name = "Page_" .. name
    page.Size = UDim2.new(1, 0, 0, 0)
    page.AutomaticSize = Enum.AutomaticSize.Y
    page.BackgroundTransparency = 1
    page.Visible = false
    page.ZIndex = 5
    page.Parent = ContentArea

    local pageLayout = Instance.new("UIListLayout")
    pageLayout.Padding = UDim.new(0, 6)
    pageLayout.Parent = page

    tabs[name] = {
        Button = tabBtn,
        ActiveBar = activeBar,
        Icon = iconLbl,
        Name = nameLbl,
    }
    tabPages[name] = page

    -- Hover
    tabBtn.MouseEnter:Connect(function()
        if currentTab ~= name then
            GE.tween(tabBtn, {BackgroundTransparency = 0.6}, 0.15)
            GE.tween(iconLbl, {TextColor3 = P.TextSecondary}, 0.15)
        end
    end)

    tabBtn.MouseLeave:Connect(function()
        if currentTab ~= name then
            GE.tween(tabBtn, {BackgroundTransparency = 1}, 0.2)
            GE.tween(iconLbl, {TextColor3 = P.TextMuted}, 0.2)
        end
    end)

    -- Tıklama
    tabBtn.MouseButton1Click:Connect(function()
        for tName, tData in pairs(tabs) do
            GE.tween(tData.Button, {BackgroundTransparency = 1}, 0.2)
            GE.tween(tData.ActiveBar, {BackgroundTransparency = 1}, 0.2)
            GE.tween(tData.Icon, {TextColor3 = P.TextMuted}, 0.2)
            GE.tween(tData.Name, {TextColor3 = P.TextMuted}, 0.2)
            tabPages[tName].Visible = false
        end

        GE.tween(tabBtn, {BackgroundTransparency = 0.55}, 0.2)
        GE.tween(activeBar, {BackgroundTransparency = 0.15}, 0.2)
        GE.tween(iconLbl, {TextColor3 = P.AccentSecondary}, 0.2)
        GE.tween(nameLbl, {TextColor3 = P.TextPrimary}, 0.2)
        page.Visible = true
        currentTab = name
        ContentArea.CanvasPosition = Vector2.new(0, 0)
    end)

    return page
end

-- Menü toggle
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Settings.UI.ToggleKey then
        MainFrame.Visible = not MainFrame.Visible
        blurEffect.Size = MainFrame.Visible and 6 or 0
    end
end)

-- Global erişim (glass3 kullanacak)
getgenv().VergiHub._GlassUI = {
    ScreenGui = ScreenGui,
    MainFrame = MainFrame,
    ShadowHost = shadowHost,
    TopBar = TopBar,
    SideBar = SideBar,
    ContentArea = ContentArea,
    BlurEffect = blurEffect,
    tabs = tabs,
    tabPages = tabPages,
    createTab = createTab,
}

print("[VergiHub] Liquid Glass UI Structure hazir!")
return true
