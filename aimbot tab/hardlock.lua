--[[
    VergiHub - HardLock v1.0
    Farklı lock türleri: Snap, Flick, Rage, Silent
    
    Lock Türleri:
    - SNAP:   Anlık kilitleme, bırakınca serbest
    - FLICK:  Hızlı flick sonrası yavaş takip
    - RAGE:   Her frame tam override, 0 smooth, prediction agresif
    - SILENT: Kamera hareket etmez, sunucuya farklı açı gönderir (exploit gerekir)
    
    Tüm türler başlangıçta kapalı gelir.
]]

local Settings = getgenv().VergiHub.Aimbot

-- Servisler
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- HardLock global ayarları
if not getgenv().VergiHub.HardLock then
    getgenv().VergiHub.HardLock = {
        Enabled = false,           -- HardLock açık/kapalı
        Mode = "Snap",             -- "Snap", "Flick", "Rage", "Silent"
        LockKey = Enum.KeyCode.Q,  -- HardLock tuşu
        TargetPart = "Head",       -- Hedef parça (aimbot'dan bağımsız override)
        OverrideTarget = false,    -- true ise kendi TargetPart'ını kullanır
        AutoFire = false,          -- Rage modda otomatik ateş
        FlickSpeed = 0.08,         -- Flick süresi (saniye)
        FlickReturn = 0.3,         -- Flick sonrası takip hızı
        RagePrediction = 0.2,      -- Rage mod prediction çarpanı
        Indicator = false,         -- Ekranda lock göstergesi
    }
end

local HLSettings = getgenv().VergiHub.HardLock

-- Durum
local hlTarget = nil
local hlActive = false
local lockIndicator = nil
local lockTargetText = nil

-- ==========================================
-- LOCK GÖSTERGESİ (Drawing API)
-- ==========================================

local function createIndicator()
    -- Merkez lock ikonu
    if lockIndicator then pcall(function() lockIndicator:Remove() end) end
    lockIndicator = Drawing.new("Circle")
    lockIndicator.Radius = 6
    lockIndicator.Color = Color3.fromRGB(248, 113, 113)
    lockIndicator.Thickness = 2
    lockIndicator.Filled = false
    lockIndicator.Visible = false

    -- Hedef ismi
    if lockTargetText then pcall(function() lockTargetText:Remove() end) end
    lockTargetText = Drawing.new("Text")
    lockTargetText.Size = 13
    lockTargetText.Center = true
    lockTargetText.Outline = true
    lockTargetText.OutlineColor = Color3.fromRGB(0, 0, 0)
    lockTargetText.Font = Drawing.Fonts.Plex
    lockTargetText.Color = Color3.fromRGB(248, 113, 113)
    lockTargetText.Visible = false
end

createIndicator()

-- ==========================================
-- HEDEF BULMA (Aimbot'dan bağımsız)
-- ==========================================

local function isHLValidTarget(player)
    if player == LocalPlayer then return false end

    local char = player.Character
    if not char then return false end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end

    local partName = HLSettings.OverrideTarget and HLSettings.TargetPart or Settings.TargetPart
    local part = char:FindFirstChild(partName)
    if not part then return false end

    if char:FindFirstChildOfClass("ForceField") then return false end

    -- Takım kontrolü (aimbot ayarından al)
    if Settings.TeamCheck then
        if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
            return false
        end
    end

    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return false end

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

-- Crosshair'e en yakın hedef
local function getHLTarget()
    local best = nil
    local bestDist = Settings.FOVSize

    for _, p in ipairs(Players:GetPlayers()) do
        if isHLValidTarget(p) then
            local char = p.Character
            local partName = HLSettings.OverrideTarget and HLSettings.TargetPart or Settings.TargetPart
            local part = char and char:FindFirstChild(partName)
            if part then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local d = (center - Vector2.new(pos.X, pos.Y)).Magnitude
                    if d < bestDist then
                        bestDist = d
                        best = p
                    end
                end
            end
        end
    end

    return best
end

-- Hedef pozisyon
local function getHLTargetPos(player)
    local char = player.Character
    if not char then return nil end

    local partName = HLSettings.OverrideTarget and HLSettings.TargetPart or Settings.TargetPart
    local part = char:FindFirstChild(partName)
    if not part then return nil end

    local pos = part.Position

    -- Rage modda agresif prediction
    if HLSettings.Mode == "Rage" then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local vel = hrp.AssemblyLinearVelocity
            pos = pos + Vector3.new(vel.X, vel.Y * 0.3, vel.Z) * HLSettings.RagePrediction
        end
    elseif Settings.Prediction then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local vel = hrp.AssemblyLinearVelocity
            pos = pos + Vector3.new(vel.X, 0, vel.Z) * Settings.PredictionAmount
        end
    end

    return pos
end

-- ==========================================
-- LOCK MODLARI
-- ==========================================

-- SNAP: Anlık kamera override
local function lockSnap(targetPos)
    if not targetPos then return end
    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
end

-- FLICK: Hızlı flick + takip
local flickPhase = "idle" -- "idle", "flick", "track"
local flickStartTime = 0

local function lockFlick(targetPos)
    if not targetPos then return end

    if flickPhase == "idle" then
        -- İlk frame: hızlı flick başlat
        flickPhase = "flick"
        flickStartTime = tick()
    end

    local elapsed = tick() - flickStartTime
    local camPos = Camera.CFrame.Position
    local targetCF = CFrame.lookAt(camPos, targetPos)

    if flickPhase == "flick" then
        -- Flick aşaması: çok hızlı interpolasyon
        local flickAlpha = math.clamp(elapsed / HLSettings.FlickSpeed, 0, 1)
        -- Ease out cubic
        flickAlpha = 1 - (1 - flickAlpha) ^ 3
        Camera.CFrame = Camera.CFrame:Lerp(targetCF, flickAlpha)

        if flickAlpha >= 0.98 then
            flickPhase = "track"
        end
    elseif flickPhase == "track" then
        -- Takip aşaması: yumuşak izleme
        Camera.CFrame = Camera.CFrame:Lerp(targetCF, HLSettings.FlickReturn)
    end
end

-- RAGE: Her frame tam override, sıfır tolerans
local function lockRage(targetPos)
    if not targetPos then return end
    -- Her frame direkt üzerine otur
    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
end

-- SILENT: Kamera değişmez, sadece sunucuya farklı açı
-- Not: Bu mod exploit seviyesi gerektirir (hookfunction, namecall hook)
local silentTargetPos = nil

local function lockSilent(targetPos)
    -- Kameraya dokunma, sadece hedefi kaydet
    silentTargetPos = targetPos
end

-- Silent aim hook (namecall)
local function setupSilentHook()
    if not HLSettings.Enabled or HLSettings.Mode ~= "Silent" then return end

    -- Eski hook varsa kaldır
    if getgenv().VergiHub_SilentHookActive then return end

    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        local args = {...}

        -- Mouse.Hit override (bazı oyunlar bunu kullanır)
        if method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay" then
            if silentTargetPos and hlActive and HLSettings.Mode == "Silent" then
                -- Ray'i hedefe yönlendir
                local origin = Camera.CFrame.Position
                local dir = (silentTargetPos - origin).Unit * 1000
                args[1] = Ray.new(origin, dir)
                return oldNamecall(self, unpack(args))
            end
        end

        return oldNamecall(self, ...)
    end))

    getgenv().VergiHub_SilentHookActive = true
end

-- ==========================================
-- ANA HARDLOCK DÖNGÜSÜ
-- ==========================================

RunService.RenderStepped:Connect(function()
    Camera = workspace.CurrentCamera

    -- Kapalıysa temizle
    if not HLSettings.Enabled then
        hlTarget = nil
        hlActive = false
        flickPhase = "idle"
        silentTargetPos = nil
        if lockIndicator then lockIndicator.Visible = false end
        if lockTargetText then lockTargetText.Visible = false end
        return
    end

    -- Tuş basılı değilse
    if not hlActive then
        flickPhase = "idle"
        silentTargetPos = nil
        if lockIndicator then lockIndicator.Visible = false end
        if lockTargetText then lockTargetText.Visible = false end
        return
    end

    -- Hedef seç (ilk basışta kilitlenir, bırakana kadar tutar)
    if not hlTarget or not isHLValidTarget(hlTarget) then
        hlTarget = getHLTarget()
        flickPhase = "idle" -- Yeni hedef, flick sıfırla
    end

    if not hlTarget then
        if lockIndicator then lockIndicator.Visible = false end
        if lockTargetText then lockTargetText.Visible = false end
        return
    end

    local targetPos = getHLTargetPos(hlTarget)
    if not targetPos then return end

    -- Seçili moda göre lock uygula
    local mode = HLSettings.Mode

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
    if HLSettings.Indicator then
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
        if onScreen then
            lockIndicator.Position = Vector2.new(screenPos.X, screenPos.Y)
            lockIndicator.Visible = true
            lockIndicator.Color = (mode == "Rage") and Color3.fromRGB(255, 50, 50) or
                                  (mode == "Silent") and Color3.fromRGB(50, 200, 255) or
                                  (mode == "Flick") and Color3.fromRGB(255, 180, 50) or
                                  Color3.fromRGB(248, 113, 113)

            lockTargetText.Position = Vector2.new(screenPos.X, screenPos.Y - 18)
            lockTargetText.Text = hlTarget.DisplayName .. " [" .. mode .. "]"
            lockTargetText.Color = lockIndicator.Color
            lockTargetText.Visible = true
        else
            lockIndicator.Visible = false
            lockTargetText.Visible = false
        end
    end

    -- Rage Auto Fire
    if mode == "Rage" and HLSettings.AutoFire then
        local partName = HLSettings.OverrideTarget and HLSettings.TargetPart or Settings.TargetPart
        local part = hlTarget.Character and hlTarget.Character:FindFirstChild(partName)
        if part then
            local sp, os = Camera:WorldToViewportPoint(part.Position)
            if os then
                local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local dist = (center - Vector2.new(sp.X, sp.Y)).Magnitude
                -- Crosshair hedefe 5px yakınsa ateşle
                if dist < 5 then
                    mouse1click()
                end
            end
        end
    end
end)

-- ==========================================
-- TUŞLAR
-- ==========================================

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if not HLSettings.Enabled then return end

    if input.KeyCode == HLSettings.LockKey then
        hlActive = true
        -- Yeni lock başlangıcında hedef bul
        hlTarget = getHLTarget()
        flickPhase = "idle"

        -- Silent hook kur
        if HLSettings.Mode == "Silent" then
            pcall(setupSilentHook)
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == HLSettings.LockKey then
        hlActive = false
        hlTarget = nil
        flickPhase = "idle"
        silentTargetPos = nil
    end
end)

-- Oyuncu ayrılma
Players.PlayerRemoving:Connect(function(player)
    if hlTarget == player then
        hlTarget = nil
        flickPhase = "idle"
    end
end)

print("[VergiHub] HardLock v1.0 hazir!")
return true
