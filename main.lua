--[[
    VergiHub - Kernel (Main.lua)
    Author: Baran
    Version: 1.0.0 (Production Ready)
    
    Architecture: Modular / Event-Driven
]]

local VergiHub = {
    _VERSION = "1.0.0",
    Settings = {}, -- Tüm hile ayarları burada tutulur (Centralized State)
    Modules = {},  -- Yüklenen modüller (Aimbot, ESP, vb.)
    Services = {}, -- Roblox servisleri (Players, RunService, vb.)
    BaseURL = "https://raw.githubusercontent.com/BaranBey1331/VergiHub/main/"
}

-- Servisleri Cache'le (Performans için)
VergiHub.Services.Players = game:GetService("Players")
VergiHub.Services.RunService = game:GetService("RunService")
VergiHub.Services.UserInputService = game:GetService("UserInputService")
VergiHub.Services.LocalPlayer = VergiHub.Services.Players.LocalPlayer

-- Global Ayar Deposu (Default Config)
VergiHub.Settings = {
    Aimbot = { Enabled = false, FOV = 100, Smooth = 5, Key = Enum.KeyCode.F },
    ESP = { Enabled = false, Box = true, Tracers = false },
    TriggerBot = { Enabled = false, Delay = 0.1 }
}

-- Güvenli Modül Yükleyici (Web Import)
function VergiHub:Import(path)
    local url = self.BaseURL .. path
    local success, result = pcall(function()
        return game:HttpGet(url)
    end)

    if not success then
        warn("[VergiHub Error]: Dosya indirilemedi -> " .. path)
        return nil
    end

    local func, loadErr = loadstring(result)
    if not func then
        warn("[VergiHub Syntax Error]: " .. path .. " -> " .. loadErr)
        return nil
    end

    return func() -- Modül tablosunu döndür
end

-- -------------------------------------------------------------------------
-- Modül Yükleme Sırası (Dependency Injection)
-- -------------------------------------------------------------------------

print("[VergiHub]: Başlatılıyor...")

-- 1. Özellik Modüllerini Yükle (Logic)
-- Link yapına uygun olarak boşluklar %20 ile ifade edilir
VergiHub.Modules.Aimbot = VergiHub:Import("aimbot%20tab/aimbot.lua")
VergiHub.Modules.ESP = VergiHub:Import("aimbot%20tab/esp.lua")
VergiHub.Modules.TriggerBot = VergiHub:Import("aimbot%20tab/triggerbot.lua")

-- Modülleri Başlat (Init)
-- Her modüle "self" (VergiHub) gönderiyoruz ki ayarlara erişebilsinler.
if VergiHub.Modules.Aimbot then VergiHub.Modules.Aimbot:Init(VergiHub) end
if VergiHub.Modules.ESP then VergiHub.Modules.ESP:Init(VergiHub) end
if VergiHub.Modules.TriggerBot then VergiHub.Modules.TriggerBot:Init(VergiHub) end

-- 2. Arayüzü Yükle (UI)
-- UI en son yüklenir çünkü modüllerin hazır olması gerekir.
local UILibrary = VergiHub:Import("ui%20tab/uimain.lua")
if UILibrary then
    UILibrary:Init(VergiHub)
end

print("[VergiHub]: Baran hocam, sistem aktif. İyi oyunlar.")
