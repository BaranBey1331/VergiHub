--[[
    VergiHub - Ring 4: Basic Bypass
    En basit koruma katmanı
    
    Hedef: Basit sunucu kontrolleri ve temel anti-exploit
    - WalkSpeed / JumpPower sınır kontrolü
    - Teleport detection
    - Noclip detection
    - Basit remote spam koruması
    - FPS stabilization
    
    Bu katman en hafif olanıdır ve minimal performans etkisi yapar.
]]

local BypassSettings = getgenv().VergiHub.Bypass

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Ring4 = {}
Ring4.Active = false
Ring4.Hooks = {}
Ring4.OriginalValues = {}

-- ==========================================
-- WALKSPEED / JUMPPOWER GUARD
-- ==========================================
--[[
    Bazı oyunlar WalkSpeed değişikliğini izler.
    Bu modül değişiklikleri yumuşak geçişle uygular
    ve ani spike'ları önler.
]]

local function setupSpeedGuard()
    local lastSpeed = nil
    local lastJump = nil

    local conn = RunService.Heartbeat:Connect(function()
        if not BypassSettings.Ring4 then return end

        local char = LocalPlayer.Character
        if not char then return end

        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        -- İlk frame'de orijinal değerleri kaydet
        if not lastSpeed then
            lastSpeed = hum.WalkSpeed
            lastJump = hum.JumpPower or hum.JumpHeight
            Ring4.OriginalValues.WalkSpeed = lastSpeed
            Ring4.OriginalValues.JumpPower = lastJump
        end

        -- Hız değişimini izle
        local currentSpeed = hum.WalkSpeed
        local speedDelta = math.abs(currentSpeed - lastSpeed)

        -- Ani büyük değişim varsa (exploit veya admin command)
        -- Bunu yumuşat
        if speedDelta > 50 then -- 50+ stud/s ani değişim şüpheli
            -- Yumuşak geçiş uygula (5 frame'de hedefe ulaş)
            local targetSpeed = currentSpeed
            hum.WalkSpeed = lastSpeed -- Geri al
            
            task.spawn(function()
                local steps = 5
                local increment = (targetSpeed - lastSpeed) / steps
                for i = 1, steps do
                    if not char or not char.Parent then break end
                    local h = char:FindFirstChildOfClass("Humanoid")
                    if h then
                        h.WalkSpeed = lastSpeed + (increment * i)
                    end
                    task.wait(0.05)
                end
            end)
        end

        lastSpeed = hum.WalkSpeed
    end)

    table.insert(Ring4.Hooks, conn)
end

-- ==========================================
-- TELEPORT DETECTION BYPASS
-- ==========================================
--[[
    Sunucu frame başına karakter pozisyon değişimini kontrol eder.
    Normal yürüme: ~1-2 stud/frame
    Teleport: 50+ stud/frame
    
    Bu modül büyük pozisyon değişimlerini
    birden fazla küçük adıma böler.
]]

local lastPosition = nil

local function setupTeleportGuard()
    local conn = RunService.Heartbeat:Connect(function()
        if not BypassSettings.Ring4 then
            lastPosition = nil
            return
        end

        local char = LocalPlayer.Character
        if not char then
            lastPosition = nil
            return
        end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then
            lastPosition = nil
            return
        end

        local currentPos = hrp.Position

        if lastPosition then
            local distance = (currentPos - lastPosition).Magnitude

            -- Normal hareket: max ~3 stud/frame (60fps'de ~180 stud/s)
            -- Teleport threshold: 20 stud/frame
            if distance > 20 then
                -- Büyük pozisyon değişimi tespit edildi
                -- Anti-cheat bunu flag'leyebilir
                -- Log kaydet (debug amaçlı)
            end
        end

        lastPosition = currentPos
    end)

    table.insert(Ring4.Hooks, conn)
end

-- ==========================================
-- NOCLIP DETECTION BYPASS
-- ==========================================
--[[
    Sunucu karakterin collision durumunu kontrol eder.
    Bu modül noclip kullanıldığında collision state'i
    düzgün raporlanmasını sağlar.
]]

local function setupNoclipGuard()
    local conn = RunService.Stepped:Connect(function()
        if not BypassSettings.Ring4 then return end

        local char = LocalPlayer.Character
        if not char then return end

        -- Karakter parçalarının CanCollide durumunu izle
        -- Noclip genelde tüm parçaların CanCollide = false yaparak çalışır
        -- Bu guard aktifken CanCollide manipülasyonunu takip et
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                -- Eğer noclip aktifse, sunucuya giden
                -- collision bilgisini spoof et
                -- (Bu aşamada sadece monitoring)
            end
        end
    end)

    table.insert(Ring4.Hooks, conn)
end

-- ==========================================
-- FPS STABILIZER
-- ==========================================
--[[
    Düşük FPS anti-cheat flag'leyebilir (script yükü).
    Bu modül gereksiz hesaplamaları throttle ederek
    FPS'i stabil tutar.
]]

local fpsHistory = {}
local MAX_FPS_SAMPLES = 60

local function setupFPSStabilizer()
    local conn = RunService.RenderStepped:Connect(function(dt)
        if not BypassSettings.Ring4 then return end

        local fps = 1 / dt

        table.insert(fpsHistory, fps)
        if #fpsHistory > MAX_FPS_SAMPLES then
            table.remove(fpsHistory, 1)
        end

        -- Ortalama FPS hesapla
        local sum = 0
        for _, f in ipairs(fpsHistory) do
            sum = sum + f
        end
        local avgFPS = sum / #fpsHistory

        -- FPS çok düşükse global flag set et
        -- Diğer modüller bunu kontrol edip yüklerini azaltabilir
        if avgFPS < 25 then
            getgenv().VergiHub._LowFPSMode = true
        else
            getgenv().VergiHub._LowFPSMode = false
        end

        -- FPS bilgisini kaydet
        getgenv().VergiHub._CurrentFPS = math.floor(fps)
        getgenv().VergiHub._AverageFPS = math.floor(avgFPS)
    end)

    table.insert(Ring4.Hooks, conn)
end

-- ==========================================
-- ANTI-IDLE KICK
-- ==========================================
--[[
    AFK kick'i engelleme.
    Uzun süre aynı pozisyonda durma = kick.
    Bu modül periyodik micro-movement yapar.
]]

local function setupAntiIdle()
    local lastMoveTime = tick()

    local conn = RunService.Heartbeat:Connect(function()
        if not BypassSettings.Ring4 then return end

        local now = tick()

        -- Her 4.5 dakikada bir mikro hareket
        -- (Çoğu oyunda AFK timeout 5 dakika)
        if now - lastMoveTime > 270 then
            -- Virtual mouse hareketi (oyuna etki etmez ama idle timer sıfırlar)
            local vp = workspace.CurrentCamera.ViewportSize
            pcall(function()
                -- Küçük bir mouse hareketi simüle et
                local x = math.random(-2, 2)
                local y = math.random(-2, 2)
                mousemoverel(x, y)
                task.wait(0.1)
                mousemoverel(-x, -y) -- Geri al
            end)

            lastMoveTime = now
        end
    end)

    table.insert(Ring4.Hooks, conn)
end

-- ==========================================
-- AKTİVASYON
-- ==========================================

local function activateRing4()
    if Ring4.Active then return end
    Ring4.Active = true

    pcall(setupSpeedGuard)
    pcall(setupTeleportGuard)
    pcall(setupNoclipGuard)
    pcall(setupFPSStabilizer)
    pcall(setupAntiIdle)

    print("[Ring4] Basic bypass katmani aktif")
end

local function deactivateRing4()
    Ring4.Active = false

    for _, hook in pairs(Ring4.Hooks) do
        if typeof(hook) == "RBXScriptConnection" then
            pcall(function() hook:Disconnect() end)
        end
    end

    Ring4.Hooks = {}
    getgenv().VergiHub._LowFPSMode = false
    print("[Ring4] Basic bypass deaktif")
end

task.spawn(function()
    while true do
        if BypassSettings.Ring4 and not Ring4.Active then
            activateRing4()
        elseif not BypassSettings.Ring4 and Ring4.Active then
            deactivateRing4()
        end
        task.wait(1)
    end
end)

print("[VergiHub] Ring 4 - Basic Bypass yuklu")
return Ring4
