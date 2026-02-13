--[[
    VergiHub Module: Floating Menu
    Author: VergiAI
]]

local Float = {}
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

function Float:Init(Core)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "VergiHub_Float"
    pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)

    local Button = Instance.new("TextButton")
    Button.Name = "TriggerBtn"
    Button.Size = UDim2.new(0, 50, 0, 50)
    Button.Position = UDim2.new(0, 50, 0.5, -25) -- Sol Ortada Başla
    Button.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    Button.Text = "V"
    Button.Font = Enum.Font.GothamBlack
    Button.TextSize = 24
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.AutoButtonColor = false
    Button.Parent = ScreenGui

    -- Yuvarlaklık
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(1, 0)
    Corner.Parent = Button

    -- Beyaz Glow Efekti (Stroke)
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(255, 255, 255)
    Stroke.Thickness = 2
    Stroke.Parent = Button

    -- Tıklama Mantığı
    Button.MouseButton1Click:Connect(function()
        if Core.UI_MainFrame then
            local Frame = Core.UI_MainFrame
            Frame.Visible = not Frame.Visible
            
            -- Butona basınca ufak bir animasyon
            TweenService:Create(Button, TweenInfo.new(0.1), {Rotation = Frame.Visible and 90 or 0}):Play()
        else
            warn("UI Main Frame bulunamadı! Lütfen scripti tekrar çalıştırın.")
        end
    end)

    -- Sürükleme (Draggable) Mantığı
    local Dragging, DragInput, DragStart, StartPos

    Button.InputBegan:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
            Dragging = true
            DragStart = Input.Position
            StartPos = Button.Position

            Input.Changed:Connect(function()
                if Input.UserInputState == Enum.UserInputState.End then
                    Dragging = false
                end
            end)
        end
    end)

    Button.InputChanged:Connect(function(Input)
        if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
            DragInput = Input
        end
    end)

    UserInputService.InputChanged:Connect(function(Input)
        if Input == DragInput and Dragging then
            local Delta = Input.Position - DragStart
            local Goal = UDim2.new(
                StartPos.X.Scale, StartPos.X.Offset + Delta.X,
                StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y
            )
            -- Sürüklerken Tween kullanımı pürüzsüzlük sağlar
            TweenService:Create(Button, TweenInfo.new(0.05), {Position = Goal}):Play()
        end
    end)
    
    print(":: Floating Menu Initialized ::")
end

return Float
