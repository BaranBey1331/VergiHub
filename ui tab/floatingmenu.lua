local UI = {}

function UI:Init(Core)
    local UserInputService = Core.Services.UserInputService
    local TweenService = Core.Services.TweenService
    local Players = Core.Services.Players
    local LocalPlayer = Players.LocalPlayer

    -- GUI Setup
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "VergiHubUI_Horizontal"
    ScreenGui.ResetOnSpawn = false
    
    pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
    if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

    -- 1. Floating Bubble (Siyah)
    local Bubble = Instance.new("TextButton") -- Image yerine TextButton daha net
    Bubble.Name = "Bubble"
    Bubble.Size = UDim2.new(0, 50, 0, 50)
    Bubble.Position = UDim2.new(0.05, 0, 0.5, -25)
    Bubble.BackgroundColor3 = Color3.new(0, 0, 0) -- Saf Siyah
    Bubble.Text = "V"
    Bubble.TextColor3 = Color3.new(1, 1, 1) -- Saf Beyaz
    Bubble.TextSize = 24
    Bubble.Font = Enum.Font.GothamBold
    Bubble.Parent = ScreenGui
    
    -- Bubble Stroke (Beyaz Çizgi)
    local BubbleStroke = Instance.new("UIStroke")
    BubbleStroke.Color = Color3.new(1, 1, 1)
    BubbleStroke.Thickness = 2
    BubbleStroke.Parent = Bubble
    
    local BubbleCorner = Instance.new("UICorner")
    BubbleCorner.CornerRadius = UDim.new(1, 0)
    BubbleCorner.Parent = Bubble

    -- 2. Horizontal Main Bar
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainBar"
    MainFrame.Size = UDim2.new(0, 0, 0, 50) -- Genişlik animasyonla açılacak
    MainFrame.Position = UDim2.new(1, 10, 0, 0) -- Balonun hemen sağı
    MainFrame.BackgroundColor3 = Color3.new(0, 0, 0) -- Siyah
    MainFrame.ClipsDescendants = true -- Taşmaları gizle (Animasyon için)
    MainFrame.Parent = Bubble -- Balonun içine koydum ki beraber hareket etsinler

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.new(1, 1, 1)
    MainStroke.Thickness = 1
    MainStroke.Parent = MainFrame

    -- Layout (Yatay)
    local Layout = Instance.new("UIListLayout")
    Layout.Parent = MainFrame
    Layout.FillDirection = Enum.FillDirection.Horizontal
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.VerticalAlignment = Enum.VerticalAlignment.Center
    Layout.Padding = UDim.new(0, 5)

    -- Padding
    local Pad = Instance.new("UIPadding")
    Pad.PaddingLeft = UDim.new(0, 10)
    Pad.PaddingRight = UDim.new(0, 10)
    Pad.Parent = MainFrame

    -- Toggle Button Oluşturucu (Kompakt)
    local function CreateToggle(Text, SettingTable, Key)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(0, 80, 0, 30) -- Sabit genişlik
        Btn.BackgroundColor3 = Color3.new(0, 0, 0)
        Btn.BorderColor3 = Color3.new(1, 1, 1)
        Btn.BorderSizePixel = 1
        Btn.Text = Text
        Btn.TextColor3 = SettingTable[Key] and Color3.new(1, 1, 1) or Color3.new(0.5, 0.5, 0.5) -- Aktifse Beyaz, Pasifse Gri
        Btn.Font = Enum.Font.GothamSemibold
        Btn.TextSize = 12
        Btn.Parent = MainFrame

        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 4)
        BtnCorner.Parent = Btn
        
        -- Beyaz Çerçeve (Stroke)
        local BtnStroke = Instance.new("UIStroke")
        BtnStroke.Color = SettingTable[Key] and Color3.new(1, 1, 1) or Color3.new(0.3, 0.3, 0.3)
        BtnStroke.Thickness = 1
        BtnStroke.Parent = Btn

        Btn.MouseButton1Click:Connect(function()
            SettingTable[Key] = not SettingTable[Key]
            
            -- Görsel Güncelleme
            if SettingTable[Key] then
                Btn.TextColor3 = Color3.new(1, 1, 1)
                BtnStroke.Color = Color3.new(1, 1, 1)
            else
                Btn.TextColor3 = Color3.new(0.5, 0.5, 0.5)
                BtnStroke.Color = Color3.new(0.3, 0.3, 0.3)
            end
        end)
    end

    -- Menü Öğeleri
    CreateToggle("AIMBOT", Core.Settings.Aimbot, "Enabled")
    CreateToggle("WALL", Core.Settings.Aimbot, "WallCheck")
    CreateToggle("ESP BOX", Core.Settings.Visuals, "Box")
    CreateToggle("ESP NAME", Core.Settings.Visuals, "Names")

    -- 3. Drag & Drop Mantığı
    local Dragging, DragInput, DragStart, StartPos
    
    Bubble.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = Input.Position
            StartPos = Bubble.Position
            
            Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    Bubble.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
            DragInput = Input
        end
    end)

    UserInputService.InputChanged:Connect(function(Input)
        if Input == DragInput and Dragging then
            local Delta = Input.Position - DragStart
            Bubble.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        end
    end)

    -- 4. Aç/Kapa Animasyonu
    local IsOpen = false
    Bubble.MouseButton1Click:Connect(function()
        if not Dragging then
            IsOpen = not IsOpen
            if IsOpen then
                -- Genişlet (Yatay)
                TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 360, 0, 50)}):Play()
            else
                -- Küçült
                TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {Size = UDim2.new(0, 0, 0, 50)}):Play()
            end
        end
    end)
end

return UI
