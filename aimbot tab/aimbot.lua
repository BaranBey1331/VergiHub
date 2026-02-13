--[[
    Module: Aimbot
    Path: aimbot tab/aimbot.lua
]]

local Aimbot = {}
Aimbot.__index = Aimbot

-- Modül Değişkenleri (Private)
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local Core = nil -- Main dosyasındaki VergiHub tablosu buraya gelecek

-- Yardımcı Fonksiyonlar (Private)
local function getClosestPlayer()
    local closest = nil
    local shortestDistance = math.huge
    local mousePos = Core.Services.UserInputService:GetMouseLocation()

    for _, player in pairs(Core.Services.Players:GetPlayers()) do
        if player ~= Core.Services.LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            -- Takım kontrolü vs. buraya eklenecek (3000 satırlık logic buraya genişler)
            local pos, onScreen = Camera:WorldToViewportPoint(player.Character.Head.Position)
            if onScreen then
                local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                if distance < shortestDistance and distance <= Core.Settings.Aimbot.FOV then
                    shortestDistance = distance
                    closest = player.Character.Head
                end
            end
        end
    end
    return closest
end

-- Ana Döngü (Heartbeat/RenderStepped)
local function onUpdate()
    if not Core.Settings.Aimbot.Enabled then return end

    local target = getClosestPlayer()
    if target then
        -- Basit smoothing mantığı (Geliştirilebilir)
        local currentCFrame = Camera.CFrame
        local targetCFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        
        Camera.CFrame = currentCFrame:Lerp(targetCFrame, Core.Settings.Aimbot.Smooth * 0.1)
    end
end

-- Init Fonksiyonu (Main.lua tarafından çağrılır)
function Aimbot:Init(VergiHubInstance)
    Core = VergiHubInstance -- Main tablosunu hafızaya al
    print("[Module]: Aimbot yüklendi.")

    -- Döngüyü başlat
    RunService.RenderStepped:Connect(onUpdate)
end

return Aimbot

