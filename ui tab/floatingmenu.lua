local UI = {}

function UI:Init(Core)
    local Services = Core.Services
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "VergiHub_Float"
    pcall(function() ScreenGui.Parent = Services.CoreGui end)

    local Bubble = Instance.new("TextButton")
    Bubble.Name = "Trigger"
    Bubble.Size = UDim2.new(0, 50, 0, 50)
    Bubble.Position = UDim2.new(0, 20, 0.5, -25)
    Bubble.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    Bubble.Text = "V"
    Bubble.TextColor3 = Color3.fromRGB(255, 255, 255)
    Bubble.Font = Enum.Font.GothamBold
    Bubble.TextSize = 24
    Bubble.Parent = ScreenGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(1, 0)
    Corner.Parent = Bubble

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Thickness = 2
    Stroke.Parent = Bubble

    -- AÇMA / KAPAMA MANTIĞI (FİX)
    Bubble.MouseButton1Click:Connect(function()
        if Core.UI_MainFrame then
            Core.UI_MainFrame.Visible = not Core.UI_MainFrame.Visible
        else
            warn("UI Main Frame henüz yüklenmedi veya bulunamadı!")
        end
    end)
    
    -- DRAGGABLE (SÜRÜKLEME)
    local Dragging, DragInput, DragStart, StartPos
    Bubble.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 then
            Dragging = true
            DragStart = Input.Position
            StartPos = Bubble.Position
            Input.Changed:Connect(function() if Input.UserInputState == Enum.UserInputState.End then Dragging = false end end)
        end
    end)
    Bubble.InputChanged:Connect(function(Input) if Input.UserInputType == Enum.UserInputType.MouseMovement then DragInput = Input end end)
    Services.UserInputService.InputChanged:Connect(function(Input)
        if Input == DragInput and Dragging then
            local Delta = Input.Position - DragStart
            Bubble.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
        end
    end)

    print(":: Floating Menu Init Success ::")
end

return UI
