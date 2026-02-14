--[[
    VergiHub - Liquid Glass Controls & Tabs v2.0
    
    Duzeltme: Ilk tab aktif basliyor, tum feature'lar gorunuyor
]]

local Settings = getgenv().VergiHub
local GE = getgenv().VergiHub.GlassEngine
local P = GE.Palette
local UI = getgenv().VergiHub._GlassUI

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local createTab = UI.createTab
local tabs = UI.tabs
local tabPages = UI.tabPages

-- ==========================================
-- GLASS KONTROL ELEMANLARI
-- ==========================================

local function createSection(parent, title)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 28)
    holder.BackgroundTransparency = 1
    holder.ZIndex = 5
    holder.Parent = parent

    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 20, 0, 1)
    line.Position = UDim2.new(0, 0, 0.5, 0)
    line.BackgroundColor3 = P.AccentPrimary
    line.BackgroundTransparency = 0.4
    line.BorderSizePixel = 0
    line.ZIndex = 6
    line.Parent = holder

    local lineGrad = Instance.new("UIGradient")
    lineGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0.2),
        NumberSequenceKeypoint.new(1, 0.2),
    })
    lineGrad.Parent = line

    local label = Instance.new("TextLabel")
    label.Text = string.upper(title)
    label.Size = UDim2.new(1, -28, 1, 0)
    label.Position = UDim2.new(0, 26, 0, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = P.TextMuted
    label.TextSize = 10
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 6
    label.Parent = holder

    return holder
end

local function createToggle(parent, label, default, callback)
    local glass = GE.createGlassPanel(parent, {
        Size = UDim2.new(1, 0, 0, 42),
        Color = P.GlassSurface,
        Transparency = 0.40,
        Corner = 12,
        ZIndex = 5,
    })
    local holder = glass.Container

    local text = Instance.new("TextLabel")
    text.Text = label
    text.Size = UDim2.new(1, -72, 1, 0)
    text.Position = UDim2.new(0, 14, 0, 0)
    text.BackgroundTransparency = 1
    text.TextColor3 = P.TextOnGlass
    text.TextSize = 13
    text.Font = Enum.Font.Gotham
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.ZIndex = 7
    text.Parent = holder

    local trackBG = Instance.new("Frame")
    trackBG.Size = UDim2.new(0, 44, 0, 24)
    trackBG.Position = UDim2.new(1, -56, 0.5, -12)
    trackBG.BackgroundColor3 = default and P.ToggleOn or P.ToggleOff
    trackBG.BackgroundTransparency = default and 0.2 or 0.3
    trackBG.BorderSizePixel = 0
    trackBG.ZIndex = 7
    trackBG.Parent = holder

    Instance.new("UICorner", trackBG).CornerRadius = UDim.new(1, 0)

    local trackStroke = Instance.new("UIStroke")
    trackStroke.Color = default and P.AccentGlow or P.BorderGlass
    trackStroke.Thickness = 1
    trackStroke.Transparency = default and 0.45 or 0.65
    trackStroke.Parent = trackBG

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.Position = default and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BackgroundTransparency = 0.02
    knob.BorderSizePixel = 0
    knob.ZIndex = 8
    knob.Parent = trackBG

    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    -- Knob frost
    local kFrost = Instance.new("Frame")
    kFrost.Size = UDim2.new(1, -4, 0.45, 0)
    kFrost.Position = UDim2.new(0, 2, 0, 1)
    kFrost.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    kFrost.BackgroundTransparency = 0.65
    kFrost.BorderSizePixel = 0
    kFrost.ZIndex = 9
    kFrost.Parent = knob
    Instance.new("UICorner", kFrost).CornerRadius = UDim.new(1, 0)

    local state = default

    local clickBtn = Instance.new("TextButton")
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""
    clickBtn.ZIndex = 10
    clickBtn.Parent = holder

    clickBtn.MouseEnter:Connect(function()
        GE.tween(glass.Background, {BackgroundTransparency = 0.30}, 0.1)
        GE.tween(glass.Stroke, {Transparency = 0.4}, 0.1)
    end)
    clickBtn.MouseLeave:Connect(function()
        GE.tween(glass.Background, {BackgroundTransparency = 0.40}, 0.15)
        GE.tween(glass.Stroke, {Transparency = 0.6}, 0.15)
    end)

    clickBtn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            GE.tween(trackBG, {BackgroundColor3 = P.ToggleOn, BackgroundTransparency = 0.2}, 0.25)
            GE.tween(knob, {Position = UDim2.new(1, -22, 0.5, -10)}, 0.25)
            GE.tween(trackStroke, {Color = P.AccentGlow, Transparency = 0.45}, 0.25)
        else
            GE.tween(trackBG, {BackgroundColor3 = P.ToggleOff, BackgroundTransparency = 0.3}, 0.25)
            GE.tween(knob, {Position = UDim2.new(0, 2, 0.5, -10)}, 0.25)
            GE.tween(trackStroke, {Color = P.BorderGlass, Transparency = 0.65}, 0.25)
        end
        if callback then callback(state) end
    end)

    return holder
end

local function createSlider(parent, label, min, max, default, callback)
    local glass = GE.createGlassPanel(parent, {
        Size = UDim2.new(1, 0, 0, 58),
        Color = P.GlassSurface,
        Transparency = 0.40,
        Corner = 12,
        ZIndex = 5,
    })
    local holder = glass.Container

    local text = Instance.new("TextLabel")
    text.Text = label
    text.Size = UDim2.new(0.6, 0, 0, 26)
    text.Position = UDim2.new(0, 14, 0, 4)
    text.BackgroundTransparency = 1
    text.TextColor3 = P.TextOnGlass
    text.TextSize = 13
    text.Font = Enum.Font.Gotham
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.ZIndex = 7
    text.Parent = holder

    local valBadge = Instance.new("Frame")
    valBadge.Size = UDim2.new(0, 50, 0, 22)
    valBadge.Position = UDim2.new(1, -60, 0, 6)
    valBadge.BackgroundColor3 = P.GlassInput
    valBadge.BackgroundTransparency = 0.35
    valBadge.BorderSizePixel = 0
    valBadge.ZIndex = 7
    valBadge.Parent = holder

    Instance.new("UICorner", valBadge).CornerRadius = UDim.new(0, 6)

    local vbStroke = Instance.new("UIStroke")
    vbStroke.Color = P.BorderGlass
    vbStroke.Thickness = 1
    vbStroke.Transparency = 0.7
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

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -28, 0, 8)
    track.Position = UDim2.new(0, 14, 0, 40)
    track.BackgroundColor3 = P.SliderTrack
    track.BackgroundTransparency = 0.25
    track.BorderSizePixel = 0
    track.ZIndex = 7
    track.Parent = holder

    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local pct = math.clamp((default - min) / (max - min), 0, 1)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = P.SliderFill
    fill.BackgroundTransparency = 0.1
    fill.BorderSizePixel = 0
    fill.ZIndex = 8
    fill.Parent = track

    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local fillGrad = Instance.new("UIGradient")
    fillGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, P.AccentCyan),
        ColorSequenceKeypoint.new(1, P.AccentPrimary),
    })
    fillGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.25),
        NumberSequenceKeypoint.new(0.5, 0.05),
        NumberSequenceKeypoint.new(1, 0.2),
    })
    fillGrad.Parent = fill

    local sKnob = Instance.new("Frame")
    sKnob.Size = UDim2.new(0, 18, 0, 18)
    sKnob.Position = UDim2.new(pct, -9, 0.5, -9)
    sKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sKnob.BackgroundTransparency = 0.02
    sKnob.BorderSizePixel = 0
    sKnob.ZIndex = 9
    sKnob.Parent = track

    Instance.new("UICorner", sKnob).CornerRadius = UDim.new(1, 0)

    local skStroke = Instance.new("UIStroke")
    skStroke.Color = P.AccentPrimary
    skStroke.Thickness = 2
    skStroke.Transparency = 0.2
    skStroke.Parent = sKnob

    local sliding = false

    local sliderBtn = Instance.new("TextButton")
    sliderBtn.Size = UDim2.new(1, 10, 0, 28)
    sliderBtn.Position = UDim2.new(0, -5, 0, 28)
    sliderBtn.BackgroundTransparency = 1
    sliderBtn.Text = ""
    sliderBtn.ZIndex = 10
    sliderBtn.Parent = holder

    sliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = true
            GE.tween(sKnob, {Size = UDim2.new(0, 22, 0, 22)}, 0.08)
            GE.tween(skStroke, {Transparency = 0}, 0.08)
        end
    end)

    sliderBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliding = false
            local cs = fill.Size.X.Scale
            GE.tween(sKnob, {Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(cs, -9, 0.5, -9)}, 0.1)
            GE.tween(skStroke, {Transparency = 0.2}, 0.1)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            rel = math.clamp(rel, 0, 1)
            local val = math.floor(min + (max - min) * rel)
            valLbl.Text = tostring(val)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            sKnob.Position = UDim2.new(rel, -11, 0.5, -11)
            if callback then callback(val) end
        end
    end)

    return holder
end

local function createDropdown(parent, label, options, default, callback)
    local isOpen = false

    local glass = GE.createGlassPanel(parent, {
        Size = UDim2.new(1, 0, 0, 42),
        Color = P.GlassSurface,
        Transparency = 0.40,
        Corner = 12,
        ZIndex = 5,
    })
    local holder = glass.Container
    holder.ClipsDescendants = true

    local text = Instance.new("TextLabel")
    text.Text = label
    text.Size = UDim2.new(0.5, 0, 0, 42)
    text.Position = UDim2.new(0, 14, 0, 0)
    text.BackgroundTransparency = 1
    text.TextColor3 = P.TextOnGlass
    text.TextSize = 13
    text.Font = Enum.Font.Gotham
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.ZIndex = 7
    text.Parent = holder

    local selBtn = Instance.new("TextButton")
    selBtn.Text = tostring(default) .. "  ▾"
    selBtn.Size = UDim2.new(0.42, -12, 0, 32)
    selBtn.Position = UDim2.new(0.58, 0, 0, 5)
    selBtn.BackgroundColor3 = P.GlassInput
    selBtn.BackgroundTransparency = 0.35
    selBtn.TextColor3 = P.AccentSecondary
    selBtn.TextSize = 12
    selBtn.Font = Enum.Font.GothamSemibold
    selBtn.BorderSizePixel = 0
    selBtn.AutoButtonColor = false
    selBtn.ZIndex = 7
    selBtn.Parent = holder

    Instance.new("UICorner", selBtn).CornerRadius = UDim.new(0, 8)

    local selStroke = Instance.new("UIStroke")
    selStroke.Color = P.BorderGlass
    selStroke.Thickness = 1
    selStroke.Transparency = 0.65
    selStroke.Parent = selBtn

    local optBtns = {}
    for i, opt in ipairs(options) do
        local ob = Instance.new("TextButton")
        ob.Text = tostring(opt)
        ob.Size = UDim2.new(0.42, -12, 0, 30)
        ob.Position = UDim2.new(0.58, 0, 0, 5 + i * 34)
        ob.BackgroundColor3 = P.GlassInput
        ob.BackgroundTransparency = 0.4
        ob.TextColor3 = P.TextSecondary
        ob.TextSize = 11
        ob.Font = Enum.Font.Gotham
        ob.BorderSizePixel = 0
        ob.AutoButtonColor = false
        ob.Visible = false
        ob.ZIndex = 8
        ob.Parent = holder

        Instance.new("UICorner", ob).CornerRadius = UDim.new(0, 7)

        ob.MouseEnter:Connect(function()
            GE.tween(ob, {BackgroundTransparency = 0.2, TextColor3 = P.AccentSecondary}, 0.1)
        end)
        ob.MouseLeave:Connect(function()
            GE.tween(ob, {BackgroundTransparency = 0.4, TextColor3 = P.TextSecondary}, 0.1)
        end)

        ob.MouseButton1Click:Connect(function()
            selBtn.Text = tostring(opt) .. "  ▾"
            isOpen = false
            GE.tween(holder, {Size = UDim2.new(1, 0, 0, 42)}, 0.2)
            for _, b in pairs(optBtns) do b.Visible = false end
            if callback then callback(opt) end
        end)

        table.insert(optBtns, ob)
    end

    selBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            GE.tween(holder, {Size = UDim2.new(1, 0, 0, 42 + #options * 34 + 8)}, 0.2)
            for _, b in pairs(optBtns) do b.Visible = true end
        else
            GE.tween(holder, {Size = UDim2.new(1, 0, 0, 42)}, 0.2)
            for _, b in pairs(optBtns) do b.Visible = false end
        end
    end)

    return holder
end

-- ==========================================
-- TAB 1: AIMBOT
-- ==========================================

local aimbotPage = createTab("Aimbot", "◎")

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
createSlider(aimbotPage, "Prediction (x1000)", 50, 500, 165, function(v) Settings.Aimbot.PredictionAmount = v / 1000 end)
createDropdown(aimbotPage, "Target Part", {"Head", "HumanoidRootPart", "UpperTorso", "LowerTorso"}, "Head", function(v) Settings.Aimbot.TargetPart = v end)

-- ==========================================
-- TAB 2: ESP
-- ==========================================

local espPage = createTab("ESP", "◈")

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

local hardlockPage = createTab("HardLock", "⊕")

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

-- Mode info
createSection(hardlockPage, "Mode Info")
local modeInfoGlass = GE.createGlassPanel(hardlockPage, {
    Size = UDim2.new(1, 0, 0, 115),
    Color = P.GlassInput,
    Transparency = 0.40,
    Corner = 12,
    ZIndex = 5,
})

local modeData = {
    {l = "Snap", d = "Instant lock every frame", c = P.Success},
    {l = "Flick", d = "Fast snap then smooth track", c = P.Warning},
    {l = "Rage", d = "Full override + auto fire", c = P.Error},
    {l = "Silent", d = "Camera stays, server gets aim", c = P.Info},
}

for i, m in ipairs(modeData) do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -20, 0, 24)
    row.Position = UDim2.new(0, 10, 0, 6 + (i-1) * 26)
    row.BackgroundTransparency = 1
    row.ZIndex = 6
    row.Parent = modeInfoGlass.Container

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 6, 0, 6)
    dot.Position = UDim2.new(0, 0, 0.5, -3)
    dot.BackgroundColor3 = m.c
    dot.BorderSizePixel = 0
    dot.ZIndex = 7
    dot.Parent = row
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local lbl = Instance.new("TextLabel")
    lbl.Text = m.l
    lbl.Size = UDim2.new(0, 48, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = m.c
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 7
    lbl.Parent = row

    local desc = Instance.new("TextLabel")
    desc.Text = m.d
    desc.Size = UDim2.new(1, -68, 1, 0)
    desc.Position = UDim2.new(0, 65, 0, 0)
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

local bypassPage = createTab("Bypass", "◆")

createSection(bypassPage, "Protection Layers")
createToggle(bypassPage, "Ring 1 — Byfron / Hyperion", false, function(s) Settings.Bypass.Ring1 = s end)
createToggle(bypassPage, "Ring 2 — Anti-Cheat Systems", false, function(s) Settings.Bypass.Ring2 = s end)
createToggle(bypassPage, "Ring 3 — ESP / Aimbot Stealth", false, function(s) Settings.Bypass.Ring3 = s end)
createToggle(bypassPage, "Ring 4 — Basic Protection", false, function(s) Settings.Bypass.Ring4 = s end)

createSection(bypassPage, "Layer Info")
local bpInfoGlass = GE.createGlassPanel(bypassPage, {
    Size = UDim2.new(1, 0, 0, 125),
    Color = P.GlassInput,
    Transparency = 0.40,
    Corner = 12,
    ZIndex = 5,
})

local bpData = {
    {l = "Ring 1", d = "Byfron memory, heartbeat, environment", c = P.Error},
    {l = "Ring 2", d = "Remote throttle, camera guard, humanize", c = P.Warning},
    {l = "Ring 3", d = "Aim noise, drawing stealth, raycast", c = Color3.fromRGB(167, 139, 250)},
    {l = "Ring 4", d = "Speed guard, teleport, FPS, anti-idle", c = P.Success},
}

for i, b in ipairs(bpData) do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -20, 0, 26)
    row.Position = UDim2.new(0, 10, 0, 6 + (i-1) * 28)
    row.BackgroundTransparency = 1
    row.ZIndex = 6
    row.Parent = bpInfoGlass.Container

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 6, 0, 6)
    dot.Position = UDim2.new(0, 0, 0.5, -3)
    dot.BackgroundColor3 = b.c
    dot.BorderSizePixel = 0
    dot.ZIndex = 7
    dot.Parent = row
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local lbl = Instance.new("TextLabel")
    lbl.Text = b.l
    lbl.Size = UDim2.new(0, 48, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = b.c
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 7
    lbl.Parent = row

    local desc = Instance.new("TextLabel")
    desc.Text = b.d
    desc.Size = UDim2.new(1, -68, 1, 0)
    desc.Position = UDim2.new(0, 65, 0, 0)
    desc.BackgroundTransparency = 1
    desc.TextColor3 = P.TextSecondary
    desc.TextSize = 10
    desc.Font = Enum.Font.Gotham
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.ZIndex = 7
    desc.Parent = row
end

-- Uyari
createSection(bypassPage, "Notice")
local warnGlass = GE.createGlassPanel(bypassPage, {
    Size = UDim2.new(1, 0, 0, 54),
    Color = Color3.fromRGB(30, 25, 12),
    Transparency = 0.30,
    Corner = 12,
    ZIndex = 5,
})

local wAccent = Instance.new("Frame")
wAccent.Size = UDim2.new(0, 3, 1, -14)
wAccent.Position = UDim2.new(0, 6, 0, 7)
wAccent.BackgroundColor3 = P.Warning
wAccent.BorderSizePixel = 0
wAccent.ZIndex = 7
wAccent.Parent = warnGlass.Container
Instance.new("UICorner", wAccent).CornerRadius = UDim.new(0, 2)

local wText = Instance.new("TextLabel")
wText.Text = "Higher rings = more protection but may impact performance. Ring 1 requires compatible executor."
wText.Size = UDim2.new(1, -26, 1, -10)
wText.Position = UDim2.new(0, 18, 0, 5)
wText.BackgroundTransparency = 1
wText.TextColor3 = Color3.fromRGB(230, 210, 150)
wText.TextSize = 11
wText.Font = Enum.Font.Gotham
wText.TextWrapped = true
wText.TextXAlignment = Enum.TextXAlignment.Left
wText.TextYAlignment = Enum.TextYAlignment.Top
wText.ZIndex = 7
wText.Parent = warnGlass.Container

-- ==========================================
-- TAB 5: SETTINGS
-- ==========================================

local settingsPage = createTab("Settings", "⚙")

createSection(settingsPage, "Information")

local infoGlass = GE.createGlassPanel(settingsPage, {
    Size = UDim2.new(1, 0, 0, 105),
    Color = P.GlassSurface,
    Transparency = 0.40,
    Corner = 12,
    ZIndex = 5,
})

local gameName = "Unknown"
pcall(function()
    gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
end)

local infoData = {
    {l = "Version", v = Settings.Version, c = P.AccentSecondary},
    {l = "User", v = LocalPlayer.DisplayName, c = P.TextPrimary},
    {l = "Game", v = gameName, c = P.TextSecondary},
    {l = "Toggle Key", v = "RightShift", c = P.TextMuted},
}

for i, info in ipairs(infoData) do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -24, 0, 22)
    row.Position = UDim2.new(0, 12, 0, 8 + (i-1) * 23)
    row.BackgroundTransparency = 1
    row.ZIndex = 7
    row.Parent = infoGlass.Container

    local lbl = Instance.new("TextLabel")
    lbl.Text = info.l
    lbl.Size = UDim2.new(0.4, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = P.TextMuted
    lbl.TextSize = 12
    lbl.Font = Enum.Font.Gotham
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 7
    lbl.Parent = row

    local val = Instance.new("TextLabel")
    val.Text = info.v
    val.Size = UDim2.new(0.6, 0, 1, 0)
    val.BackgroundTransparency = 1
    val.TextColor3 = info.c
    val.TextSize = 12
    val.Font = Enum.Font.GothamSemibold
    val.TextXAlignment = Enum.TextXAlignment.Right
    val.ZIndex = 7
    val.Parent = row
end

createSection(settingsPage, "Credits")

local creditGlass = GE.createGlassPanel(settingsPage, {
    Size = UDim2.new(1, 0, 0, 52),
    Color = P.GlassSurface,
    Transparency = 0.40,
    Corner = 12,
    ZIndex = 5,
    AccentGlow = P.AccentPrimary,
})

local cAccent = Instance.new("Frame")
cAccent.Size = UDim2.new(0, 3, 1, -14)
cAccent.Position = UDim2.new(0, 6, 0, 7)
cAccent.BackgroundColor3 = P.AccentPrimary
cAccent.BorderSizePixel = 0
cAccent.ZIndex = 7
cAccent.Parent = creditGlass.Container
Instance.new("UICorner", cAccent).CornerRadius = UDim.new(0, 2)

local cText = Instance.new("TextLabel")
cText.Text = "Developed by Baran\nVergiHub — Private Use Only"
cText.Size = UDim2.new(1, -26, 1, -10)
cText.Position = UDim2.new(0, 18, 0, 5)
cText.BackgroundTransparency = 1
cText.TextColor3 = P.TextSecondary
cText.TextSize = 12
cText.Font = Enum.Font.Gotham
cText.TextWrapped = true
cText.TextXAlignment = Enum.TextXAlignment.Left
cText.TextYAlignment = Enum.TextYAlignment.Top
cText.ZIndex = 7
cText.Parent = creditGlass.Container

-- ==========================================
-- İLK TAB AKTİF (BUG FIX)
-- ==========================================

-- Aimbot tabini programatik olarak aktif et
local firstTab = tabs["Aimbot"]
if firstTab then
    firstTab.Button.BackgroundTransparency = 0.45
    firstTab.ActiveBar.BackgroundTransparency = 0.1
    firstTab.Icon.TextColor3 = P.AccentSecondary
    firstTab.Name.TextColor3 = P.TextPrimary
    tabPages["Aimbot"].Visible = true
end

print("[VergiHub] Liquid Glass Controls & Tabs v2.0 hazir!")
return true
