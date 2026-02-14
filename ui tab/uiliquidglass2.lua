--[[
    VergiHub - Liquid Glass UI Structure v2.0
    
    Duzeltmeler:
    - shadowHost gizlenme sorunu
    - BlurEffect kapanmama sorunu
    - Floating menu'ye donus
    - Minimize siyah ekran
]]

local Settings = getgenv().VergiHub
local GE = getgenv().VergiHub.GlassEngine
local P = GE.Palette

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

-- Eski UI kaldir
if game.CoreGui:FindFirstChild("VergiHubUI") then
    game.CoreGui:FindFirstChild("VergiHubUI"):Destroy()
end

-- Eski blur kaldir
local oldBlur = Lighting:FindFirstChild("VergiHubBlur")
if oldBlur then oldBlur:Destroy() end

-- ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VergiHubUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = game.CoreGui

-- ==========================================
-- BLUR EFFECT
-- ==========================================

local blurEffect = Instance.new("BlurEffect")
blurEffect.Name = "VergiHubBlur"
blurEffect.Size = 8
blurEffect.Parent = Lighting

-- ==========================================
-- GOSTER / GIZLE FONKSİYONU (Tek merkezden)
-- ==========================================

local isMenuVisible = true

local function setMenuVisible(visible)
    isMenuVisible = visible

    if visible then
        ScreenGui.Enabled = true
        GE.tween(blurEffect, {Size = 8}, 0.3)
    else
        ScreenGui.Enabled = false
        blurEffect.Size = 0
    end
end

-- ==========================================
-- ANA PENCERE
-- ==========================================

-- Shadow host
local shadowHost = Instance.new("Frame")
shadowHost.Name = "ShadowHost"
shadowHost.Size = UDim2.new(0, 580, 0, 460)
shadowHost.Position = UDim2.new(0.5, -290, 0.5, -230)
shadowHost.BackgroundTransparency = 1
shadowHost.BorderSizePixel = 0
shadowHost.Parent = ScreenGui

GE.addDepthShadow(shadowHost, {Offset = 14, Transparency = 0.4})

-- Ana cam pencere
local mainGlass = GE.createGlassPanel(shadowHost, {
    Name = "MainFrame",
    Size = UDim2.new(1, 0, 1, 0),
    Color = Color3.fromRGB(12, 12, 26),
    Transparency = 0.18,
    Corner = 18,
    AccentGlow = P.AccentPrimary,
    ZIndex = 1,
})

local MainFrame = mainGlass.Container
MainFrame.ClipsDescendants = true

-- Refraction (hareket eden isik)
GE.addRefractionAnimation(mainGlass.Background, {
    Speed = 14,
    Color1 = Color3.fromRGB(60, 140, 255),
    Color2 = Color3.fromRGB(220, 80, 255),
})

-- ==========================================
-- UST BAR (Glass)
-- ==========================================

local topBarGlass = GE.createGlassPanel(MainFrame, {
    Name = "TopBar",
    Size = UDim2.new(1, 0, 0, 50),
    Color = Color3.fromRGB(14, 14, 30),
    Transparency = 0.12,
    Corner = 0,
    ZIndex = 10,
})

local TopBar = topBarGlass.Container

-- Ust bar alt cam cizgisi (gradient animasyonlu)
local topLine = Instance.new("Frame")
topLine.Size = UDim2.new(1, 0, 0, 2)
topLine.Position = UDim2.new(0, 0, 1, -2)
topLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
topLine.BorderSizePixel = 0
topLine.ZIndex = 12
topLine.Parent = TopBar

local topLineGrad = Instance.new("UIGradient")
topLineGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, P.AccentCyan),
    ColorSequenceKeypoint.new(0.25, P.AccentPrimary),
    ColorSequenceKeypoint.new(0.5, P.AccentPink),
    ColorSequenceKeypoint.new(0.75, P.AccentPrimary),
    ColorSequenceKeypoint.new(1, P.AccentCyan),
})
topLineGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.3),
    NumberSequenceKeypoint.new(0.5, 0.1),
    NumberSequenceKeypoint.new(1, 0.3),
})
topLineGrad.Parent = topLine

-- Gradient animasyonu (sonsuz kayma)
task.spawn(function()
    local offset = 0
    while topLineGrad and topLineGrad.Parent do
        offset = (offset + 0.005) % 1
        topLineGrad.Offset = Vector2.new(offset, 0)
        task.wait(0.03)
    end
end)

-- Logo
local logoFrame = Instance.new("Frame")
logoFrame.Size = UDim2.new(0, 34, 0, 34)
logoFrame.Position = UDim2.new(0, 12, 0.5, -17)
logoFrame.BackgroundColor3 = P.AccentPrimary
logoFrame.BackgroundTransparency = 0.2
logoFrame.BorderSizePixel = 0
logoFrame.ZIndex = 11
logoFrame.Parent = TopBar

Instance.new("UICorner", logoFrame).CornerRadius = UDim.new(0, 10)

local logoStroke = Instance.new("UIStroke")
logoStroke.Color = P.AccentGlow
logoStroke.Thickness = 1.5
logoStroke.Transparency = 0.4
logoStroke.Parent = logoFrame

local logoText = Instance.new("TextLabel")
logoText.Text = "V"
logoText.Size = UDim2.new(1, 0, 1, 0)
logoText.BackgroundTransparency = 1
logoText.TextColor3 = Color3.fromRGB(255, 255, 255)
logoText.TextSize = 20
logoText.Font = Enum.Font.GothamBold
logoText.ZIndex = 12
logoText.Parent = logoFrame

-- Baslik
local titleLbl = Instance.new("TextLabel")
titleLbl.Text = "VergiHub"
titleLbl.Size = UDim2.new(0, 110, 1, 0)
titleLbl.Position = UDim2.new(0, 54, 0, 0)
titleLbl.BackgroundTransparency = 1
titleLbl.TextColor3 = P.TextPrimary
titleLbl.TextSize = 18
titleLbl.Font = Enum.Font.GothamBold
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.ZIndex = 11
titleLbl.Parent = TopBar

-- Versiyon badge
local verBadge = Instance.new("Frame")
verBadge.Size = UDim2.new(0, 44, 0, 22)
verBadge.Position = UDim2.new(0, 164, 0.5, -11)
verBadge.BackgroundColor3 = P.GlassElevated
verBadge.BackgroundTransparency = 0.35
verBadge.BorderSizePixel = 0
verBadge.ZIndex = 11
verBadge.Parent = TopBar

Instance.new("UICorner", verBadge).CornerRadius = UDim.new(0, 6)

local vbStroke = Instance.new("UIStroke")
vbStroke.Color = P.BorderGlass
vbStroke.Thickness = 1
vbStroke.Transparency = 0.65
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

-- Kullanici pill
local userPill = Instance.new("Frame")
userPill.Size = UDim2.new(0, 140, 0, 30)
userPill.Position = UDim2.new(1, -240, 0.5, -15)
userPill.BackgroundColor3 = P.GlassInput
userPill.BackgroundTransparency = 0.4
userPill.BorderSizePixel = 0
userPill.ZIndex = 11
userPill.Parent = TopBar

Instance.new("UICorner", userPill).CornerRadius = UDim.new(1, 0)

local upStroke = Instance.new("UIStroke")
upStroke.Color = P.BorderGlass
upStroke.Thickness = 1
upStroke.Transparency = 0.65
upStroke.Parent = userPill

local onlineDot = Instance.new("Frame")
onlineDot.Size = UDim2.new(0, 8, 0, 8)
onlineDot.Position = UDim2.new(0, 10, 0.5, -4)
onlineDot.BackgroundColor3 = P.Success
onlineDot.BorderSizePixel = 0
onlineDot.ZIndex = 12
onlineDot.Parent = userPill
Instance.new("UICorner", onlineDot).CornerRadius = UDim.new(1, 0)

local userLbl = Instance.new("TextLabel")
userLbl.Text = LocalPlayer.DisplayName
userLbl.Size = UDim2.new(1, -30, 1, 0)
userLbl.Position = UDim2.new(0, 24, 0, 0)
userLbl.BackgroundTransparency = 1
userLbl.TextColor3 = P.TextSecondary
userLbl.TextSize = 12
userLbl.Font = Enum.Font.Gotham
userLbl.TextXAlignment = Enum.TextXAlignment.Left
userLbl.TextTruncate = Enum.TextTruncate.AtEnd
userLbl.ZIndex = 12
userLbl.Parent = userPill

-- KAPAT butonu
local closeBtn = Instance.new("TextButton")
closeBtn.Text = "×"
closeBtn.Size = UDim2.new(0, 38, 0, 38)
closeBtn.Position = UDim2.new(1, -44, 0.5, -19)
closeBtn.BackgroundColor3 = P.Error
closeBtn.BackgroundTransparency = 0.85
closeBtn.TextColor3 = P.TextMuted
closeBtn.TextSize = 22
closeBtn.Font = Enum.Font.GothamBold
closeBtn.BorderSizePixel = 0
closeBtn.AutoButtonColor = false
closeBtn.ZIndex = 11
closeBtn.Parent = TopBar

Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)

closeBtn.MouseButton1Click:Connect(function()
    setMenuVisible(false)
end)

closeBtn.MouseEnter:Connect(function()
    GE.tween(closeBtn, {BackgroundTransparency = 0.4, TextColor3 = P.Error}, 0.12)
end)
closeBtn.MouseLeave:Connect(function()
    GE.tween(closeBtn, {BackgroundTransparency = 0.85, TextColor3 = P.TextMuted}, 0.15)
end)

-- MINIMİZE butonu
local minBtn = Instance.new("TextButton")
minBtn.Text = "–"
minBtn.Size = UDim2.new(0, 38, 0, 38)
minBtn.Position = UDim2.new(1, -84, 0.5, -19)
minBtn.BackgroundColor3 = P.GlassElevated
minBtn.BackgroundTransparency = 0.75
minBtn.TextColor3 = P.TextMuted
minBtn.TextSize = 20
minBtn.Font = Enum.Font.GothamBold
minBtn.BorderSizePixel = 0
minBtn.AutoButtonColor = false
minBtn.ZIndex = 11
minBtn.Parent = TopBar

Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 8)

minBtn.MouseButton1Click:Connect(function()
    setMenuVisible(false)
end)

minBtn.MouseEnter:Connect(function()
    GE.tween(minBtn, {BackgroundTransparency = 0.45, TextColor3 = P.TextSecondary}, 0.12)
end)
minBtn.MouseLeave:Connect(function()
    GE.tween(minBtn, {BackgroundTransparency = 0.75, TextColor3 = P.TextMuted}, 0.15)
end)

-- ==========================================
-- SURÜKLEME
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

local sideGlass = GE.createGlassPanel(MainFrame, {
    Name = "SideBar",
    Size = UDim2.new(0, 140, 1, -50),
    Position = UDim2.new(0, 0, 0, 50),
    Color = Color3.fromRGB(10, 10, 22),
    Transparency = 0.15,
    Corner = 0,
    ZIndex = 5,
})

local SideBar = sideGlass.Container

-- Sag kenar cam cizgi
local sideBarLine = Instance.new("Frame")
sideBarLine.Size = UDim2.new(0, 1, 1, 0)
sideBarLine.Position = UDim2.new(1, 0, 0, 0)
sideBarLine.BackgroundColor3 = P.BorderGlass
sideBarLine.BackgroundTransparency = 0.75
sideBarLine.BorderSizePixel = 0
sideBarLine.ZIndex = 6
sideBarLine.Parent = SideBar

-- Tab container
local tabContainer = Instance.new("Frame")
tabContainer.Name = "TabContainer"
tabContainer.Size = UDim2.new(1, -14, 1, -16)
tabContainer.Position = UDim2.new(0, 7, 0, 8)
tabContainer.BackgroundTransparency = 1
tabContainer.ZIndex = 6
tabContainer.Parent = SideBar

local tabLayout = Instance.new("UIListLayout")
tabLayout.Padding = UDim.new(0, 5)
tabLayout.Parent = tabContainer

-- ==========================================
-- İCERİK ALANI
-- ==========================================

local ContentArea = Instance.new("ScrollingFrame")
ContentArea.Name = "ContentArea"
ContentArea.Size = UDim2.new(1, -156, 1, -62)
ContentArea.Position = UDim2.new(0, 148, 0, 56)
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
contentPad.PaddingBottom = UDim.new(0, 14)
contentPad.PaddingLeft = UDim.new(0, 8)
contentPad.PaddingRight = UDim.new(0, 10)
contentPad.Parent = ContentArea

local contentLayout = Instance.new("UIListLayout")
contentLayout.Padding = UDim.new(0, 6)
contentLayout.Parent = ContentArea

-- ==========================================
-- TAB SİSTEMİ
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
    local tabBtn = Instance.new("TextButton")
    tabBtn.Name = "Tab_" .. name
    tabBtn.Text = ""
    tabBtn.Size = UDim2.new(1, 0, 0, 40)
    tabBtn.BackgroundColor3 = P.GlassInput
    tabBtn.BackgroundTransparency = 1
    tabBtn.BorderSizePixel = 0
    tabBtn.AutoButtonColor = false
    tabBtn.ZIndex = 7
    tabBtn.Parent = tabContainer

    Instance.new("UICorner", tabBtn).CornerRadius = UDim.new(0, 10)

    -- Aktif sol bar
    local activeBar = Instance.new("Frame")
    activeBar.Name = "ActiveBar"
    activeBar.Size = UDim2.new(0, 3, 0.55, 0)
    activeBar.Position = UDim2.new(0, 2, 0.225, 0)
    activeBar.BackgroundColor3 = P.AccentPrimary
    activeBar.BackgroundTransparency = 1
    activeBar.BorderSizePixel = 0
    activeBar.ZIndex = 8
    activeBar.Parent = tabBtn
    Instance.new("UICorner", activeBar).CornerRadius = UDim.new(0, 2)

    -- Ikon
    local iconLbl = Instance.new("TextLabel")
    iconLbl.Text = icon or ""
    iconLbl.Size = UDim2.new(0, 30, 1, 0)
    iconLbl.Position = UDim2.new(0, 10, 0, 0)
    iconLbl.BackgroundTransparency = 1
    iconLbl.TextColor3 = P.TextMuted
    iconLbl.TextSize = 16
    iconLbl.Font = Enum.Font.GothamBold
    iconLbl.ZIndex = 8
    iconLbl.Parent = tabBtn

    -- Ad
    local nameLbl = Instance.new("TextLabel")
    nameLbl.Text = name
    nameLbl.Size = UDim2.new(1, -44, 1, 0)
    nameLbl.Position = UDim2.new(0, 40, 0, 0)
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

    tabs[name] = {Button = tabBtn, ActiveBar = activeBar, Icon = iconLbl, Name = nameLbl}
    tabPages[name] = page

    -- Hover
    tabBtn.MouseEnter:Connect(function()
        if currentTab ~= name then
            GE.tween(tabBtn, {BackgroundTransparency = 0.55}, 0.12)
            GE.tween(iconLbl, {TextColor3 = P.TextSecondary}, 0.12)
        end
    end)

    tabBtn.MouseLeave:Connect(function()
        if currentTab ~= name then
            GE.tween(tabBtn, {BackgroundTransparency = 1}, 0.15)
            GE.tween(iconLbl, {TextColor3 = P.TextMuted}, 0.15)
        end
    end)

    -- Tiklama
    tabBtn.MouseButton1Click:Connect(function()
        for tName, tData in pairs(tabs) do
            GE.tween(tData.Button, {BackgroundTransparency = 1}, 0.2)
            GE.tween(tData.ActiveBar, {BackgroundTransparency = 1}, 0.2)
            GE.tween(tData.Icon, {TextColor3 = P.TextMuted}, 0.2)
            GE.tween(tData.Name, {TextColor3 = P.TextMuted}, 0.2)
            tabPages[tName].Visible = false
        end

        GE.tween(tabBtn, {BackgroundTransparency = 0.45}, 0.2)
        GE.tween(activeBar, {BackgroundTransparency = 0.1}, 0.2)
        GE.tween(iconLbl, {TextColor3 = P.AccentSecondary}, 0.2)
        GE.tween(nameLbl, {TextColor3 = P.TextPrimary}, 0.2)
        page.Visible = true
        currentTab = name
        ContentArea.CanvasPosition = Vector2.new(0, 0)
    end)

    return page
end

-- ==========================================
-- MENU TOGGLE (RightShift + Floating Menu)
-- ==========================================

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Settings.UI.ToggleKey then
        isMenuVisible = not isMenuVisible
        setMenuVisible(isMenuVisible)
    end
end)

-- ==========================================
-- GLOBAL ERİSİM
-- ==========================================

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
    setMenuVisible = setMenuVisible,
    isMenuVisible = function() return isMenuVisible end,
}

print("[VergiHub] Liquid Glass UI Structure v2.0 hazir!")
return true
