--[[
    VergiHub - Liquid Glass Controls & Tabs v1.0
    Glass toggle, slider, dropdown + tüm tab içerikleri
]]

local Settings = getgenv().VergiHub
local GE = getgenv().VergiHub.GlassEngine
local P = GE.Palette
local A = GE.Alpha
local UI = getgenv().VergiHub._GlassUI

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local createTab = UI.createTab
local ContentArea = UI.ContentArea
local tabs = UI.tabs
local tabPages = UI.tabPages

-- ==========================================
-- GLASS KONTROL ELEMANLARI
-- ==========================================

-- Section başlığı (cam çizgi ile)
local function createSection(parent, title)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 28)
    holder.BackgroundTransparency = 1
    holder.ZIndex = 5
    holder.Parent = parent

    -- Sol cam çizgi
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 18, 0, 1)
    line.Position = UDim2.new(0, 0, 0.5, 0)
    line.BackgroundColor3 = P.AccentPrimary
    line.BackgroundTransparency = 0.5
    line.BorderSizePixel = 0
    line.ZIndex = 6
    line.Parent = holder

    local lineGrad = Instance.new("UIGradient")
    lineGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0.3),
        NumberSequenceKeypoint.new(1, 0.3),
    })
    lineGrad.Parent = line

    local label = Instance.new("TextLabel")
    label.Text = string.upper(title)
    label.Size = UDim2.new(1, -26, 1, 0)
    label.Position = UDim2.new(0, 24, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = P.TextMuted
    label.TextSize = 10
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 6
    label.Parent = holder

    return holder
end

-- Glass Toggle
local function createToggle(parent, label, default, callback)
    local glassCard = GE.createGlassPanel(parent, {
        Name = "Toggle_" .. label,
        Size = UDim2.new(1, 0, 0, 40),
        Color = P.GlassSurface,
        Transparency = A.GlassSurface,
        Corner = 12,
        ZIndex = 5,
    })

    local holder = glassCard.Container

    -- Label
    local text = Instance.new("TextLabel")
    text.Text = label
    text.Size = UDim2.new(1, -70, 1, 0)
    text.Position = UDim2.new(0, 14, 0, 0)
    text.BackgroundTransparency = 1
    text.TextColor3 = P.TextOnGlass
    text.TextSize = 13
    text.Font = Enum.Font.Gotham
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.ZIndex = 7
    text.Parent = holder

    -- Toggle track (cam pill)
    local trackBG = Instance.new("Frame")
    trackBG.Size = UDim2.new(0, 42, 0, 22)
    trackBG.Position = UDim2.new(1, -54, 0.5, -11)
    trackBG.BackgroundColor3 = default and P.ToggleOn or P.ToggleOff
    trackBG.BackgroundTransparency = default and 0.25 or 0.35
    trackBG.BorderSizePixel = 0
    trackBG.ZIndex = 7
    trackBG.Parent = holder

    local trackCnr = Instance.new("UICorner")
    trackCnr.CornerRadius = UDim.new(1, 0)
    trackCnr.Parent = trackBG

    local trackStroke = Instance.new("UIStroke")
    trackStroke.Color = default and P.AccentGlow or P.BorderGlass
    trackStroke.Thickness = 1
    trackStroke.Transparency = default and 0.5 or 0.7
    trackStroke.Parent = trackBG

    -- Toggle knob (cam daire)
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = default and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BackgroundTransparency = 0.05
    knob.BorderSizePixel = 0
    knob.ZIndex = 8
    knob.Parent = trackBG

    local knobCnr = Instance.new("UICorner")
    knobCnr.CornerRadius = UDim.new(1, 0)
    knobCnr.Parent = knob

    -- Knob içi frost
    local knobFrost = Instance.new("Frame")
    knobFrost.Size = UDim2.new(1, -4, 0.5, 0)
    knobFrost.Position = UDim2.new(0, 2, 0, 1)
    knobFrost.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knobFrost.BackgroundTransparency = 0.7
    knobFrost.BorderSizePixel = 0
    knobFrost.ZIndex = 9
    knobFrost.Parent = knob

    local kfCnr = Instance.new("UICorner")
    kfCnr.CornerRadius = UDim.new(1, 0)
    kfCnr.Parent = knobFrost

    local state = default

    -- Tıklama
    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.ZIndex = 10
    clickBtn.Parent = holder

    clickBtn.MouseEnter:Connect(function()
        GE.tween(glassCard.Background, {BackgroundTransparency = A.GlassSurface - 0.08}, 0.12)
        GE.tween(glassCard.Stroke, {Transparency = 0.4}, 0.12)
    end)
    clickBtn.MouseLeave:Connect(function()
        GE.tween(glassCard.Background, {BackgroundTransparency = A.GlassSurface}, 0.2)
        GE.tween(glassCard.Stroke, {Transparency = A.BorderGlow}, 0.2)
    end)

    clickBtn.MouseButton1Click:Connect(function()
        state = not state

        if state then
            GE.tween(trackBG, {BackgroundColor3 = P.ToggleOn, BackgroundTransparency = 0.25}, 0.25)
            GE.tween(knob, {Position = UDim2.new(1, -20, 0.5, -9)}, 0.25)
            GE.tween(trackStroke, {Color = P.AccentGlow, Transparency = 0.5}, 0.25)
        else
            GE.tween(trackBG, {BackgroundColor3 = P.ToggleOff, BackgroundTransparency = 0.35}, 0.25)
            GE.tween(knob, {Position = UDim2.new(0, 2, 0.5, -9)}, 0.25)
            GE.tween(trackStroke, {Color = P.BorderGlass, Transparency = 0.7}, 0.25)
        end

        if callback then callback(state) end
    end)

    return holder
end

-- Glass Slider
local function createSlider(parent, label, min, max, default, callback)
    local glassCard = GE.createGlassPanel(parent, {
        Name = "Slider_" .. label,
        Size = UDim2.new(1, 0, 0, 56),
        Color = P.GlassSurface,
        Transparency = A.GlassSurface,
        Corner = 12,
        ZIndex = 5,
    })

    local holder = glassCard.Container

    -- Label
    local text = Instance.new("TextLabel")
    text.Text = label
    text.Size = UDim2.new(0.62, 0, 0, 24)
    text.Position = UDim2.new(0, 14, 0, 4)
    text.BackgroundTransparency = 1
    text.TextColor3 = P.TextOnGlass
    text.TextSize = 13
    text.Font = Enum.Font.Gotham
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.ZIndex = 7
    text.Parent = holder

    -- Değer cam badge
    local valBadge = Instance.new("Frame")
    valBadge.Size = UDim2.new(0, 48, 0, 22)
    valBadge.Position = UDim2.new(1, -58, 0, 5)
    valBadge.BackgroundColor3 = P.GlassInput
    valBadge.BackgroundTransparency = 0.4
    valBadge.BorderSizePixel = 0
    valBadge.ZIndex = 7
    valBadge.Parent = holder

    local vbCnr = Instance.new("UICorner")
    vbCnr.CornerRadius = UDim.new(0, 6)
    vbCnr.Parent = valBadge

    local vbStroke = Instance.new("UIStroke")
    vbStroke.Color = P.BorderGlass
    vbStroke.Thickness = 1
    vbStroke.Transparency = 0.75
    vbStroke.Parent = valBadge

    local valLbl = Instance.new("TextLabel")
    valLbl.Text = tostring(default)
    valLbl.Size = UDim2.new(1, 0, 1, 0)
    valLbl.BackgroundTransparency = 1
    valLbl.TextColor3 = P.AccentSecondary
    valLbl.TextSize = 11
    valLbl.Font = Enum.Font.GothamBold
    valLbl.ZIndex = 8
    valLbl.Parent = valBadge

    -- Slider track (cam)
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -28, 0, 6)
    track.Position = UDim2.new(0, 14, 0, 39)
    track.BackgroundColor3 = P.SliderTrack
    track.BackgroundTransparency = 0.3
    track.BorderSizePixel = 0
    track.ZIndex = 7
    track.Parent = holder

    local trackCnr = Instance.new("UICorner")
    trackCnr.CornerRadius = UDim.new(1, 0)
    trackCnr.Parent = track

    -- Fill (gradient cam)
    local pct = math.clamp((default - min) / (max - min), 0, 1)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = P.SliderFill
    fill.BackgroundTransparency = 0.15
    fill.BorderSizePixel = 0
    fill.ZIndex = 8
    fill.Parent = track

    local fillCnr = Instance.new("UICorner")
    fillCnr.CornerRadius = UDim.new(1, 0)
    fillCnr.Parent = fill

    -- Fill gradient (cam efekti)
    local fillGrad = Instance.new("UIGradient")
    fillGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, P.AccentCyan),
        ColorSequenceKeypoint.new(1, P.AccentPrimary),
    })
    fillGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.3),
        NumberSequenceKeypoint.new(0.5, 0.1),
        NumberSequenceKeypoint.new(1, 0.25),
    })
    fillGrad.Parent = fill

    -- Knob (cam daire)
    local sKnob = Instance.new("Frame")
    sKnob.Size = UDim2.new(0, 16, 0, 16)
    sKnob.Position = UDim2.new(pct, -8, 0.5, -8)
    sKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sKnob.BackgroundTransparency = 0.05
    sKnob.BorderSizePixel = 0
    sKnob.ZIndex = 9
    sKnob.Parent = track

    local skCnr = Instance.new("UICorner")
    skCnr.CornerRadius = UDim.new(1, 0)
    skCnr.Parent = sKnob

    local skStroke = Instance.new("UIStroke")
    skStroke.Color = P.AccentPrimary
    skStroke.Thickness = 2
    skStroke.Transparency = 0.3
    skStroke.Parent = sKnob

    -- Etkileşim
    local sliding = false

    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(1, 10, 0, 26)
    sliderBtn.Position = UDim2.new(0, -5, 0, 28)
    sliderBtn.BackgroundTransparency = 1
    sliderBtn.Text = ""
    sliderBtn.ZIndex = 10
    sliderBtn.Parent = holder

    sliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true
            GE.tween(sKnob, {Size = UDim2.new(0, 20, 0, 20)}, 0.1)
            GE.tween(skStroke, {Transparency = 0.1}, 0.1)
        end
    end)

    sliderBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = false
            local cs = fill.Size.X.Scale
            GE.tween(sKnob, {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(cs, -8, 0.5, -8)}, 0.1)
            GE.tween(skStroke, {Transparency = 0.3}, 0.1)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            rel = math.clamp(rel, 0, 1)
            local val = math.floor(min + (max - min) * rel)
            valLbl.Text = tostring(val)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            sKnob.Position = UDim2.new(rel, -10, 0.5, -10)
            if callback then callback(val) end
        end
    end)

    return holder
end

-- Glass Dropdown
local function createDropdown(parent, label, options, default, callback)
    local isOpen = false

    local glassCard = GE.createGlassPanel(parent, {
        Name = "DD_" .. label,
        Size = UDim2.new(1, 0, 0, 40),
        Color = P.GlassSurface,
        Transparency = A.GlassSurface,
        Corner = 12,
        ZIndex = 5,
    })

    local holder = glassCard.Container
    holder.ClipsDescendants = true

    local text = Instance.new("TextLabel")
    text.Text = label
    text.Size = UDim2.new(0.5, 0, 0, 40)
    text.Position = UDim2.new(0, 14, 0, 0)
    text.BackgroundTransparency = 1
    text.TextColor3 = P.TextOnGlass
    text.TextSize = 13
    text.Font = Enum.Font.Gotham
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.ZIndex = 7
    text.Parent = holder

    -- Seçili değer (cam buton)
    local selBtn = Instance.new("TextButton")
    selBtn.Text = tostring(default) .. "  ▾"
    selBtn.Size = UDim2.new(0.42, -12, 0, 30)
    selBtn.Position = UDim2.new(0.58, 0, 0, 5)
    selBtn.BackgroundColor3 = P.GlassInput
    selBtn.BackgroundTransparency = 0.4
    selBtn.TextColor3 = P.AccentSecondary
    selBtn.TextSize = 12
    selBtn.Font = Enum.Font.GothamSemibold
    selBtn.BorderSizePixel = 0
    selBtn.AutoButtonColor = false
    selBtn.ZIndex = 7
    selBtn.Parent = holder

    local selCnr = Instance.new("UICorner")
    selCnr.CornerRadius = UDim.new(0, 8)
    selCnr.Parent = selBtn

    local selStroke = Instance.new("UIStroke")
    selStroke.Color = P.BorderGlass
    selStroke.Thickness = 1
    selStroke.Transparency = 0.7
    selStroke.Parent = selBtn

    -- Seçenekler
    local optBtns = {}
    for i, opt in ipairs(options) do
        local ob = Instance.new("TextButton")
        ob.Text = tostring(opt)
        ob.Size = UDim2.new(0.42, -12, 0, 28)
        ob.Position = UDim2.new(0.58, 0, 0, 5 + i * 32)
        ob.BackgroundColor3 = P.GlassInput
        ob.BackgroundTransparency = 0.45
        ob.TextColor3 = P.TextSecondary
        ob.TextSize = 11
        ob.Font = Enum.Font.Gotham
        ob.BorderSizePixel = 0
        ob.AutoButtonColor = false
        ob.Visible = false
        ob.ZIndex = 8
        ob.Parent = holder

        local oCnr = Instance.new("UICorner")
        oCnr.CornerRadius = UDim.new(0, 7)
        oCnr.Parent = ob

        ob.MouseEnter:Connect(function()
            GE.tween(ob, {BackgroundTransparency = 0.25, TextColor3 = P.AccentSecondary}, 0.12)
        end)
        ob.MouseLeave:Connect(function()
            GE.tween(ob, {BackgroundTransparency = 0.45, TextColor3 = P.TextSecondary}, 0.12)
        end)

        ob.MouseButton1Click:Connect(function()
            selBtn.Text = tostring(opt) .. "  ▾"
            isOpen = false
            GE.tween(holder, {Size = UDim2.new(1, 0, 0, 40)}, 0.2)
            for _, b in pairs(optBtns) do b.Visible = false end
            if callback then callback(opt) end
        end)

        table.insert(optBtns, ob)
    end

    selBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            GE.tween(holder, {Size = UDim2.new(1, 0, 0, 40 + #options * 32 + 6)}, 0.2)
            for _, b in pairs(optBtns) do b.Visible = true end
        else
            GE.tween(holder, {Size = UDim2.new(1, 0, 0, 40)}, 0.2)
            for _, b in pairs(optBtns) do b.Visible = false end
        end
    end)

    return holder
end

-- ==========================================
-- TAB 1: AIMBOT
-- ==========================================

local aimbotPage = createTab("Aimbot", TAB_ICONS.Aimbot)

createSection(aimbotPage, "General")
createToggle(aimbotPage, "Aimbot", false, function(s) Settings.Aimbot.Enabled = s end)
createToggle(aimbotPage, "Team Check", false, function(s) Settings.Aimbot.TeamCheck = s end)
createToggle(aimbotPage, "Visibility Check", false, function(s) Settings.Aimbot.VisibleCheck = s end)
createToggle(aimbotPage, "Show FOV Circle", false, function(s) Settings.Aimbot.FOVEnabled = s end)
createToggle(aimbotPage, "Sticky Aim", false, function(s) Settings.Aimbot.StickyAim = s end)

createSection(aimbotPage, "Precision")
createSlider(aimbotPage, "FOV Size", 50, 500, 150, function(v) Settings.Aimbot.FOVSize = v end)
createSlider(aimbotPage, "Smoothness", 1, 20, 5, function(v) Settings.Aimbot.Smoothness = v end)
createSlider(aimbotPage, "Max Distance", 100, 2000, 500, function(v) Settings.Aimbot.MaxDistance = v end)

createSection(aimbotPage, "Ballistics")
createToggle(aimbotPage, "Movement Prediction", false, function(s) Settings.Aimbot.Prediction = s end)
createSlider(aimbotPage, "Prediction Amount (x1000)", 50, 500, 165, function(v) Settings.Aimbot.PredictionAmount = v / 1000 end)
createDropdown(aimbotPage, "Target Part", {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}, "Head", function(v) Settings.Aimbot.TargetPart = v end)

-- ==========================================
-- TAB 2: ESP
-- ==========================================

local espPage = createTab("ESP", TAB_ICONS.ESP)

createSection(espPage, "General")
createToggle(espPage, "ESP", false, function(s) Settings.ESP.Enabled = s end)
createToggle(espPage, "Team Check", false, function(s) Settings.ESP.TeamCheck = s end)
createToggle(espPage, "Use Team Color", false, function(s) Settings.ESP.TeamColor = s end)

createSection(espPage, "Visuals")
createToggle(espPage, "Box ESP", false, function(s) Settings.ESP.Boxes = s end)
createDropdown(espPage, "Box Type", {"2D", "Corner"}, "2D", function(v) Settings.ESP.BoxType = v end)
createToggle(espPage, "Names", false, function(s) Settings.ESP.Names = s end)
createToggle(espPage, "Health Bar", false, function(s) Settings.ESP.Health = s end)
createToggle(espPage, "Distance", false, function(s) Settings.ESP.Distance = s end)

createSection(espPage, "Extra")
createToggle(espPage, "Tracers", false, function(s) Settings.ESP.Tracers = s end)
createDropdown(espPage, "Tracer Origin", {"Bottom", "Center", "Mouse"}, "Bottom", function(v) Settings.ESP.TracerOrigin = v end)
createToggle(espPage, "Chams / Highlight", false, function(s) Settings.ESP.Chams = s end)
createSlider(espPage, "Chams Opacity (x100)", 0, 100, 50, function(v) Settings.ESP.ChamsTransparency = v / 100 end)
createSlider(espPage, "Max ESP Distance", 100, 3000, 1000, function(v) Settings.ESP.MaxDistance = v end)

-- ==========================================
-- TAB 3: HARDLOCK
-- ==========================================

local hardlockPage = createTab("HardLock", TAB_ICONS.HardLock)

createSection(hardlockPage, "General")
createToggle(hardlockPage, "HardLock", false, function(s) Settings.HardLock.Enabled = s end)
createToggle(hardlockPage, "Lock Indicator", false, function(s) Settings.HardLock.Indicator = s end)
createToggle(hardlockPage, "Override Target Part", false, function(s) Settings.HardLock.OverrideTarget = s end)

createSection(hardlockPage, "Lock Mode")
createDropdown(hardlockPage, "Mode", {"Snap", "Flick", "Rage", "Silent"}, "Snap", function(v) Settings.HardLock.Mode = v end)
createDropdown(hardlockPage, "Target Part", {"Head", "HumanoidRootPart", "UpperTorso"}, "Head", function(v) Settings.HardLock.TargetPart = v end)

createSection(hardlockPage, "Flick")
createSlider(hardlockPage, "Flick Speed (ms)", 20, 200, 80, function(v) Settings.HardLock.FlickSpeed = v / 1000 end)
createSlider(hardlockPage, "Return Speed (%)", 10, 80, 30, function(v) Settings.HardLock.FlickReturn = v / 100 end)

createSection(hardlockPage, "Rage")
createToggle(hardlockPage, "Auto Fire", false, function(s) Settings.HardLock.AutoFire = s end)
createSlider(hardlockPage, "Rage Prediction (x1000)", 50, 400, 200, function(v) Settings.HardLock.RagePrediction = v / 1000 end)

-- Mode bilgi kartı
createSection(hardlockPage, "Mode Info")

local modeInfoGlass = GE.createGlassPanel(hardlockPage, {
    Size = UDim2.new(1, 0, 0, 110),
    Color = P.GlassInput,
    Transparency = 0.45,
    Corner = 12,
    ZIndex = 5,
})

local modeLines = {
    {label = "Snap", desc = "Instant lock every frame", color = P.Success},
    {label = "Flick", desc = "Fast snap then smooth track", color = P.Warning},
    {label = "Rage", desc = "Full override + auto fire", color = P.Error},
    {label = "Silent", desc = "Camera stays, server gets aim", color = P.Info},
}

for i, info in ipairs(modeLines) do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -20, 0, 22)
    row.Position = UDim2.new(0, 10, 0, 6 + (i - 1) * 25)
    row.BackgroundTransparency = 1
    row.ZIndex = 6
    row.Parent = modeInfoGlass.Container

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 6, 0, 6)
    dot.Position = UDim2.new(0, 0, 0.5, -3)
    dot.BackgroundColor3 = info.color
    dot.BorderSizePixel = 0
    dot.ZIndex = 7
    dot.Parent = row
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local lbl = Instance.new("TextLabel")
    lbl.Text = info.label
    lbl.Size = UDim2.new(0, 45, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = info.color
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 7
    lbl.Parent = row

    local desc = Instance.new("TextLabel")
    desc.Text = info.desc
    desc.Size = UDim2.new(1, -65, 1, 0)
    desc.Position = UDim2.new(0, 62, 0, 0)
    desc.BackgroundTransparency = 1
    desc.TextColor3 = P.TextSecondary
    desc.TextSize = 10
    desc.Font = Enum.Font.Gotham
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.ZIndex = 7
    desc.Parent = row
end

-- ==========================================
-- TAB 4: BYPASS
-- ==========================================

local bypassPage = createTab("Bypass", TAB_ICONS.Bypass)

createSection(bypassPage, "Protection Layers")
createToggle(bypassPage, "Ring 1 — Byfron / Hyperion", false, function(s) Settings.Bypass.Ring1 = s end)
createToggle(bypassPage, "Ring 2 — Anti-Cheat Systems", false, function(s) Settings.Bypass.Ring2 = s end)
createToggle(bypassPage, "Ring 3 — ESP / Aimbot Stealth", false, function(s) Settings.Bypass.Ring3 = s end)
createToggle(bypassPage, "Ring 4 — Basic Protection", false, function(s) Settings.Bypass.Ring4 = s end)

createSection(bypassPage, "Layer Info")

local bypassInfoGlass = GE.createGlassPanel(bypassPage, {
    Size = UDim2.new(1, 0, 0, 120),
    Color = P.GlassInput,
    Transparency = 0.45,
    Corner = 12,
    ZIndex = 5,
})

local bypassLines = {
    {label = "Ring 1", desc = "Byfron memory, heartbeat, environment", color = P.Error},
    {label = "Ring 2", desc = "Remote throttle, camera guard, humanize", color = P.Warning},
    {label = "Ring 3", desc = "Aim noise, drawing stealth, raycast", color = Color3.fromRGB(167, 139, 250)},
    {label = "Ring 4", desc = "Speed guard, teleport, FPS, anti-idle", color = P.Success},
}

for i, info in ipairs(bypassLines) do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -20, 0, 24)
    row.Position = UDim2.new(0, 10, 0, 6 + (i - 1) * 28)
    row.BackgroundTransparency = 1
    row.ZIndex = 6
    row.Parent = bypassInfoGlass.Container

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 6, 0, 6)
    dot.Position = UDim2.new(0, 0, 0.5, -3)
    dot.BackgroundColor3 = info.color
    dot.BorderSizePixel = 0
    dot.ZIndex = 7
    dot.Parent = row
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local lbl = Instance.new("TextLabel")
    lbl.Text = info.label
    lbl.Size = UDim2.new(0, 45, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = info.color
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 7
    lbl.Parent = row

    local desc = Instance.new("TextLabel")
    desc.Text = info.desc
    desc.Size = UDim2.new(1, -65, 1, 0)
    desc.Position = UDim2.new(0, 62, 0, 0)
    desc.BackgroundTransparency = 1
    desc.TextColor3 = P.TextSecondary
    desc.TextSize = 10
    desc.Font = Enum.Font.Gotham
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.ZIndex = 7
    desc.Parent = row
end

-- Uyarı kartı (cam)
createSection(bypassPage, "Notice")

local warnGlass = GE.createGlassPanel(bypassPage, {
    Size = UDim2.new(1, 0, 0, 52),
    Color = Color3.fromRGB(30, 25, 12),
    Transparency = 0.35,
    Corner = 12,
    ZIndex = 5,
})

local warnAccent = Instance.new("Frame")
warnAccent.Size = UDim2.new(0, 3, 1, -12)
warnAccent.Position = UDim2.new(0, 5, 0, 6)
warnAccent.BackgroundColor3 = P.Warning
warnAccent.BorderSizePixel = 0
warnAccent.ZIndex = 7
warnAccent.Parent = warnGlass.Container
Instance.new("UICorner", warnAccent).CornerRadius = UDim.new(0, 2)

local warnText = Instance.new("TextLabel")
warnText.Text = "Higher rings provide more protection but may impact performance. Ring 1 requires compatible executor."
warnText.Size = UDim2.new(1, -24, 1, -8)
warnText.Position = UDim2.new(0, 16, 0, 4)
warnText.BackgroundTransparency = 1
warnText.TextColor3 = Color3.fromRGB(230, 210, 150)
warnText.TextSize = 11
warnText.Font = Enum.Font.Gotham
warnText.TextWrapped = true
warnText.TextXAlignment = Enum.TextXAlignment.Left
warnText.TextYAlignment = Enum.TextYAlignment.Top
warnText.ZIndex = 7
warnText.Parent = warnGlass.Container

-- ==========================================
-- TAB 5: SETTINGS
-- ==========================================

local settingsPage = createTab("Settings", TAB_ICONS.Settings)

createSection(settingsPage, "Information")

local infoGlass = GE.createGlassPanel(settingsPage, {
    Size = UDim2.new(1, 0, 0, 100),
    Color = P.GlassSurface,
    Transparency = A.GlassSurface,
    Corner = 12,
    ZIndex = 5,
})

local gameName = "Unknown"
pcall(function()
    gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
end)

local infoLines = {
    {label = "Version", value = Settings.Version, color = P.AccentSecondary},
    {label = "User", value = LocalPlayer.DisplayName, color = P.TextPrimary},
    {label = "Game", value = gameName, color = P.TextSecondary},
    {label = "Toggle Key", value = "RightShift", color = P.TextMuted},
}

for i, info in ipairs(infoLines) do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -24, 0, 20)
    row.Position = UDim2.new(0, 12, 0, 8 + (i - 1) * 22)
    row.BackgroundTransparency = 1
    row.ZIndex = 7
    row.Parent = infoGlass.Container

    local lbl = Instance.new("TextLabel")
    lbl.Text = info.label
    lbl.Size = UDim2.new(0.4, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = P.TextMuted
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 7
    lbl.Parent = row

    local val = Instance.new("TextLabel")
    val.Text = info.value
    val.Size = UDim2.new(0.6, 0, 1, 0)
    val.BackgroundTransparency = 1
    val.TextColor3 = info.color
    val.TextSize = 12
    val.Font = Enum.Font.GothamSemibold
    val.TextXAlignment = Enum.TextXAlignment.Right
    val.ZIndex = 7
    val.Parent = row
end

createSection(settingsPage, "Credits")

local creditGlass = GE.createGlassPanel(settingsPage, {
    Size = UDim2.new(1, 0, 0, 50),
    Color = P.GlassSurface,
    Transparency = A.GlassSurface,
    Corner = 12,
    ZIndex = 5,
    AccentGlow = P.AccentPrimary,
})

local creditAccent = Instance.new("Frame")
creditAccent.Size = UDim2.new(0, 3, 1, -12)
creditAccent.Position = UDim2.new(0, 5, 0, 6)
creditAccent.BackgroundColor3 = P.AccentPrimary
creditAccent.BorderSizePixel = 0
creditAccent.ZIndex = 7
creditAccent.Parent = creditGlass.Container
Instance.new("UICorner", creditAccent).CornerRadius = UDim.new(0, 2)

local creditText = Instance.new("TextLabel")
creditText.Text = "Developed by Baran\nVergiHub — Private Use Only"
creditText.Size = UDim2.new(1, -24, 1, -8)
creditText.Position = UDim2.new(0, 16, 0, 4)
creditText.BackgroundTransparency = 1
creditText.TextColor3 = P.TextSecondary
creditText.TextSize = 12
creditText.Font = Enum.Font.Gotham
creditText.TextWrapped = true
creditText.TextXAlignment = Enum.TextXAlignment.Left
creditText.TextYAlignment = Enum.TextYAlignment.Top
creditText.ZIndex = 7
creditText.Parent = creditGlass.Container

-- ==========================================
-- İLK TAB AKTİF ET
-- ==========================================

local firstTab = tabs["Aimbot"]
firstTab.Button.BackgroundTransparency = 0.55
firstTab.ActiveBar.BackgroundTransparency = 0.15
firstTab.Icon.TextColor3 = P.AccentSecondary
firstTab.Name.TextColor3 = P.TextPrimary
tabPages["Aimbot"].Visible = true

print("[VergiHub] Liquid Glass Controls & Tabs hazir!")
return true
