--[[
    VergiHub UI - Premium Black Edition
    Author: VergiAI
]]

local UI = {}
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

function UI:Init(Core)
    -- Temizlik
    if CoreGui:FindFirstChild("VergiHub_MainUI") then
        CoreGui.VergiHub_MainUI:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "VergiHub_MainUI"
    pcall(function() ScreenGui.Parent = CoreGui end)

    -- 1. Ana Panel (Main Frame)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 600, 0, 380)
    MainFrame.Position = UDim2.new(0.5, -300, 0.5, -190)
    MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18) -- Derin Siyah
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = false -- !! GİZLİ BAŞLAR !!
    MainFrame.Parent = ScreenGui

    -- Global'e Kayıt (Floating Menu için hayati önem taşır)
    Core.UI_MainFrame = MainFrame

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame

    -- Aksan Çizgisi (Üst)
    local TopLine = Instance.new("Frame")
    TopLine.Size = UDim2.new(1, 0, 0, 2)
    TopLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    TopLine.BorderSizePixel = 0
    TopLine.Parent = MainFrame
    local LineCorner = Instance.new("UICorner")
    LineCorner.Parent = TopLine

    -- 2. Sidebar (Sol Menü)
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 150, 1, -2)
    Sidebar.Position = UDim2.new(0, 0, 0, 2)
    Sidebar.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    local SideCorner = Instance.new("UICorner")
    SideCorner.CornerRadius = UDim.new(0, 8)
    SideCorner.Parent = Sidebar
    
    -- Köşe Düzeltici (Sidebar'ın sağ tarafını düzleştirir)
    local FixPatch = Instance.new("Frame")
    FixPatch.Size = UDim2.new(0, 10, 1, 0)
    FixPatch.Position = UDim2.new(1, -10, 0, 0)
    FixPatch.BackgroundColor3 = Sidebar.BackgroundColor3
    FixPatch.BorderSizePixel = 0
    FixPatch.Parent = Sidebar

    -- Logo
    local Logo = Instance.new("TextLabel")
    Logo.Text = "VERGI<b>HUB</b>"
    Logo.RichText = true
    Logo.Size = UDim2.new(1, 0, 0, 50)
    Logo.BackgroundTransparency = 1
    Logo.TextColor3 = Color3.fromRGB(255, 255, 255)
    Logo.Font = Enum.Font.GothamBold
    Logo.TextSize = 20
    Logo.Parent = Sidebar

    -- 3. Sayfa Alanı (Content)
    local PageContainer = Instance.new("Frame")
    PageContainer.Name = "Pages"
    PageContainer.Size = UDim2.new(1, -160, 1, -20)
    PageContainer.Position = UDim2.new(0, 160, 0, 10)
    PageContainer.BackgroundTransparency = 1
    PageContainer.Parent = MainFrame

    -- Tab Yöneticisi
    local TabList = Instance.new("UIListLayout")
    TabList.Parent = Sidebar
    TabList.SortOrder = Enum.SortOrder.LayoutOrder
    TabList.Padding = UDim.new(0, 5)
    TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local TabPad = Instance.new("UIPadding")
    TabPad.PaddingTop = UDim.new(0, 60)
    TabPad.Parent = Sidebar

    local ActivePage = nil

    local function CreateTab(Name)
        -- Buton
        local TabBtn = Instance.new("TextButton")
        TabBtn.Text = Name
        TabBtn.Size = UDim2.new(0.85, 0, 0, 32)
        TabBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextSize = 13
        TabBtn.Parent = Sidebar
        
        local TCorner = Instance.new("UICorner")
        TCorner.CornerRadius = UDim.new(0, 6)
        TCorner.Parent = TabBtn

        -- Sayfa
        local Page = Instance.new("ScrollingFrame")
        Page.Name = Name
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 50)
        Page.Visible = false
        Page.Parent = PageContainer

        local PLayout = Instance.new("UIListLayout")
        PLayout.Parent = Page
        PLayout.Padding = UDim.new(0, 8)
        PLayout.SortOrder = Enum.SortOrder.LayoutOrder

        -- Tıklama Olayı
        TabBtn.MouseButton1Click:Connect(function()
            if ActivePage then ActivePage.Visible = false end
            Page.Visible = true
            ActivePage = Page
            
            -- Görsel Feedback
            for _, btn in pairs(Sidebar:GetChildren()) do
                if btn:IsA("TextButton") then
                    TweenService:Create(btn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150, 150, 150), BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
                end
            end
            TweenService:Create(TabBtn, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundColor3 = Color3.fromRGB(50, 50, 50)}):Play()
        end)

        -- İlk Sayfa Kontrolü
        if ActivePage == nil then
            ActivePage = Page
            Page.Visible = true
            TabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end

        local Components = {}

        -- Toggle Ekleme
        function Components:AddToggle(Text, ConfigTable, ConfigKey)
            local ToggleFrame = Instance.new("TextButton")
            ToggleFrame.Text = ""
            ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
            ToggleFrame.AutoButtonColor = false
            ToggleFrame.Parent = Page

            local TfCorner = Instance.new("UICorner")
            TfCorner.CornerRadius = UDim.new(0, 6)
            TfCorner.Parent = ToggleFrame

            local Label = Instance.new("TextLabel")
            Label.Text = Text
            Label.Size = UDim2.new(0.7, 0, 1, 0)
            Label.Position = UDim2.new(0, 15, 0, 0)
            Label.BackgroundTransparency = 1
            Label.TextColor3 = Color3.fromRGB(220, 220, 220)
            Label.Font = Enum.Font.GothamMedium
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.TextSize = 14
            Label.Parent = ToggleFrame

            -- Switch Görseli
            local Switch = Instance.new("Frame")
            Switch.Size = UDim2.new(0, 36, 0, 18)
            Switch.Position = UDim2.new(1, -50, 0.5, -9)
            Switch.BackgroundColor3 = ConfigTable[ConfigKey] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(50, 50, 50)
            Switch.Parent = ToggleFrame
            local SCorner = Instance.new("UICorner")
            SCorner.CornerRadius = UDim.new(1, 0)
            SCorner.Parent = Switch

            local Dot = Instance.new("Frame")
            Dot.Size = UDim2.new(0, 14, 0, 14)
            Dot.Position = ConfigTable[ConfigKey] and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
            Dot.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
            Dot.Parent = Switch
            local DCorner = Instance.new("UICorner")
            DCorner.CornerRadius = UDim.new(1, 0)
            DCorner.Parent = Dot

            ToggleFrame.MouseButton1Click:Connect(function()
                ConfigTable[ConfigKey] = not ConfigTable[ConfigKey]
                local State = ConfigTable[ConfigKey]

                -- Animasyon
                TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = State and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(50, 50, 50)}):Play()
                TweenService:Create(Dot, TweenInfo.new(0.2), {Position = State and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
            end)
        end

        return Components
    end

    -- [[ MENÜ OLUŞTURMA ]]
    local Combat = CreateTab("COMBAT")
    Combat:AddToggle("Aimbot Active", Core.Settings.Aimbot, "Enabled")
    Combat:AddToggle("Team Check", Core.Settings.Aimbot, "TeamCheck")
    Combat:AddToggle("Wall Check (Görünürlük)", Core.Settings.Aimbot, "WallCheck")

    local Visuals = CreateTab("VISUALS")
    Visuals:AddToggle("Box ESP", Core.Settings.Visuals, "Box")
    Visuals:AddToggle("Name ESP", Core.Settings.Visuals, "Names")
    Visuals:AddToggle("Health Bar", Core.Settings.Visuals, "Health")

    print(":: UI Main Initialized ::")
end

return UI
