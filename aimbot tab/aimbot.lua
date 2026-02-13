--[[
    VergiHub - Aimbot Engine v2.1
    Düzeltme: Tam lock sistemi - crosshair hedefe tam oturur
    CFrame dominant yaklaşım, mousemoverel sadece destek
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

-- FOV dairesi
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

-- Geçerli hedef kontrolü
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

-- FOV mesafesi (ekran piksel)
local function getFOVDistance(player)
    local char = player.Character
    if not char then return math.huge end

    local part = char:FindFirstChild(Settings.TargetPart)
    if not part then return math.huge end

    local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
    if not onScreen then return math.huge end

    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    return (center - Vector2.new(pos.X, pos.Y)).Magnitude
end

-- En yakın hedef
local function getClosestTarget()
    local best = nil
    local bestDist = Settings.FOVSize

    for _, p in ipairs(Players:GetPlayers()) do
        if isValidTarget(p) then
            local d = getFOVDistance(p)
            if d < bestDist then
                bestDist = d
                best = p
            end
        end
    end

    return best
end

-- Hedef pozisyon (prediction dahil)
local function getTargetPosition(player)
    local char = player.Character
    if not char then return nil end

    local part = char:FindFirstChild(Settings.TargetPart)
    if not part then return nil end

    local pos = part.Position

    if Settings.Prediction then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local vel = hrp.AssemblyLinearVelocity
            -- Sadece yatay velocity kullan (daha isabetli)
            pos = pos + Vector3.new(vel.X, 0, vel.Z) * Settings.PredictionAmount
        end
    end

    return pos
end

-- =============================================
-- ANA AIM FONKSİYONU - TAM LOCK
-- =============================================
--[[
    Smoothness değerine göre 3 mod:
    1 = Instant snap (CFrame direkt override)
    2-4 = Hızlı lock (CFrame lerp yüksek alpha)
    5+ = Yumuşak geçiş (CFrame lerp düşük alpha)
    
    Eski sorun: mousemoverel integer yuvarlama yüzünden 
    küçük açılarda hedefe ulaşamıyordu.
    Çözüm: Her durumda CFrame kullan, mousemoverel kaldırıldı.
]]

local function aimAtTarget(targetPos)
    if not targetPos then return end

    Camera = workspace.CurrentCamera
    local camPos = Camera.CFrame.Position
    local smooth = math.clamp(Settings.Smoothness, 1, 20)

    -- Hedef CFrame hesapla
    local targetCF = CFrame.lookAt(camPos, targetPos)

    if smooth <= 1 then
        -- SNAP: Anlık kilitleme, sıfır gecikme
        Camera.CFrame = targetCF
    else
        -- LERP: Alpha değeri smoothness'a ters orantılı
        -- smooth=2 -> alpha=0.65 (çok hızlı lock)
        -- smooth=5 -> alpha=0.35 (orta)
        -- smooth=10 -> alpha=0.18 (yavaş geçiş)
        -- smooth=20 -> alpha=0.09 (çok yavaş)
        local alpha = 1.3 / smooth
        alpha = math.clamp(alpha, 0.05, 0.85)

        Camera.CFrame = Camera.CFrame:Lerp(targetCF, alpha)
    end
end

-- Ana döngü
RunService.RenderStepped:Connect(function()
    Camera = workspace.CurrentCamera

    -- FOV dairesi
    if fovCircle then
        fovCircle.Visible = Settings.Enabled and Settings.FOVEnabled
        fovCircle.Radius = Settings.FOVSize
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    end

    if not Settings.Enabled then
        currentTarget = nil
        lockedTarget = nil
        return
    end

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
        currentTarget = getClosestTarget()
        if Settings.StickyAim and currentTarget then
            lockedTarget = currentTarget
        end
    end

    -- Aim uygula
    if currentTarget then
        local pos = getTargetPosition(currentTarget)
        aimAtTarget(pos)
    end
end)

-- Tuş girdileri
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

Players.PlayerRemoving:Connect(function(player)
    if currentTarget == player then currentTarget = nil end
    if lockedTarget == player then lockedTarget = nil end
end)

print("[VergiHub] Aimbot Engine v2.1 hazir!")
return true
