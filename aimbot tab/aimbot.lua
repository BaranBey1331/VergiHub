--[[
    VergiHub - Aimbot Engine v2.0
    Gelişmiş aimbot - Crosshair'i doğrudan kafaya götürür
    mousemoverel + CFrame hibrit sistem
]]

local Settings = getgenv().VergiHub.Aimbot

-- Servisler
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Durum değişkenleri
local currentTarget = nil
local isAiming = false
local fovCircle = nil
local lockedTarget = nil -- Kilitlenmiş hedef (sticky için)

-- FOV dairesi oluştur
local function createFOVCircle()
    if fovCircle then pcall(function() fovCircle:Remove() end) end
    fovCircle = Drawing.new("Circle")
    fovCircle.Color = Color3.fromRGB(138, 43, 226)
    fovCircle.Thickness = 1.5
    fovCircle.Filled = false
    fovCircle.Transparency = 0.7
    fovCircle.Visible = false
    return fovCircle
end

fovCircle = createFOVCircle()

-- Oyuncu geçerli mi kontrol et
local function isValidTarget(player)
    if player == LocalPlayer then return false end

    local character = player.Character
    if not character then return false end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end

    local targetPart = character:FindFirstChild(Settings.TargetPart)
    if not targetPart then return false end

    -- ForceField kontrolü (spawn koruması)
    if character:FindFirstChildOfClass("ForceField") then return false end

    -- Takım kontrolü
    if Settings.TeamCheck then
        if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
            return false
        end
    end

    -- Kendi karakterimiz var mı
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return false end

    -- Mesafe kontrolü
    local distance = (myChar.HumanoidRootPart.Position - targetPart.Position).Magnitude
    if distance > Settings.MaxDistance then return false end

    -- Görünürlük kontrolü (gelişmiş raycast)
    if Settings.VisibleCheck then
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = {myChar, Camera}
        rayParams.RespectCanCollide = true

        local origin = Camera.CFrame.Position
        local targetPos = targetPart.Position
        local direction = (targetPos - origin)
        local rayResult = workspace:Raycast(origin, direction, rayParams)

        if rayResult then
            -- Raycast bir şeye çarptı, hedef karaktere ait mi kontrol et
            if not rayResult.Instance:IsDescendantOf(character) then
                return false
            end
        end
    end

    return true
end

-- Ekrandaki FOV mesafesini hesapla (mouse pozisyonundan)
local function getFOVDistance(player)
    local character = player.Character
    if not character then return math.huge end

    local targetPart = character:FindFirstChild(Settings.TargetPart)
    if not targetPart then return math.huge end

    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
    if not onScreen then return math.huge end

    -- Ekranın tam ortası (crosshair pozisyonu)
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local targetScreen = Vector2.new(screenPos.X, screenPos.Y)

    return (screenCenter - targetScreen).Magnitude
end

-- En yakın hedefi bul
local function getClosestTarget()
    local closestPlayer = nil
    local closestFOV = Settings.FOVSize

    for _, player in ipairs(Players:GetPlayers()) do
        if isValidTarget(player) then
            local fovDist = getFOVDistance(player)
            if fovDist < closestFOV then
                closestFOV = fovDist
                closestPlayer = player
            end
        end
    end

    return closestPlayer
end

-- Hedef pozisyonunu hesapla (prediction dahil)
local function getTargetPosition(player)
    local character = player.Character
    if not character then return nil end

    local targetPart = character:FindFirstChild(Settings.TargetPart)
    if not targetPart then return nil end

    local targetPos = targetPart.Position

    -- Hareket tahmini
    if Settings.Prediction then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local velocity = rootPart.AssemblyLinearVelocity
            -- Yerçekimi etkisini çıkar (sadece yatay hareket tahmini daha isabetli)
            local horizontalVel = Vector3.new(velocity.X, 0, velocity.Z)
            targetPos = targetPos + (horizontalVel * Settings.PredictionAmount)
        end
    end

    return targetPos
end

-- === ANA AIM FONKSİYONU ===
-- Crosshair'i doğrudan hedefe götürür (mousemoverel hibrit)
local function aimAtTarget(targetPos)
    if not targetPos then return end

    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
    if not onScreen then return end

    -- Ekran merkezinden hedefe olan fark (piksel cinsinden)
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local deltaX = screenPos.X - screenCenter.X
    local deltaY = screenPos.Y - screenCenter.Y

    -- Smoothness hesapla
    local smoothness = math.clamp(Settings.Smoothness, 1, 20)

    -- Düşük smoothness = daha hızlı ve isabetli
    if smoothness <= 2 then
        -- Neredeyse anlık kilitleme - CFrame yöntemi
        local currentCFrame = Camera.CFrame
        local targetCFrame = CFrame.lookAt(currentCFrame.Position, targetPos)
        Camera.CFrame = currentCFrame:Lerp(targetCFrame, 1 / smoothness)
    else
        -- Mouse hareketi ile yumuşak geçiş
        local moveX = deltaX / smoothness
        local moveY = deltaY / smoothness

        -- Çok küçük hareketleri yoksay (titreme önleme)
        if math.abs(moveX) < 0.5 and math.abs(moveY) < 0.5 then
            -- Hedefe çok yakınız, ince ayar yap
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
        else
            mousemoverel(moveX, moveY)
        end
    end
end

-- === SNAP AIM (Anlık kilitleme modu) ===
-- Smoothness 1 olduğunda doğrudan CFrame ile kilitler
local function snapToTarget(targetPos)
    if not targetPos then return end
    Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
end

-- Ana aimbot döngüsü
RunService.RenderStepped:Connect(function()
    -- Kamera referansını güncelle
    Camera = workspace.CurrentCamera

    -- FOV dairesi güncelleme
    if fovCircle then
        fovCircle.Visible = Settings.Enabled and Settings.FOVEnabled
        fovCircle.Radius = Settings.FOVSize
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    end

    -- Aimbot kapalıysa
    if not Settings.Enabled then
        currentTarget = nil
        lockedTarget = nil
        return
    end

    -- Aim tuşu basılı değilse
    if not isAiming then
        if not Settings.StickyAim then
            currentTarget = nil
            lockedTarget = nil
        end
        return
    end

    -- Hedef seçimi
    if Settings.StickyAim and lockedTarget and isValidTarget(lockedTarget) then
        -- Yapışkan aim: kilitli hedefe devam et
        currentTarget = lockedTarget
    else
        currentTarget = getClosestTarget()
        if Settings.StickyAim and currentTarget then
            lockedTarget = currentTarget
        end
    end

    -- Hedefe aim yap
    if currentTarget then
        local targetPos = getTargetPosition(currentTarget)
        if targetPos then
            if Settings.Smoothness <= 1 then
                -- Snap aim: anlık kilitleme
                snapToTarget(targetPos)
            else
                -- Smooth aim: yumuşak geçiş
                aimAtTarget(targetPos)
            end
        end
    end
end)

-- Tuş girdileri
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.UserInputType == Settings.AimKey or input.KeyCode == Settings.AimKey then
        isAiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Settings.AimKey or input.KeyCode == Settings.AimKey then
        isAiming = false
        -- Yapışkan aim kapalıysa hedefi bırak
        if not Settings.StickyAim then
            currentTarget = nil
            lockedTarget = nil
        end
    end
end)

-- Oyuncu ayrıldığında hedefi sıfırla
Players.PlayerRemoving:Connect(function(player)
    if currentTarget == player then currentTarget = nil end
    if lockedTarget == player then lockedTarget = nil end
end)

print("[VergiHub] 🎯 Aimbot Engine v2.0 hazır!")
return true
