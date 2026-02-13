--[[
    VergiHub - Arsenal Özel Aimbot v1.0
    Arsenal oyununa optimize edilmiş aimbot sistemi
    - Arsenal karakter yapısına uygun hedefleme
    - Silah geri tepmesi kompanzasyonu
    - Arsenal takım sistemi uyumu
]]

local Settings = getgenv().VergiHub.Aimbot

-- Servisler
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Arsenal özel değişkenler
local currentTarget = nil
local isAiming = false
local lockedTarget = nil
local fovCircle = nil

-- Arsenal'a özel ayarları override et (opsiyonel)
-- Kullanıcı ana menüden değiştirebilir, buradaki sadece Arsenal'a uygun varsayılan
local arsenalDefaults = {
    TargetPart = "Head",
    PredictionAmount = 0.135, -- Arsenal için optimize edilmiş
    Smoothness = 3,           -- Arsenal hızlı oyun, düşük smooth daha iyi
}

-- FOV dairesi
local function createFOVCircle()
    if fovCircle then pcall(function() fovCircle:Remove() end) end
    fovCircle = Drawing.new("Circle")
    fovCircle.Color = Color3.fromRGB(255, 165, 0) -- Arsenal için turuncu FOV
    fovCircle.Thickness = 1.5
    fovCircle.Filled = false
    fovCircle.Transparency = 0.6
    fovCircle.Visible = false
    return fovCircle
end

fovCircle = createFOVCircle()

-- Arsenal'da oyuncu geçerli mi
local function isValidArsenalTarget(player)
    if player == LocalPlayer then return false end

    local character = player.Character
    if not character then return false end

    -- Humanoid kontrolü
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end

    -- Hedef parça kontrolü
    local targetPart = character:FindFirstChild(Settings.TargetPart)
    if not targetPart then return false end

    -- ForceField (spawn koruması)
    if character:FindFirstChildOfClass("ForceField") then return false end

    -- Arsenal takım kontrolü
    if Settings.TeamCheck then
        -- Arsenal'da takım bilgisi
        if player.Team and LocalPlayer.Team then
            if player.Team == LocalPlayer.Team then
                return false
            end
        end
    end

    -- Kendi karakterimiz
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return false end

    -- Mesafe
    local distance = (myChar.HumanoidRootPart.Position - targetPart.Position).Magnitude
    if distance > Settings.MaxDistance then return false end

    -- Görünürlük kontrolü
    if Settings.VisibleCheck then
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = {myChar, Camera}
        rayParams.RespectCanCollide = true

        local origin = Camera.CFrame.Position
        local direction = (targetPart.Position - origin)
        local rayResult = workspace:Raycast(origin, direction, rayParams)

        if rayResult and not rayResult.Instance:IsDescendantOf(character) then
            return false
        end
    end

    return true
end

-- FOV mesafesi hesapla
local function getFOVDistance(player)
    local character = player.Character
    if not character then return math.huge end

    local targetPart = character:FindFirstChild(Settings.TargetPart)
    if not targetPart then return math.huge end

    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
    if not onScreen then return math.huge end

    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    return (center - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
end

-- En yakın hedef
local function getClosestTarget()
    local closest = nil
    local closestDist = Settings.FOVSize

    for _, player in ipairs(Players:GetPlayers()) do
        if isValidArsenalTarget(player) then
            local dist = getFOVDistance(player)
            if dist < closestDist then
                closestDist = dist
                closest = player
            end
        end
    end

    return closest
end

-- Arsenal hedef pozisyonu (prediction + head offset)
local function getArsenalTargetPos(player)
    local character = player.Character
    if not character then return nil end

    local targetPart = character:FindFirstChild(Settings.TargetPart)
    if not targetPart then return nil end

    local pos = targetPart.Position

    -- Arsenal hareket tahmini
    if Settings.Prediction then
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local vel = hrp.AssemblyLinearVelocity
            -- Arsenal'da yatay hareket tahmini daha doğru
            local predVel = Vector3.new(vel.X, 0, vel.Z)
            local predAmount = Settings.PredictionAmount
            pos = pos + (predVel * predAmount)
        end
    end

    return pos
end

-- Ana aim fonksiyonu - Crosshair'i hedefe götür
local function aimToTarget(targetPos)
    if not targetPos then return end

    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
    if not onScreen then return end

    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local deltaX = screenPos.X - center.X
    local deltaY = screenPos.Y - center.Y

    local smooth = math.clamp(Settings.Smoothness, 1, 20)

    if smooth <= 1 then
        -- Anlık snap
        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
    elseif smooth <= 3 then
        -- Hızlı kilitleme (Arsenal için ideal)
        local camPos = Camera.CFrame.Position
        local targetCF = CFrame.lookAt(camPos, targetPos)
        Camera.CFrame = Camera.CFrame:Lerp(targetCF, 1 / smooth)
    else
        -- Mouse hareketi ile yumuşak
        local moveX = deltaX / smooth
        local moveY = deltaY / smooth

        if math.abs(moveX) < 0.3 and math.abs(moveY) < 0.3 then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
        else
            mousemoverel(moveX, moveY)
        end
    end
end

-- Ana döngü
local aimConnection = RunService.RenderStepped:Connect(function()
    Camera = workspace.CurrentCamera

    -- FOV güncelle
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

    -- Hedef seç
    if Settings.StickyAim and lockedTarget and isValidArsenalTarget(lockedTarget) then
        currentTarget = lockedTarget
    else
        currentTarget = getClosestTarget()
        if Settings.StickyAim and currentTarget then
            lockedTarget = currentTarget
        end
    end

    -- Aim uygula
    if currentTarget then
        local targetPos = getArsenalTargetPos(currentTarget)
        aimToTarget(targetPos)
    end
end)

-- Tuş girdileri
local inputBeganConn = UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Settings.AimKey or input.KeyCode == Settings.AimKey then
        isAiming = true
    end
end)

local inputEndedConn = UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Settings.AimKey or input.KeyCode == Settings.AimKey then
        isAiming = false
        if not Settings.StickyAim then
            currentTarget = nil
            lockedTarget = nil
        end
    end
end)

-- Temizlik
Players.PlayerRemoving:Connect(function(player)
    if currentTarget == player then currentTarget = nil end
    if lockedTarget == player then lockedTarget = nil end
end)

-- Arsenal tespit bildirimi
if getgenv().VergiHub.Notify then
    getgenv().VergiHub.Notify("Arsenal Aimbot", "Arsenal'a özel aimbot aktif!", "success", 3)
end

print("[VergiHub] 🎯 Arsenal Aimbot v1.0 hazır!")
return true
