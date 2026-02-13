--[[
    VergiHub - ESP Visuals v1.0
    Kutu, isim, can barı, mesafe, tracer, chams desteği
    Drawing API kullanır
]]

local Settings = getgenv().VergiHub.ESP

-- Servisler
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Her oyuncu için ESP çizim objeleri
local espObjects = {}

-- Tek bir oyuncu için ESP çizimleri oluştur
local function createESPForPlayer(player)
    if player == LocalPlayer then return end
    
    local drawings = {
        -- 2D Kutu
        BoxOutline = Drawing.new("Square"),
        Box = Drawing.new("Square"),
        
        -- İsim
        Name = Drawing.new("Text"),
        
        -- Mesafe
        Distance = Drawing.new("Text"),
        
        -- Can barı
        HealthBarOutline = Drawing.new("Square"),
        HealthBarBG = Drawing.new("Square"),
        HealthBar = Drawing.new("Square"),
        HealthText = Drawing.new("Text"),
        
        -- Tracer
        Tracer = Drawing.new("Line"),
    }
    
    -- Kutu ayarları
    drawings.BoxOutline.Thickness = 3
    drawings.BoxOutline.Color = Color3.fromRGB(0, 0, 0)
    drawings.BoxOutline.Filled = false
    drawings.BoxOutline.Visible = false
    
    drawings.Box.Thickness = 1.5
    drawings.Box.Filled = false
    drawings.Box.Visible = false
    
    -- İsim ayarları
    drawings.Name.Size = 14
    drawings.Name.Center = true
    drawings.Name.Outline = true
    drawings.Name.OutlineColor = Color3.fromRGB(0, 0, 0)
    drawings.Name.Font = Drawing.Fonts.Plex
    drawings.Name.Visible = false
    
    -- Mesafe ayarları
    drawings.Distance.Size = 13
    drawings.Distance.Center = true
    drawings.Distance.Outline = true
    drawings.Distance.OutlineColor = Color3.fromRGB(0, 0, 0)
    drawings.Distance.Font = Drawing.Fonts.Plex
    drawings.Distance.Visible = false
    
    -- Can barı arka plan
    drawings.HealthBarOutline.Thickness = 1
    drawings.HealthBarOutline.Color = Color3.fromRGB(0, 0, 0)
    drawings.HealthBarOutline.Filled = true
    drawings.HealthBarOutline.Visible = false
    
    drawings.HealthBarBG.Thickness = 1
    drawings.HealthBarBG.Color = Color3.fromRGB(40, 40, 40)
    drawings.HealthBarBG.Filled = true
    drawings.HealthBarBG.Visible = false
    
    drawings.HealthBar.Thickness = 1
    drawings.HealthBar.Filled = true
    drawings.HealthBar.Visible = false
    
    -- Can yazısı
    drawings.HealthText.Size = 12
    drawings.HealthText.Center = false
    drawings.HealthText.Outline = true
    drawings.HealthText.OutlineColor = Color3.fromRGB(0, 0, 0)
    drawings.HealthText.Font = Drawing.Fonts.Plex
    drawings.HealthText.Visible = false
    
    -- Tracer ayarları
    drawings.Tracer.Thickness = 1.5
    drawings.Tracer.Visible = false
    
    espObjects[player] = drawings
end

-- ESP çizimlerini kaldır
local function removeESP(player)
    local drawings = espObjects[player]
    if not drawings then return end
    
    for _, drawing in pairs(drawings) do
        pcall(function()
            drawing:Remove()
        end)
    end
    
    espObjects[player] = nil
end

-- Tüm ESP çizimlerini gizle
local function hideESP(player)
    local drawings = espObjects[player]
    if not drawings then return end
    
    for _, drawing in pairs(drawings) do
        pcall(function()
            drawing.Visible = false
        end)
    end
end

-- Renk belirle (takım veya düşman)
local function getColor(player)
    if Settings.TeamColor and player.Team then
        return player.TeamColor.Color
    end
    
    if Settings.TeamCheck and player.Team and LocalPlayer.Team then
        if player.Team == LocalPlayer.Team then
            return Settings.AllyColor
        end
    end
    
    return Settings.EnemyColor
end

-- Can barı rengi (yeşilden kırmızıya)
local function getHealthColor(healthPercent)
    local r = math.clamp(2 * (1 - healthPercent), 0, 1)
    local g = math.clamp(2 * healthPercent, 0, 1)
    return Color3.new(r, g, 0)
end

-- Mevcut oyuncular için ESP oluştur
for _, player in ipairs(Players:GetPlayers()) do
    createESPForPlayer(player)
end

-- Yeni oyuncu katılınca ESP oluştur
Players.PlayerAdded:Connect(function(player)
    createESPForPlayer(player)
end)

-- Oyuncu ayrılınca ESP kaldır
Players.PlayerRemoving:Connect(function(player)
    removeESP(player)
end)

-- Ana ESP güncelleme döngüsü
RunService.RenderStepped:Connect(function()
    for player, drawings in pairs(espObjects) do
        -- ESP kapalıysa gizle
        if not Settings.Enabled then
            hideESP(player)
            continue
        end
        
        -- Karakter ve humanoid kontrolü
        local character = player.Character
        if not character then
            hideESP(player)
            continue
        end
        
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local head = character:FindFirstChild("Head")
        
        if not humanoid or not rootPart or not head or humanoid.Health <= 0 then
            hideESP(player)
            continue
        end
        
        -- Takım kontrolü
        if Settings.TeamCheck and player.Team and LocalPlayer.Team then
            if player.Team == LocalPlayer.Team then
                hideESP(player)
                continue
            end
        end
        
        -- Kendi karakterimiz var mı
        local myChar = LocalPlayer.Character
        if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then
            hideESP(player)
            continue
        end
        
        -- Mesafe kontrolü
        local distance = (myChar.HumanoidRootPart.Position - rootPart.Position).Magnitude
        if distance > Settings.MaxDistance then
            hideESP(player)
            continue
        end
        
        -- Ekran pozisyonları hesapla
        local rootScreen, rootOnScreen = Camera:WorldToViewportPoint(rootPart.Position)
        
        if not rootOnScreen then
            hideESP(player)
            continue
        end
        
        -- Kutu boyutları hesapla (karakter boyutuna göre)
        local headScreen = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 1, 0))
        local footScreen = Camera:WorldToViewportPoint(rootPart.Position - Vector3.new(0, 3, 0))
        
        local boxHeight = math.abs(headScreen.Y - footScreen.Y)
        local boxWidth = boxHeight * 0.55
        
        local boxX = rootScreen.X - boxWidth / 2
        local boxY = headScreen.Y
        
        local color = getColor(player)
        
        -- === KUTU ESP ===
        if Settings.Boxes then
            if Settings.BoxType == "2D" then
                drawings.BoxOutline.Size = Vector2.new(boxWidth, boxHeight)
                drawings.BoxOutline.Position = Vector2.new(boxX, boxY)
                drawings.BoxOutline.Visible = true
                
                drawings.Box.Size = Vector2.new(boxWidth, boxHeight)
                drawings.Box.Position = Vector2.new(boxX, boxY)
                drawings.Box.Color = color
                drawings.Box.Visible = true
            elseif Settings.BoxType == "Corner" then
                -- Corner box: sadece köşeleri çiz (basit 2D fallback)
                drawings.BoxOutline.Size = Vector2.new(boxWidth, boxHeight)
                drawings.BoxOutline.Position = Vector2.new(boxX, boxY)
                drawings.BoxOutline.Visible = true
                
                drawings.Box.Size = Vector2.new(boxWidth, boxHeight)
                drawings.Box.Position = Vector2.new(boxX, boxY)
                drawings.Box.Color = color
                drawings.Box.Visible = true
            end
        else
            drawings.BoxOutline.Visible = false
            drawings.Box.Visible = false
        end
        
        -- === İSİM ===
        if Settings.Names then
            drawings.Name.Text = player.DisplayName
            drawings.Name.Position = Vector2.new(rootScreen.X, boxY - 18)
            drawings.Name.Color = color
            drawings.Name.Visible = true
        else
            drawings.Name.Visible = false
        end
        
        -- === MESAFE ===
        if Settings.Distance then
            drawings.Distance.Text = math.floor(distance) .. " stud"
            drawings.Distance.Position = Vector2.new(rootScreen.X, boxY + boxHeight + 2)
            drawings.Distance.Color = Color3.fromRGB(200, 200, 210)
            drawings.Distance.Visible = true
        else
            drawings.Distance.Visible = false
        end
        
        -- === CAN BARI ===
        if Settings.Health then
            local healthPercent = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
            local barWidth = 3
            local barX = boxX - barWidth - 3
            
            -- Arka plan
            drawings.HealthBarOutline.Size = Vector2.new(barWidth + 2, boxHeight + 2)
            drawings.HealthBarOutline.Position = Vector2.new(barX - 1, boxY - 1)
            drawings.HealthBarOutline.Visible = true
            
            drawings.HealthBarBG.Size = Vector2.new(barWidth, boxHeight)
            drawings.HealthBarBG.Position = Vector2.new(barX, boxY)
            drawings.HealthBarBG.Visible = true
            
            -- Can barı (aşağıdan yukarı dolar)
            local barHeight = boxHeight * healthPercent
            drawings.HealthBar.Size = Vector2.new(barWidth, barHeight)
            drawings.HealthBar.Position = Vector2.new(barX, boxY + (boxHeight - barHeight))
            drawings.HealthBar.Color = getHealthColor(healthPercent)
            drawings.HealthBar.Visible = true
            
            -- Can yüzdesi yazısı (can düşükse göster)
            if healthPercent < 1 then
                drawings.HealthText.Text = math.floor(humanoid.Health)
                drawings.HealthText.Position = Vector2.new(barX - 2, boxY + (boxHeight - barHeight) - 14)
                drawings.HealthText.Color = getHealthColor(healthPercent)
                drawings.HealthText.Visible = true
            else
                drawings.HealthText.Visible = false
            end
        else
            drawings.HealthBarOutline.Visible = false
            drawings.HealthBarBG.Visible = false
            drawings.HealthBar.Visible = false
            drawings.HealthText.Visible = false
        end
        
        -- === TRACER ===
        if Settings.Tracers then
            local fromPos
            if Settings.TracerOrigin == "Bottom" then
                fromPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            elseif Settings.TracerOrigin == "Center" then
                fromPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            elseif Settings.TracerOrigin == "Mouse" then
                local mousePos = UserInputService:GetMouseLocation()
                fromPos = Vector2.new(mousePos.X, mousePos.Y)
            else
                fromPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
            end
            
            drawings.Tracer.From = fromPos
            drawings.Tracer.To = Vector2.new(rootScreen.X, boxY + boxHeight)
            drawings.Tracer.Color = color
            drawings.Tracer.Visible = true
        else
            drawings.Tracer.Visible = false
        end
        
        -- === CHAMS (Highlight) ===
        if Settings.Chams then
            local existing = character:FindFirstChild("VergiHub_Highlight")
            if not existing then
                local highlight = Instance.new("Highlight")
                highlight.Name = "VergiHub_Highlight"
                highlight.FillColor = color
                highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                highlight.FillTransparency = Settings.ChamsTransparency
                highlight.OutlineTransparency = 0.3
                highlight.Adornee = character
                highlight.Parent = character
            else
                existing.FillColor = color
                existing.FillTransparency = Settings.ChamsTransparency
            end
        else
            local existing = character:FindFirstChild("VergiHub_Highlight")
            if existing then existing:Destroy() end
        end
    end
end)

-- Temizlik fonksiyonu
local function cleanup()
    for player, _ in pairs(espObjects) do
        removeESP(player)
    end
    
    -- Tüm highlight'ları temizle
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character then
            local hl = player.Character:FindFirstChild("VergiHub_Highlight")
            if hl then hl:Destroy() end
        end
    end
end

print("[VergiHub] 👁️ ESP Visuals hazır!")
return true
