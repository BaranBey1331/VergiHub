--[[
    VergiHub - HardLock v3.0
    Tam yeniden yazım - Production Grade
    
    Lock Modları:
    - SNAP:   Her frame CFrame.lookAt override, sıfır tolerance
    - FLICK:  İlk frame anlık snap + sonrasinda takip
    - RAGE:   CFrame override + agresif prediction + auto fire + anti-anim
    - SILENT: Kamera değişmez, namecall/raycast hook ile sunucuya aim
    
    Özellikler:
    - FPS-bağımsız hesaplama
    - Gelişmiş flick: ease curve, multi-phase
    - Rage: ölüm kontrolü, auto fire timing, multi-part targeting
    - Silent: gelişmiş hook sistemi, çoklu method desteği
    - Indicator: hedef bilgisi, mesafe, can
    - Hedef hafıza: son hedefi hatırla, geçiş yumuşatma
]]

local Settings = getgenv().VergiHub.Aimbot
local HLSettings = getgenv().VergiHub.HardLock

-- Servisler
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local Camera = Workspace.CurrentCamera

-- ==========================================
-- SABİTLER
-- ==========================================

local FLICK_LOCK_DURATION = 0.12   -- Flick sonrası tam lock süresi (sn)
local RAGE_FIRE_COOLDOWN = 0.05    -- Auto fire aralığı (sn)
local RAGE_FIRE_THRESHOLD = 6      -- Auto fire piksel eşiği
local TARGET_MEMORY_DURATION = 0.5  -- Hedef kayıp sonrası hafıza süresi
local INDICATOR_UPDATE_RATE = 2     -- İndicator güncelleme (her N frame)

-- ==========================================
-- DURUM
-- ==========================================

local hlTarget = nil
local hlActive = false
local hlPreviousTarget = nil
local hlTargetLostTime = 0

-- Flick state
local flickState = "idle"   -- "idle" | "snap" | "locked" | "track"
local flickStartTime = 0
local flickSnapCF = nil

-- Rage state
local rageLastFireTime = 0
local rageKillCount = 0

-- Silent state
local silentTargetPos = nil
local silentHookInstalled = false

-- Indicator
local indicatorFrame = 0

-- Drawing objeler
local lockCircle = nil
local lockCircleOuter = nil
local lockText = nil
local lockLine = nil
local lockHealthBar = nil
local lockHealthFill = nil

-- ==========================================
-- RENK TABLOSU
-- ==========================================

local MODE_COLORS = {
    Snap   = Color3.fromRGB(60, 220, 160),
    Flick  = Color3.fromRGB(255, 200, 60),
    Rage   = Color3.fromRGB(255, 70, 70),
    Silent = Color3.fromRGB(80, 180, 255),
}

-- ==========================================
-- YARDIMCI MATEMATIK
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

local function easeOutBack(t)
    t = clamp(t, 0, 1)
    local c1 = 1.70158
    local c3 = c1 + 1
    return 1 + c3 * (t - 1) ^ 3 + c1 * (t - 1) ^ 2
end

-- ==========================================
-- GÖSTERGE SİSTEMİ (Drawing API)
-- ==========================================

local function createIndicators()
    pcall(function()
        if lockCircle then lockCircle:Remove() end
        if lockCircleOuter then lockCircleOuter:Remove() end
        if lockText then lockText:Remove() end
        if lockLine then lockLine:Remove() end
        if lockHealthBar then lockHealthBar:Remove() end
        if lockHealthFill then lockHealthFill:Remove() end
    end)

    -- İç daire (hedef üstü)
    lockCircle = Drawing.new("Circle")
    lockCircle.Radius = 8
    lockCircle.Thickness = 2
    lockCircle.Filled = false
    lockCircle.NumSides = 32
    lockCircle.Visible = false

    -- Dış daire (dönen animasyon efekti)
    lockCircleOuter = Drawing.new("Circle")
    lockCircleOuter.Radius = 16
    lockCircleOuter.Thickness = 1
    lockCircleOuter.Filled = false
    lockCircleOuter.NumSides = 6  -- Altıgen
    lockCircleOuter.Visible = false

    -- Hedef ismi + mod
    lockText = Drawing.new("Text")
    lockText.Size = 13
    lockText.Center = true
    lockText.Outline = true
    lockText.OutlineColor = Color3.fromRGB(0, 0, 0)
    lockText.Font = Drawing.Fonts.Plex
    lockText.Visible = false

    -- Crosshair -> hedef çizgisi
    lockLine = Drawing.new("Line")
    lockLine.Thickness = 1
    lockLine.Visible = false

    -- Can barı arka plan
    lockHealthBar = Drawing.new("Line")
    lockHealthBar.Thickness = 3
    lockHealthBar.Color = Color3.fromRGB(40, 40, 40)
    lockHealthBar.Visible = false

    -- Can barı dolgu
    lockHealthFill = Drawing.new("Line")
    lockHealthFill.Thickness = 3
    lockHealthFill.Visible = false
end

createIndicators()

local function hideIndicators()
    if lockCircle then lockCircle.Visible = false end
    if lockCircleOuter then lockCircleOuter.Visible = false end
    if lockText then lockText.Visible = false end
    if lockLine then lockLine.Visible = false end
    if lockHealthBar then lockHealthBar.Visible = false end
    if lockHealthFill then lockHealthFill.Visible = false end
end

local function updateIndicators(targetPos, mode, target)
    if not HLSettings.Indicator then
        hideIndicators()
        return
    end

    indicatorFrame = indicatorFrame + 1

    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
    if not onScreen then
        hideIndicators()
        return
    end

    local sx, sy = screenPos.X, screenPos.Y
    local color = MODE_COLORS[mode] or MODE_COLORS.Snap
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    -- İç daire
    lockCircle.Position = Vector2.new(sx, sy)
    lockCircle.Color = color
    lockCircle.Visible = true

    -- Dış daire (yavaş dönüş animasyonu)
    lockCircleOuter.Position = Vector2.new(sx, sy)
    lockCircleOuter.Color = color
    lockCircleOuter.Transparency = 0.5
    lockCircleOuter.Visible = true

    -- İsim + mod + mesafe
    local char = target.Character
    local myChar = LocalPlayer.Character

    local distText = ""
    if char and myChar then
        local hrp1 = myChar:FindFirstChild("HumanoidRootPart")
        local hrp2 = char:FindFirstChild("HumanoidRootPart")
        if hrp1 and hrp2 then
            distText = " [" .. math.floor((hrp1.Position - hrp2.Position).Magnitude) .. "m]"
        end
    end

    lockText.Position = Vector2.new(sx, sy - 26)
    lockText.Text = target.DisplayName .. " [" .. mode .. "]" .. distText
    lockText.Color = color
    lockText.Visible = true

    -- Crosshair çizgisi
    lockLine.From = center
    lockLine.To = Vector2.new(sx, sy)
    lockLine.Color = color
    lockLine.Transparency = 0.6
    lockLine.Visible = true

    -- Can barı
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local healthPct = clamp(hum.Health / hum.MaxHealth, 0, 1)
            local barWidth = 40
            local barX = sx - barWidth / 2
            local barY = sy + 16

            lockHealthBar.From = Vector2.new(barX, barY)
            lockHealthBar.To = Vector2.new(barX + barWidth, barY)
            lockHealthBar.Visible = true

            -- Can rengi (yeşil -> sarı -> kırmızı)
            local healthColor
            if healthPct > 0.6 then
                healthColor = Color3.fromRGB(60, 220, 100)
            elseif healthPct > 0.3 then
                healthColor = Color3.fromRGB(255, 200, 60)
            else
                healthColor = Color3.fromRGB(255, 70, 70)
            end

            lockHealthFill.From = Vector2.new(barX, barY)
            lockHealthFill.To = Vector2.new(barX + barWidth * healthPct, barY)
            lockHealthFill.Color = healthColor
            lockHealthFill.Visible = true
        end
    end
end

-- ==========================================
-- HEDEF SİSTEMİ
-- ==========================================

local function getTargetPartName()
    if HLSettings.OverrideTarget then
        return HLSettings.TargetPart
    end
    return Settings.TargetPart
end

local function getHLPart(char)
    local partName = getTargetPartName()
    local part = char:FindFirstChild(partName)

    if not part then
        local fallbacks = {"Head", "HumanoidRootPart", "UpperTorso", "Torso"}
        for _, fb in ipairs(fallbacks) do
            part = char:FindFirstChild(fb)
            if part then break end
        end
    end

    return part
end

local function isHLValid(player)
    if player == LocalPlayer then return false end

    local char = player.Character
    if not char then return false end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end

    local part = getHLPart(char)
    if not part then return false end

    if char:FindFirstChildOfClass("ForceField") then return false end

    if Settings.TeamCheck then
        if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
            return false
        end
    end

    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return false end

    local dist = (myChar.HumanoidRootPart.Position - part.Position).Magnitude
    if dist > Settings.MaxDistance then return false end

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

-- Crosshair'e en yakın hedef (skor bazlı)
local function findHLTarget()
    local best = nil
    local bestScore = math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if isHLValid(player) then
            local char = player.Character
            local part = getHLPart(char)

            if part then
                local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local fovDist = dist2D(center, Vector2.new(sp.X, sp.Y))

                    if fovDist < Settings.FOVSize then
                        -- Skor: FOV mesafesi + 3D mesafe ağırlıklı
                        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        local worldDist = myHRP and (myHRP.Position - part.Position).Magnitude or 0

                        local score = fovDist * 0.7 + (worldDist / 10) * 0.3

                        if score < bestScore then
                            bestScore = score
                            best = player
                        end
                    end
                end
            end
        end
    end

    return best
end

-- Hedef pozisyon (mod bazlı prediction)
local function getHLTargetPos(player)
    local char = player.Character
    if not char then return nil end

    local part = getHLPart(char)
    if not part then return nil end

    local pos = part.Position
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return pos end

    local vel = hrp.AssemblyLinearVelocity
    local mode = HLSettings.Mode

    if mode == "Rage" then
        -- Agresif: tam velocity (Y dahil) + yüksek çarpan
        local predAmount = HLSettings.RagePrediction
        pos = pos + vel * predAmount

    elseif mode == "Flick" then
        -- Orta prediction
        if Settings.Prediction then
            local predAmount = Settings.PredictionAmount
            pos = pos + Vector3.new(vel.X, 0, vel.Z) * predAmount
        end

    elseif mode == "Snap" then
        -- Hafif prediction
        if Settings.Prediction then
            pos = pos + Vector3.new(vel.X, 0, vel.Z) * Settings.PredictionAmount * 0.75
        end

    elseif mode == "Silent" then
        -- Tam prediction
        if Settings.Prediction then
            pos = pos + Vector3.new(vel.X, vel.Y * 0.4, vel.Z) * Settings.PredictionAmount
        end
    end

    return pos
end

-- ==========================================
-- LOCK MODLARI
-- ==========================================

-- === SNAP ===
-- Her frame CFrame.lookAt, sıfır tolerans
local function lockSnap(targetPos)
    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
end

-- === FLICK ===
-- Çok fazlı: snap -> lock -> track
local function lockFlick(targetPos)
    local now = tick()

    if flickState == "idle" then
        -- FAZ 1: Anlık snap (ilk frame)
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
        flickState = "locked"
        flickStartTime = now
        flickSnapCF = Camera.CFrame
        return
    end

    local elapsed = now - flickStartTime

    if flickState == "locked" then
        -- FAZ 2: Tam lock (FLICK_LOCK_DURATION boyunca)
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)

        if elapsed >= FLICK_LOCK_DURATION then
            flickState = "track"
        end
        return
    end

    if flickState == "track" then
        -- FAZ 3: Yumuşak takip
        local returnSpeed = clamp(HLSettings.FlickReturn, 0.05, 0.9)
        local trackElapsed = elapsed - FLICK_LOCK_DURATION

        -- İlk birkaç frame hızlı, sonra yavaşla
        local trackAlpha = returnSpeed
        if trackElapsed < 0.15 then
            trackAlpha = clamp(returnSpeed * 1.8, 0.3, 0.95)
        end

        local targetCF = CFrame.lookAt(Camera.CFrame.Position, targetPos)
        Camera.CFrame = Camera.CFrame:Lerp(targetCF, trackAlpha)
    end
end

-- === RAGE ===
-- Tam override + agresif + auto fire
local function lockRage(targetPos)
    -- Her frame tam CFrame override
    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)

    -- Auto fire
    if HLSettings.AutoFire and hlTarget then
        local now = tick()
        if now - rageLastFireTime < RAGE_FIRE_COOLDOWN then return end

        local char = hlTarget.Character
        if not char then return end

        local part = getHLPart(char)
        if not part then return end

        local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
        if not onScreen then return end

        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local pixelDist = dist2D(center, Vector2.new(sp.X, sp.Y))

        if pixelDist < RAGE_FIRE_THRESHOLD then
            mouse1click()
            rageLastFireTime = now
        end
    end
end

-- === SILENT ===
-- Kameraya dokunma, hook ile sunucuya farklı açı
local silentActive = false

local function lockSilent(targetPos)
    silentTargetPos = targetPos
    silentActive = true
    -- Kamera değişmez
end

-- Silent hook kurulumu (bir kez)
local function installSilentHook()
    if silentHookInstalled then return end
    if not hookmetamethod then
        warn("[HardLock] Silent mode: hookmetamethod bulunamadi")
        return
    end

    local success = pcall(function()
        local mt = getrawmetatable(game)
        local wasReadonly = isreadonly(mt)

        if wasReadonly then
            setreadonly(mt, false)
        end

        local originalNamecall = mt.__namecall

        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()

            if silentActive and silentTargetPos and hlActive then
                -- FindPartOnRay hook
                if method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" then
                    local args = {...}
                    local origin = Camera.CFrame.Position
                    local dir = (silentTargetPos - origin).Unit * 1000
                    args[1] = Ray.new(origin, dir)
                    return originalNamecall(self, unpack(args))
                end

                -- Raycast hook
                if method == "Raycast" and self == Workspace then
                    local args = {...}
                    local origin = Camera.CFrame.Position
                    local dir = (silentTargetPos - origin).Unit * 1000
                    args[1] = origin
                    args[2] = dir
                    return originalNamecall(self, unpack(args))
                end
            end

            return originalNamecall(self, ...)
        end)

        if wasReadonly then
            setreadonly(mt, true)
        end
    end)

    if success then
        silentHookInstalled = true
        print("[HardLock] Silent hook kuruldu")
    else
        warn("[HardLock] Silent hook kurulamadi")
    end
end

-- ==========================================
-- ANA DÖNGÜ
-- ==========================================

local lastHLFrame = tick()

RunService.RenderStepped:Connect(function(dt)
    Camera = Workspace.CurrentCamera
    local now = tick()
    local deltaTime = now - lastHLFrame
    lastHLFrame = now

    local mode = HLSettings.Mode

    -- Kapalı veya aktif değilse
    if not HLSettings.Enabled or not hlActive then
        if not hlActive then
            -- Lock bırakıldı
            hlTarget = nil
            flickState = "idle"
            silentTargetPos = nil
            silentActive = false
        end
        hideIndicators()
        return
    end

    -- Hedef seç
    if not hlTarget or not isHLValid(hlTarget) then
        -- Hedef kayboldu, hafıza süresi kontrol et
        if hlTarget and not isHLValid(hlTarget) then
            if hlTargetLostTime == 0 then
                hlTargetLostTime = now
                hlPreviousTarget = hlTarget
            end

            -- Hafıza süresi doldu mu?
            if now - hlTargetLostTime > TARGET_MEMORY_DURATION then
                hlTarget = nil
                hlPreviousTarget = nil
                hlTargetLostTime = 0
                flickState = "idle"
            end
        end

        -- Yeni hedef ara
        if not hlTarget or not isHLValid(hlTarget) then
            local newTarget = findHLTarget()

            if newTarget then
                hlTarget = newTarget
                hlTargetLostTime = 0
                flickState = "idle" -- Yeni hedef, flick sıfırla
            else
                hideIndicators()
                return
            end
        end
    else
        hlTargetLostTime = 0
    end

    -- Hedef yoksa çık
    if not hlTarget then
        hideIndicators()
        return
    end

    -- Hedef pozisyon
    local targetPos = getHLTargetPos(hlTarget)
    if not targetPos then
        hideIndicators()
        return
    end

    -- Moda göre lock uygula
    if mode == "Snap" then
        lockSnap(targetPos)

    elseif mode == "Flick" then
        lockFlick(targetPos)

    elseif mode == "Rage" then
        lockRage(targetPos)

    elseif mode == "Silent" then
        lockSilent(targetPos)
    end

    -- Gösterge güncelle
    updateIndicators(targetPos, mode, hlTarget)
end)

-- ==========================================
-- TUŞLAR
-- ==========================================

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if not HLSettings.Enabled then return end

    if input.KeyCode == HLSettings.LockKey then
        hlActive = true
        hlTarget = findHLTarget()
        flickState = "idle"
        hlTargetLostTime = 0

        -- Silent hook kur
        if HLSettings.Mode == "Silent" then
            pcall(installSilentHook)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == HLSettings.LockKey then
        hlActive = false
        hlTarget = nil
        hlPreviousTarget = nil
        hlTargetLostTime = 0
        flickState = "idle"
        silentTargetPos = nil
        silentActive = false
        hideIndicators()
    end
end)

-- ==========================================
-- TEMİZLİK
-- ==========================================

Players.PlayerRemoving:Connect(function(player)
    if hlTarget == player then
        hlTarget = nil
        flickState = "idle"
        hlTargetLostTime = 0
    end
    if hlPreviousTarget == player then
        hlPreviousTarget = nil
    end
end)

print("[VergiHub] HardLock v3.0 hazir!")
return true
