--[[
    VergiHub Kernel - Fix Build
    Author: Baran
]]

local VergiHub = {
    Settings = {
        Aimbot = {
            Enabled = false, -- Default: KAPALI
            Key = Enum.UserInputType.MouseButton2,
            Smoothing = 0.5,
            TeamCheck = false,
            WallCheck = false
        },
        Visuals = {
            Box = false, -- Default: KAPALI
            Names = false, -- Default: KAPALI
            Health = false -- Default: KAPALI
        },
        UI = {
            Open = false
        }
    },
    -- Global UI Referansı (İletişim için)
    UI_MainFrame = nil, 
    
    BaseURL = "https://raw.githubusercontent.com/BaranBey1331/VergiHub/main/",
    Services = {
        Players = game:GetService("Players"),
        RunService = game:GetService("RunService"),
        UserInputService = game:GetService("UserInputService"),
        TweenService = game:GetService("TweenService"),
        CoreGui = game:GetService("CoreGui")
    }
}

-- Global Erişim
getgenv().VergiHub = VergiHub

function VergiHub:Import(path)
    local url = self.BaseURL .. path
    local success, result = pcall(function() return game:HttpGet(url) end)
    if not success then return warn("HATA: " .. path) end
    local func, err = loadstring(result)
    if not func then return warn("SENTAKS: " .. err) end
    return func()
end

print(":: VergiHub Başlatılıyor ::")

-- Modülleri Sırayla Yükle (UI Önce)
local UI = VergiHub:Import("ui%20tab/uimain.lua")
if UI then UI:Init(VergiHub) end

local Float = VergiHub:Import("ui%20tab/floatingmenu.lua")
if Float then Float:Init(VergiHub) end

local ESP = VergiHub:Import("aimbot%20tab/esp.lua")
if ESP then task.spawn(function() ESP:Init(VergiHub) end) end

local Aimbot = VergiHub:Import("aimbot%20tab/aimbot.lua")
if Aimbot then task.spawn(function() Aimbot:Init(VergiHub) end) end

print(":: Sistem Hazır (Tüm Özellikler Kapalı) ::")
