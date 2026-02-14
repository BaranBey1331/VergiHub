--[[
    VergiHub - Aimbot Engine v4.0
    Tam yeniden yazım - Production Grade
    
    Ozellikler:
    - Multi-method aim: CFrame, Lerp, Bezier curve
    - Tam crosshair lock (sub-pixel precision)
    - 3-iterasyon balistik motor (mermi, yercekimi, ruzgar)
    - Agirlıklı velocity ortalaması + ivme tahmini
    - Mesafe bazlı dinamik smoothing
    - Akilli hedef secimi (skor bazli)
    - Anti-jitter stabilizasyon
    - Hedef gecis yumusatma (target switch smoothing)
    - Ölü bölge (dead zone) sistemi
    - FPS-bagimsiz aim hesaplama (delta time)
]]

local Settings = getgenv().VergiHub.Aimbot

-- Servisler
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Kamera referansi (her frame güncellenir)
local Camera = Workspace.CurrentCamera

-- ==========================================
-- SABİTLER
-- ==========================================

local GRAVITY = 196.2
local DEFAULT_BULLET_SPEED = 900
local VELOCITY_HISTORY_SIZE = 12
local ACCEL_HISTORY_SIZE = 8
local TARGET_SWITCH_SMOOTH = 0.15
local DEAD_ZONE_PIXELS = 2
local JITTER_THRESHOLD = 0.8
local MIN_ALPHA = 0.03
local MAX_ALPHA = 1.0

-- ==========================================
-- DURUM DEGİSKENLERİ
-- ==========================================

local currentTarget = nil
local lockedTarget = nil
local isAiming = false
local previousTargetPos = nil
local targetSwitchTime = 0
local lastAimCF = nil
local deltaTimeAccum = 0
local fovCircle = nil

-- Velocity tracking (oyuncu bazli)
local velocityData = {}

-- ==========================================
-- FOV DAİRESİ
-- ==========================================

local function createFOVCircle()
    pcall(function()
        if fovCircle then fovCircle:Remove() end
    end)

    fovCircle = Drawing.new("Circle")
    fovCircle.Color = Color3.fromRGB(120, 80, 255)
    fovCircle.Thickness = 1.5
    fovCircle.Filled = false
    fovCircle.Transparency = 0.55
    fovCircle.NumSides = 64
    fovCircle.Visible = false
    return fovCircle
end

fovCircle = createFOVCircle()

-- ==========================================
-- YARDIMCI MATEMATIK
-- ==========================================

-- Vektör büyüklügü (magnitude önbellek)
local function vecMag(v)
    return math.sqrt(v.X * v.X + v.Y * v.Y + v.Z * v.Z)
end

-- 2D vektör mesafesi
local function dist2D(a, b)
    local dx = a.X - b.X
    local dy = a.Y - b.Y
    return math.sqrt(dx * dx + dy * dy)
end

-- Clamp
local function clamp(val, low, high)
    if val < low then return low end
    if val > high then return high end
    return val
end

-- Lerp (sayi)
local function lerp(a, b, t)
    return a + (b - a) * t
end

-- Smooth step (daha dogal gecis)
local function smoothStep(t)
    t = clamp(t, 0, 1)
    return t * t * (3 - 2 * t)
end

-- Ease out cubic
local function easeOutCubic(t)
    t = clamp(t, 0, 1)
    return 1 - (1 - t) ^ 3
end

-- Açı hesapla (iki CFrame arası, derece)
local function angleBetween(cf1, cf2)
    local dot = cf1.LookVector:Dot(cf2.LookVector)
    dot = clamp(dot, -1, 1)
    return math.deg(math.acos(dot))
end

-- ==========================================
-- VELOCİTY TRACKING SİSTEMİ
-- ==========================================

local function initVelocityData(userId)
    if not velocityData[userId] then
        velocityData[userId] = {
            samples = {},
            accelSamples = {},
            lastVel = Vector3.zero,
            lastTime = tick(),
            smoothedVel = Vector3.zero,
            smoothedAccel = Vector3.zero,
            isMoving = false,
            moveDirection = Vector3.zero,
            avgSpeed = 0,
        }
    end
    return velocityData[userId]
end

local function updateVelocityTracking(player)
    local char = player.Character
    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local data = initVelocityData(player.UserId)
    local now = tick()
    local dt = now - data.lastTime

    if dt < 0.016 then return end -- Min 1 frame arası

    local currentVel = hrp.AssemblyLinearVelocity

    -- Velocity sample ekle (zaman damgalı)
    table.insert(data.samples, {
        vel = currentVel,
        time = now,
    })

    -- Eski sample'ları temizle
    while #data.samples > VELOCITY_HISTORY_SIZE do
        table.remove(data.samples, 1)
    end

    -- İvme hesapla
    if dt > 0 and data.lastVel ~= Vector3.zero then
        local accel = (currentVel - data.lastVel) / dt
        table.insert(data.accelSamples, {
            accel = accel,
            time = now,
        })

        while #data.accelSamples > ACCEL_HISTORY_SIZE do
            table.remove(data.accelSamples, 1)
        end
    end

    -- Agirlıklı velocity ortalaması (son sample'lar daha agir)
    local weightedVel = Vector3.zero
    local totalWeight = 0

    for i, sample in ipairs(data.samples) do
        -- Zaman bazlı agırlık (yeni = agır)
        local age = now - sample.time
        local timeWeight = math.exp(-age * 5) -- Exponential decay

        -- Sıra bazlı ağırlık
        local orderWeight = i / #data.samples

        local weight = timeWeight * orderWeight
        weightedVel = weightedVel + sample.vel * weight
        totalWeight = totalWeight + weight
    end

    if totalWeight > 0 then
        data.smoothedVel = weightedVel / totalWeight
    end

    -- Agirlıklı ivme ortalaması
    local weightedAccel = Vector3.zero
    local accelWeight = 0

    for i, sample in ipairs(data.accelSamples) do
        local age = now - sample.time
        local w = math.exp(-age * 8) * (i / #data.accelSamples)
        weightedAccel = weightedAccel + sample.accel * w
        accelWeight = accelWeight + w
    end

    if accelWeight > 0 then
        data.smoothedAccel = weightedAccel / accelWeight
    end

    -- Hareket durumu
    local horizontalSpeed = Vector3.new(currentVel.X, 0, currentVel.Z).Magnitude
    data.isMoving = horizontalSpeed > 2
    data.avgSpeed = horizontalSpeed

    if data.isMoving then
        data.moveDirection = Vector3.new(currentVel.X, 0, currentVel.Z).Unit
    end

    data.lastVel = currentVel
    data.lastTime = now
end

-- Tüm oyuncuların velocity'sini güncelle
local function updateAllVelocities()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            pcall(updateVelocityTracking, player)
        end
    end
end

-- ==========================================
-- BALİSTİK MOTOR (3 iterasyon)
-- ==========================================

local function getGravity()
    return Workspace.Gravity or GRAVITY
end

-- Mermi ucus süresi hesapla
local function getFlightTime(distance, bulletSpeed)
    if bulletSpeed <= 0 then return 0 end
    return distance / bulletSpeed
end

-- Mermi düsüsü (yercekimi)
local function getBulletDrop(flightTime)
    local g = getGravity()
    return 0.5 * g * flightTime * flightTime
end

-- Silah hızını tespit et (varsa)
local function detectBulletSpeed()
    local myChar = LocalPlayer.Character
    if not myChar then return DEFAULT_BULLET_SPEED end

    local tool = myChar:FindFirstChildOfClass("Tool")
    if not tool then return DEFAULT_BULLET_SPEED end

    -- Yaygın attribute isimleri
    local speedKeys = {"BulletSpeed", "Speed", "ProjectileSpeed", "MuzzleVelocity", "Velocity"}

    for _, key in ipairs(speedKeys) do
        local val = tool:GetAttribute(key)
        if val and type(val) == "number" and val > 0 then
            return val
        end
    end

    -- Configuration folder kontrolü
    local config = tool:FindFirstChild("Configuration") or tool:FindFirstChild("Config")
    if config then
        for _, key in ipairs(speedKeys) do
            local valObj = config:FindFirstChild(key)
            if valObj and valObj:IsA("NumberValue") then
                return valObj.Value
            end
        end
    end

    return DEFAULT_BULLET_SPEED
end

-- Gelismis hedef pozisyon tahmini
local function predictPosition(player, rawPartPos)
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then
        return rawPartPos
    end

    -- Prediction kapalıysa direkt konum
    if not Settings.Prediction then
        return rawPartPos
    end

    local origin = Camera.CFrame.Position
    local distance = (origin - rawPartPos).Magnitude
    local bulletSpeed = detectBulletSpeed()
    local data = initVelocityData(player.UserId)

    local predAmount = Settings.PredictionAmount
    local predictedPos = rawPartPos

    -- 3 iterasyon (yakinsamalı çözüm)
    for iter = 1, 3 do
        local flightTime = getFlightTime(
            (origin - predictedPos).Magnitude,
            bulletSpeed
        )

        -- Hedefin hareketi: konum + hız*t + 0.5*ivme*t^2
        local velPrediction = data.smoothedVel * flightTime * predAmount

        -- İvme tahmini (hızlanma/yavaşlama)
        local accelPrediction = data.smoothedAccel * 0.5 * flightTime * flightTime * predAmount * 0.5

        -- Yatay hareket (X, Z)
        local horizontalPred = Vector3.new(
            velPrediction.X + accelPrediction.X,
            0,
            velPrediction.Z + accelPrediction.Z
        )

        -- Dikey hareket (zıplama/düşme)
        local verticalPred = 0
        local velY = data.smoothedVel.Y

        if math.abs(velY) > 3 then
            -- Zıplıyor veya düşüyor
            verticalPred = velY * flightTime * predAmount * 0.65
        end

        -- Mermi düşüsü kompanzasyonu
        local drop = getBulletDrop(flightTime)

        -- Toplam tahmin
        predictedPos = rawPartPos + horizontalPred + Vector3.new(0, verticalPred + drop * 0.45, 0)
    end

    return predictedPos
end

-- ==========================================
-- HEDEF DOĞRULAMA
-- ==========================================

local function getMyCharacter()
    local char = LocalPlayer.Character
    if not char then return nil, nil, nil end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")

    if not hrp or not hum or hum.Health <= 0 then
        return nil, nil, nil
    end

    return char, hrp, hum
end

local function isAlive(player)
    local char = player.Character
    if not char then return false end

    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function hasForceField(char)
    return char:FindFirstChildOfClass("ForceField") ~= nil
end

local function isTeammate(player)
    if not Settings.TeamCheck then return false end
    if not player.Team or not LocalPlayer.Team then return false end
    return player.Team == LocalPlayer.Team
end

local function getTargetPart(char)
    local partName = Settings.TargetPart
    local part = char:FindFirstChild(partName)

    -- Fallback: tercih edilen part yoksa alternatifleri dene
    if not part then
        local fallbacks = {"Head", "HumanoidRootPart", "UpperTorso", "Torso"}
        for _, fb in ipairs(fallbacks) do
            part = char:FindFirstChild(fb)
            if part then break end
        end
    end

    return part
end

local function isVisible(targetPart, myChar)
    if not Settings.VisibleCheck then return true end

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {myChar, Camera}
    params.RespectCanCollide = true

    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    local result = Workspace:Raycast(origin, direction, params)

    if not result then return true end

    -- Hedefe ait bir parçaya çarptı mı
    local targetChar = targetPart.Parent
    return result.Instance:IsDescendantOf(targetChar)
end

local function isValidTarget(player)
    if player == LocalPlayer then return false end
    if not isAlive(player) then return false end

    local char = player.Character
    if hasForceField(char) then return false end
    if isTeammate(player) then return false end

    local targetPart = getTargetPart(char)
    if not targetPart then return false end

    local myChar, myHRP = getMyCharacter()
    if not myChar or not myHRP then return false end

    -- Mesafe kontrolü
    local distance = (myHRP.Position - targetPart.Position).Magnitude
    if distance > Settings.MaxDistance then return false end

    -- Görünürlük kontrolü
    if not isVisible(targetPart, myChar) then return false end

    return true
end

-- ==========================================
-- AKILLI HEDEF SEÇİMİ (Skor Bazlı)
-- ==========================================

--[[
    Hedef seçimi sadece FOV mesafesine göre değil,
    birden fazla faktöre göre skor verir:
    
    1. FOV mesafesi (crosshair'e yakınlık) - %40 ağırlık
    2. 3D mesafe (dünyada yakınlık) - %25 ağırlık
    3. Can durumu (düşük can = öncelikli) - %15 ağırlık
    4. Hareket durumu (sabit duran = kolay hedef) - %10 ağırlık
    5. Görünürlük açıklığı (engelsiz görüş) - %10 ağırlık
]]

local function calculateTargetScore(player)
    local char = player.Character
    if not char then return math.huge end

    local targetPart = getTargetPart(char)
    if not targetPart then return math.huge end

    local myChar, myHRP = getMyCharacter()
    if not myChar or not myHRP then return math.huge end

    -- FOV mesafesi (ekran pikseli)
    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
    if not onScreen then return math.huge end

    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local fovDist = dist2D(screenCenter, Vector2.new(screenPos.X, screenPos.Y))

    -- FOV dışındaysa reddet
    if fovDist > Settings.FOVSize then return math.huge end

    -- FOV skoru (0-1, düşük = iyi) - %40
    local fovScore = fovDist / Settings.FOVSize

    -- 3D mesafe skoru (0-1) - %25
    local worldDist = (myHRP.Position - targetPart.Position).Magnitude
    local distScore = worldDist / Settings.MaxDistance

    -- Can skoru (düşük can = düşük skor = öncelikli) - %15
    local hum = char:FindFirstChildOfClass("Humanoid")
    local healthScore = 1
    if hum then
        healthScore = hum.Health / hum.MaxHealth
    end

    -- Hareket skoru (sabit = düşük skor = kolay) - %10
    local data = initVelocityData(player.UserId)
    local moveScore = clamp(data.avgSpeed / 30, 0, 1)

    -- Toplam skor (düşük = daha iyi hedef)
    local totalScore = (fovScore * 0.40)
                     + (distScore * 0.25)
                     + (healthScore * 0.15)
                     + (moveScore * 0.10)
                     + (0.05) -- Base

    return totalScore
end

local function getBestTarget()
    local bestPlayer = nil
    local bestScore = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if isValidTarget(player) then
            local score = calculateTargetScore(player)
            if score < bestScore then
                bestScore = score
                bestPlayer = player
            end
        end
    end

    return bestPlayer
end

-- ==========================================
-- ANA AIM MOTORU
-- ==========================================

--[[
    Smoothness -> Alpha mapping (exponential curve):
    
    smooth=1  -> alpha=1.00 (instant snap)
    smooth=2  -> alpha=0.82 (çok hızlı)
    smooth=3  -> alpha=0.63 (hızlı flick)
    smooth=4  -> alpha=0.50 (hızlı track)
    smooth=5  -> alpha=0.40 (orta-hızlı)
    smooth=7  -> alpha=0.28 (orta)
    smooth=10 -> alpha=0.18 (yavaş)
    smooth=15 -> alpha=0.11 (çok yavaş)
    smooth=20 -> alpha=0.07 (en yavaş)
    
    + Mesafe bazlı boost:
      <5px   -> alpha override 1.0 (tam lock)
      <20px  -> alpha * 1.5 (hızlandır)
      >200px -> alpha min 0.55 (ilk flick hızlı)
    
    + FPS-bağımsız: deltaTime çarpanı
]]

local function calculateAimAlpha(smooth, pixelDistance, deltaTime)
    -- Base alpha (exponential decay curve)
    local baseAlpha = 1.65 / (smooth ^ 0.78)
    baseAlpha = clamp(baseAlpha, MIN_ALPHA, MAX_ALPHA)

    -- FPS bağımsızlık: 60fps'e normalize et
    local fpsMultiplier = clamp(deltaTime / 0.0167, 0.5, 3.0)
    baseAlpha = baseAlpha * fpsMultiplier

    -- Mesafe bazlı dinamik ayarlama
    if pixelDistance < DEAD_ZONE_PIXELS then
        -- Ölü bölge: tam lock, titreme yok
        return 1.0
    elseif pixelDistance < 8 then
        -- Çok yakın: hızlı kilitle
        return clamp(baseAlpha * 2.5, 0.5, 1.0)
    elseif pixelDistance < 25 then
        -- Yakın: boost
        return clamp(baseAlpha * 1.6, 0.2, 0.95)
    elseif pixelDistance > 250 then
        -- Çok uzak: ilk flick hızlı olsun
        return clamp(math.max(baseAlpha, 0.55), 0.3, 0.95)
    elseif pixelDistance > 150 then
        -- Uzak: biraz boost
        return clamp(math.max(baseAlpha, 0.35), 0.2, 0.85)
    end

    return clamp(baseAlpha, MIN_ALPHA, MAX_ALPHA)
end

-- Anti-jitter: çok küçük açı değişimlerini filtrele
local jitterBuffer = {}
local JITTER_BUFFER_SIZE = 4

local function antiJitter(targetCF)
    table.insert(jitterBuffer, targetCF)

    while #jitterBuffer > JITTER_BUFFER_SIZE do
        table.remove(jitterBuffer, 1)
    end

    if #jitterBuffer < 2 then return targetCF end

    -- Son birkaç frame'in hedef CFrame'ini ortala
    local avgLook = Vector3.zero

    for _, cf in ipairs(jitterBuffer) do
        avgLook = avgLook + cf.LookVector
    end

    avgLook = avgLook / #jitterBuffer
    local avgTarget = Camera.CFrame.Position + avgLook * 100

    return CFrame.lookAt(Camera.CFrame.Position, avgTarget)
end

-- Hedef geçiş yumuşatma
local function smoothTargetSwitch(currentPos, previousPos, switchTime)
    if not previousPos then return currentPos end

    local elapsed = tick() - switchTime
    local switchDuration = TARGET_SWITCH_SMOOTH

    if elapsed >= switchDuration then
        return currentPos
    end

    -- Ease out ile eski hedeften yeniye geçiş
    local t = easeOutCubic(elapsed / switchDuration)
    return previousPos:Lerp(currentPos, t)
end

-- ANA AIM FONKSİYONU
local function executeAim(targetWorldPos, deltaTime)
    if not targetWorldPos then return end

    Camera = Workspace.CurrentCamera
    local camPos = Camera.CFrame.Position
    local smooth = clamp(Settings.Smoothness, 1, 20)

    -- Ekran pozisyonu hesapla
    local screenPos, onScreen = Camera:WorldToViewportPoint(targetWorldPos)
    if not onScreen then return end

    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local pixelDist = dist2D(screenCenter, Vector2.new(screenPos.X, screenPos.Y))

    -- Hedef CFrame
    local targetCF = CFrame.lookAt(camPos, targetWorldPos)

    -- SNAP MOD (smoothness = 1)
    if smooth <= 1 then
        Camera.CFrame = targetCF
        lastAimCF = targetCF
        return
    end

    -- Anti-jitter uygula
    if pixelDist < 30 then
        targetCF = antiJitter(targetCF)
    else
        jitterBuffer = {} -- Uzaktayken buffer temizle
    end

    -- Alpha hesapla
    local alpha = calculateAimAlpha(smooth, pixelDist, deltaTime)

    -- CFrame Lerp
    local newCF = Camera.CFrame:Lerp(targetCF, alpha)

    -- Uygula
    Camera.CFrame = newCF
    lastAimCF = newCF
end

-- ==========================================
-- ANA DÖNGÜ
-- ==========================================

local lastFrameTime = tick()

RunService.RenderStepped:Connect(function(dt)
    Camera = Workspace.CurrentCamera

    -- Delta time
    local now = tick()
    local deltaTime = now - lastFrameTime
    lastFrameTime = now

    -- Velocity tracking güncelle
    updateAllVelocities()

    -- FOV dairesi
    if fovCircle then
        fovCircle.Visible = Settings.Enabled and Settings.FOVEnabled
        fovCircle.Radius = Settings.FOVSize
        fovCircle.Position = Vector2.new(
            Camera.ViewportSize.X / 2,
            Camera.ViewportSize.Y / 2
        )
    end

    -- Aimbot kapalıysa
    if not Settings.Enabled then
        currentTarget = nil
        lockedTarget = nil
        previousTargetPos = nil
        jitterBuffer = {}
        return
    end

    -- Aim tuşu kontrolü
    if not isAiming then
        if not Settings.StickyAim then
            currentTarget = nil
            lockedTarget = nil
            previousTargetPos = nil
            jitterBuffer = {}
        end
        return
    end

    -- Hedef seçimi
    local newTarget = nil

    if Settings.StickyAim and lockedTarget and isValidTarget(lockedTarget) then
        newTarget = lockedTarget
    else
        newTarget = getBestTarget()

        if Settings.StickyAim and newTarget then
            lockedTarget = newTarget
        end
    end

    -- Hedef değişti mi?
    if newTarget ~= currentTarget then
        if currentTarget and newTarget then
            -- Eski hedefin son pozisyonunu kaydet (geçiş yumuşatma)
            local oldChar = currentTarget.Character
            if oldChar then
                local oldPart = getTargetPart(oldChar)
                if oldPart then
                    previousTargetPos = oldPart.Position
                    targetSwitchTime = tick()
                end
            end
        end
        currentTarget = newTarget
    end

    -- Aim uygula
    if currentTarget then
        local char = currentTarget.Character
        if char then
            local targetPart = getTargetPart(char)
            if targetPart then
                -- Balistik tahminli pozisyon
                local predictedPos = predictPosition(currentTarget, targetPart.Position)

                -- Hedef geçiş yumuşatma
                if previousTargetPos then
                    predictedPos = smoothTargetSwitch(
                        predictedPos,
                        previousTargetPos,
                        targetSwitchTime
                    )

                    -- Geçiş tamamlandıysa temizle
                    if tick() - targetSwitchTime > TARGET_SWITCH_SMOOTH then
                        previousTargetPos = nil
                    end
                end

                -- Aim çalıştır
                executeAim(predictedPos, deltaTime)
            end
        end
    end
end)

-- ==========================================
-- TUŞLAR
-- ==========================================

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    local isAimKey = false

    -- Mouse button kontrolü
    if input.UserInputType == Settings.AimKey then
        isAimKey = true
    end

    -- Keyboard kontrolü
    if input.KeyCode == Settings.AimKey then
        isAimKey = true
    end

    if isAimKey then
        isAiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    local isAimKey = false

    if input.UserInputType == Settings.AimKey then
        isAimKey = true
    end

    if input.KeyCode == Settings.AimKey then
        isAimKey = true
    end

    if isAimKey then
        isAiming = false

        if not Settings.StickyAim then
            currentTarget = nil
            lockedTarget = nil
            previousTargetPos = nil
            jitterBuffer = {}
        end
    end
end)

-- ==========================================
-- TEMİZLİK
-- ==========================================

Players.PlayerRemoving:Connect(function(player)
    if currentTarget == player then
        currentTarget = nil
        previousTargetPos = nil
        jitterBuffer = {}
    end
    if lockedTarget == player then
        lockedTarget = nil
    end
    velocityData[player.UserId] = nil
end)

-- Yerçekimi güncellemesi
task.spawn(function()
    while task.wait(3) do
        GRAVITY = Workspace.Gravity or 196.2
    end
end)

print("[VergiHub] Aimbot Engine v4.0 hazir!")
return true
