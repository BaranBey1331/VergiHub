local AimbotModule = {}

function AimbotModule:Init(Core)
    local Camera = workspace.CurrentCamera
    local LocalPlayer = Core.Services.Players.LocalPlayer
    local Mouse = LocalPlayer:GetMouse()

    -- En Yakın Oyuncuyu Bulma (Distance based)
    local function GetClosestPlayer()
        local Closest = nil
        local ShortestDistance = math.huge
        local MousePos = Core.Services.UserInputService:GetMouseLocation()

        for _, Player in pairs(Core.Services.Players:GetPlayers()) do
            if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.Health > 0 then
                
                -- Takım Kontrolü
                if Core.Settings.Aimbot.TeamCheck and Player.Team == LocalPlayer.Team then
                    continue 
                end

                local TargetPart = Player.Character:FindFirstChild("Head") or Player.Character:FindFirstChild("HumanoidRootPart")
                
                if TargetPart then
                    local ScreenPos, OnScreen = Camera:WorldToViewportPoint(TargetPart.Position)
                    
                    if OnScreen then
                        local Distance = (Vector2.new(ScreenPos.X, ScreenPos.Y) - MousePos).Magnitude
                        
                        if Distance < ShortestDistance then
                            ShortestDistance = Distance
                            Closest = TargetPart
                        end
                    end
                end
            end
        end
        return Closest
    end

    -- Loop
    Core.Services.RunService.RenderStepped:Connect(function()
        if Core.Settings.Aimbot.Enabled then
            -- Sağ Tık Basılı mı?
            if Core.Services.UserInputService:IsMouseButtonPressed(Core.Settings.Aimbot.Key) then
                local Target = GetClosestPlayer()
                if Target then
                    local CurrentCF = Camera.CFrame
                    local TargetCF = CFrame.new(CurrentCF.Position, Target.Position)
                    
                    -- Smooth Aim (Lerp)
                    Camera.CFrame = CurrentCF:Lerp(TargetCF, Core.Settings.Aimbot.Smoothing)
                end
            end
        end
    end)
    
    print(":: Aimbot Modülü Yüklendi ::")
end

return AimbotModule
