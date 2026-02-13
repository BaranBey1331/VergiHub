local UI = {}

function UI:Init(Core)
    local UserInputService = Core.Services.UserInputService
    local TweenService = Core.Services.TweenService
    local LocalPlayer = Core.Services.Players.LocalPlayer
    
    -- ScreenGui
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "VergiHub_Float"
    pcall(function() ScreenGui.Parent = game.CoreGui end)
    if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer.PlayerGui end

    -- Yuvarlak Yüzen Buton
    local Bubble = Instance.new("TextButton")
    Bubble.Name = "ToggleBtn"
    Bubble.Size = UDim2.new(0, 50, 0, 50)
    Bubble.Position = UDim2.new(0.02, 0, 0.5, 0) -- Sol orta
    Bubble.BackgroundColor3 = Color3.fromRGB(15, 15, 15) -- Siyah
    Bubble.Text = "V"
    Bubble.TextColor3 = Color3.fromRGB(255, 255, 255)
    Bubble.Font = Enum.Font.GothamBlack
    Bubble.TextSize = 28
    Bubble.AutoButtonColor = false
    Bubble.Parent = ScreenGui

    -- Yuvarlaklık
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(1, 0)
    Corner.Parent = Bubble

    -- Beyaz Glow/Stroke efekt (Outline değil, iç gölge gibi temiz bir his)
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Thickness = 1.5 -- Çok ince zarif bir çizgi
    Stroke.Transparency = 0.5
    Stroke.Parent = Bubble

    -- Tıklama Animasyonu ve Logic
    local IsOpen = false
    Bubble.MouseButton1Click:Connect(function()
        IsOpen = not IsOpen
        Core.Settings.UI.Open = IsOpen
        
        if Core.UIFrame then
            Core.UIFrame.Visible = IsOpen
            
            -- Animasyonlu açılış (Pop effect)
            if IsOpen then
                Core.UIFrame.Size = UDim2.new(0, 0, 0, 0)
                Core.UIFrame.BackgroundTransparency = 1
                
                local Goal = {Size = UDim2.new(0, 600, 0, 400), BackgroundTransparency = 0}
                TweenService:Create(Core.UIFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), Goal):Play()
            end
        end

        -- Buton Animasyonu
        TweenService:Create(Bubble, TweenInfo.new(0.2), {Rotation = IsOpen and 180 or 0}):Play()
    end)
    
    -- Sürükleme Mantığı (Draggable)
    local Dragging, DragInput, DragStart, StartPos
    Bubble.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = Input.Position
            StartPos = Bubble.Position
            
            Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then Dragging = false end
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
            TweenService:Create(Bubble, TweenInfo.new(0.05), {
                Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
            }):Play()
        end
    end)

    print(":: Floating Menu Active ::")
end

return UI
