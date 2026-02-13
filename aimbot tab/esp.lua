--[[
    VergiHub Module: ESP (Visuals)
    Author: VergiAI
    Status: Production Ready
]]

local ESP = {}
local Core = nil
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ESP Konteyneri (Yönetim için)
local ESP_Folder = Instance.new("Folder")
ESP_Folder.Name = "VergiHub_ESP_Storage"
ESP_Folder.Parent = game:GetService("CoreGui")

local function CreateVisuals(Player)
    -- Kendi üzerimize ESP açmayalım
    if Player == LocalPlayer then return end

    local function Updater()
        local Connection
        Connection = RunService.RenderStepped:Connect(function()
            -- 1. Oyuncu veya Karakter yoksa bağlantıyı kes (Memory Leak Önleme)
            if not Player or not Player.Parent then
                if Connection then Connection:Disconnect() end
                return
            end

            local Character = Player.Character
            if Character and Character:FindFirstChild("HumanoidRootPart") and Character:FindFirstChild("Humanoid") then
                local Root = Character.HumanoidRootPart
                local Hum = Character.Humanoid
                
                -- TEAM CHECK KONTROLÜ
                -- Eğer TeamCheck açıksa ve aynı takımdaysak -> Gösterme
                local IsTeammate = (Core.Settings.Aimbot.TeamCheck and Player.Team == LocalPlayer.Team)

                -- ESP Nesnesini Kontrol Et / Oluştur
                local Holder = Root:FindFirstChild("VergiVisuals")
                if not Holder then
                    Holder = Instance.new("BillboardGui")
                    Holder.Name = "VergiVisuals"
                    Holder.AlwaysOnTop = true
                    Holder.Size = UDim2.new(4.5, 0, 6, 0)
                    Holder.StudsOffset = Vector3.new(0, 0, 0)
                    Holder.Adornee = Root
                    Holder.Parent = Root

                    -- Kutu
                    local Box = Instance.new("Frame")
                    Box.Name = "Box"
                    Box.Size = UDim2.new(1, 0, 1, 0)
                    Box.BackgroundTransparency = 1
                    Box.BorderSizePixel = 0
                    Box.Parent = Holder
                    
                    local Stroke = Instance.new("UIStroke")
                    Stroke.Name = "Stroke"
                    Stroke.Color = Color3.fromRGB(255, 50, 50)
                    Stroke.Thickness = 1.5
                    Stroke.Parent = Box

                    -- İsim
                    local NameTag = Instance.new("TextLabel")
                    NameTag.Name = "Name"
                    NameTag.Size = UDim2.new(1, 0, 0.2, 0)
                    NameTag.Position = UDim2.new(0, 0, -0.2, 0)
                    NameTag.BackgroundTransparency = 1
                    NameTag.TextColor3 = Color3.fromRGB(255, 255, 255)
                    NameTag.TextStrokeTransparency = 0
                    NameTag.Font = Enum.Font.GothamBold
                    NameTag.TextSize = 13
                    NameTag.Text = Player.Name
                    NameTag.Parent = Holder

                    -- Can Barı Arkaplan
                    local HealthBg = Instance.new("Frame")
                    HealthBg.Name = "HealthBg"
                    HealthBg.Size = UDim2.new(0.05, 0, 1, 0)
                    HealthBg.Position = UDim2.new(-0.1, 0, 0, 0)
                    HealthBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                    HealthBg.BorderSizePixel = 0
                    HealthBg.Parent = Holder

                    -- Can Barı Dolum
                    local HealthBar = Instance.new("Frame")
                    HealthBar.Name = "HealthBar"
                    HealthBar.Parent = HealthBg
                    HealthBar.BorderSizePixel = 0
                    HealthBar.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
                end

                -- GÖRÜNÜRLÜK YÖNETİMİ
                if IsTeammate then
                    Holder.Enabled = false
                else
                    Holder.Enabled = true
                    
                    local Box = Holder:FindFirstChild("Box")
                    local Name = Holder:FindFirstChild("Name")
                    local HBg = Holder:FindFirstChild("HealthBg")

                    if Box then Box.Visible = Core.Settings.Visuals.Box end
                    if Name then Name.Visible = Core.Settings.Visuals.Names end
                    
                    if HBg then 
                        HBg.Visible = Core.Settings.Visuals.Health 
                        local Bar = HBg:FindFirstChild("HealthBar")
                        if Bar then
                            local Pct = math.clamp(Hum.Health / Hum.MaxHealth, 0, 1)
                            Bar.Size = UDim2.new(1, 0, Pct, 0)
                            Bar.Position = UDim2.new(0, 0, 1 - Pct, 0) -- Aşağıdan yukarı dolsun
                            Bar.BackgroundColor3 = Color3.fromHSV(Pct * 0.3, 1, 1) -- Renk değişimi
                        end
                    end
                end
            end
        end)
    end
    
    task.spawn(Updater)
end

function ESP:Init(VergiHubCore)
    Core = VergiHubCore
    print(":: ESP Modülü (v4) Yüklendi ::")

    -- Mevcut Oyuncular
    for _, P in pairs(Players:GetPlayers()) do
        CreateVisuals(P)
    end

    -- Yeni Gelenler
    Players.PlayerAdded:Connect(function(P)
        P.CharacterAdded:Connect(function()
            task.wait(1) -- Karakter yüklenmesini bekle
            CreateVisuals(P)
        end)
    end)
end

return ESP
