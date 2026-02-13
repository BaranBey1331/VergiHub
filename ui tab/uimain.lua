--[[
    VergiHub UI Framework - Premium Black & White Edition
    Author: Baran & VergiAI
    Version: 3.0 (Production Ready)
    
    Style: Minimalist, Round, Horizontal, Black/White
]]

local UILibrary = {}
local Core = nil

-- Servisler
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Yardımcı Fonksiyonlar
local function Create(class, properties)
    local instance = Instance.new(class)
    for k, v in pairs(properties) do
        instance[k] = v
    end
    return instance
end

local function Tween(obj, info, props)
    TweenService:Create(obj, info, props):Play()
end

-- UI Başlatıcı
function UILibrary:Init(VergiHubCore)
    Core = VergiHubCore
    
    -- Varolan UI'ları temizle
    if game.CoreGui:FindFirstChild("VergiHub_Main") then
        game.CoreGui.VergiHub_Main:Destroy()
    end

    local ScreenGui = Create("ScreenGui", {
        Name = "VergiHub_Main",
        Parent = game.CoreGui,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false
    })

    -- Ana Çerçeve (Main Window)
    local MainFrame = Create("Frame", {
        Name = "MainFrame",
        Parent = ScreenGui,
        BackgroundColor3 = Color3.fromRGB(15, 15, 15), -- Derin Siyah
        Position = UDim2.new(0.5, -300, 0.5, -200), -- Ortala
        Size = UDim2.new(0, 600, 0, 400), -- Yatay Genişlik
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = false -- Başlangıçta gizli (Floating buton açacak)
    })

    -- Global Erişim için UI referansını kaydet
    Core.UIFrame = MainFrame

    local MainCorner = Create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 12)})

    -- Sol Menü Barı (Sidebar)
    local Sidebar = Create("Frame", {
        Name = "Sidebar",
        Parent = MainFrame,
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        Size = UDim2.new(0, 160, 1, 0),
        BorderSizePixel = 0
    })
    
    local SidebarCorner = Create("UICorner", {Parent = Sidebar, CornerRadius = UDim.new(0, 12)})
    -- Köşe düzeltme (Sağ taraf düz olsun)
    local SidebarFix = Create("Frame", {
        Parent = Sidebar,
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        Size = UDim2.new(0, 20, 1, 0),
        Position = UDim2.new(1, -10, 0, 0),
        BorderSizePixel = 0,
        ZIndex = 0
    })

    -- Başlık
    local Title = Create("TextLabel", {
        Parent = Sidebar,
        Text = "VERGI<b>HUB</b>",
        RichText = true,
        Font = Enum.Font.GothamBold,
        TextSize = 24,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 60),
        Position = UDim2.new(0, 0, 0, 10)
    })

    -- Tab Konteyner
    local TabContainer = Create("ScrollingFrame", {
        Parent = Sidebar,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -80),
        Position = UDim2.new(0, 0, 0, 80),
        ScrollBarThickness = 0
    })
    
    local TabListLayout = Create("UIListLayout", {
        Parent = TabContainer,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        HorizontalAlignment = Enum.HorizontalAlignment.Center
    })

    -- İçerik Alanı (Pages Area)
    local Pages = Create("Frame", {
        Name = "Pages",
        Parent = MainFrame,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -170, 1, -20),
        Position = UDim2.new(0, 170, 0, 10),
        ClipsDescendants = true
    })

    -- [[ TAB SİSTEMİ ]] --
    local Tabs = {}
    local FirstTab = true

    local function MakeTab(Name, IconId)
        local Tab = {}
        
        -- Tab Butonu
        local TabBtn = Create("TextButton", {
            Parent = TabContainer,
            Text = Name,
            Font = Enum.Font.GothamMedium,
            TextColor3 = Color3.fromRGB(150, 150, 150),
            TextSize = 14,
            BackgroundColor3 = Color3.fromRGB(25, 25, 25),
            Size = UDim2.new(0.85, 0, 0, 35),
            AutoButtonColor = false,
            BorderSizePixel = 0
        })
        
        local BtnCorner = Create("UICorner", {Parent = TabBtn, CornerRadius = UDim.new(0, 8)})
        
        -- Tab Sayfası (Page)
        local Page = Create("ScrollingFrame", {
            Name = Name .. "Page",
            Parent = Pages,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 2,
            ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
            Visible = false
        })

        local PageLayout = Create("UIListLayout", {
            Parent = Page,
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10)
        })
        
        local PagePad = Create("UIPadding", {
            Parent = Page,
            PaddingTop = UDim.new(0, 5),
            PaddingLeft = UDim.new(0, 5),
            PaddingRight = UDim.new(0, 5)
        })

        -- Tab Aktifleştirme Fonksiyonu
        function Tab:Activate()
            -- Diğerlerini kapat
            for _, t in pairs(Tabs) do
                Tween(t.Btn, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(150, 150, 150), BackgroundColor3 = Color3.fromRGB(25, 25, 25)})
                t.Page.Visible = false
            end
            -- Kendini aç
            Tween(TabBtn, TweenInfo.new(0.3), {TextColor3 = Color3.fromRGB(255, 255, 255), BackgroundColor3 = Color3.fromRGB(40, 40, 40)})
            Page.Visible = true
        end

        TabBtn.MouseButton1Click:Connect(function()
            Tab:Activate()
        end)

        Tab.Btn = TabBtn
        Tab.Page = Page
        table.insert(Tabs, Tab)

        if FirstTab then
            Tab:Activate()
            FirstTab = false
        end

        -- [[ ELEMENTLER ]] --

        -- 1. TOGGLE
        function Tab:AddToggle(Text, SettingTable, Key, Callback)
            local ToggleFrame = Create("TextButton", {
                Parent = Page,
                Text = "",
                BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                Size = UDim2.new(1, 0, 0, 40),
                AutoButtonColor = false,
                BorderSizePixel = 0
            })
            local TCorner = Create("UICorner", {Parent = ToggleFrame, CornerRadius = UDim.new(0, 6)})

            local TLabel = Create("TextLabel", {
                Parent = ToggleFrame,
                Text = Text,
                Font = Enum.Font.GothamMedium,
                TextColor3 = Color3.fromRGB(200, 200, 200),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Size = UDim2.new(0.7, 0, 1, 0),
                Position = UDim2.new(0, 15, 0, 0)
            })

            local Switch = Create("Frame", {
                Parent = ToggleFrame,
                BackgroundColor3 = SettingTable[Key] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(50, 50, 50),
                Size = UDim2.new(0, 40, 0, 20),
                Position = UDim2.new(1, -55, 0.5, -10)
            })
            local SCorner = Create("UICorner", {Parent = Switch, CornerRadius = UDim.new(1, 0)})

            local Circle = Create("Frame", {
                Parent = Switch,
                BackgroundColor3 = Color3.fromRGB(15, 15, 15),
                Size = UDim2.new(0, 16, 0, 16),
                Position = SettingTable[Key] and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            })
            local CCorner = Create("UICorner", {Parent = Circle, CornerRadius = UDim.new(1, 0)})

            local function UpdateToggle()
                local Status = SettingTable[Key]
                if Status then
                    Tween(Switch, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)})
                    Tween(Circle, TweenInfo.new(0.2), {Position = UDim2.new(1, -18, 0.5, -8)})
                    Tween(TLabel, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)})
                else
                    Tween(Switch, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 50, 50)})
                    Tween(Circle, TweenInfo.new(0.2), {Position = UDim2.new(0, 2, 0.5, -8)})
                    Tween(TLabel, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(200, 200, 200)})
                end
                if Callback then Callback(Status) end
            end

            ToggleFrame.MouseButton1Click:Connect(function()
                SettingTable[Key] = not SettingTable[Key]
                UpdateToggle()
            end)
            
            -- Başlangıç durumu
            UpdateToggle()
        end

        -- 2. SLIDER
        function Tab:AddSlider(Text, SettingTable, Key, Min, Max)
            local SliderFrame = Create("Frame", {
                Parent = Page,
                BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                Size = UDim2.new(1, 0, 0, 60),
                BorderSizePixel = 0
            })
            Create("UICorner", {Parent = SliderFrame, CornerRadius = UDim.new(0, 6)})

            local SLabel = Create("TextLabel", {
                Parent = SliderFrame,
                Text = Text,
                Font = Enum.Font.GothamMedium,
                TextColor3 = Color3.fromRGB(200, 200, 200),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 10),
                Size = UDim2.new(1, -30, 0, 20)
            })

            local ValueLabel = Create("TextLabel", {
                Parent = SliderFrame,
                Text = tostring(SettingTable[Key]),
                Font = Enum.Font.GothamBold,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right,
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 15, 0, 10),
                Size = UDim2.new(1, -30, 0, 20)
            })

            local Bar = Create("Frame", {
                Parent = SliderFrame,
                BackgroundColor3 = Color3.fromRGB(50, 50, 50),
                Size = UDim2.new(1, -30, 0, 4),
                Position = UDim2.new(0, 15, 0, 40),
                BorderSizePixel = 0
            })
            Create("UICorner", {Parent = Bar, CornerRadius = UDim.new(1, 0)})

            local Fill = Create("Frame", {
                Parent = Bar,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Size = UDim2.new(0, 0, 1, 0), -- Başlangıç
                BorderSizePixel = 0
            })
            Create("UICorner", {Parent = Fill, CornerRadius = UDim.new(1, 0)})

            local Trigger = Create("TextButton", {
                Parent = Bar,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Text = ""
            })

            local function UpdateSlider(Input)
                local SizeX = math.clamp((Input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                local Value = math.floor(Min + ((Max - Min) * SizeX))
                
                SettingTable[Key] = Value
                ValueLabel.Text = tostring(Value)
                Tween(Fill, TweenInfo.new(0.1), {Size = UDim2.new(SizeX, 0, 1, 0)})
            end
            
            -- Başlangıç Değeri Ayarlama
            local StartPercent = (SettingTable[Key] - Min) / (Max - Min)
            Fill.Size = UDim2.new(StartPercent, 0, 1, 0)

            local Dragging = false
            Trigger.MouseButton1Down:Connect(function() Dragging = true end)
            UserInputService.InputEnded:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then Dragging = false end
            end)
            
            UserInputService.InputChanged:Connect(function(Input)
                if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement) then
                    UpdateSlider(Input)
                end
            end)
            
            -- Tek tık için
            Trigger.MouseButton1Down:Connect(function()
                 UpdateSlider(Mouse) -- Mouse nesnesi globalden
            end)
        end

        -- 3. LABEL (Bilgi)
        function Tab:AddLabel(Text)
            local Lab = Create("TextLabel", {
                Parent = Page,
                Text = Text,
                Font = Enum.Font.Gotham,
                TextColor3 = Color3.fromRGB(100, 100, 100),
                TextSize = 12,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20)
            })
        end

        return Tab
    end

    -- [[ MENÜNÜN OLUŞTURULMASI ]] --
    
    -- 1. Tab: Aimbot
    local AimTab = MakeTab("Combat", "")
    AimTab:AddToggle("Aimbot Aktif", Core.Settings.Aimbot, "Enabled")
    AimTab:AddToggle("Takım Arkadaşlarını Yoksay", Core.Settings.Aimbot, "TeamCheck")
    AimTab:AddToggle("Duvar Arkası Vurma (WallCheck)", Core.Settings.Aimbot, "WallCheck")
    AimTab:AddSlider("Yumuşatma (Smoothness)", Core.Settings.Aimbot, "Smoothing", 0, 100) -- %0 ile %100 arası
    AimTab:AddLabel("Düşük smoothness daha robotik, yüksek daha legit.")

    -- 2. Tab: Visuals
    local VisTab = MakeTab("Visuals", "")
    VisTab:AddToggle("Kutu ESP (Box)", Core.Settings.Visuals, "Box")
    VisTab:AddToggle("İsim Göster (Names)", Core.Settings.Visuals, "Names")
    VisTab:AddToggle("Can Barı (Health)", Core.Settings.Visuals, "Health")
    VisTab:AddLabel("ESP tüm oyuncuları ve takım arkadaşlarını kapsar.")

    -- 3. Tab: Settings
    local SetTab = MakeTab("Settings", "")
    SetTab:AddLabel("VergiHub v3.0 - Baran Edition")
    SetTab:AddLabel("Production Ready Build")
    
    -- Sürükleme Mantığı (Drag)
    local Dragging, DragInput, DragStart, StartPos
    MainFrame.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = Input.Position
            StartPos = MainFrame.Position
            
            Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)
    MainFrame.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement then
            DragInput = Input
        end
    end)
    UserInputService.InputChanged:Connect(function(Input)
        if Input == DragInput and Dragging then
            local Delta = Input.Position - DragStart
            Tween(MainFrame, TweenInfo.new(0.1), {Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)})
        end
    end)

    print(":: UI Framework Hazır ::")
end

return UILibrary
