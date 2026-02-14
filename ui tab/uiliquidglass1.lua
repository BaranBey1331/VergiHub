--[[
    VergiHub - Liquid Glass Engine v1.0
    iOS 26 Liquid Glass efekt sistemi
    
    Frosted glass, blur simulation, inner glow,
    refraction edges, depth shadows
    
    Bu modül diğer UI dosyaları tarafından kullanılır.
]]

local TweenService = game:GetService("TweenService")

-- Glass Engine modülü
local GlassEngine = {}

-- ==========================================
-- RENK PALETTESİ (Liquid Glass)
-- ==========================================

GlassEngine.Palette = {
    -- Cam arka planları (çok düşük opaklık)
    GlassPrimary     = Color3.fromRGB(30, 30, 50),      -- Ana cam
    GlassSurface     = Color3.fromRGB(25, 25, 42),      -- Kart yüzeyi
    GlassElevated    = Color3.fromRGB(35, 35, 55),      -- Yükseltilmiş cam
    GlassInput       = Color3.fromRGB(20, 20, 38),      -- Input alanları

    -- Frosted katmanlar
    FrostLight       = Color3.fromRGB(200, 200, 230),    -- Açık frost
    FrostMedium      = Color3.fromRGB(140, 140, 170),    -- Orta frost
    FrostDark        = Color3.fromRGB(80, 80, 110),      -- Koyu frost

    -- Accent (ışık kırılması efekti)
    AccentPrimary    = Color3.fromRGB(120, 80, 255),     -- Ana mor
    AccentSecondary  = Color3.fromRGB(160, 120, 255),    -- Açık mor
    AccentGlow       = Color3.fromRGB(180, 150, 255),    -- Glow mor
    AccentCyan       = Color3.fromRGB(80, 200, 255),     -- Cam kırılma mavisi
    AccentPink       = Color3.fromRGB(255, 100, 200),    -- Sıcak kırılma

    -- Durum
    Success          = Color3.fromRGB(60, 220, 160),
    Error            = Color3.fromRGB(255, 90, 90),
    Warning          = Color3.fromRGB(255, 200, 60),
    Info             = Color3.fromRGB(100, 180, 255),

    -- Yazı
    TextPrimary      = Color3.fromRGB(240, 240, 255),
    TextSecondary    = Color3.fromRGB(180, 180, 210),
    TextMuted        = Color3.fromRGB(120, 120, 155),
    TextOnGlass      = Color3.fromRGB(220, 220, 245),

    -- Kontrol
    ToggleOn         = Color3.fromRGB(120, 80, 255),
    ToggleOff        = Color3.fromRGB(60, 60, 85),
    SliderFill       = Color3.fromRGB(120, 80, 255),
    SliderTrack      = Color3.fromRGB(40, 40, 65),

    -- Kenar
    BorderGlass      = Color3.fromRGB(255, 255, 255),    -- Beyaz cam kenar
    BorderSubtle     = Color3.fromRGB(80, 80, 120),      -- İnce kenar
}

local P = GlassEngine.Palette

-- ==========================================
-- TRANSPARENCY DEĞERLERİ
-- ==========================================

GlassEngine.Alpha = {
    GlassBackground  = 0.25,   -- Ana arka plan camı
    GlassSurface     = 0.35,   -- Kart yüzeyi
    GlassElevated    = 0.30,   -- Yükseltilmiş kartlar
    GlassInput       = 0.45,   -- Input alanları
    GlassTopBar      = 0.20,   -- Üst bar (daha opak)
    GlassSideBar     = 0.22,   -- Yan panel
    FrostOverlay     = 0.88,   -- Frost katmanı (çok saydam)
    BorderGlow       = 0.55,   -- Kenar parlaması
    InnerGlow        = 0.80,   -- İç glow
    RefractionEdge   = 0.70,   -- Kırılma kenarı
}

local A = GlassEngine.Alpha

-- ==========================================
-- TWEEN YARDIMCISI
-- ==========================================

function GlassEngine.tween(obj, props, duration, style, dir)
    local t = TweenService:Create(
        obj,
        TweenInfo.new(
            duration or 0.3,
            style or Enum.EasingStyle.Quart,
            dir or Enum.EasingDirection.Out
        ),
        props
    )
    t:Play()
    return t
end

-- ==========================================
-- LIQUID GLASS FRAME OLUŞTURUCU
-- ==========================================
--[[
    iOS 26 Liquid Glass efekti katmanları:
    
    1. Ana arka plan (düşük opaklık, koyu renk)
    2. Frost overlay (beyazımsı, çok saydam)
    3. Üst kenar highlight (ışık kırılması)
    4. Alt kenar shadow (derinlik)
    5. İç glow gradient (merkeze doğru aydınlanma)
    6. Kenarlık (ince beyaz, saydam)
]]

function GlassEngine.createGlassPanel(parent, config)
    config = config or {}
    local size = config.Size or UDim2.new(1, 0, 1, 0)
    local position = config.Position or UDim2.new(0, 0, 0, 0)
    local cornerRadius = config.Corner or 14
    local bgColor = config.Color or P.GlassPrimary
    local bgAlpha = config.Transparency or A.GlassSurface
    local name = config.Name or "GlassPanel"
    local zindex = config.ZIndex or 1

    -- Ana container
    local container = Instance.new("Frame")
    container.Name = name
    container.Size = size
    container.Position = position
    container.BackgroundTransparency = 1
    container.BorderSizePixel = 0
    container.ZIndex = zindex
    container.Parent = parent

    -- KATMAN 1: Ana cam arka plan
    local glassBG = Instance.new("Frame")
    glassBG.Name = "GlassBG"
    glassBG.Size = UDim2.new(1, 0, 1, 0)
    glassBG.BackgroundColor3 = bgColor
    glassBG.BackgroundTransparency = bgAlpha
    glassBG.BorderSizePixel = 0
    glassBG.ZIndex = zindex
    glassBG.Parent = container

    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, cornerRadius)
    bgCorner.Parent = glassBG

    -- KATMAN 2: Frost overlay (üstten gelen ışık simülasyonu)
    local frostOverlay = Instance.new("Frame")
    frostOverlay.Name = "FrostOverlay"
    frostOverlay.Size = UDim2.new(1, -2, 0.5, 0)
    frostOverlay.Position = UDim2.new(0, 1, 0, 1)
    frostOverlay.BackgroundColor3 = P.FrostLight
    frostOverlay.BackgroundTransparency = A.FrostOverlay
    frostOverlay.BorderSizePixel = 0
    frostOverlay.ZIndex = zindex + 1
    frostOverlay.Parent = container

    local frostCorner = Instance.new("UICorner")
    frostCorner.CornerRadius = UDim.new(0, cornerRadius)
    frostCorner.Parent = frostOverlay

    -- Frost gradient (yukarıdan aşağı fade)
    local frostGradient = Instance.new("UIGradient")
    frostGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
    })
    frostGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.7),
        NumberSequenceKeypoint.new(0.4, 0.92),
        NumberSequenceKeypoint.new(1, 1),
    })
    frostGradient.Rotation = 90
    frostGradient.Parent = frostOverlay

    -- KATMAN 3: Üst kenar highlight (ışık kırılması çizgisi)
    local topHighlight = Instance.new("Frame")
    topHighlight.Name = "TopHighlight"
    topHighlight.Size = UDim2.new(1, -cornerRadius * 2, 0, 1)
    topHighlight.Position = UDim2.new(0, cornerRadius, 0, 0)
    topHighlight.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    topHighlight.BackgroundTransparency = A.RefractionEdge
    topHighlight.BorderSizePixel = 0
    topHighlight.ZIndex = zindex + 2
    topHighlight.Parent = container

    -- KATMAN 4: Cam kenarlık (ince, beyaz, saydam)
    local glassStroke = Instance.new("UIStroke")
    glassStroke.Color = P.BorderGlass
    glassStroke.Thickness = 1
    glassStroke.Transparency = A.BorderGlow
    glassStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    glassStroke.Parent = glassBG

    -- KATMAN 5: İç kenar glow (gradient)
    local innerGlow = Instance.new("Frame")
    innerGlow.Name = "InnerGlow"
    innerGlow.Size = UDim2.new(1, 0, 1, 0)
    innerGlow.BackgroundTransparency = 1
    innerGlow.BorderSizePixel = 0
    innerGlow.ZIndex = zindex + 1
    innerGlow.Parent = container

    local innerGlowCorner = Instance.new("UICorner")
    innerGlowCorner.CornerRadius = UDim.new(0, cornerRadius)
    innerGlowCorner.Parent = innerGlow

    -- İç kenar stroke (accent rengiyle hafif glow)
    if config.AccentGlow then
        local accentStroke = Instance.new("UIStroke")
        accentStroke.Color = config.AccentGlow or P.AccentPrimary
        accentStroke.Thickness = 1
        accentStroke.Transparency = 0.75
        accentStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        accentStroke.Parent = innerGlow
    end

    -- Return: container + erişilebilir katmanlar
    return {
        Container = container,
        Background = glassBG,
        Frost = frostOverlay,
        Highlight = topHighlight,
        Stroke = glassStroke,
        InnerGlow = innerGlow,
    }
end

-- ==========================================
-- GLASS BUTON
-- ==========================================

function GlassEngine.createGlassButton(parent, config)
    config = config or {}
    local size = config.Size or UDim2.new(0, 100, 0, 36)
    local position = config.Position or UDim2.new(0, 0, 0, 0)
    local text = config.Text or "Button"
    local cornerRadius = config.Corner or 10
    local zindex = config.ZIndex or 5

    local btn = Instance.new("TextButton")
    btn.Name = config.Name or "GlassBtn"
    btn.Size = size
    btn.Position = position
    btn.BackgroundColor3 = P.GlassElevated
    btn.BackgroundTransparency = A.GlassElevated
    btn.Text = text
    btn.TextColor3 = P.TextPrimary
    btn.TextSize = config.TextSize or 13
    btn.Font = Enum.Font.GothamSemibold
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.ZIndex = zindex
    btn.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, cornerRadius)
    corner.Parent = btn

    -- Cam kenarlık
    local stroke = Instance.new("UIStroke")
    stroke.Color = P.BorderGlass
    stroke.Thickness = 1
    stroke.Transparency = 0.65
    stroke.Parent = btn

    -- Frost overlay
    local frost = Instance.new("Frame")
    frost.Size = UDim2.new(1, -2, 0.5, 0)
    frost.Position = UDim2.new(0, 1, 0, 1)
    frost.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    frost.BackgroundTransparency = 0.92
    frost.BorderSizePixel = 0
    frost.ZIndex = zindex + 1
    frost.Parent = btn

    local fCorner = Instance.new("UICorner")
    fCorner.CornerRadius = UDim.new(0, cornerRadius)
    fCorner.Parent = frost

    local fGrad = Instance.new("UIGradient")
    fGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.75),
        NumberSequenceKeypoint.new(0.5, 0.93),
        NumberSequenceKeypoint.new(1, 1),
    })
    fGrad.Rotation = 90
    fGrad.Parent = frost

    -- Hover efektleri
    btn.MouseEnter:Connect(function()
        GlassEngine.tween(btn, {BackgroundTransparency = A.GlassElevated - 0.12}, 0.15)
        GlassEngine.tween(stroke, {Transparency = 0.45, Color = P.AccentSecondary}, 0.15)
    end)

    btn.MouseLeave:Connect(function()
        GlassEngine.tween(btn, {BackgroundTransparency = A.GlassElevated}, 0.2)
        GlassEngine.tween(stroke, {Transparency = 0.65, Color = P.BorderGlass}, 0.2)
    end)

    return btn
end

-- ==========================================
-- GLASS SEPARATOR (İnce cam çizgi)
-- ==========================================

function GlassEngine.createSeparator(parent, config)
    config = config or {}

    local sep = Instance.new("Frame")
    sep.Size = config.Size or UDim2.new(1, -20, 0, 1)
    sep.Position = config.Position or UDim2.new(0, 10, 0, 0)
    sep.BackgroundColor3 = P.BorderGlass
    sep.BackgroundTransparency = 0.8
    sep.BorderSizePixel = 0
    sep.Parent = parent

    local grad = Instance.new("UIGradient")
    grad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.2, 0.7),
        NumberSequenceKeypoint.new(0.8, 0.7),
        NumberSequenceKeypoint.new(1, 1),
    })
    grad.Parent = sep

    return sep
end

-- ==========================================
-- REFRACTION ANİMASYONU
-- ==========================================
-- Cam yüzeyinde yavaşça hareket eden ışık kırılması

function GlassEngine.addRefractionAnimation(frame, config)
    config = config or {}
    local speed = config.Speed or 8
    local color1 = config.Color1 or P.AccentCyan
    local color2 = config.Color2 or P.AccentPink

    -- Gradient overlay
    local refraction = Instance.new("Frame")
    refraction.Name = "Refraction"
    refraction.Size = UDim2.new(1, 0, 1, 0)
    refraction.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    refraction.BackgroundTransparency = 0.94
    refraction.BorderSizePixel = 0
    refraction.ZIndex = frame.ZIndex + 1
    refraction.Parent = frame

    local rCorner = Instance.new("UICorner")
    rCorner.CornerRadius = UDim.new(0, 14)
    rCorner.Parent = refraction

    local rGrad = Instance.new("UIGradient")
    rGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, color1),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, color2),
    })
    rGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.85),
        NumberSequenceKeypoint.new(0.5, 0.97),
        NumberSequenceKeypoint.new(1, 0.85),
    })
    rGrad.Rotation = 0
    rGrad.Parent = refraction

    -- Yavaş dönme animasyonu
    task.spawn(function()
        while refraction and refraction.Parent do
            GlassEngine.tween(rGrad, {Rotation = 360}, speed, Enum.EasingStyle.Linear)
            task.wait(speed)
            rGrad.Rotation = 0
        end
    end)

    return refraction
end

-- ==========================================
-- DEPTH SHADOW (Cam altı gölge)
-- ==========================================

function GlassEngine.addDepthShadow(frame, config)
    config = config or {}
    local offset = config.Offset or 6
    local transparency = config.Transparency or 0.6

    local shadow = Instance.new("ImageLabel")
    shadow.Name = "DepthShadow"
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0, -offset, 0, -offset)
    shadow.Size = UDim2.new(1, offset * 2, 1, offset * 2)
    shadow.ZIndex = frame.ZIndex - 1
    shadow.Image = "rbxassetid://6014261993"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = transparency
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.Parent = frame

    return shadow
end

-- Global erişim
getgenv().VergiHub.GlassEngine = GlassEngine

print("[VergiHub] Liquid Glass Engine v1.0 hazir!")
return GlassEngine
