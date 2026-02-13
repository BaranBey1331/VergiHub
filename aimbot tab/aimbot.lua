local AimbotModule = {}

function AimbotModule:Init(Core)
    local Players = Core.Services.Players
    local RunService = Core.Services.RunService
    local UserInputService = Core.Services.UserInputService
    local Camera = workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer

    -- Raycast Parametreleri (Kendi karakterimizi yoksay)
    local RayParams = RaycastParams.new()
    RayParams.FilterType = Enum.RaycastFilterType.Blacklist
    RayParams.IgnoreWater = true

    -- Görünürlük Kontrolü (Wall Check)
    local function IsVisible(TargetPart, Origin)
        -- Eğer WallCheck kapalıysa direkt true dön
        if not Core.Settings.Aimbot.WallCheck then return true end

        -- Raycast filtresini güncelle (Yeni karakterleri yoksaymak için)
        RayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}

        local Direction = TargetPart.Position - Origin
        local Result = workspace:Raycast(Origin, Direction, RayParams)

        -- Eğer ışın bir şeye çarptıysa ve çarptığı şey hedefin parçasıysa -> Görünürdür
        if Result then
            if Result.Instance:IsDescendantOf(TargetPart.Parent) then
                return true
            end
            return false -- Araya duvar girdi
        end
        return true -- Hiçbir şeye çarpmadı (Boşluk)
    end

    -- En İyi Hedefi Bulma Algoritması
    local function GetBestTarget()
        local BestTarget = nil
        local ShortestDist = math.huge
        local MousePos = UserInputService:GetMouseLocation()

        for _, Player in ipairs(Players:GetPlayers()) do
            -- Temel Kontroller
            if Player == LocalPlayer or not Player.Character then continue end
            
            -- Takım Kontrolü (Built-in)
            if Core.Settings.Aimbot.TeamCheck and Player.Team == LocalPlayer.Team then continue end

            local Humanoid = Player.Character:FindFirstChild("Humanoid")
            local Head = Player.Character:FindFirstChild("Head")
            
            -- Canlı mı?
            if Humanoid and Humanoid.Health > 0 and Head then
                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Head.Position)
                
                if OnScreen then
                    -- Görünür mü?
                    if IsVisible(Head, Camera.CFrame.Position) then
                        local Dist = (Vector2.new(ScreenPos.X, ScreenPos.Y) - MousePos).Magnitude
                        
                        -- FOV içindeyse ve en yakınsa seç
                        -- Not: Core.Settings.Aimbot.FOV değeri ekleyebilirsin, şimdilik sonsuz
                        if Dist < ShortestDist then
                            ShortestDist = Dist
                            BestTarget = Head
                        end
                    end
                end
            end
        end
        return BestTarget
    end

    -- Loop
    RunService.RenderStepped:Connect(function()
        if Core.Settings.Aimbot.Enabled and UserInputService:IsMouseButtonPressed(Core.Settings.Aimbot.Key) then
            local Target = GetBestTarget()
            if Target then
                -- Kamera Hareketi (Smoothing ile)
                local CurrentCF = Camera.CFrame
                local TargetPos = Target.Position + (Target.Parent.HumanoidRootPart.Velocity * 0.1) -- Basit Prediction
                local TargetCF = CFrame.new(CurrentCF.Position, TargetPos)
                
                Camera.CFrame = CurrentCF:Lerp(TargetCF, Core.Settings.Aimbot.Smoothing or 0.5)
            end
        end
    end)
    
    print(":: Aimbot Logic v2 (WallCheck & TeamCheck) Aktif ::")
end

return AimbotModule
