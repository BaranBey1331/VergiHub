local ESPModule = {}

function ESPModule:Init(Core)
    local Players = Core.Services.Players
    local LocalPlayer = Players.LocalPlayer
    
    -- ESP Nesnesi Oluşturucu
    local function CreateESP(Player)
        if Player == LocalPlayer then return end

        local function Updater()
            local Connection
            Connection = Core.Services.RunService.RenderStepped:Connect(function()
                -- Oyuncu oyundan çıktıysa bağlantıyı kes
                if not Player or not Player.Parent then 
                    Connection:Disconnect()
                    return 
                end

                local Character = Player.Character
                if Character and Character:FindFirstChild("HumanoidRootPart") and Character:FindFirstChild("Humanoid") then
                    local Root = Character.HumanoidRootPart
                    local Hum = Character.Humanoid

                    -- Daha önce eklenmemişse ekle
                    if not Root:FindFirstChild("VergiESP") then
                        -- Ana Billboard
                        local Bill = Instance.new("BillboardGui")
                        Bill.Name = "VergiESP"
                        Bill.Adornee = Root
                        Bill.AlwaysOnTop = true
                        Bill.Size = UDim2.new(4, 0, 5.5, 0) -- Kutu boyutu
                        Bill.StudsOffset = Vector3.new(0, 0, 0)
                        Bill.Parent = Root

                        -- Kutu (Box)
                        local Box = Instance.new("Frame")
                        Box.Name = "Box"
                        Box.Size = UDim2.new(1, 0, 1, 0)
                        Box.BackgroundTransparency = 1
                        Box.BorderSizePixel = 0
                        Box.Parent = Bill
                        
                        -- Çerçeve Çizgisi (Stroke)
                        local Stroke = Instance.new("UIStroke")
                        Stroke.Thickness = 1.5
                        Stroke.Color = Color3.fromRGB(255, 0, 0) -- Kırmızı
                        Stroke.Parent = Box

                        -- İsim
                        local NameLabel = Instance.new("TextLabel")
                        NameLabel.Name = "Name"
                        NameLabel.Size = UDim2.new(1, 0, 0, 20)
                        NameLabel.Position = UDim2.new(0, 0, -0.2, 0)
                        NameLabel.BackgroundTransparency = 1
                        NameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                        NameLabel.TextStrokeTransparency = 0
                        NameLabel.Font = Enum.Font.GothamBold
                        NameLabel.TextSize = 12
                        NameLabel.Text = Player.Name
                        NameLabel.Parent = Bill

                        -- Can Barı
                        local HealthBar = Instance.new("Frame")
                        HealthBar.Name = "HealthBar"
                        HealthBar.Size = UDim2.new(0.05, 0, 1, 0)
                        HealthBar.Position = UDim2.new(-0.1, 0, 0, 0)
                        HealthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                        HealthBar.BorderSizePixel = 0
                        HealthBar.Parent = Bill
                    end

                    -- Görünürlük Kontrolü
                    local ESPGui = Root:FindFirstChild("VergiESP")
                    if ESPGui then
                        local Box = ESPGui:FindFirstChild("Box")
                        local Name = ESPGui:FindFirstChild("Name")
                        local Health = ESPGui:FindFirstChild("HealthBar")

                        ESPGui.Enabled = true -- Genel Açık/Kapalı

                        if Box then Box.Visible = Core.Settings.Visuals.Box end
                        if Name then Name.Visible = Core.Settings.Visuals.Names end
                        
                        -- Can Barı Güncelleme
                        if Health then 
                            Health.Visible = Core.Settings.Visuals.Health
                            local HealthPct = Hum.Health / Hum.MaxHealth
                            Health.Size = UDim2.new(0.05, 0, HealthPct, 0)
                            Health.BackgroundColor3 = Color3.fromHSV(HealthPct * 0.3, 1, 1) -- Yeşilden Kırmızıya
                        end
                    end
                end
            end)
        end
        task.spawn(Updater)
    end

    -- Mevcut Oyuncular İçin
    for _, P in pairs(Players:GetPlayers()) do CreateESP(P) end
    
    -- Yeni Gelenler İçin
    Players.PlayerAdded:Connect(function(P)
        P.CharacterAdded:Connect(function()
            task.wait(1)
            CreateESP(P)
        end)
    end)

    print(":: ESP Modülü Yüklendi ::")
end

return ESPModule

