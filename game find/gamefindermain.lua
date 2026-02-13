--[[
    VergiHub - Game Finder v1.0 (Preview)
    Oyunu otomatik tespit eder ve desteklenen oyun modüllerini yükler
    Bildirim sistemi ile kullanıcıya geri bildirim verir
]]

local BASE_URL = "https://raw.githubusercontent.com/BaranBey1331/VergiHub/main/"
local Settings = getgenv().VergiHub
local Theme = Settings.UI.Theme

-- Servisler
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")

-- ==========================================
-- BİLDİRİM SİSTEMİ (Sağ Alt Köşe)
-- ==========================================

-- Bildirim GUI
local NotifGui = Instance.new("ScreenGui")
NotifGui.Name = "VergiHubNotifications"
NotifGui.ResetOnSpawn = false
NotifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
NotifGui.Parent = game.CoreGui

-- Bildirim konteyneri (sağ alt)
local NotifContainer = Instance.new("Frame")
NotifContainer.Name = "Container"
NotifContainer.Size = UDim2.new(0, 320, 1, 0)
NotifContainer.Position = UDim2.new(1, -330, 0, 0)
NotifContainer.BackgroundTransparency = 1
NotifContainer.Parent = NotifGui

local notifLayout = Instance.new("UIListLayout")
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifLayout.Padding = UDim.new(0, 8)
notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifLayout.Parent = NotifContainer

local notifPadding = Instance.new("UIPadding")
notifPadding.PaddingBottom = UDim.new(0, 15)
notifPadding.PaddingRight = UDim.new(0, 5)
notifPadding.Parent = NotifContainer

-- Bildirim gönderme fonksiyonu
-- tipler: "success" (yeşil), "error" (kırmızı), "info" (mor), "warning" (turuncu)
local function sendNotification(title, message, notifType, duration)
    duration = duration or 4

    -- Renk belirleme
    local colors = {
        success = {
            bg = Color3.fromRGB(20, 35, 20),
            accent = Color3.fromRGB(80, 220, 100),
            icon = "✅"
        },
        error = {
            bg = Color3.fromRGB(35, 20, 20),
            accent = Color3.fromRGB(255, 70, 70),
            icon = "❌"
        },
        info = {
            bg = Color3.fromRGB(25, 20, 40),
            accent = Color3.fromRGB(138, 43, 226),
            icon = "🔮"
        },
        warning = {
            bg = Color3.fromRGB(35, 30, 15),
            accent = Color3.fromRGB(255, 180, 50),
            icon = "⚠️"
        }
    }

    local color = colors[notifType] or colors.info

    -- Ana bildirim frame
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(1, 0, 0, 72)
    notif.BackgroundColor3 = color.bg
    notif.BorderSizePixel = 0
    notif.BackgroundTransparency = 1 -- Animasyon için başta görünmez
    notif.ClipsDescendants = true
    notif.Parent = NotifContainer

    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 10)
    notifCorner.Parent = notif

    -- Sol accent çizgisi
    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 4, 1, 0)
    accentBar.Position = UDim2.new(0, 0, 0, 0)
    accentBar.BackgroundColor3 = color.accent
    accentBar.BorderSizePixel = 0
    accentBar.Parent = notif

    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, 2)
    accentCorner.Parent = accentBar

    -- İkon
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Text = color.icon
    iconLabel.Size = UDim2.new(0, 30, 0, 30)
    iconLabel.Position = UDim2.new(0, 14, 0, 12)
    iconLabel.BackgroundTransparency = 1
    iconLabel.TextSize = 20
    iconLabel.Parent = notif

    -- Başlık
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Text = title
    titleLabel.Size = UDim2.new(1, -60, 0, 22)
    titleLabel.Position = UDim2.new(0, 48, 0, 10)
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextColor3 = color.accent
    titleLabel.TextSize = 14
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
    titleLabel.Parent = notif

    -- Mesaj
    local msgLabel = Instance.new("TextLabel")
    msgLabel.Text = message
    msgLabel.Size = UDim2.new(1, -60, 0, 30)
    msgLabel.Position = UDim2.new(0, 48, 0, 32)
    msgLabel.BackgroundTransparency = 1
    msgLabel.TextColor3 = Color3.fromRGB(200, 200, 210)
    msgLabel.TextSize = 12
    msgLabel.Font = Enum.Font.Gotham
    msgLabel.TextXAlignment = Enum.TextXAlignment.Left
    msgLabel.TextWrapped = true
    msgLabel.TextYAlignment = Enum.TextYAlignment.Top
    msgLabel.Parent = notif

    -- Alt ilerleme çubuğu (zamanlayıcı)
    local progressBG = Instance.new("Frame")
    progressBG.Size = UDim2.new(1, -8, 0, 3)
    progressBG.Position = UDim2.new(0, 4, 1, -6)
    progressBG.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    progressBG.BorderSizePixel = 0
    progressBG.Parent = notif

    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(1, 0)
    progressCorner.Parent = progressBG

    local progressFill = Instance.new("Frame")
    progressFill.Size = UDim2.new(1, 0, 1, 0)
    progressFill.BackgroundColor3 = color.accent
    progressFill.BorderSizePixel = 0
    progressFill.Parent = progressBG

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = progressFill

    -- Giriş animasyonu (sağdan kayarak gelir)
    notif.Position = UDim2.new(1, 50, 0, 0) -- Ekran dışında başla
    TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0,
        Position = UDim2.new(0, 0, 0, 0)
    }):Play()

    -- İlerleme çubuğu animasyonu
    TweenService:Create(progressFill, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 1, 0)
    }):Play()

    -- Süre dolunca kapat
    task.delay(duration, function()
        if notif and notif.Parent then
            local fadeOut = TweenService:Create(notif, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                BackgroundTransparency = 1,
                Position = UDim2.new(1, 50, 0, 0)
            })
            fadeOut:Play()
            fadeOut.Completed:Wait()
            
            if notif and notif.Parent then
                notif:Destroy()
            end
        end
    end)
end

-- Fonksiyonu global yap (diğer modüller de kullanabilsin)
getgenv().VergiHub.Notify = sendNotification

-- ==========================================
-- OYUN TESPİT SİSTEMİ
-- ==========================================

-- Desteklenen oyunlar tablosu
-- PlaceId => oyun bilgisi
local SUPPORTED_GAMES = {
    [286090429] = {
        name = "Arsenal",
        folder = "arsenal",
        modules = {
            {path = "aimbot%20tab/aimbot.lua", label = "Arsenal Aimbot"},
            {path = "ui%20tab/uimain.lua", label = "Arsenal UI"},
        }
    },
    -- İleride eklenecek oyunlar:
    -- [2377868063] = { name = "Da Hood", folder = "dahood", modules = {...} },
    -- [5581042867] = { name = "Rivals", folder = "rivals", modules = {...} },
}

-- Modül yükleme
local function loadGameModule(gamePath, label)
    local url = BASE_URL .. "game%20find/" .. gamePath
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    
    if success then
        print("[GameFinder] ✅ " .. label .. " yüklendi!")
        return true
    else
        warn("[GameFinder] ❌ " .. label .. " yüklenemedi: " .. tostring(result))
        return false
    end
end

-- Ana tespit fonksiyonu
local function detectAndLoad()
    local placeId = game.PlaceId
    local gameName = "Bilinmeyen"

    -- Oyun adını almaya çalış
    pcall(function()
        gameName = MarketplaceService:GetProductInfo(placeId).Name
    end)

    print("[GameFinder] 🔍 Oyun tespit ediliyor...")
    print("[GameFinder] 📋 PlaceId: " .. placeId .. " | Oyun: " .. gameName)

    -- Başlangıç bildirimi
    sendNotification("Game Finder", "Oyun taranıyor...", "info", 3)
    task.wait(1.5)

    -- Desteklenen oyun mu kontrol et
    local gameData = SUPPORTED_GAMES[placeId]

    if gameData then
        -- ✅ Desteklenen oyun bulundu
        print("[GameFinder] ✅ Desteklenen oyun: " .. gameData.name)

        sendNotification(
            "Oyun Tespit Edildi!",
            gameData.name .. " desteği yükleniyor...",
            "success",
            4
        )

        task.wait(1)

        -- Oyun modüllerini yükle
        local allSuccess = true
        for _, moduleInfo in ipairs(gameData.modules) do
            local fullPath = gameData.folder .. "/" .. moduleInfo.path
            local loaded = loadGameModule(fullPath, moduleInfo.label)
            
            if loaded then
                sendNotification(
                    "Modül Yüklendi",
                    moduleInfo.label .. " aktif!",
                    "success",
                    3
                )
            else
                allSuccess = false
                sendNotification(
                    "Modül Hatası",
                    moduleInfo.label .. " yüklenemedi!",
                    "error",
                    4
                )
            end
            task.wait(0.8)
        end

        if allSuccess then
            sendNotification(
                "🎮 " .. gameData.name,
                "Tüm oyun özellikleri aktif!",
                "success",
                5
            )
        end

        -- Global'e kaydet
        getgenv().VergiHub.DetectedGame = gameData.name
        getgenv().VergiHub.GameSupported = true

    else
        -- ❌ Desteklenmeyen oyun
        print("[GameFinder] ⚠️ Desteklenmeyen oyun: " .. gameName)

        sendNotification(
            "Oyun Desteklenmiyor",
            gameName .. " (" .. placeId .. ") için özel destek bulunmuyor.",
            "warning",
            5
        )

        task.wait(1)

        sendNotification(
            "Genel Mod Aktif",
            "Evrensel aimbot ve ESP kullanılıyor.",
            "info",
            4
        )

        getgenv().VergiHub.DetectedGame = gameName
        getgenv().VergiHub.GameSupported = false
    end
end

-- Tespit başlat
task.spawn(detectAndLoad)

print("[VergiHub] 🔍 Game Finder v1.0 hazır!")
return sendNotification
