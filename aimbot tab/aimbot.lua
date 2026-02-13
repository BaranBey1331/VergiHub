--[[
    VergiHub - Aimbot Engine v3.0
    
    Yenilikler:
    - Crosshair bazlı hedefleme (ekran merkezi)
    - Hızlı ve doğal flick + micro-smooth
    - Akıllı balistik hesaplama (mermi hızı, düşman hızı, yerçekimi)
    - Mesafe bazlı dinamik smoothing
    - Sub-pixel precision ile tam lock
    
    Smoothness: 1 = snap, 2-3 = hızlı flick (doğal), 4-6 = orta, 7+ = yavaş
]]

local Settings = getgenv().VergiHub.Aimbot

-- Servisler
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Durum
local currentTarget = nil
local lockedTarget = nil
local isAiming = false
local fovCircle = nil

-- Balistik sabitler
local GRAVITY = Vector3.new(0, -196.2, 0) -- Roblox yerçekimi (workspace.Gravity)
local DEFAULT_BULLET_SPEED = 1000          -- Varsayılan mermi hızı (stud/s)

-- ==========================================
-- FOV DAİRESİ
-- ==========================================

local function createFOVCircle()
    if fovCircle then pcall(function() fovCircle:Remove() end) end
    fovCircle = Drawing.new("Circle")
    fovCircle.Color = Color3.fromRGB(124, 58, 237)
    fovCircle.Thickness = 1.5
    fovCircle.Filled = false
    fovCircle.Transparency = 0.6
    fovCircle.Visible = false
    return fovCircle
end

fovCircle = createFOVCircle()

-- ==========================================
-- DÜŞMAN HIZ / İVME HESAPLAMA
-- ==========================================

-- Her oyuncu için velocity geçmişi (ivme tahmini için)
local velocityHistory = {}
local VELOCITY_SAMPLES = 8

local function getSmoothedVelocity(player)
    local char = player.Character
    if not char then return Vector3.zero end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return Vector3.zero end

    local vel = hrp.AssemblyLinearVelocity
    local key = player.UserId

    -- Velocity geçmişi oluştur
    if not velocityHistory[key] then
        velocityHistory[key] = {}
    end

    local history = velocityHistory[key]
    table.insert(history, {vel = vel, time = tick()})

    -- Eski örnekleri temizle
    while #history > VELOCITY_SAMPLES do
        table.remove(history, 1)
    end

    -- Ağırlıklı ortalama (yeni örneklere daha fazla ağırlık)
    if #history < 2 then return vel end

    local weightedSum = Vector3.zero
    local totalWeight = 0

    for i, sample in ipairs(history) do
        local weight = i / #history -- Son örnek en ağır
        weightedSum = weightedSum + sample.vel * weight
        totalWeight = totalWeight + weight
    end

    return weightedSum / totalWeight
end

-- İvme hesaplama (velocity değişim oranı)
local function getAcceleration(player)
    local key = player.UserId
    local history = velocityHistory[key]

    if not history or #history < 3 then return Vector3.zero end

    local recent = history[#history]
    local older = history[#history - 2]

    local dt = recent.time - older.time
    if dt <= 0 then return Vector3.zero end

    return (recent.vel - older.vel) / dt
end

-- ==========================================
-- BALİSTİK HESAPLAMA
-- ==========================================
--[[
    Mermi düşüşü + hedef hareketi + yerçekimi hesabı.
    
    Problem: Mermi hedefe ulaşana kadar hedef hareket eder.
    Çözüm: İteratif çözüm - merminin uçuş süresini hesapla,
    o süre boyunca hedefin nereye gideceğini tahmin et.
]]

local function calculateBulletDrop(distance, bulletSpeed)
    -- Merminin hedefe ulaşma süresi
    local flightTime = distance / bulletSpeed

    -- Yerçekimi düşüşü: d = 0.5 * g * t^2
    local gravity = workspace.Gravity or 196.2
    local drop = 0.5 * gravity * flightTime * flightTime

    return drop, flightTime
end

-- Gelişmiş hedef pozisyon tahmini
-- Mermi hızı, düşman velocity, ivme, yerçekimi hepsi hesaplanır
local function predictTargetPosition(player, targetPartPos)
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then
        return targetPartPos
    end

    local origin = Camera.CFrame.Position
    local distance = (origin - targetPartPos).Magnitude

    -- Prediction kapalıysa direkt pozisyon
    if not Settings.Prediction then
        return targetPartPos
    end

    -- Düşman velocity (ağırlıklı ortalama)
    local enemyVel = getSmoothedVelocity(player)
    local enemyAccel = getAcceleration(player)

    -- Mermi hızı (oyundan algıla veya varsayılan kullan)
    local bulletSpeed = DEFAULT_BULLET_SPEED

    -- Silah tespiti (varsa)
    local myTool = myChar:FindFirstChildOfClass("Tool")
    if myTool then
        -- Bazı oyunlarda silah hızı attribute olarak saklanır
        local spd = myTool:GetAttribute("BulletSpeed") or myTool:GetAttribute("Speed")
        if spd and type(spd) == "number" then
            bulletSpeed = spd
        end
    end

    -- İteratif çözüm: 3 iterasyon yeterli (yakınsama)
    local predictedPos = targetPartPos
    local flightTime = distance / bulletSpeed

    for iteration = 1, 3 do
        -- Hedefin tahminî pozisyonu (hareket + ivme)
        -- x(t) = x0 + v*t + 0.5*a*t^2
        local linearMove = enemyVel * flightTime * Settings.PredictionAmount
        local accelMove = enemyAccel * 0.5 * flightTime * flightTime * Settings.PredictionAmount

        -- Yatay hareket tahmini (Y ekseni ayrı - yerçekimi)
        local horizontalPrediction = Vector3.new(
            linearMove.X + accelMove.X,
            0,
            linearMove.Z + accelMove.Z
        )

        -- Dikey tahmin: düşman zıplıyorsa Y velocity'yi de hesapla
        local verticalPrediction = 0
        if math.abs(enemyVel.Y) > 5 then -- Zıplıyor veya düşüyor
            verticalPrediction = enemyVel.Y * flightTime * Settings.PredictionAmount * 0.7
        end

        predictedPos = targetPartPos + horizontalPrediction + Vector3.new(0, verticalPrediction, 0)

        -- Mermi düşüşü kompanzasyonu
        local drop, newFlightTime = calculateBulletDrop(
            (origin - predictedPos).Magnitude,
            bulletSpeed
        )

        -- Düşüş kompanzasyonu: nişanı yukarı kaldır
        predictedPos = predictedPos + Vector3.new(0, drop * 0.5, 0)

        -- Yeni flight time ile tekrar hesapla
        flightTime = newFlightTime
    end

    return predictedPos
end

-- ==========================================
-- HEDEF DOĞRULAMA
-- ==========================================

local function isValidTarget(player)
    if player == LocalPlayer then return false end

    local char = player.Character
    if not char then return false end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end

    local part = char:FindFirstChild(Settings.TargetPart)
    if not part then return false end

    if char:FindFirstChildOfClass("ForceField") then return false end

    -- Takım kontrolü
    if Settings.TeamCheck then
        if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
            return false
        end
    end

    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return false end

    -- Mesafe
    local dist = (myChar.HumanoidRootPart.Position - part.Position).Magnitude
    if dist > Settings.MaxDistance then return false end

    -- Görünürlük
    if Settings.VisibleCheck then
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {myChar, Camera}
        params.RespectCanCollide = true

        local origin = Camera.CFrame.Position
        local dir = (part.Position - origin)
        local result = workspace:Raycast(origin, dir, params)

        if result and not result.Instance:IsDescendantOf(char) then
            return false
        end
    end

    return true
end

-- ==========================================
-- HEDEF SEÇİMİ (Crosshair bazlı)
-- ==========================================

-- Crosshair'e (ekran merkezine) en yakın hedefi seç
local function getClosestToCrosshair()
    local best = nil
    local bestDist = Settings.FOVSize
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if isValidTarget(player) then
            local char = player.Character
            local part = char:FindFirstChild(Settings.TargetPart)
            if part then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local screenDist = (screenCenter - Vector2.new(pos.X, pos.Y)).Magnitude
                    if screenDist < bestDist then
                        bestDist = screenDist
                        best = player
                    end
                end
            end
        end
    end

    return best
end

-- ==========================================
-- ANA AIM FONKSİYONU - CROSSHAIR BAZLI
-- ==========================================
--[[
    Mantık:
    1. Hedef pozisyonunu dünya koordinatında hesapla (balistik dahil)
    2. Hedefi ekran koordinatına çevir
    3. Ekran merkezinden (crosshair) hedefe olan delta'yı bul
    4. Delta'yı smoothness'a göre böl
    5. CFrame.lookAt ile kamerayı döndür
    
    Smoothness mapping (doğal hissiyat):
    1     = tam snap (CFrame direkt)
    2     = çok hızlı flick (alpha 0.85)
    3     = hızlı flick (alpha 0.65) -- insanüstü ama doğal
    4-5   = hızlı tracking (alpha 0.40-0.50)
    6-8   = orta smooth (alpha 0.25-0.35)
    9-12  = yavaş smooth (alpha 0.15-0.20)
    13-20 = çok yavaş (alpha 0.05-0.12)
]]

local function calculateAlpha(smoothness)
    -- Exponential decay curve: daha doğal hissiyat
    -- smooth=1 -> 1.0, smooth=2 -> 0.85, smooth=3 -> 0.65
    -- smooth=5 -> 0.45, smooth=10 -> 0.18, smooth=20 -> 0.06
    local alpha = 1.7 / (smoothness ^ 0.75)
    return math.clamp(alpha, 0.04, 1.0)
end

local function aimAtTarget(targetWorldPos)
    if not targetWorldPos then return end

    Camera = workspace.CurrentCamera
    local camPos = Camera.CFrame.Position
    local smooth = math.clamp(Settings.Smoothness, 1, 20)

    -- Hedef CFrame
    local targetCF = CFrame.lookAt(camPos, targetWorldPos)

    if smooth <= 1 then
        -- SNAP: Anlık, sıfır gecikme
        Camera.CFrame = targetCF
        return
    end

    -- Dinamik alpha hesapla
    local alpha = calculateAlpha(smooth)

    -- Mesafe bazlı alpha boost: yakın hedeflere daha hızlı lock
    local screenPos, onScreen = Camera:WorldToViewportPoint(targetWorldPos)
    if onScreen then
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local pixelDist = (center - Vector2.new(screenPos.X, screenPos.Y)).Magnitude

        -- Crosshair hedefe çok yakınsa (< 10px) tam lock
        if pixelDist < 10 then
            Camera.CFrame = targetCF
            return
        end

        -- Hedefe yaklaştıkça alpha artır (hızlan)
        if pixelDist < 50 then
            alpha = alpha * 1.4
        end

        -- Çok uzaktaysa (> 200px) ilk flick hızlı olsun
        if pixelDist > 200 then
            alpha = math.max(alpha, 0.5)
        end
    end

    alpha = math.clamp(alpha, 0.04, 1.0)

    -- CFrame Lerp ile kamera döndür
    Camera.CFrame = Camera.CFrame:Lerp(targetCF, alpha)
end

-- ==========================================
-- ANA DÖNGÜ
-- ==========================================

RunService.RenderStepped:Connect(function()
    Camera = workspace.CurrentCamera

    -- FOV dairesi güncelle
    if fovCircle then
        fovCircle.Visible = Settings.Enabled and Settings.FOVEnabled
        fovCircle.Radius = Settings.FOVSize
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    end

    -- Aimbot kapalıysa temizle
    if not Settings.Enabled then
        currentTarget = nil
        lockedTarget = nil
        return
    end

    -- Aim tuşu kontrolü
    if not isAiming then
        if not Settings.StickyAim then
            currentTarget = nil
            lockedTarget = nil
        end
        return
    end

    -- Hedef seçimi
    if Settings.StickyAim and lockedTarget and isValidTarget(lockedTarget) then
        currentTarget = lockedTarget
    else
        currentTarget = getClosestToCrosshair()
        if Settings.StickyAim and currentTarget then
            lockedTarget = currentTarget
        end
    end

    -- Aim uygula
    if currentTarget then
        local char = currentTarget.Character
        if char then
            local part = char:FindFirstChild(Settings.TargetPart)
            if part then
                -- Balistik tahminli pozisyon
                local predictedPos = predictTargetPosition(currentTarget, part.Position)
                aimAtTarget(predictedPos)
            end
        end
    end
end)

-- ==========================================
-- TUŞLAR
-- ==========================================

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Settings.AimKey or input.KeyCode == Settings.AimKey then
        isAiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Settings.AimKey or input.KeyCode == Settings.AimKey then
        isAiming = false
        if not Settings.StickyAim then
            currentTarget = nil
            lockedTarget = nil
        end
    end
end)

-- Oyuncu ayrılma
Players.PlayerRemoving:Connect(function(player)
    if currentTarget == player then currentTarget = nil end
    if lockedTarget == player then lockedTarget = nil end
    velocityHistory[player.UserId] = nil
end)

-- Yerçekimi güncellemesi
task.spawn(function()
    while true do
        GRAVITY = Vector3.new(0, -(workspace.Gravity or 196.2), 0)
        task.wait(5)
    end
end)

print("[VergiHub] Aimbot Engine v3.0 hazir!")
return true
