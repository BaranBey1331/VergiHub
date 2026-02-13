local AimbotModule = {}

function AimbotModule:Init(Core)
    local Camera = workspace.CurrentCamera
    local LocalPlayer = Core.Services.Players.LocalPlayer
    local Mouse = LocalPlayer:GetMouse()
    local FOVCircle = Drawing.new("Circle") -- Executor Drawing API

    -- FOV Çember Ayarları
    FOVCircle.Color = Color3.fromRGB(255, 255, 255)
    FOVCircle.Thickness = 1
    FOVCircle.Filled = false
    FOVCircle.Transparency = 1
    
    -- Hedef Seçici (En gelişmiş algoritma)
    local function GetTarget()
        local Closest = nil
        local MaxDist = Core.Settings.Aimbot.FOV
        local MousePos = Core.Services.UserInputService:GetMouseLocation()

        for _, Player in pairs(Core.Services.Players:GetPlayers()) do
            if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("Humanoid") and Player.Character.Humanoid.Health > 0 then
                -- Takım Kontrolü eklenebilir
                local TargetPart = Player.Character:FindFirstChild(Core.Settings.Aimbot.TargetPart)
                if TargetPart then
                    local ScreenPos, OnScreen = Camera:WorldToViewportPoint(TargetPart.Position)
                    
                    if OnScreen then
                        local Dist = (Vector2.new(ScreenPos.X, ScreenPos.Y) - MousePos).Magnitude
                        
                        -- WallCheck (Raycasting)
                        local CanSee = true
                        if Core.Settings.Aimbot.WallCheck then
                            local Params = RaycastParams.new()
                            Params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
                            Params.FilterType = Enum.RaycastFilterType.Blacklist
                            
                            local RayHit = workspace:Raycast(Camera.CFrame.Position, (TargetPart.Position - Camera.CFrame.Position).Unit * 500, Params)
                            if RayHit and not RayHit.Instance:IsDescendantOf(Player.Character) then
                                CanSee = false
                            end
                        end

                        if Dist < MaxDist and CanSee then
                            MaxDist = Dist
                            Closest = TargetPart
                        end
                    end
                end
            end
        end
        return Closest
    end

    -- Ana Döngü (RenderStepped - Her karede çalışır)
    Core.Services.RunService.RenderStepped:Connect(function()
        -- FOV Güncelle
        FOVCircle.Position = Core.Services.UserInputService:GetMouseLocation()
        FOVCircle.Radius = Core.Settings.Aimbot.FOV
        FOVCircle.Visible = Core.Settings.Aimbot.ShowFOV

        -- Aimbot Logic
        if Core.Settings.Aimbot.Enabled and Core.Services.UserInputService:IsKeyDown(Core.Settings.Aimbot.Key) then
            local Target = GetTarget()
            if Target then
                -- Prediction Hesaplaması (Velocity bazlı)
                local Velocity = Target.Parent.HumanoidRootPart.Velocity
                local PredictedPos = Target.Position + (Velocity * Core.Settings.Aimbot.Prediction)
                
                -- Smoothing (Yumuşatma)
                local MainCF = Camera.CFrame
                local TargetCF = CFrame.new(MainCF.Position, PredictedPos)
                
                Camera.CFrame = MainCF:Lerp(TargetCF, Core.Settings.Aimbot.Smoothing)
            end
        end
    end)
end

return AimbotModule
