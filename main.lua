--[[
    VergiHub v1.2 - Ana Yükleyici
    + HardLock modülü
    + Bypass katman sistemi (Ring 1-4)
]]

local BASE_URL = "https://raw.githubusercontent.com/BaranBey1331/VergiHub/main/"

if getgenv().VergiHubLoaded then
    warn("[VergiHub] Zaten yuklu!")
    return
end
getgenv().VergiHubLoaded = true

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Global ayar tablosu
getgenv().VergiHub = {
    Version = "1.2.0",
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

    HardLock = {
        Enabled = false,
        Mode = "Snap",
        LockKey = Enum.KeyCode.Q,
        TargetPart = "Head",
        OverrideTarget = false,
        AutoFire = false,
        FlickSpeed = 0.08,
        FlickReturn = 0.3,
        RagePrediction = 0.2,
        Indicator = false,
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

    Bypass = {
        Ring1 = false, -- Byfron seviye
        Ring2 = false, -- Anti-cheat seviye
        Ring3 = false, -- ESP/Aimbot koruma
        Ring4 = false, -- Basit bypass
    },

    UI = {
        Visible = true,
        ToggleKey = Enum.KeyCode.RightShift,
        Theme = {
            Background    = Color3.fromRGB(13, 14, 22),
            Surface       = Color3.fromRGB(21, 23, 34),
            Surface2      = Color3.fromRGB(28, 31, 46),
            TopBar        = Color3.fromRGB(18, 19, 30),
            Primary       = Color3.fromRGB(124, 58, 237),
            Accent        = Color3.fromRGB(167, 139, 250),
            AccentGlow    = Color3.fromRGB(196, 181, 253),
            Success       = Color3.fromRGB(52, 211, 153),
            Error         = Color3.fromRGB(248, 113, 113),
            Warning       = Color3.fromRGB(251, 191, 36),
            Text          = Color3.fromRGB(226, 232, 240),
            TextDim       = Color3.fromRGB(148, 163, 184),
            TextMuted     = Color3.fromRGB(100, 116, 139),
            ToggleOn      = Color3.fromRGB(124, 58, 237),
            ToggleOff     = Color3.fromRGB(51, 65, 85),
            SliderFill    = Color3.fromRGB(124, 58, 237),
            SliderTrack   = Color3.fromRGB(30, 41, 59),
            Border        = Color3.fromRGB(30, 41, 59),
            TabActive     = Color3.fromRGB(124, 58, 237),
            TabInactive   = Color3.fromRGB(28, 31, 46),
        }
    }
}

local function loadModule(path, name)
    local s, r = pcall(function()
        return loadstring(game:HttpGet(BASE_URL .. path))()
    end)
    if s then
        print("[VergiHub] + " .. name)
        return r
    else
        warn("[VergiHub] x " .. name .. ": " .. tostring(r))
        return nil
    end
end

print("[VergiHub] Yukleme basliyor...")
print("[VergiHub] Kullanici: " .. LocalPlayer.Name)

-- Bypass katmanları ÖNCE yükle (koruma aktif olsun)
task.wait(0.2)
loadModule("Bypass/ring4.lua", "Ring 4 - Basic Bypass")
task.wait(0.1)
loadModule("Bypass/ring3.lua", "Ring 3 - ESP/Aim Bypass")
task.wait(0.1)
loadModule("Bypass/ring2.lua", "Ring 2 - Anti-Cheat Bypass")
task.wait(0.1)
loadModule("Bypass/ring1.lua", "Ring 1 - Byfron Bypass")

-- UI modülleri
task.wait(0.3)
loadModule("ui%20tab/floatingmenu.lua", "Floating Menu")
task.wait(0.3)
loadModule("ui%20tab/uimain.lua", "UI Dashboard")

-- Aimbot modülleri
task.wait(0.3)
loadModule("aimbot%20tab/aimbot.lua", "Aimbot Engine")
task.wait(0.2)
loadModule("aimbot%20tab/hardlock.lua", "HardLock")
task.wait(0.3)
loadModule("aimbot%20tab/esp.lua", "ESP Visuals")

-- Game Finder
task.wait(0.5)
loadModule("game%20find/gamefindermain.lua", "Game Finder")

print("[VergiHub] Tum moduller yuklendi!")
print("[VergiHub] Menu tusu: RightShift")
