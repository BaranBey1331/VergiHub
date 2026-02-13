local UI = {}

function UI:Init(Core)
    local UserInputService = Core.Services.UserInputService
    local TweenService = Core.Services.TweenService
    local Players = Core.Services.Players

    -- GUI Oluştur
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "VergiHubUI"
    ScreenGui.ResetOnSpawn = false
    -- Güvenli yerleşim (CoreGui veya PlayerGui)
    pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
    if not ScreenGui.Parent then ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end

    -- 1. Yüzen Balon (Floating Bubble)
    local Bubble = Instance.new("ImageButton")
    Bubble.Name = "Bubble"
    Bubble.Size = UDim2.new(0, 50, 0, 50)
    Bubble.Position = UDim2.new(0.1, 0, 0.1, 0) -- Başlangıç konumu
    Bubble.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Bubble.Image = "rbxassetid://13460405230" -- Logo veya İkon (Örnek icon)
    Bubble.Parent = ScreenGui
    
    local BubbleCorner = Instance.new("UICorner")
    BubbleCorner.CornerRadius = UDim.new(1, 0) -- Tam Yuvarlak
    BubbleCorner.Parent = Bubble

    local BubbleStroke = Instance.new("UIStroke")
    BubbleStroke.Color = Color3.fromRGB(255, 0, 0)
    BubbleStroke.Thickness = 2
    BubbleStroke.Parent = Bubble

    -- 2. Ana Menü (Panel)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "Menu"
    MainFrame.Size = UDim2.new(0, 200, 0, 250)
    MainFrame.Position = UDim2.new(0.15, 0, 0.1, 0) -- Balonun yanı
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    MainFrame.Visible = false -- Başlangıçta gizli
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainFrame

    local Title = Instance.new("TextLabel")
    Title.Text = "VERGIHUB"
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBlack
    Title.Parent = MainFrame

    local Container = Instance.new("UIListLayout")
    Container.Parent = MainFrame
    Container.Padding = UDim.new(0, 5)
    Container.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Container.SortOrder = Enum.SortOrder.LayoutOrder
    
    -- Padding (Boşluk bırakıcı)
    local Pad = Instance.new("UIPadding")
    Pad.PaddingTop = UDim.new(0, 35)
    Pad.Parent = MainFrame

    -- Button Oluşturucu
    local function CreateButton(Text, Table, Key)
        local Btn = Instance.new("TextButton")
        Btn.Size = UDim2.new(0.9, 0, 0, 30)
        Btn.BackgroundColor3 = Table[Key] and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(60, 60, 60)
        Btn.Text = Text
        Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        Btn.Font = Enum.Font.GothamSemibold
        Btn.Parent = MainFrame
        
        local BtnCorner = Instance.new("UICorner")
        BtnCorner.CornerRadius = UDim.new(0, 6)
        BtnCorner.Parent = Btn

        Btn.MouseButton1Click:Connect(function()
            Table[Key] = not Table[Key]
            -- Renk değişimi animasyonu
            local Goal = {BackgroundColor3 = Table[Key] and Color3.fromRGB(40, 200, 40) or Color3.fromRGB(60, 60, 60)}
            TweenService:Create(Btn, TweenInfo.new(0.3), Goal):Play()
        end)
    end

    -- Menü Öğeleri
    CreateButton("Aimbot Aktif", Core.Settings.Aimbot, "Enabled")
    CreateButton("Takım Kontrolü", Core.Settings.Aimbot, "TeamCheck")
    CreateButton("Box ESP", Core.Settings.Visuals, "Box")
    CreateButton("Name ESP", Core.Settings.Visuals, "Names")
    CreateButton("Health Bar", Core.Settings.Visuals, "Health")

    -- 3. Sürükleme Mantığı (Draggable Bubble)
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
            -- Menüyü de balonla beraber taşı
            MainFrame.Position = UDim2.new(Bubble.Position.X.Scale, Bubble.Position.X.Offset + 60, Bubble.Position.Y.Scale, Bubble.Position.Y.Offset)
        end
    end)

    -- 4. Açma/Kapama Mantığı
    Bubble.MouseButton1Click:Connect(function()
        -- Eğer sürüklenmiyorsa tıkla
        if not Dragging then
            Core.Settings.UI.Open = not Core.Settings.UI.Open
            MainFrame.Visible = Core.Settings.UI.Open
            
            -- Menüyü balonun yanına hizala (Güncel pozisyon)
            MainFrame.Position = UDim2.new(Bubble.Position.X.Scale, Bubble.Position.X.Offset + 60, Bubble.Position.Y.Scale, Bubble.Position.Y.Offset)
        end
    end)

    print(":: Yüzen UI Yüklendi ::")
end

return UI

