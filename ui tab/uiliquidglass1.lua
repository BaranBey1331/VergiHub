--[[
    VergiHub - Liquid Glass Engine v2.0
    iOS 26 Liquid Glass efekt sistemi
    
    Gercek cam hissi: coklu frost katman, refraction,
    depth glow, specular highlight, edge light
]]

local TweenService = game:GetService("TweenService")

local GlassEngine = {}

-- ==========================================
-- RENK PALETTESİ
-- ==========================================

GlassEngine.Palette = {
    -- Cam arka planlar
    GlassPrimary     = Color3.fromRGB(20, 20, 40),
    GlassSurface     = Color3.fromRGB(25, 25, 48),
    GlassElevated    = Color3.fromRGB(32, 32, 58),
    GlassInput       = Color3.fromRGB(18, 18, 38),
    GlassDeep        = Color3.fromRGB(10, 10, 24),

    -- Frost
    FrostWhite       = Color3.fromRGB(220, 225, 255),
    FrostBlue        = Color3.fromRGB(150, 170, 230),
    FrostPurple      = Color3.fromRGB(160, 140, 220),

    -- Accent
    AccentPrimary    = Color3.fromRGB(120, 80, 255),
    AccentSecondary  = Color3.fromRGB(160, 120, 255),
    AccentGlow       = Color3.fromRGB(180, 150, 255),
    AccentCyan       = Color3.fromRGB(80, 200, 255),
    AccentPink       = Color3.fromRGB(255, 100, 200),
    AccentWhite      = Color3.fromRGB(230, 235, 255),

    -- Durum
    Success          = Color3.fromRGB(60, 220, 160),
    Error            = Color3.fromRGB(255, 90, 90),
    Warning          = Color3.fromRGB(255, 200, 60),
    Info             = Color3.fromRGB(100, 180, 255),

    -- Yazi
    TextPrimary      = Color3.fromRGB(240, 242, 255),
    TextSecondary    = Color3.fromRGB(175, 180, 215),
    TextMuted        = Color3.fromRGB(110, 115, 150),
    TextOnGlass      = Color3.fromRGB(225, 228, 250),

    -- Kontrol
    ToggleOn         = Color3.fromRGB(120, 80, 255),
    ToggleOff        = Color3.fromRGB(55, 55, 80),
    SliderFill       = Color3.fromRGB(120, 80, 255),
    SliderTrack      = Color3.fromRGB(35, 35, 60),

    -- Kenar
    BorderGlass      = Color3.fromRGB(255, 255, 255),
    BorderSubtle     = Color3.fromRGB(70, 75, 110),
}

local P = GlassEngine.Palette

-- ==========================================
-- TWEEN
-- ==========================================

function GlassEngine.tween(obj, props, duration, style, dir)
    if not obj or not obj.Parent then return end
    local t = TweenService:Create(
        obj,
        TweenInfo.new(duration or 0.3, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
        props
    )
    t:Play()
    return t
end

-- ==========================================
-- LIQUID GLASS PANEL
-- ==========================================

function GlassEngine.createGlassPanel(parent, config)
    config = config or {}
    local size = config.Size or UDim2.new(1, 0, 1, 0)
    local position = config.Position or UDim2.new(0, 0, 0, 0)
    local corner = config.Corner or 14
    local bgColor = config.Color or P.GlassPrimary
    local bgTransparency = config.Transparency or 0.35
    local name = config.Name or "GlassPanel"
    local zindex = config.ZIndex or 1

    -- Container
    local container = Instance.new("Frame")
    container.Name = name
    container.Size = size
    container.Position = position
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ZIndex = zindex
    container.Parent = parent

    -- KATMAN 1: Ana cam (koyu, yari saydam)
    local glassBG = Instance.new("Frame")
    glassBG.Name = "GlassBG"
    glassBG.Size = UDim2.new(1, 0, 1, 0)
    glassBG.BackgroundColor3 = bgColor
    glassBG.BackgroundTransparency = bgTransparency
    glassBG.BorderSizePixel = 0
    glassBG.ZIndex = zindex
    glassBG.Parent = container

    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, corner)
    bgCorner.Parent = glassBG

    -- KATMAN 2: Frost overlay (ustten gelen isik - GUCLU)
    local frost1 = Instance.new("Frame")
    frost1.Name = "Frost1"
    frost1.Size = UDim2.new(1, 0, 1, 0)
    frost1.BackgroundColor3 = P.FrostWhite
    frost1.BackgroundTransparency = 0.92
    frost1.BorderSizePixel = 0
    frost1.ZIndex = zindex + 1
    frost1.Parent = container

    local f1Corner = Instance.new("UICorner")
    f1Corner.CornerRadius = UDim.new(0, corner)
    f1Corner.Parent = frost1

    -- Frost gradient (ustten asagi erir)
    local f1Grad = Instance.new("UIGradient")
    f1Grad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.55),
        NumberSequenceKeypoint.new(0.15, 0.75),
        NumberSequenceKeypoint.new(0.5, 0.92),
        NumberSequenceKeypoint.new(1, 1),
    })
    f1Grad.Rotation = 90
    f1Grad.Parent = frost1

    -- KATMAN 3: Renk kirilma katmani (mor-mavi shift)
    local frost2 = Instance.new("Frame")
    frost2.Name = "Frost2"
    frost2.Size = UDim2.new(1, 0, 1, 0)
    frost2.BackgroundTransparency = 0.94
    frost2.BorderSizePixel = 0
    frost2.ZIndex = zindex + 1
    frost2.Parent = container

    local f2Corner = Instance.new("UICorner")
    f2Corner.CornerRadius = UDim.new(0, corner)
    f2Corner.Parent = frost2

    local f2Grad = Instance.new("UIGradient")
    f2Grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, P.AccentCyan),
        ColorSequenceKeypoint.new(0.5, P.AccentPrimary),
        ColorSequenceKeypoint.new(1, P.AccentPink),
    })
    f2Grad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.85),
        NumberSequenceKeypoint.new(0.5, 0.95),
        NumberSequenceKeypoint.new(1, 0.85),
    })
    f2Grad.Rotation = 135
    f2Grad.Parent = frost2

    -- KATMAN 4: Ust kenar specular highlight (parlak cizgi)
    local specular = Instance.new("Frame")
    specular.Name = "Specular"
    specular.Size = UDim2.new(1, -(corner * 2), 0, 1)
    specular.Position = UDim2.new(0, corner, 0, 0)
    specular.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    specular.BackgroundTransparency = 0.5
    specular.BorderSizePixel = 0
    specular.ZIndex = zindex + 2
    specular.Parent = container

    -- Specular gradient (ortasi parlak, kenarlari solar)
    local specGrad = Instance.new("UIGradient")
    specGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.3, 0.4),
        NumberSequenceKeypoint.new(0.5, 0.2),
        NumberSequenceKeypoint.new(0.7, 0.4),
        NumberSequenceKeypoint.new(1, 1),
    })
    specGrad.Parent = specular

    -- KATMAN 5: Cam kenarlik (beyaz, saydam)
    local glassStroke = Instance.new("UIStroke")
    glassStroke.Color = P.BorderGlass
    glassStroke.Thickness = 1
    glassStroke.Transparency = 0.6
    glassStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    glassStroke.Parent = glassBG

    -- KATMAN 6: Accent glow kenarlik (opsiyonel)
    local accentStroke = nil
    if config.AccentGlow then
        local innerFrame = Instance.new("Frame")
        innerFrame.Size = UDim2.new(1, 0, 1, 0)
        innerFrame.BackgroundTransparency = 1
        innerFrame.BorderSizePixel = 0
        innerFrame.ZIndex = zindex
        innerFrame.Parent = container

        local ifCorner = Instance.new("UICorner")
        ifCorner.CornerRadius = UDim.new(0, corner)
        ifCorner.Parent = innerFrame

        accentStroke = Instance.new("UIStroke")
        accentStroke.Color = config.AccentGlow
        accentStroke.Thickness = 1
        accentStroke.Transparency = 0.7
        accentStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        accentStroke.Parent = innerFrame
    end

    return {
        Container = container,
        Background = glassBG,
        Frost1 = frost1,
        Frost2 = frost2,
        Specular = specular,
        Stroke = glassStroke,
        AccentStroke = accentStroke,
    }
end

-- ==========================================
-- REFRACTION ANİMASYONU (Hareket eden isik)
-- ==========================================

function GlassEngine.addRefractionAnimation(parentFrame, config)
    config = config or {}
    local speed = config.Speed or 10

    -- Refraction frame'i parentFrame'in icinde
    local refraction = Instance.new("Frame")
    refraction.Name = "Refraction"
    refraction.Size = UDim2.new(1, 0, 1, 0)
    refraction.BackgroundTransparency = 1
    refraction.BorderSizePixel = 0
    refraction.ZIndex = parentFrame.ZIndex + 1
    refraction.ClipsDescendants = true
    refraction.Parent = parentFrame

    local rCorner = Instance.new("UICorner")
    rCorner.CornerRadius = UDim.new(0, 14)
    rCorner.Parent = refraction

    -- Hareket eden isik noktasi
    local lightOrb = Instance.new("Frame")
    lightOrb.Size = UDim2.new(0.6, 0, 0.4, 0)
    lightOrb.Position = UDim2.new(-0.3, 0, -0.2, 0)
    lightOrb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    lightOrb.BackgroundTransparency = 0.92
    lightOrb.BorderSizePixel = 0
    lightOrb.ZIndex = parentFrame.ZIndex + 1
    lightOrb.Parent = refraction

    local orbCorner = Instance.new("UICorner")
    orbCorner.CornerRadius = UDim.new(1, 0)
    orbCorner.Parent = lightOrb

    -- Orb gradient
    local orbGrad = Instance.new("UIGradient")
    orbGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, config.Color1 or P.AccentCyan),
        ColorSequenceKeypoint.new(1, config.Color2 or P.AccentPink),
    })
    orbGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.85),
        NumberSequenceKeypoint.new(0.5, 0.92),
        NumberSequenceKeypoint.new(1, 1),
    })
    orbGrad.Parent = lightOrb

    -- Hareket animasyonu (sonsuz dongu)
    task.spawn(function()
        while lightOrb and lightOrb.Parent do
            -- Sol usttten sag alta
            GlassEngine.tween(lightOrb, {
                Position = UDim2.new(0.7, 0, 0.6, 0)
            }, speed * 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(speed * 0.5)

            if not lightOrb or not lightOrb.Parent then break end

            -- Sag alttan sol uste
            GlassEngine.tween(lightOrb, {
                Position = UDim2.new(-0.3, 0, -0.2, 0)
            }, speed * 0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(speed * 0.5)
        end
    end)

    return refraction
end

-- ==========================================
-- DEPTH SHADOW
-- ==========================================

function GlassEngine.addDepthShadow(frame, config)
    config = config or {}
    local offset = config.Offset or 8

    local shadow = Instance.new("ImageLabel")
    shadow.Name = "DepthShadow"
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0, -offset, 0, -offset)
    shadow.Size = UDim2.new(1, offset * 2, 1, offset * 2)
    shadow.ZIndex = frame.ZIndex - 1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = config.Transparency or 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.Parent = frame

    return shadow
end

-- ==========================================
-- CAM SEPARATOR
-- ==========================================

function GlassEngine.createSeparator(parent, config)
    config = config or {}

    local sep = Instance.new("Frame")
    sep.Size = config.Size or UDim2.new(1, -20, 0, 1)
    sep.Position = config.Position or UDim2.new(0, 10, 0, 0)
    sep.BackgroundColor3 = P.BorderGlass
    sep.BackgroundTransparency = 0.75
    sep.BorderSizePixel = 0
    sep.Parent = parent

    local grad = Instance.new("UIGradient")
    grad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.2, 0.6),
        NumberSequenceKeypoint.new(0.8, 0.6),
        NumberSequenceKeypoint.new(1, 1),
    })
    grad.Parent = sep

    return sep
end

-- Global erisim
getgenv().VergiHub.GlassEngine = GlassEngine

print("[VergiHub] Liquid Glass Engine v2.0 hazir!")
return GlassEngine
