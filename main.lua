--[[
    VergiHub Kernel - Universal Build
    Author: Baran
]]

local VergiHub = {
    Settings = {
        Aimbot = {
            Enabled = true,
            Key = Enum.UserInputType.MouseButton2, -- Sağ Tık
            Smoothing = 0.2, -- 0.1 (Robotik) - 1.0 (Yavaş)
            TeamCheck = true
        },
        Visuals = {
            Box = true,
            Names = true,
            Health = true
        },
        UI = {
            Open = false -- UI Başlangıç durumu
        }
    },
    BaseURL = "https://raw.githubusercontent.com/BaranBey1331/VergiHub/main/",
    Services = {
        Players = game:GetService("Players"),
        RunService = game:GetService("RunService"),
        UserInputService = game:GetService("UserInputService"),
        TweenService = game:GetService("TweenService")
    }
}

-- Global Erişim
getgenv().VergiHub = VergiHub

-- Modül Import Fonksiyonu
function VergiHub:Import(path)
    local url = self.BaseURL .. path
    local success, result = pcall(function() return game:HttpGet(url) end)
    
    if not success then 
        warn(":: KRİTİK HATA :: Dosya yüklenemedi -> " .. path)
        return nil 
    end
    
    local func, loadErr = loadstring(result)
    if not func then 
        warn(":: SÖZDİZİMİ HATASI :: " .. path .. " -> " .. loadErr) 
        return nil 
    end
    
    return func()
end

print(":: VergiHub Başlatılıyor ::")

-- 1. Görsel Modüller (ESP)
local ESP = VergiHub:Import("aimbot%20tab/esp.lua")
if ESP then task.spawn(function() ESP:Init(VergiHub) end) end

-- 2. Savaş Modülleri (Aimbot)
local Aimbot = VergiHub:Import("aimbot%20tab/aimbot.lua")
if Aimbot then task.spawn(function() Aimbot:Init(VergiHub) end) end

-- 3. Arayüz (Floating UI)
local UI = VergiHub:Import("ui%20tab/floatingmenu.lua")
if UI then UI:Init(VergiHub) end

print(":: Sistem Hazır ::")
