--[[
    ██╗   ██╗███████╗██████╗  ██████╗ ██╗██╗  ██╗██╗   ██╗██████╗ 
    ██║   ██║██╔════╝██╔══██╗██╔════╝ ██║██║  ██║██║   ██║██╔══██╗
    ██║   ██║█████╗  ██████╔╝██║  ███╗██║███████║██║   ██║██████╔╝
    ╚██╗ ██╔╝██╔══╝  ██╔══██╗██║   ██║██║██╔══██║██║   ██║██╔══██╗
     ╚████╔╝ ███████╗██║  ██║╚██████╔╝██║██║  ██║╚██████╔╝██████╔╝
      ╚═══╝  ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ 
    
    VergiHub v1.1 - Ana Yükleyici
    Geliştirici: Baran
    Platform: Roblox
]]

local BASE_URL = "https://raw.githubusercontent.com/BaranBey1331/VergiHub/main/"

-- Çoklu çalışma engeli
if getgenv().VergiHubLoaded then
    warn("[VergiHub] Zaten yüklü!")
    return
end
getgenv().VergiHubLoaded = true

-- Servisler
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Global ayar tablosu - HER ŞEY KAPALI
getgenv().VergiHub = {
    Version = "1.1.0",
    Player = LocalPlayer.Name,
    
    Aimbot = {
        Enabled = false,
        TeamCheck = false,
        VisibleCheck = false,
        FOVEnabled = false,
        FOVSize = 150,
        Smoothness = 5,
        TargetPart = "Head",
        AimKey = Enum.UserInputType.MouseButton2,
        MaxDistance = 500,
        Prediction = false,
        PredictionAmount = 0.165,
        StickyAim = false,
    },
    
    ESP = {
        Enabled = false,
        Boxes = false,
        BoxType = "2D",
        Names = false,
        Health = false,
        Distance = false,
        Tracers = false,
        TracerOrigin = "Bottom",
        TeamCheck = false,
        TeamColor = false,
        EnemyColor = Color3.fromRGB(255, 50, 50),
        AllyColor = Color3.fromRGB(50, 255, 50),
        MaxDistance = 1000,
        ShowFOV = false,
        Chams = false,
        ChamsTransparency = 0.5,
    },
    
    UI = {
        Visible = true,
        ToggleKey = Enum.KeyCode.RightShift,
        Theme = {
            Primary = Color3.fromRGB(138, 43, 226),
            Secondary = Color3.fromRGB(25, 25, 35),
            Accent = Color3.fromRGB(180, 80, 255),
            Text = Color3.fromRGB(255, 255, 255),
            DimText = Color3.fromRGB(180, 180, 190),
            Background = Color3.fromRGB(18, 18, 28),
            TopBar = Color3.fromRGB(30, 30, 45),
            TabActive = Color3.fromRGB(138, 43, 226),
            TabInactive = Color3.fromRGB(40, 40, 55),
            ToggleOn = Color3.fromRGB(138, 43, 226),
            ToggleOff = Color3.fromRGB(60, 60, 75),
            SliderFill = Color3.fromRGB(138, 43, 226),
            Border = Color3.fromRGB(50, 50, 65),
        }
    }
}

-- Modül yükleme fonksiyonu
local function loadModule(path, name)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(BASE_URL .. path))()
    end)
    
    if success then
        print("[VergiHub] ✅ " .. name .. " yüklendi!")
        return result
    else
        warn("[VergiHub] ❌ " .. name .. " yüklenemedi: " .. tostring(result))
        return nil
    end
end

-- Yükleme başlat
print("[VergiHub] 🚀 Yükleme başlıyor...")
print("[VergiHub] 👤 Hoş geldin, " .. LocalPlayer.Name)

-- Ana modülleri yükle
task.wait(0.3)
loadModule("ui%20tab/floatingmenu.lua", "Floating Menu")

task.wait(0.3)
loadModule("ui%20tab/uimain.lua", "UI Dashboard")

task.wait(0.3)
loadModule("aimbot%20tab/aimbot.lua", "Aimbot Engine v2")

task.wait(0.3)
loadModule("aimbot%20tab/esp.lua", "ESP Visuals")

-- ==========================================
-- GAME FINDER SİSTEMİ (Preview)
-- ==========================================
task.wait(0.5)
loadModule("game%20find/gamefindermain.lua", "Game Finder")

print("[VergiHub] ✅ Tüm modüller yüklendi!")
print("[VergiHub] ⌨️ Menü tuşu: RightShift")
