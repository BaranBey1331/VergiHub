--[[
    ██╗   ██╗███████╗██████╗  ██████╗ ██╗██╗  ██╗██╗   ██╗██████╗ 
    ██║   ██║██╔════╝██╔══██╗██╔════╝ ██║██║  ██║██║   ██║██╔══██╗
    ██║   ██║█████╗  ██████╔╝██║  ███╗██║███████║██║   ██║██████╔╝
    ╚██╗ ██╔╝██╔══╝  ██╔══██╗██║   ██║██║██╔══██║██║   ██║██╔══██╗
     ╚████╔╝ ███████╗██║  ██║╚██████╔╝██║██║  ██║╚██████╔╝██████╔╝
      ╚═══╝  ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ 
    
    VergiHub v1.0 - Ana Yükleyici
    Geliştirici: Baran
    Platform: Roblox
]]

-- GitHub raw base URL
local BASE_URL = "https://raw.githubusercontent.com/BaranBey1331/VergiHub/main/"

-- Güvenlik kontrolü - çoklu çalışmayı engelle
if getgenv().VergiHubLoaded then
    warn("[VergiHub] Zaten yüklü!")
    return
end
getgenv().VergiHubLoaded = true

-- Servisler
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Global ayar tablosu - HER ŞEY KAPALI BAŞLAR
getgenv().VergiHub = {
    -- Genel bilgiler
    Version = "1.0.0",
    Player = LocalPlayer.Name,
    
    -- Aimbot Ayarları (tümü false)
    Aimbot = {
        Enabled = false,           -- Aimbot açık/kapalı
        TeamCheck = false,         -- Takım arkadaşını hedefleme
        VisibleCheck = false,      -- Görünürlük kontrolü (duvar arkası hedefleme)
        FOVEnabled = false,        -- FOV dairesi göster
        FOVSize = 150,             -- FOV yarıçapı (piksel)
        Smoothness = 5,            -- Yumuşaklık (1 = anlık, 10 = yavaş)
        TargetPart = "Head",       -- Hedef vücut parçası
        AimKey = Enum.UserInputType.MouseButton2, -- Sağ tık
        MaxDistance = 500,         -- Maksimum mesafe (stud)
        Prediction = false,        -- Hareket tahmini
        PredictionAmount = 0.165,  -- Tahmin çarpanı
        StickyAim = false,         -- Hedefe yapışma
    },
    
    -- ESP Ayarları (tümü false)
    ESP = {
        Enabled = false,           -- ESP açık/kapalı
        Boxes = false,             -- Kutu ESP
        BoxType = "2D",            -- "2D" veya "Corner"
        Names = false,             -- İsim gösterme
        Health = false,            -- Can barı
        Distance = false,          -- Mesafe gösterme
        Tracers = false,           -- Çizgi (ayaktan hedefe)
        TracerOrigin = "Bottom",   -- Çizgi başlangıcı: "Bottom", "Center", "Mouse"
        TeamCheck = false,         -- Takım arkadaşını gösterme
        TeamColor = false,         -- Takım rengini kullan
        EnemyColor = Color3.fromRGB(255, 50, 50),    -- Düşman rengi (kırmızı)
        AllyColor = Color3.fromRGB(50, 255, 50),     -- Dost rengi (yeşil)
        MaxDistance = 1000,        -- Maksimum ESP mesafesi
        ShowFOV = false,           -- FOV dairesi çizimi
        Chams = false,             -- Highlight/Chams
        ChamsTransparency = 0.5,   -- Chams şeffaflığı
    },
    
    -- UI Ayarları
    UI = {
        Visible = true,            -- Ana menü görünürlüğü
        ToggleKey = Enum.KeyCode.RightShift, -- Menü aç/kapat tuşu
        Theme = {
            Primary = Color3.fromRGB(138, 43, 226),    -- Ana renk (mor)
            Secondary = Color3.fromRGB(25, 25, 35),     -- Arka plan
            Accent = Color3.fromRGB(180, 80, 255),      -- Vurgu rengi
            Text = Color3.fromRGB(255, 255, 255),       -- Yazı rengi
            DimText = Color3.fromRGB(180, 180, 190),    -- Soluk yazı
            Background = Color3.fromRGB(18, 18, 28),    -- Ana arka plan
            TopBar = Color3.fromRGB(30, 30, 45),        -- Üst bar
            TabActive = Color3.fromRGB(138, 43, 226),   -- Aktif tab
            TabInactive = Color3.fromRGB(40, 40, 55),   -- Pasif tab
            ToggleOn = Color3.fromRGB(138, 43, 226),    -- Toggle açık
            ToggleOff = Color3.fromRGB(60, 60, 75),     -- Toggle kapalı
            SliderFill = Color3.fromRGB(138, 43, 226),  -- Slider dolgu
            Border = Color3.fromRGB(50, 50, 65),        -- Kenarlık
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

-- Yükleme sırası
print("[VergiHub] 🚀 Yükleme başlıyor...")
print("[VergiHub] 👤 Hoş geldin, " .. LocalPlayer.Name)

-- Modülleri sırayla yükle
task.wait(0.3)
loadModule("ui%20tab/floatingmenu.lua", "Floating Menu")

task.wait(0.3)
loadModule("ui%20tab/uimain.lua", "UI Dashboard")

task.wait(0.3)
loadModule("aimbot%20tab/aimbot.lua", "Aimbot Engine")

task.wait(0.3)
loadModule("aimbot%20tab/esp.lua", "ESP Visuals")

print("[VergiHub] ✅ Tüm modüller yüklendi!")
print("[VergiHub] ⌨️ Menü tuşu: RightShift")
