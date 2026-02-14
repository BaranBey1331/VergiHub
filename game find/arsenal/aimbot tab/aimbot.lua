--[[
    VergiHub - Arsenal Aimbot v2.0
    Arsenal'a özel optimize edilmiş aimbot
    
    Arsenal spesifik:
    - Arsenal silah sistemi entegrasyonu
    - Arsenal takım yapısı desteği
    - Hızlı TTK (time to kill) odaklı hedefleme
    - Arsenal spawn koruması tespiti
    - Knife/melee mesafe kontrolü
    - Arsenal'ın kendi anti-cheat'ine uyum
]]

local Settings = getgenv().VergiHub.Aimbot

-- Servisler
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local Camera = Workspace.CurrentCamera

-- ==========================================
-- ARSENAL SABİTLER
-- ==========================================

local ARSENAL_PLACE_IDS = {286090429, 5765828882} -- Ana + VIP
local VELOCITY_HISTORY = 10
local ACCEL_HISTORY = 6
local DEAD_ZONE = 2
local FLICK_BOOST_THRESHOLD = 180
local NEAR_LOCK_THRESHOLD = 12

-- ==========================================
-- DURUM
-- ==========================================

local currentTarget = nil
local lockedTarget = nil
local isAiming = false
local previousTargetPos = nil
local targetSwitchTime = 0
local lastFrameTime = tick()
local fovCircle = nil
local velocityData = {}
local jitterBuffer = {}

-- Arsenal spesifik
local isArsenal = false
local currentWeaponType = "gun" -- "gun" | "melee" | "grenade"

-- ==========================================
-- ARSENAL TESPİT
-- ==========================================

local function detectArsenal()
    local placeId = game.PlaceId
    for _, id in ipairs(ARSENAL_PLACE_IDS) do
        if placeId == id then
            isArsenal = true
            return true
        end
    end
    isArsenal = false
    return false
end

detectArsenal()

-- Silah tipi tespit
local function detectWeaponType()
    local char = LocalPlayer.Character
    if not char then return "gun" end

    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return "gun" end

    local toolName = string.lower(tool.Name)

    -- Melee silahlar
    local meleeKeywords = {"knife", "sword", "bat", "axe", "fist", "melee", "blade", "dagger"}
    for _, keyword in ipairs(meleeKeywords) do
        if string.find(toolName, keyword) then
            return "melee"
        end
    end

    -- Patlayıcılar
    local grenadeKeywords = {"grenade", "rocket", "rpg", "launcher", "explosive", "bomb"}
    for _, keyword in ipairs(grenadeKeywords) do
        if string.find(toolName, keyword) then
            return "grenade"
        end
    end

    return "gun"
end

-- ==========================================
-- FOV DAİRESİ
-- ==========================================

local function createFOVCircle()
    pcall(function()
        if fovCircle then fovCircle:Remove() end
    end)

    fovCircle = Drawing.new("Circle")
    fovCircle.Color = Color3.fromRGB(255, 165, 0) -- Arsenal turuncu
    fovCircle.Thickness = 1.5
    fovCircle.Filled = false
    fovCircle.Transparency = 0.55
    fovCircle.NumSides = 64
    fovCircle.Visible = false
    return fovCircle
end

fovCircle = createFOVCircle()

-- ==========================================
-- YARDIMCI
-- ==========================================

local function clamp(v, lo, hi)
    if v < lo then return lo end
    if v > hi then return hi end
    return v
end

local function dist2D(a, b)
    local dx = a.X - b.X
    local dy = a.Y - b.Y
    return math.sqrt(dx * dx + dy * dy)
end

local function easeOutCubic(t)
    return 1 - (1 - clamp(t, 0, 1)) ^ 3
end

-- ==========================================
-- VELOCİTY TRACKING
-- ==========================================

local function initVelData(uid)
    if not velocityData[uid] then
        velocityData[uid] = {
            samples = {},
            accelSamples = {},
            lastVel = Vector3.zero,
            lastTime = tick(),
            smoothedVel = Vector3.zero,
            smoothedAccel = Vector3.zero,
            isMoving = false,
            avgSpeed = 0,
        }
    end
    return velocityData[uid]
end

local function updateVelocity(player)
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local data = initVelData(player.UserId)
    local now = tick()
    local dt = now - data.lastTime
    if dt < 0.016 then return end

    local vel = hrp.AssemblyLinearVelocity

    table.insert(data.samples, {vel = vel, time = now})
    while #data.samples > VELOCITY_HISTORY do
        table.remove(data.samples, 1)
    end

    if dt > 0 and data.lastVel ~= Vector3.zero then
        local accel = (vel - data.lastVel) / dt
        table.insert(data.accelSamples, {accel = accel, time = now})
        while #data.accelSamples > ACCEL_HISTORY do
            table.remove(data.accelSamples, 1)
        end
    end

    -- Ağırlıklı ortalama
    local wVel = Vector3.zero
    local wTotal = 0
    for i, s in ipairs(data.samples) do
        local age = now - s.time
        local w = math.exp(-age * 6) * (i / #data.samples)
        wVel = wVel + s.vel * w
        wTotal = wTotal + w
    end
    if wTotal > 0 then data.smoothedVel = wVel / wTotal end

    -- İvme
    local wAccel = Vector3.zero
    local aTotal = 0
    for i, s in ipairs(data.accelSamples) do
        local age = now - s.time
        local w = math.exp(-age * 10) * (i / #data.accelSamples)
        wAccel = wAccel + s.accel * w
        aTotal = aTotal + w
    end
    if aTotal > 0 then data.smoothedAccel = wAccel / aTotal end

    local hSpeed = Vector3.new(vel.X, 0, vel.Z).Magnitude
    data.isMoving = hSpeed > 2
    data.avgSpeed = hSpeed

    data.lastVel = vel
    data.lastTime = now
end

local function updateAllVelocities()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            pcall(updateVelocity, p)
        end
    end
end

-- ==========================================
-- ARSENAL PREDICTION
-- ==========================================

local function arsenalPredict(player, partPos)
    if not Settings.Prediction then return partPos end

    local data = initVelData(player.UserId)
    local origin = Camera.CFrame.Position
    local distance = (origin - partPos).Magnitude

    -- Arsenal'da mermi hızı genelde yüksek
    local bulletSpeed = 1200
    local predAmount = Settings.PredictionAmount

    -- Arsenal optimize: 0.135 civarı ideal
    if isArsenal then
        predAmount = clamp(predAmount, 0.08, 0.25)
    end

    local predicted = partPos

    for iter = 1, 3 do
        local flight = distance / bulletSpeed
        if flight <= 0 then break end

        local velPred = data.smoothedVel * flight * predAmount
        local accelPred = data.smoothedAccel * 0.5 * flight * flight * predAmount * 0.4

        local hPred = Vector3.new(
            velPred.X + accelPred.X,
            0,
            velPred.Z + accelPred.Z
        )

        local vPred = 0
        if math.abs(data.smoothedVel.Y) > 3 then
            vPred = data.smoothedVel.Y * flight * predAmount * 0.6
        end

        local g = Workspace.Gravity or 196.2
        local drop = 0.5 * g * flight * flight

        predicted = partPos + hPred + Vector3.new(0, vPred + drop * 0.4, 0)
        distance = (origin - predicted).Magnitude
    end

    return predicted
end

-- ==========================================
-- HEDEF DOĞRULAMA
-- ==========================================

local function getMyChar()
    local c = LocalPlayer.Character
    if not c then return nil, nil end
    local h = c:FindFirstChild("HumanoidRootPart")
    local hum = c:FindFirstChildOfClass("Humanoid")
    if not h or not hum or hum.Health <= 0 then return nil, nil end
    return c, h
end

local function getTargetPart(char)
    local part = char:FindFirstChild(Settings.TargetPart)
    if not part then
        for _, fb in ipairs({"Head", "HumanoidRootPart", "UpperTorso", "Torso"}) do
            part = char:FindFirstChild(fb)
            if part then break end
        end
    end
    return part
end

local function isValidTarget(player)
    if player == LocalPlayer then return false end

    local char = player.Character
    if not char then return false end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end

    local part = getTargetPart(char)
    if not part then return false end

    -- ForceField (Arsenal spawn koruması)
    if char:FindFirstChildOfClass("ForceField") then return false end

    -- Arsenal takım kontrolü
    if Settings.TeamCheck then
        if player.Team and LocalPlayer.Team then
            if player.Team == LocalPlayer.Team then
                return false
            end
        end
    end

    local myChar, myHRP = getMyChar()
    if not myChar or not myHRP then return false end

    -- Mesafe
    local dist = (myHRP.Position - part.Position).Magnitude
    if dist > Settings.MaxDistance then return false end

    -- Melee silahta mesafe sınırı
    if currentWeaponType == "melee" and dist > 15 then
        return false
    end

    -- Görünürlük
    if Settings.VisibleCheck then
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {myChar, Camera}
        params.RespectCanCollide = true

        local origin = Camera.CFrame.Position
        local dir = part.Position - origin
        local result = Workspace:Raycast(origin, dir, params)

        if result and not result.Instance:IsDescendantOf(char) then
            return false
        end
    end

    return true
end

-- ==========================================
-- HEDEF SEÇİMİ (Arsenal optimize)
-- ==========================================

local function calculateScore(player)
    local char = player.Character
    if not char then return math.huge end

    local part = getTargetPart(char)
    if not part then return math.huge end

    local myChar, myHRP = getMyChar()
    if not myChar or not myHRP then return math.huge end

    local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
    if not onScreen then return math.huge end

    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local fovDist = dist2D(center, Vector2.new(sp.X, sp.Y))

    if fovDist > Settings.FOVSize then return math.huge end

    local fovScore = fovDist / Settings.FOVSize
    local worldDist = (myHRP.Position - part.Position).Magnitude
    local distScore = worldDist / Settings.MaxDistance

    local hum = char:FindFirstChildOfClass("Humanoid")
    local healthScore = hum and (hum.Health / hum.MaxHealth) or 1

    local data = initVelData(player.UserId)
    local moveScore = clamp(data.avgSpeed / 30, 0, 1)

    -- Arsenal: melee'de mesafe çok önemli
    local meleeBonus = 0
    if currentWeaponType == "melee" then
        meleeBonus = distScore * 0.3 -- Yakın düşmanlar öncelikli
    end

    return (fovScore * 0.40) + (distScore * 0.25) + (healthScore * 0.15) + (moveScore * 0.10) + meleeBonus
end

local function getBestTarget()
    local best = nil
    local bestScore = math.huge

    for _, p in ipairs(Players:GetPlayers()) do
        if isValidTarget(p) then
            local score = calculateScore(p)
            if score < bestScore then
                bestScore = score
                best = p
            end
        end
    end

    return best
end

-- ==========================================
-- AIM MOTORU
-- ==========================================

local function calculateAlpha(smooth, pixelDist, dt)
    local base = 1.65 / (smooth ^ 0.78)
    base = clamp(base, 0.03, 1.0)

    local fpsMul = clamp(dt / 0.0167, 0.5, 3.0)
    base = base * fpsMul

    if pixelDist < DEAD_ZONE then
        return 1.0
    elseif pixelDist < 8 then
        return clamp(base * 2.5, 0.5, 1.0)
    elseif pixelDist < 25 then
        return clamp(base * 1.6, 0.2, 0.95)
    elseif pixelDist > 250 then
        return clamp(math.max(base, 0.55), 0.3, 0.95)
    elseif pixelDist > FLICK_BOOST_THRESHOLD then
        return clamp(math.max(base, 0.40), 0.2, 0.85)
    end

    return clamp(base, 0.03, 1.0)
end

local function antiJitter(targetCF)
    table.insert(jitterBuffer, targetCF)
    while #jitterBuffer > 4 do
        table.remove(jitterBuffer, 1)
    end

    if #jitterBuffer < 2 then return targetCF end

    local avgLook = Vector3.zero
    for _, cf in ipairs(jitterBuffer) do
        avgLook = avgLook + cf.LookVector
    end
    avgLook = avgLook / #jitterBuffer

    return CFrame.lookAt(Camera.CFrame.Position, Camera.CFrame.Position + avgLook * 100)
end

local function executeAim(targetWorldPos, deltaTime)
    if not targetWorldPos then return end

    Camera = Workspace.CurrentCamera
    local camPos = Camera.CFrame.Position
    local smooth = clamp(Settings.Smoothness, 1, 20)

    local sp, onScreen = Camera:WorldToViewportPoint(targetWorldPos)
    if not onScreen then return end

    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local pixelDist = dist2D(center, Vector2.new(sp.X, sp.Y))

    local targetCF = CFrame.lookAt(camPos, targetWorldPos)

    -- Snap
    if smooth <= 1 then
        Camera.CFrame = targetCF
        return
    end

    -- Anti-jitter (yakın mesafede)
    if pixelDist < 30 then
        targetCF = antiJitter(targetCF)
    else
        jitterBuffer = {}
    end

    -- Alpha
    local alpha = calculateAlpha(smooth, pixelDist, deltaTime)

    -- Arsenal boost: melee'de daha hızlı lock
    if currentWeaponType == "melee" then
        alpha = clamp(alpha * 1.4, 0.2, 1.0)
    end

    Camera.CFrame = Camera.CFrame:Lerp(targetCF, alpha)
end

-- ==========================================
-- ANA DÖNGÜ
-- ==========================================

RunService.RenderStepped:Connect(function(dt)
    Camera = Workspace.CurrentCamera

    local now = tick()
    local deltaTime = now - lastFrameTime
    lastFrameTime = now

    -- Silah tipi güncelle
    currentWeaponType = detectWeaponType()

    -- Velocity güncelle
    updateAllVelocities()

    -- FOV
    if fovCircle then
        fovCircle.Visible = Settings.Enabled and Settings.FOVEnabled
        fovCircle.Radius = Settings.FOVSize
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    end

    if not Settings.Enabled then
        currentTarget = nil
        lockedTarget = nil
        previousTargetPos = nil
        jitterBuffer = {}
        return
    end

    if not isAiming then
        if not Settings.StickyAim then
            currentTarget = nil
            lockedTarget = nil
            previousTargetPos = nil
            jitterBuffer = {}
        end
        return
    end

    -- Hedef seç
    local newTarget

    if Settings.StickyAim and lockedTarget and isValidTarget(lockedTarget) then
        newTarget = lockedTarget
    else
        newTarget = getBestTarget()
        if Settings.StickyAim and newTarget then
            lockedTarget = newTarget
        end
    end

    -- Hedef değişimi
    if newTarget ~= currentTarget then
        if currentTarget and newTarget then
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

    -- Aim
    if currentTarget then
        local char = currentTarget.Character
        if char then
            local part = getTargetPart(char)
            if part then
                local predicted = arsenalPredict(currentTarget, part.Position)

                -- Hedef geçiş yumuşatma
                if previousTargetPos then
                    local elapsed = tick() - targetSwitchTime
                    if elapsed < 0.15 then
                        local t = easeOutCubic(elapsed / 0.15)
                        predicted = previousTargetPos:Lerp(predicted, t)
                    else
                        previousTargetPos = nil
                    end
                end

                executeAim(predicted, deltaTime)
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
            previousTargetPos = nil
            jitterBuffer = {}
        end
    end
end)

-- Temizlik
Players.PlayerRemoving:Connect(function(player)
    if currentTarget == player then currentTarget = nil; previousTargetPos = nil end
    if lockedTarget == player then lockedTarget = nil end
    velocityData[player.UserId] = nil
end)

-- Arsenal bildirim
if getgenv().VergiHub.Notify then
    getgenv().VergiHub.Notify("Arsenal Aimbot", "v2.0 aktif — " .. currentWeaponType .. " modu", "success", 3)
end

print("[VergiHub] Arsenal Aimbot v2.0 hazir!")
return true
