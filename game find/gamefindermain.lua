--[[
    VergiHub - Game Finder v1.1 (Bildirim UI Rework)
    Emoji-free, yeni palette ile bildirim sistemi
    Oyun tespit + modül yükleme
]]

local BASE_URL = "https://raw.githubusercontent.com/BaranBey1331/VergiHub/main/"
local Settings = getgenv().VergiHub
local Theme = Settings.UI.Theme

-- Servisler
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")

-- ==========================================
-- BİLDİRİM SİSTEMİ (Reworked)
-- ==========================================

-- Eski varsa kaldır
if game.CoreGui:FindFirstChild("VergiHubNotifications") then
    game.CoreGui:FindFirstChild("VergiHubNotifications"):Destroy()
end

local NotifGui = Instance.new("ScreenGui")
NotifGui.Name = "VergiHubNotifications"
NotifGui.ResetOnSpawn = false
NotifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
NotifGui.Parent = game.CoreGui

-- Sağ alt konteyner
local NotifContainer = Instance.new("Frame")
NotifContainer.Name = "Container"
NotifContainer.Size = UDim2.new(0, 300, 1, 0)
NotifContainer.Position = UDim2.new(1, -310, 0, 0)
NotifContainer.BackgroundTransparency = 1
NotifContainer.Parent = NotifGui

local notifLayout = Instance.new("UIListLayout")
notifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifLayout.Padding = UDim.new(0, 6)
notifLayout.SortOrder = Enum.SortOrder.LayoutOrder
notifLayout.Parent = NotifContainer

local notifPadding = Instance.new("UIPadding")
notifPadding.PaddingBottom = UDim.new(0, 12)
notifPadding.PaddingRight = UDim.new(0, 4)
notifPadding.Parent = NotifContainer

-- Bildirim tipleri: renk ve ikon tanımları (emoji-free)
local NOTIF_TYPES = {
    success = {
        bg = Color3.fromRGB(13, 25, 18),
        accent = Color3.fromRGB(52, 211, 153),       -- Mint yeşili
        iconBg = Color3.fromRGB(20, 45, 30),
        icon = "✓",                                    -- Basit checkmark
    },
    error = {
        bg = Color3.fromRGB(25, 13, 13),
        accent = Color3.fromRGB(248, 113, 113),       -- Soft kırmızı
        iconBg = Color3.fromRGB(45, 20, 20),
        icon = "!",
    },
    info = {
        bg = Color3.fromRGB(15, 13, 28),
        accent = Color3.fromRGB(167, 139, 250),       -- Lavanta
        iconBg = Color3.fromRGB(30, 22, 50),
        icon = "i",
    },
    warning = {
        bg = Color3.fromRGB(28, 22, 10),
        accent = Color3.fromRGB(251, 191, 36),        -- Altın sarısı
        iconBg = Color3.fromRGB(45, 35, 15),
        icon = "!",
    }
}

local function sendNotification(title, message, notifType, duration)
    duration = duration or 4
    local style = NOTIF_TYPES[notifType] or NOTIF_TYPES.info

    -- Ana bildirim frame
    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(1, 0, 0, 68)
    notif.BackgroundColor3 = style.bg
    notif.BorderSizePixel = 0
    notif.BackgroundTransparency = 1
    notif.ClipsDescendants = true
    notif.Parent = NotifContainer

    local nCorner = Instance.new("UICorner")
    nCorner.CornerRadius = UDim.new(0, 10)
    nCorner.Parent = notif

    -- İnce kenarlık
    local nStroke = Instance.new("UIStroke")
    nStroke.Color = style.accent
    nStroke.Thickness = 1
    nStroke.Transparency = 0.7
    nStroke.Parent = notif

    -- Sol accent bar
    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 3, 1, -8)
    accentBar.Position = UDim2.new(0, 4, 0, 4)
    accentBar.BackgroundColor3 = style.accent
    accentBar.BorderSizePixel = 0
    accentBar.Parent = notif

    local abCorner = Instance.new("UICorner")
    abCorner.CornerRadius = UDim.new(0, 2)
    abCorner.Parent = accentBar

    -- İkon dairesi
    local iconCircle = Instance.new("Frame")
    iconCircle.Size = UDim2.new(0, 28, 0, 28)
    iconCircle.Position = UDim2.new(0, 14, 0, 12)
    iconCircle.BackgroundColor3 = style.iconBg
    iconCircle.BorderSizePixel = 0
    iconCircle.Parent = notif

    local icCorner = Instance.new("UICorner")
    icCorner.CornerRadius = UDim.new(1, 0)
    icCorner.Parent = iconCircle

    local iconStroke = Instance.new("UIStroke")
    iconStroke.Color = style.accent
    iconStroke.Thickness = 1
    iconStroke.Transparency = 0.5
    iconStroke.Parent = iconCircle

    local iconText = Instance.new("TextLabel")
    iconText.Text = style.icon
    iconText.Size = UDim2.new(1, 0, 1, 0)
    iconText.BackgroundTransparency = 1
    iconText.TextColor3 = style.accent
    iconText.TextSize = 14
    iconText.Font = Enum.Font.GothamBold
    iconText.Parent = iconCircle

    -- Başlık
    local titleLbl = Instance.new("TextLabel")
    titleLbl.Text = title
    titleLbl.Size = UDim2.new(1, -58, 0, 20)
    titleLbl.Position = UDim2.new(0, 48, 0, 10)
    titleLbl.BackgroundTransparency = 1
    titleLbl.TextColor3 = style.accent
    titleLbl.TextSize = 13
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
    titleLbl.Parent = notif

    -- Mesaj
    local msgLbl = Instance.new("TextLabel")
    msgLbl.Text = message
    msgLbl.Size = UDim2.new(1, -58, 0, 26)
    msgLbl.Position = UDim2.new(0, 48, 0, 30)
    msgLbl.BackgroundTransparency = 1
    msgLbl.TextColor3 = Color3.fromRGB(180, 185, 195)
    msgLbl.TextSize = 11
    msgLbl.Font = Enum.Font.Gotham
    msgLbl.TextXAlignment = Enum.TextXAlignment.Left
    msgLbl.TextWrapped = true
    msgLbl.TextYAlignment = Enum.TextYAlignment.Top
    msgLbl.Parent = notif

    -- Alt ilerleme çubuğu
    local progressTrack = Instance.new("Frame")
    progressTrack.Size = UDim2.new(1, -16, 0, 2)
    progressTrack.Position = UDim2.new(0, 8, 1, -6)
    progressTrack.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
    progressTrack.BorderSizePixel = 0
    progressTrack.Parent = notif

    local ptCorner = Instance.new("UICorner")
    ptCorner.CornerRadius = UDim.new(1, 0)
    ptCorner.Parent = progressTrack

    local progressFill = Instance.new("Frame")
    progressFill.Size = UDim2.new(1, 0, 1, 0)
    progressFill.BackgroundColor3 = style.accent
    progressFill.BackgroundTransparency = 0.3
    progressFill.BorderSizePixel = 0
    progressFill.Parent = progressTrack

    local pfCorner = Instance.new("UICorner")
    pfCorner.CornerRadius = UDim.new(1, 0)
    pfCorner.Parent = progressFill

    -- Giriş animasyonu (sağdan kayma + fade)
    notif.Position = UDim2.new(0, 40, 0, 0)
    local enterTween = TweenService:Create(notif, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0.05,
        Position = UDim2.new(0, 0, 0, 0)
    })
    enterTween:Play()

    -- İlerleme çubuğu animasyonu
    TweenService:Create(progressFill, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
        Size = UDim2.new(0, 0, 1, 0)
    }):Play()

    -- Süre dolunca çıkış animasyonu
    task.delay(duration, function()
        if notif and notif.Parent then
            local exitTween = TweenService:Create(notif, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 50, 0, 0)
            })
            TweenService:Create(nStroke, TweenInfo.new(0.35), {Transparency = 1}):Play()
            exitTween:Play()
            exitTween.Completed:Wait()

            if notif and notif.Parent then
                notif:Destroy()
            end
        end
    end)
end

-- Global erişim
getgenv().VergiHub.Notify = sendNotification

-- ==========================================
-- OYUN TESPİT SİSTEMİ
-- ==========================================

local SUPPORTED_GAMES = {
    [286090429] = {
        name = "Arsenal",
        folder = "arsenal",
        modules = {
            {path = "aimbot%20tab/aimbot.lua", label = "Arsenal Aimbot"},
            {path = "ui%20tab/uimain.lua", label = "Arsenal UI"},
        }
    },
}

local function loadGameModule(gamePath, label)
    local url = BASE_URL .. "game%20find/" .. gamePath
    local success, result = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)

    if success then
        print("[GameFinder] Loaded: " .. label)
        return true
    else
        warn("[GameFinder] Failed: " .. label .. " - " .. tostring(result))
        return false
    end
end

local function detectAndLoad()
    local placeId = game.PlaceId
    local gameName = "Unknown"

    pcall(function()
        gameName = MarketplaceService:GetProductInfo(placeId).Name
    end)

    print("[GameFinder] Scanning PlaceId: " .. placeId)

    sendNotification("Game Finder", "Scanning game...", "info", 3)
    task.wait(1.5)

    local gameData = SUPPORTED_GAMES[placeId]

    if gameData then
        -- Desteklenen oyun
        print("[GameFinder] Supported: " .. gameData.name)

        sendNotification(
            "Game Detected",
            gameData.name .. " — loading optimized modules...",
            "success",
            4
        )

        task.wait(1)

        local allSuccess = true
        for _, moduleInfo in ipairs(gameData.modules) do
            local fullPath = gameData.folder .. "/" .. moduleInfo.path
            local loaded = loadGameModule(fullPath, moduleInfo.label)

            if loaded then
                sendNotification("Module Loaded", moduleInfo.label .. " is active", "success", 3)
            else
                allSuccess = false
                sendNotification("Module Error", moduleInfo.label .. " failed to load", "error", 4)
            end
            task.wait(0.8)
        end

        if allSuccess then
            sendNotification(gameData.name, "All game features are active", "success", 5)
        end

        getgenv().VergiHub.DetectedGame = gameData.name
        getgenv().VergiHub.GameSupported = true

    else
        -- Desteklenmeyen oyun
        print("[GameFinder] Unsupported: " .. gameName)

        sendNotification(
            "Game Not Supported",
            gameName .. " — no optimized modules available",
            "warning",
            5
        )

        task.wait(1)

        sendNotification("Universal Mode", "Using generic aimbot and ESP", "info", 4)

        getgenv().VergiHub.DetectedGame = gameName
        getgenv().VergiHub.GameSupported = false
    end
end

task.spawn(detectAndLoad)

print("[VergiHub] Game Finder v1.1 hazir!")
return sendNotification
