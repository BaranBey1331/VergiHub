--[[
    ██╗   ██╗███████╗██████╗  ██████╗ ██╗██╗  ██╗██╗   ██╗██████╗ 
    ██║   ██║██╔════╝██╔══██╗██╔════╝ ██║██║  ██║██║   ██║██╔══██╗
    ██║   ██║█████╗  ██████╔╝██║  ███╗██║███████║██║   ██║██████╔╝
    ╚██╗ ██╔╝██╔══╝  ██╔══██╗██║   ██║██║██╔══██║██║   ██║██╔══██╗
     ╚████╔╝ ███████╗██║  ██║╚██████╔╝██║██║  ██║╚██████╔╝██████╔╝
      ╚═══╝  ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ 
    
    VergiHub v1.3 - Ana Yukleyici
    Gelistirici: Baran
    Platform: Roblox
    UI: iOS 26 Liquid Glass
]]

local BASE_URL = "https://raw.githubusercontent.com/BaranBey1331/VergiHub/main/"

-- Coklu calisma engeli
if getgenv().VergiHubLoaded then
    warn("[VergiHub] Zaten yuklu!")
    return
end
getgenv().VergiHubLoaded = true

-- Servisler
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- ==========================================
-- GLOBAL AYAR TABLOSU (Her sey kapali)
-- ==========================================

getgenv().VergiHub = {
    Version = "1.3.0",
    Player = LocalPlayer.Name,

    -- Aimbot ayarlari
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

    -- HardLock ayarlari
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

    -- ESP ayarlari
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

    -- Bypass ayarlari
    Bypass = {
        Ring1 = false,
        Ring2 = false,
        Ring3 = false,
        Ring4 = false,
    },

    -- UI ayarlari
    UI = {
        Visible = true,
        ToggleKey = Enum.KeyCode.RightShift,
        Theme = {}, -- Glass Engine tarafindan doldurulacak
    },
}

-- ==========================================
-- MODUL YUKLEME
-- ==========================================

local function loadModule(path, name)
    local success, result = pcall(function()
        return loadstring(game:HttpGet(BASE_URL .. path))()
    end)

    if success then
        print("[VergiHub] + " .. name)
        return result
    else
        warn("[VergiHub] x " .. name .. ": " .. tostring(result))
        return nil
    end
end

print("[VergiHub] Yukleme basliyor...")
print("[VergiHub] Kullanici: " .. LocalPlayer.Name)

-- ==========================================
-- BYPASS KATMANLARI (Oncelikli - koruma aktif olsun)
-- ==========================================

task.wait(0.2)
loadModule("Bypass/ring4.lua", "Ring 4 - Basic Bypass")
task.wait(0.1)
loadModule("Bypass/ring3.lua", "Ring 3 - ESP/Aim Bypass")
task.wait(0.1)
loadModule("Bypass/ring2.lua", "Ring 2 - Anti-Cheat Bypass")
task.wait(0.1)
loadModule("Bypass/ring1.lua", "Ring 1 - Byfron Bypass")

-- ==========================================
-- UI MODULLERI (Liquid Glass - sira onemli!)
-- ==========================================

task.wait(0.3)
loadModule("ui%20tab/floatingmenu.lua", "Floating Menu")

task.wait(0.2)
loadModule("ui%20tab/uiliquidglass1.lua", "Glass Engine")

task.wait(0.2)
loadModule("ui%20tab/uiliquidglass2.lua", "Glass UI Structure")

task.wait(0.2)
loadModule("ui%20tab/uiliquidglass3.lua", "Glass Controls & Tabs")

-- ==========================================
-- AIMBOT MODULLERI
-- ==========================================

task.wait(0.3)
loadModule("aimbot%20tab/aimbot.lua", "Aimbot Engine v3")

task.wait(0.2)
loadModule("aimbot%20tab/hardlock.lua", "HardLock v2")

task.wait(0.3)
loadModule("aimbot%20tab/esp.lua", "ESP Visuals")

-- ==========================================
-- GAME FINDER (En son yukle)
-- ==========================================

task.wait(0.5)
loadModule("game%20find/gamefindermain.lua", "Game Finder")

-- ==========================================
-- YUKLEME TAMAMLANDI
-- ==========================================

print("[VergiHub] ================================")
print("[VergiHub] Tum moduller yuklendi!")
print("[VergiHub] Versiyon: " .. getgenv().VergiHub.Version)
print("[VergiHub] UI: Liquid Glass")
print("[VergiHub] Menu tusu: RightShift")
print("[VergiHub] ================================")
