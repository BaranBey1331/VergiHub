local UILibrary = {}

function UILibrary:Init(Core)
    local Services = Core.Services
    
    -- Eski GUI temizle
    if Services.CoreGui:FindFirstChild("VergiHub_Main") then
        Services.CoreGui.VergiHub_Main:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "VergiHub_Main"
    pcall(function() ScreenGui.Parent = Services.CoreGui end)

    -- Ana Çerçeve (Gizli Başlar)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 550, 0, 350)
    MainFrame.Position = UDim2.new(0.5, -275, 0.5, -175)
    MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Koyu Gri/Siyah
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = false -- BAŞLANGIÇTA GİZLİ
    MainFrame.Parent = ScreenGui

    -- !! KRİTİK: Global referansa ata !!
    Core.UI_MainFrame = MainFrame

    -- Köşeler
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainFrame

    -- Yan Menü (Sidebar)
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 130, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    
    local SideCorner = Instance.new("UICorner")
    SideCorner.CornerRadius = UDim.new(0, 10)
    SideCorner.Parent = Sidebar

    -- Başlık
    local Title = Instance.new("TextLabel")
    Title.Text = "VERGIHUB"
    Title.Font = Enum.Font.GothamBlack
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Size = UDim2.new(1, 0, 0, 50)
    Title.BackgroundTransparency = 1
    Title.Parent = Sidebar

    -- Sayfa Konteyner (Pages)
    local PageContainer = Instance.new("Frame")
    PageContainer.Size = UDim2.new(1, -140, 1, -20)
    PageContainer.Position = UDim2.new(0, 140, 0, 10)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = MainFrame

    -- Tab Butonları Konteyner
    local TabContainer = Instance.new("UIListLayout")
    TabContainer.Parent = Sidebar
    TabContainer.SortOrder = Enum.SortOrder.LayoutOrder
    TabContainer.Padding = UDim.new(0, 5)
    TabContainer.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    local TabPadding = Instance.new("UIPadding")
    TabPadding.PaddingTop = UDim.new(0, 60)
    TabPadding.Parent = Sidebar

    local CurrentPage = nil

    local function CreateTab(Name)
        -- Tab Butonu
        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0.8, 0, 0, 30)
        TabBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        TabBtn.Text = Name
        TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.TextSize = 12
        TabBtn.Parent = Sidebar
        
        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 6)
        BtnCorner.Parent = TabBtn

        -- Sayfa
        local Page = Instance.new("ScrollingFrame")
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.Visible = false
        Page.Parent = PageContainer
        
        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Parent = Page
        PageLayout.Padding = UDim.new(0, 5)
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder

        -- Tab Geçiş Mantığı
        TabBtn.MouseButton1Click:Connect(function()
            if CurrentPage then CurrentPage.Visible = false end
            Page.Visible = true
            CurrentPage = Page
        end)

        -- İlk Tab ise aç
        if CurrentPage == nil then
            CurrentPage = Page
            Page.Visible = true
        end

        local Funcs = {}

        -- Toggle Ekleme
        function Funcs:AddToggle(Text, Table, Key)
            local Frame = Instance.new("Frame")
            Frame.Size = UDim2.new(1, 0, 0, 35)
            Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
            Frame.Parent = Page
            
            local FCorner = Instance.new("UICorner")
            FCorner.CornerRadius = UDim.new(0, 6)
            FCorner.Parent = Frame

            local Label = Instance.new("TextLabel")
            Label.Text = Text
            Label.Size = UDim2.new(0.7, 0, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.TextColor3 = Color3.fromRGB(255, 255, 255)
            Label.BackgroundTransparency = 1
            Label.Font = Enum.Font.GothamMedium
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = Frame

            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(0, 20, 0, 20)
            Btn.Position = UDim2.new(1, -30, 0.5, -10)
            Btn.Text = ""
            Btn.BackgroundColor3 = Table[Key] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(60, 60, 60)
            Btn.Parent = Frame
            
            local BCorner = Instance.new("UICorner")
            BCorner.CornerRadius = UDim.new(0, 4)
            BCorner.Parent = Btn

            Btn.MouseButton1Click:Connect(function()
                Table[Key] = not Table[Key]
                Btn.BackgroundColor3 = Table[Key] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(60, 60, 60)
            end)
        end

        return Funcs
    end

    -- TABLARI OLUŞTUR
    local AimTab = CreateTab("COMBAT")
    AimTab:AddToggle("Aimbot Active", Core.Settings.Aimbot, "Enabled")
    AimTab:AddToggle("Team Check", Core.Settings.Aimbot, "TeamCheck")
    AimTab:AddToggle("Wall Check", Core.Settings.Aimbot, "WallCheck")

    local VisTab = CreateTab("VISUALS")
    VisTab:AddToggle("Box ESP", Core.Settings.Visuals, "Box")
    VisTab:AddToggle("Name ESP", Core.Settings.Visuals, "Names")
    VisTab:AddToggle("Health Bar", Core.Settings.Visuals, "Health")

    print(":: UI Framework Init Success ::")
end

return UILibrary
