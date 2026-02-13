--[[
    Module: UI Manager
    Path: ui tab/uimain.lua
]]

local UI = {}

function UI:Init(Core)
    print("[UI]: Arayüz yükleniyor...")
    
    -- Örnek olarak basit bir kütüphane veya kendi GUI kodların
    -- Burada Orion Lib veya benzeri bir yapı kullandığını varsayalım:
    
    local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()
    local Window = Library:MakeWindow({Name = "VergiHub - " .. Core._VERSION, HidePremium = false, SaveConfig = true})

    -- TAB: Aimbot
    local AimTab = Window:MakeTab({Name = "Aimbot", Icon = "rbxassetid://4483345998", PremiumOnly = false})

    -- Toggle: Aimbot Enabled
    AimTab:AddToggle({
        Name = "Aktif Et",
        Default = Core.Settings.Aimbot.Enabled,
        Callback = function(Value)
            Core.Settings.Aimbot.Enabled = Value -- Global ayarı güncelle
        end    
    })

    -- Slider: FOV
    AimTab:AddSlider({
        Name = "FOV Çapı",
        Min = 0,
        Max = 500,
        Default = Core.Settings.Aimbot.FOV,
        Color = Color3.fromRGB(255,0,0),
        Increment = 1,
        Callback = function(Value)
            Core.Settings.Aimbot.FOV = Value
        end    
    })
    
    -- TAB: ESP
    local ESPTab = Window:MakeTab({Name = "Visuals", Icon = "rbxassetid://4483345998", PremiumOnly = false})
    
    ESPTab:AddToggle({
        Name = "Kutu ESP",
        Default = Core.Settings.ESP.Box,
        Callback = function(Value)
            Core.Settings.ESP.Box = Value
        end    
    })

    Library:Init()
end

return UI

