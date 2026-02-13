--[[
    VergiHub Kernel - Production Ready
    Author: Baran
]]

local VergiHub = {
    Settings = {
        -- Global Combat Settings
        Aimbot = {
            Enabled = true,
            Key = Enum.KeyCode.E,
            FOV = 120,
            Smoothing = 0.5, -- 0 ile 1 arası (Düşük = Daha legit)
            TargetPart = "Head",
            WallCheck = true,
            Prediction = 0.145, -- Ping/Velocity tahmin katsayısı
            ShowFOV = true
        },
        Visuals = {
            BoxEsp = true,
            Tracer = false
        }
    },
    BaseURL = "https://raw.githubusercontent.com/BaranBey1331/VergiHub/main/",
    Services = {
        Players = game:GetService("Players"),
        RunService = game:GetService("RunService"),
        UserInputService = game:GetService("UserInputService"),
        Workspace = game:GetService("Workspace")
    }
}

-- Global erişim (Debug için)
getgenv().VergiHub = VergiHub

-- Modül Yükleyici (GitHub Raw Çekici)
function VergiHub:Import(path)
    local url = self.BaseURL .. path
    local success, result = pcall(function() return game:HttpGet(url) end)
    if not success then return warn("CRITICAL: Dosya çekilemedi ->", path) end
    
    local func, err = loadstring(result)
    if not func then return warn("SYNTAX ERROR ->", path, err) end
    
    return func()
end

-- Başlatma Sırası
print(":: VergiHub Başlatılıyor ::")

-- 1. UI Yükle (Önce arayüz ki ayarları görelim)
local UI = VergiHub:Import("ui%20tab/uimain.lua")
if UI then UI:Init(VergiHub) end

-- 2. Aimbot Yükle (Logic)
local Aimbot = VergiHub:Import("aimbot%20tab/aimbot.lua")
if Aimbot then Aimbot:Init(VergiHub) end

print(":: Sistem Aktif ::")
