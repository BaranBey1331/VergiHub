--[[
    VergiHub - HardLock v2.0
    
    Düzeltmeler:
    - Flick artık anlık + takip fazı düzgün çalışıyor
    - Snap gerçekten her frame tam lock
    - Rage mode agresif, sıfır tolerans
    - Silent mode düzgün hook sistemi
    - Indicator düzgün pozisyonlanıyor
    
    Lock Modları:
    - SNAP:   Her frame CFrame override, tuş basılıyken tam lock
    - FLICK:  İlk frame hızlı snap, sonra smooth takip
    - RAGE:   Snap + agresif prediction + auto fire
    - SILENT: Kameraya dokunmaz, namecall hook ile sunucuya aim gönderir
]]

local Settings = getgenv().VergiHub.Aimbot
local HLSettings = getgenv().VergiHub.HardLock

-- Servisler
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Durum
local hlTarget = nil
local hlActive = false
local flickLocked = false    -- Flick ilk snap yapıldı mı
local flickLockTime = 0      -- Flick başlangıç zamanı

-- ==========================================
-- GÖSTERGE (Drawing API)
-- ==========================================

local lockCircle = nil
local lockText = nil
local lockLine = nil

local function createIndicators()
    -- Hedef etrafı daire
    pcall(function()
        if lockCircle then lockCircle:Remove() end
        if lockText then lockText:Remove() end
        if lockLine then lockLine:Remove() end
    end)

    lockCircle = Drawing.new("Circle")
    lockCircle.Radius = 12
    lockCircle.Thickness = 2
    lockCircle.Filled = false
    lockCircle.Visible = false

    lockText = Drawing.new("Text")
    lockText.Size = 12
    lockText.Center = true
    lockText.Outline = true
    lockText.OutlineColor = Color3.fromRGB(0, 0, 0)
    lockText.Font = Drawing.Fonts.Plex
    lockText.Visible = false

    lockLine = Drawing.new("Line")
    lockLine.Thickness = 1
    lockLine.Visible = false
end

createIndicators()

-- Renk tablosu
local MODE_COLORS = {
    Snap   = Color3.fromRGB(52, 211, 153),   -- Yeşil
    Flick  = Color3.fromRGB(251, 191, 36),    -- Sarı
    Rage   = Color3.fromRGB(248, 113, 113),   -- Kırmızı
    Silent = Color3.fromRGB(96, 165, 250),    -- Mavi
}

-- ==========================================
-- HEDEF SİSTEMİ
-- ==========================================

local function isHLValid(player)
    if player == LocalPlayer then return false end

    local char = player.Character
    if not char then return false end

    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end

    local partName = HLSettings.OverrideTarget and HLSettings.TargetPart or Settings.TargetPart
    local part = char:FindFirstChild(partName)
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
        local dir = (part.Position - origin)
        local result = workspace:Raycast(origin, dir, params)

        if result and not result.Instance:IsDescendantOf(char) then
            return false
        end
    end

    return true
end

local function getHLTarget()
    local best = nil
    local bestDist = Settings.FOVSize
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, p in ipairs(Players:GetPlayers()) do
        if isHLValid(p) then
            local char = p.Character
            local partName = HLSettings.OverrideTarget and HLSettings.TargetPart or Settings.TargetPart
            local part = char and char:FindFirstChild(partName)
            if part then
                local sp, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local d = (center - Vector2.new(sp.X, sp.Y)).Magnitude
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

-- Hedef pozisyon (mode'a göre prediction)
local function getHLPos(player)
    local char = player.Character
    if not char then return nil end

    local partName = HLSettings.OverrideTarget and HLSettings.TargetPart or Settings.TargetPart
    local part = char:FindFirstChild(partName)
    if not part then return nil end

    local pos = part.Position
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return pos end

    local vel = hrp.AssemblyLinearVelocity
    local mode = HLSettings.Mode

    if mode == "Rage" then
        -- Agresif prediction: tam velocity + dikey
        local predAmount = HLSettings.RagePrediction
        pos = pos + vel * predAmount
    elseif mode == "Flick" then
        -- Orta prediction
        if Settings.Prediction then
            pos = pos + Vector3.new(vel.X, 0, vel.Z) * Settings.PredictionAmount
        end
    elseif mode == "Snap" then
        -- Hafif prediction
        if Settings.Prediction then
            pos = pos + Vector3.new(vel.X, 0, vel.Z) * Settings.PredictionAmount * 0.8
        end
    elseif mode == "Silent" then
        -- Tam prediction
        if Settings.Prediction then
            pos = pos + Vector3.new(vel.X, vel.Y * 0.3, vel.Z) * Settings.PredictionAmount
        end
    end

    return pos
end

-- ==========================================
-- LOCK MODLARI
-- ==========================================

-- SNAP: Her frame tam CFrame override
local function lockSnap(targetPos)
    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
end

-- FLICK: İlk frame anlık snap, sonra smooth tracking
local function lockFlick(targetPos)
    if not flickLocked then
        -- İlk frame: ANLIK SNAP (gerçek flick)
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
        flickLocked = true
        flickLockTime = tick()
        return
    end

    -- Sonraki frameler: smooth takip
    local elapsed = tick() - flickLockTime
    local returnSpeed = HLSettings.FlickReturn

    -- İlk 0.1s tam lock, sonra smooth geçiş
    if elapsed < 0.1 then
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
    else
        -- Smooth tracking (returnSpeed: 0.1 = yavaş, 0.8 = hızlı)
        local targetCF = CFrame.lookAt(Camera.CFrame.Position, targetPos)
        Camera.CFrame = Camera.CFrame:Lerp(targetCF, returnSpeed)
    end
end

-- RAGE: Tam override + auto fire
local function lockRage(targetPos)
    -- Her frame tam override, sıfır smooth
    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
end

-- SILENT: Kameraya dokunma
local silentTargetPos = nil

local function lockSilent(targetPos)
    silentTargetPos = targetPos
    -- Kamera değişmez
end

-- Silent hook (bir kez kurulur)
local silentHookInstalled = false

local function installSilentHook()
    if silentHookInstalled then return end
    if not hookmetamethod then return end

    pcall(function()
        local mt = getrawmetatable(game)
        local oldReadonly = isreadonly(mt)
        setreadonly(mt, false)

        local oldNamecall = mt.__namecall
        mt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()

            if silentTargetPos and hlActive and HLSettings.Mode == "Silent" then
                if method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay" then
                    local args = {...}
                    local origin = Camera.CFrame.Position
                    local dir = (silentTargetPos - origin).Unit * 1000
                    args[1] = Ray.new(origin, dir)
                    return oldNamecall(self, unpack(args))
                end
            end

            return oldNamecall(self, ...)
        end)

        setreadonly(mt, oldReadonly)
        silentHookInstalled = true
    end)
end

-- ==========================================
-- ANA HARDLOCK DÖNGÜSÜ
-- ==========================================

RunService.RenderStepped:Connect(function()
    Camera = workspace.CurrentCamera
    local mode = HLSettings.Mode
    local modeColor = MODE_COLORS[mode] or MODE_COLORS.Snap

    -- Kapalıysa temizle
    if not HLSettings.Enabled or not hlActive then
        if not hlActive then
            hlTarget = nil
            flickLocked = false
            silentTargetPos = nil
        end
        if lockCircle then lockCircle.Visible = false end
        if lockText then lockText.Visible = false end
        if lockLine then lockLine.Visible = false end
        return
    end

    -- Hedef seç (ilk basışta kilitlenir)
    if not hlTarget or not isHLValid(hlTarget) then
        hlTarget = getHLTarget()
        flickLocked = false -- Yeni hedef, flick sıfırla
    end

    -- Hedef yoksa göstergeleri gizle
    if not hlTarget then
        if lockCircle then lockCircle.Visible = false end
        if lockText then lockText.Visible = false end
        if lockLine then lockLine.Visible = false end
        return
    end

    -- Hedef pozisyon hesapla
    local targetPos = getHLPos(hlTarget)
    if not targetPos then return end

    -- Seçili moda göre lock uygula
    if mode == "Snap" then
        lockSnap(targetPos)
    elseif mode == "Flick" then
        lockFlick(targetPos)
    elseif mode == "Rage" then
        lockRage(targetPos)
    elseif mode == "Silent" then
        lockSilent(targetPos)
    end

    -- Rage auto fire
    if mode == "Rage" and HLSettings.AutoFire then
        local partName = HLSettings.OverrideTarget and HLSettings.TargetPart or Settings.TargetPart
        local part = hlTarget.Character and hlTarget.Character:FindFirstChild(partName)
        if part then
            local sp, os = Camera:WorldToViewportPoint(part.Position)
            if os then
                local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local dist = (center - Vector2.new(sp.X, sp.Y)).Magnitude
                if dist < 8 then
                    mouse1click()
                end
            end
        end
    end

    -- Gösterge güncelle
    if HLSettings.Indicator then
        local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)

        if onScreen then
            -- Lock dairesi
            lockCircle.Position = Vector2.new(screenPos.X, screenPos.Y)
            lockCircle.Color = modeColor
            lockCircle.Visible = true

            -- Hedef ismi + mod
            lockText.Position = Vector2.new(screenPos.X, screenPos.Y - 22)
            lockText.Text = hlTarget.DisplayName .. " [" .. mode .. "]"
            lockText.Color = modeColor
            lockText.Visible = true

            -- Crosshair'den hedefe çizgi
            local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            lockLine.From = center
            lockLine.To = Vector2.new(screenPos.X, screenPos.Y)
            lockLine.Color = modeColor
            lockLine.Transparency = 0.5
            lockLine.Visible = true
        else
            lockCircle.Visible = false
            lockText.Visible = false
            lockLine.Visible = false
        end
    else
        if lockCircle then lockCircle.Visible = false end
        if lockText then lockText.Visible = false end
        if lockLine then lockLine.Visible = false end
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
        hlTarget = getHLTarget()
        flickLocked = false

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
        flickLocked = false
        silentTargetPos = nil
    end
end)

-- Oyuncu ayrılma
Players.PlayerRemoving:Connect(function(player)
    if hlTarget == player then
        hlTarget = nil
        flickLocked = false
    end
end)

print("[VergiHub] HardLock v2.0 hazir!")
return true
