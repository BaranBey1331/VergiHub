--[[
    VergiHub Module: Aimbot (High Performance)
    Author: VergiAI
    Status: Production Ready
]]

local Aimbot = {}
local Core = nil

-- Sabitler ve Servisler (Cache)
local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    Workspace = game:GetService("Workspace")
}

local LocalPlayer = Services.Players.LocalPlayer
local Camera = Services.Workspace.CurrentCamera

-- Raycast Parametreleri (GC Optimizasyonu için dışarıda tanımlandı)
local RayParams = RaycastParams.new()
RayParams.FilterType = Enum.RaycastFilterType.Exclude
RayParams.IgnoreWater = true

-- Yardımcı: Görünürlük Kontrolü
local function IsVisible(TargetPart)
    if not Core.Settings.Aimbot.WallCheck then return true end

    -- Raycast için kendi karakterimizi ve kamerayı yoksay
    local IgnoreList = {LocalPlayer.Character, Camera}
    RayParams.FilterDescendantsInstances = IgnoreList

    local Origin = Camera.CFrame.Position
    local Direction = (TargetPart.Position - Origin)
    
    local Result = Services.Workspace:Raycast(Origin, Direction, RayParams)

    -- Eğer ışın hedefe çarparsa veya hedef ile arada engel yoksa
    if Result then
        if Result.Instance:IsDescendantOf(TargetPart.Parent) then
            return true
        end
        return false -- Engel var
    end
    return true
end

-- Algoritma: En İyi Hedef
local function GetTarget()
    local BestTarget = nil
    local ShortestDistance = math.huge
    local MousePos = Services.UserInputService:GetMouseLocation()

    for _, Player in ipairs(Services.Players:GetPlayers()) do
        -- 1. Temel Kontroller
        if Player == LocalPlayer or not Player.Character then continue end
        
        -- 2. Takım Kontrolü (Settings'den)
        if Core.Settings.Aimbot.TeamCheck and Player.Team == LocalPlayer.Team then continue end

        local Humanoid = Player.Character:FindFirstChild("Humanoid")
        local Head = Player.Character:FindFirstChild("Head")

        -- 3. Canlılık Kontrolü
        if Humanoid and Humanoid.Health > 0 and Head then
            local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Head.Position)
            
            -- 4. Ekranda mı?
            if OnScreen then
                local Distance = (Vector2.new(ScreenPos.X, ScreenPos.Y) - MousePos).Magnitude
                
                -- 5. Görünürlük ve Mesafe Kontrolü
                if Distance < ShortestDistance and IsVisible(Head) then
                    ShortestDistance = Distance
                    BestTarget = Head
                end
            end
        end
    end
    return BestTarget
end

function Aimbot:Init(VergiHubCore)
    Core = VergiHubCore
    print(":: Aimbot Modülü (v4) Yüklendi ::")

    Services.RunService.RenderStepped:Connect(function()
        -- Global Switch ve Tuş Kontrolü
        if Core.Settings.Aimbot.Enabled and Services.UserInputService:IsMouseButtonPressed(Core.Settings.Aimbot.Key) then
            local Target = GetTarget()
            
            if Target then
                -- Kamera Mantığı (Linear Interpolation)
                local CurrentCF = Camera.CFrame
                local TargetPos = Target.Position
                
                -- Eğer hareket tahminlemesi (prediction) istersen buraya eklenir
                -- local TargetPos = Target.Position + (Target.Parent.HumanoidRootPart.Velocity * 0.05)

                local GoalCF = CFrame.new(CurrentCF.Position, TargetPos)
                
                -- Smoothing Değeri (0.1 = Robotik, 1.0 = Yavaş)
                -- Ayarlardan gelen değeri tersine çeviriyoruz (Daha mantıklı kullanım için)
                local Smoothness = Core.Settings.Aimbot.Smoothing or 0.5
                
                Camera.CFrame = CurrentCF:Lerp(GoalCF, Smoothness)
            end
        end
    end)
end

return Aimbot
