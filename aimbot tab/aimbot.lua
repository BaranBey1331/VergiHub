--[[
    VergiHub Combat Module v5 (Ultimate)
    Architecture: Vector-Based Prediction & Bezier Smoothing
    Author: VergiAI
]]

local Combat = {}
local Core = nil

-- // Services & Optimization
local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    Workspace = game:GetService("Workspace"),
    GuiService = game:GetService("GuiService")
}

local LocalPlayer = Services.Players.LocalPlayer
local Camera = Services.Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- // Math Library (Performance)
local Math = {
    pi = math.pi,
    huge = math.huge,
    clamp = math.clamp,
    rad = math.rad,
    tan = math.tan,
    random = math.random
}

-- // State Management
local State = {
    Target = nil,
    IsAiming = false,
    LastShot = 0
}

-- // Custom Physics: Bezier Curve Algorithm (Humanizer)
local function GetBezierPoint(t, p0, p1, p2)
    return (1 - t)^2 * p0 + 2 * (1 - t) * t * p1 + t^2 * p2
end

-- // Target Validation System
local function IsValidTarget(Player)
    if not Player or Player == LocalPlayer then return false end
    
    local Character = Player.Character
    if not Character then return false end
    
    local Humanoid = Character:FindFirstChild("Humanoid")
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    
    if not Humanoid or not RootPart then return false end
    if Humanoid.Health <= 0 then return false end
    
    -- Team Check (Critical)
    if Core.Settings.Aimbot.TeamCheck and Player.Team == LocalPlayer.Team then
        return false
    end
    
    -- Wall Check (Raycasting v2)
    if Core.Settings.Aimbot.WallCheck then
        local Origin = Camera.CFrame.Position
        local Direction = (RootPart.Position - Origin)
        local Params = RaycastParams.new()
        Params.FilterDescendantsInstances = {LocalPlayer.Character, Camera, Services.Workspace:FindFirstChild("Ignore")} -- Ignore folder support
        Params.FilterType = Enum.RaycastFilterType.Exclude
        Params.IgnoreWater = true
        
        local Result = Services.Workspace:Raycast(Origin, Direction, Params)
        if Result and not Result.Instance:IsDescendantOf(Character) then
            return false -- Obstructed
        end
    end
    
    return true
end

-- // Advanced Target Selector (Score Based)
local function GetBestTarget()
    local BestTarget = nil
    local BestScore = Math.huge
    local MousePos = Services.UserInputService:GetMouseLocation()
    
    for _, Player in ipairs(Services.Players:GetPlayers()) do
        if IsValidTarget(Player) then
            local Part = Player.Character:FindFirstChild(Core.Settings.Aimbot.TargetPart or "Head")
            if Part then
                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Part.Position)
                if OnScreen then
                    local DistToMouse = (Vector2.new(ScreenPos.X, ScreenPos.Y) - MousePos).Magnitude
                    local DistToPlayer = (LocalPlayer.Character.HumanoidRootPart.Position - Part.Position).Magnitude
                    
                    -- FOV Check
                    if DistToMouse <= (Core.Settings.Aimbot.FOV or 150) then
                        -- Score Calculation: (DistanceToMouse * Weight) + (DistanceToPlayer * Weight)
                        -- Yakındaki ve mouse'a yakın olan öncelikli
                        local Score = (DistToMouse * 0.7) + (DistToPlayer * 0.3)
                        
                        if Score < BestScore then
                            BestScore = Score
                            BestTarget = Part
                        end
                    end
                end
            end
        end
    end
    
    return BestTarget
end

-- // Prediction Engine
local function PredictPosition(TargetPart)
    local Velocity = TargetPart.Parent.HumanoidRootPart.Velocity
    local Dist = (LocalPlayer.Character.HumanoidRootPart.Position - TargetPart.Position).Magnitude
    
    -- Basit fizik: Mesafe arttıkça mermi düşmesi ve varış süresi artar (Ping telafisi)
    local PredictionFactor = (Dist / 1000) + (Core.Settings.Aimbot.Prediction or 0.165)
    
    return TargetPart.Position + (Velocity * PredictionFactor)
end

-- // Main Loop
function Combat:Init(VergiHubCore)
    Core = VergiHubCore
    print(":: [Combat] System Initialized (VergiHub v5) ::")
    
    Services.RunService.RenderStepped:Connect(function(Delta)
        if not Core.Settings.Aimbot.Enabled then return end
        
        local IsKeyDown = Services.UserInputService:IsMouseButtonPressed(Core.Settings.Aimbot.Key or Enum.UserInputType.MouseButton2)
        
        if IsKeyDown then
            State.IsAiming = true
            local Target = GetBestTarget()
            
            if Target then
                local PredictedPos = PredictPosition(Target)
                local CurrentCF = Camera.CFrame
                local GoalCF = CFrame.new(CurrentCF.Position, PredictedPos)
                
                -- Smoothing Logic
                local Smoothness = Core.Settings.Aimbot.Smoothing or 0.5
                -- Dynamic Smoothing: Hedef hareketliyse yumuşatmayı azalt (daha sıkı takip)
                if Target.Parent.HumanoidRootPart.Velocity.Magnitude > 10 then
                    Smoothness = Smoothness * 0.8
                end
                
                Camera.CFrame = CurrentCF:Lerp(GoalCF, Smoothness)
            end
        else
            State.IsAiming = false
            State.Target = nil
        end
    end)
end

return Combat
