local UIModule = {}

function UIModule:Init(Core)
    -- UI Oluşturma (CoreGui Koruması)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "VergiHubUI"
    pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end) 
    if not ScreenGui.Parent then ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end

    -- Ana Çerçeve
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 450, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25) -- Dark Theme
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true -- Sürüklenebilir yap
    MainFrame.Parent = ScreenGui

    -- UI Corner (Yuvarlak köşeler)
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = MainFrame

    -- Başlık
    local Title = Instance.new("TextLabel")
    Title.Text = "VERGIHUB | Production Build"
    Title.Size = UDim2.new(1, -20, 0, 40)
    Title.Position = UDim2.new(0, 10, 0, 5)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(200, 200, 200)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 18
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = MainFrame

    -- Ayarlar Container
    local Container = Instance.new("ScrollingFrame")
    Container.Size = UDim2.new(1, -20, 1, -60)
    Container.Position = UDim2.new(0, 10, 0, 50)
    Container.BackgroundTransparency = 1
    Container.BorderSizePixel = 0
    Container.ScrollBarThickness = 2
    Container.Parent = MainFrame

    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = Container
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.Padding = UDim.new(0, 5)

    -- Toggle Oluşturucu Fonksiyon
    local function CreateToggle(Text, SettingTable, SettingKey)
        local ToggleBtn = Instance.new("TextButton")
        ToggleBtn.Size = UDim2.new(1, 0, 0, 35)
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        ToggleBtn.Text = ""
        ToggleBtn.Parent = Container
        
        local TCorner = Instance.new("UICorner")
        TCorner.CornerRadius = UDim.new(0, 4)
        TCorner.Parent = ToggleBtn

        local Label = Instance.new("TextLabel")
        Label.Text = Text
        Label.Size = UDim2.new(0.7, 0, 1, 0)
        Label.Position = UDim2.new(0, 10, 0, 0)
        Label.BackgroundTransparency = 1
        Label.TextColor3 = Color3.fromRGB(255, 255, 255)
        Label.Font = Enum.Font.GothamSemibold
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = ToggleBtn

        local Status = Instance.new("Frame")
        Status.Size = UDim2.new(0, 20, 0, 20)
        Status.Position = UDim2.new(1, -30, 0.5, -10)
        Status.Parent = ToggleBtn
        local SCorner = Instance.new("UICorner")
        SCorner.CornerRadius = UDim.new(0, 4)
        SCorner.Parent = Status

        -- Renk Güncelleme
        local function UpdateColor()
            if SettingTable[SettingKey] then
                Status.BackgroundColor3 = Color3.fromRGB(0, 255, 100) -- Yeşil
            else
                Status.BackgroundColor3 = Color3.fromRGB(255, 50, 50) -- Kırmızı
            end
        end
        UpdateColor()

        ToggleBtn.MouseButton1Click:Connect(function()
            SettingTable[SettingKey] = not SettingTable[SettingKey]
            UpdateColor()
        end)
    end

    -- Menü Öğelerini Ekle
    CreateToggle("Aimbot Active", Core.Settings.Aimbot, "Enabled")
    CreateToggle("Wall Check (Duvar Arkası Vurmaz)", Core.Settings.Aimbot, "WallCheck")
    CreateToggle("Show FOV Circle", Core.Settings.Aimbot, "ShowFOV")
    CreateToggle("Box ESP", Core.Settings.Visuals, "BoxEsp")
end

return UIModule
