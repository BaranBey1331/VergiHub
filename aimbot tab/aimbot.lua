--[[
    VergiHub - Aimbot Engine v1.0
    Gelişmiş aimbot sistemi - hareket tahmini, FOV kontrolü, yumuşak geçiş
]]

local Settings = getgenv().VergiHub.Aimbot

-- Servisler
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Durum değişkenleri
local currentTarget = nil    -- Şu anki hedef
local isAiming = false       -- Aim tuşu basılı mı
local fovCircle = nil        -- FOV dairesi çizimi

-- FOV dairesi oluştur (Drawing API)
local function createFOVCircle()
    if fovCircle then fovCircle:Remove() end
    fovCircle = Drawing.new("Circle")
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    fovCircle.Radius = Settings.FOVSize
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
    -- Kendimizi hedefleme
    if player == LocalPlayer then return false end
    
    -- Karakter var mı
    local character = player.Character
    if not character then return false end
    
    -- Humanoid ve can kontrolü
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    
    -- Hedef vücut parçası var mı
    local targetPart = character:FindFirstChild(Settings.TargetPart)
    if not targetPart then return false end
    
    -- Takım kontrolü
    if Settings.TeamCheck then
        if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
            return false
        end
    end
    
    -- Mesafe kontrolü
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return false end
    
    local distance = (myChar.HumanoidRootPart.Position - targetPart.Position).Magnitude
    if distance > Settings.MaxDistance then return false end
    
    -- Görünürlük kontrolü (Raycast)
    if Settings.VisibleCheck then
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        rayParams.FilterDescendantsInstances = {myChar, Camera}
        
        local origin = Camera.CFrame.Position
        local direction = (targetPart.Position - origin).Unit * distance
        local rayResult = workspace:Raycast(origin, direction, rayParams)
        
        if rayResult and not rayResult.Instance:IsDescendantOf(character) then
            return false
        end
    end
    
    return true
end

-- Ekrandaki FOV mesafesini hesapla
local function getFOVDistance(player)
    local character = player.Character
    if not character then return math.huge end
    
    local targetPart = character:FindFirstChild(Settings.TargetPart)
    if not targetPart then return math.huge end
    
    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
    if not onScreen then return math.huge end
    
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local targetScreen = Vector2.new(screenPos.X, screenPos.Y)
    
    return (screenCenter - targetScreen).Magnitude
end

-- En yakın hedefi bul (FOV bazlı)
local function getClosestTarget()
    local closestPlayer = nil
    local closestFOV = Settings.FOVSize -- FOV dışındakileri eleme
    
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
    
    -- Hareket tahmini (Prediction)
    if Settings.Prediction then
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            local velocity = rootPart.AssemblyLinearVelocity
            targetPos = targetPos + (velocity * Settings.PredictionAmount)
        end
    end
    
    return targetPos
end

-- Aim uygulama (yumuşak geçiş ile)
local function aimAt(targetPos)
    if not targetPos then return end
    
    local smoothness = math.clamp(Settings.Smoothness, 1, 20)
    local smoothFactor = 1 / smoothness
    
    -- Hedef CFrame hesapla
    local currentCFrame = Camera.CFrame
    local targetCFrame = CFrame.lookAt(currentCFrame.Position, targetPos)
    
    -- Yumuşak geçiş (Lerp)
    Camera.CFrame = currentCFrame:Lerp(targetCFrame, smoothFactor)
end

-- Ana aimbot döngüsü (RenderStepped - her frame)
RunService.RenderStepped:Connect(function()
    -- FOV dairesi güncelleme
    if fovCircle then
        fovCircle.Visible = Settings.Enabled and Settings.FOVEnabled
        fovCircle.Radius = Settings.FOVSize
        fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    end
    
    -- Aimbot kapalıysa çık
    if not Settings.Enabled then
        currentTarget = nil
        return
    end
    
    -- Aim tuşu basılı değilse çık
    if not isAiming then
        if not Settings.StickyAim then
            currentTarget = nil
        end
        return
    end
    
    -- Hedef bul veya mevcut hedefi koru
    if Settings.StickyAim and currentTarget and isValidTarget(currentTarget) then
        -- Yapışkan aim: mevcut hedefi koru
    else
        currentTarget = getClosestTarget()
    end
    
    -- Hedefe aim yap
    if currentTarget then
        local targetPos = getTargetPosition(currentTarget)
        aimAt(targetPos)
    end
end)

-- Tuş girdileri - Mouse butonları
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    -- Aim tuşu kontrolü (varsayılan: sağ tık)
    if input.UserInputType == Settings.AimKey or input.KeyCode == Settings.AimKey then
        isAiming = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Settings.AimKey or input.KeyCode == Settings.AimKey then
        isAiming = false
    end
end)

-- Temizlik: oyuncu ayrıldığında hedefi sıfırla
Players.PlayerRemoving:Connect(function(player)
    if currentTarget == player then
        currentTarget = nil
    end
end)

print("[VergiHub] 🎯 Aimbot Engine hazır!")
return true
