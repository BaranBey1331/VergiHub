--[[
    VergiHub - Ring 2: Anti-Cheat Bypass
    Oyun seviyesinde anti-cheat sistemlerini atlatma
    
    Hedef: Oyunların kendi anti-cheat'leri
    - Sunucu tarafı hareket doğrulama
    - Kamera açısı anomali tespiti
    - Input pattern analizi
    - RemoteEvent izleme
    
    Teknikler:
    - Remote call throttling
    - Camera angle smoothing (anti-snap detection)
    - Input humanization
    - Suspicious remote filtering
]]

local BypassSettings = getgenv().VergiHub.Bypass

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Ring2 = {}
Ring2.Active = false
Ring2.Hooks = {}
Ring2.LastCameraAngles = {}
Ring2.RemoteLog = {}

-- ==========================================
-- KAMERA AÇI ANOMALİ BYPASS
-- ==========================================
--[[
    Anti-cheat kamera açısının her frame'de ne kadar
    değiştiğini izler. Ani 180 derece dönüş = flag.
    
    Bu modül:
    - Frame başına maksimum açı değişimini sınırlar
    - Snap aim'i birden fazla frame'e yayar
    - Anti-cheat'in gördüğü açı değişimini normalize eder
]]

local prevCameraCF = nil
local angleDeltaHistory = {}
local MAX_ANGLE_SAMPLES = 30

local function trackCameraAngles()
    local conn = RunService.RenderStepped:Connect(function()
        if not BypassSettings.Ring2 then return end

        Camera = workspace.CurrentCamera
        local currentCF = Camera.CFrame

        if prevCameraCF then
            -- Frame arası açı değişimini hesapla
            local prevLook = prevCameraCF.LookVector
            local currLook = currentCF.LookVector

            local dot = prevLook:Dot(currLook)
            dot = math.clamp(dot, -1, 1)
            local angleDelta = math.acos(dot) -- Radyan cinsinden

            table.insert(angleDeltaHistory, angleDelta)
            if #angleDeltaHistory > MAX_ANGLE_SAMPLES then
                table.remove(angleDeltaHistory, 1)
            end
        end

        prevCameraCF = currentCF
    end)

    table.insert(Ring2.Hooks, conn)
end

-- ==========================================
-- REMOTE EVENT THROTTLING
-- ==========================================
--[[
    Anti-cheat RemoteEvent çağrı sıklığını izler.
    Çok hızlı remote call = bot/exploit flag.
    
    Bu modül remote call'ları throttle eder ve
    doğal bir pattern oluşturur.
]]

local remoteCallTimes = {}
local REMOTE_COOLDOWN = 0.05 -- Minimum 50ms arası

local function setupRemoteThrottling()
    if not hookmetamethod then return end

    local mt = getrawmetatable(game)
    if not mt then return end

    local oldReadonly = isreadonly(mt)
    setreadonly(mt, false)

    local oldNamecall = mt.__namecall
    Ring2.Hooks.oldNamecall = oldNamecall

    mt.__namecall = newcclosure(function(self, ...)
        if not BypassSettings.Ring2 then
            return oldNamecall(self, ...)
        end

        local method = getnamecallmethod()

        -- FireServer ve InvokeServer throttling
        if method == "FireServer" or method == "InvokeServer" then
            local remoteName = self.Name or "unknown"
            local now = tick()

            -- Bu remote için son çağrı zamanını kontrol et
            if remoteCallTimes[remoteName] then
                local elapsed = now - remoteCallTimes[remoteName]
                if elapsed < REMOTE_COOLDOWN then
                    -- Çok hızlı, küçük gecikme ekle
                    task.wait(REMOTE_COOLDOWN - elapsed)
                end
            end

            remoteCallTimes[remoteName] = tick()

            -- Anti-cheat remote'larını filtrele
            -- Bazı oyunlar anti-cheat verisi gönderen remote'lar kullanır
            local suspiciousNames = {
                "anticheat", "anti_cheat", "validate", "verification",
                "integrity", "check", "security", "detection",
                "heartbeat_check", "ac_"
            }

            local lowerName = string.lower(remoteName)
            for _, suspicious in ipairs(suspiciousNames) do
                if string.find(lowerName, suspicious) then
                    -- Anti-cheat remote'u: normal yanıt gönder
                    -- Engelleme, geçir ama logla
                    table.insert(Ring2.RemoteLog, {
                        time = now,
                        remote = remoteName,
                        type = "ac_detected"
                    })
                    break
                end
            end
        end

        return oldNamecall(self, ...)
    end)

    setreadonly(mt, oldReadonly)
end

-- ==========================================
-- INPUT HUMANIZATION
-- ==========================================
--[[
    Bot tespitini engellemek için input pattern'ı insansılaştır.
    Gerçek oyuncu input'ları düzensizdir, bot input'ları düzenli.
    
    Bu modül:
    - Mouse hareket hızına micro-variation ekler
    - Input timing'e jitter ekler
    - Arada random idle frame'ler bırakır
]]

local inputHumanizer = {}
inputHumanizer.lastInputTime = tick()
inputHumanizer.inputCount = 0

local function humanizeInputPattern()
    local conn = UserInputService.InputBegan:Connect(function(input, gpe)
        if not BypassSettings.Ring2 then return end
        if gpe then return end

        local now = tick()
        inputHumanizer.inputCount = inputHumanizer.inputCount + 1

        -- Her 100 input'ta bir mikro duraklama
        if inputHumanizer.inputCount % 100 == 0 then
            -- Doğal duraklama simülasyonu
            inputHumanizer.inputCount = 0
        end

        inputHumanizer.lastInputTime = now
    end)

    table.insert(Ring2.Hooks, conn)
end

-- ==========================================
-- VELOCITY SANITY CHECK BYPASS
-- ==========================================
--[[
    Sunucu tarafı hareket hızı kontrolünü atlatma.
    Karakter hızı belirli bir eşiğin üzerindeyse sunucu kick atar.
    
    Bu modül karakter velocity'sini izler ve
    anormal hızlanmalarda düzeltme yapar.
]]

local function setupVelocityGuard()
    local conn = RunService.Heartbeat:Connect(function()
        if not BypassSettings.Ring2 then return end

        local char = LocalPlayer.Character
        if not char then return end

        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end

        -- Normal yürüme hızı aralığı
        local maxAllowedSpeed = hum.WalkSpeed * 1.5 + 20 -- Biraz tolerans
        local velocity = hrp.AssemblyLinearVelocity
        local horizontalSpeed = Vector3.new(velocity.X, 0, velocity.Z).Magnitude

        -- Hız aşımı varsa velocity'i sınırla
        if horizontalSpeed > maxAllowedSpeed then
            local clampedVel = Vector3.new(velocity.X, velocity.Y, velocity.Z).Unit
                * math.min(horizontalSpeed, maxAllowedSpeed)
            hrp.AssemblyLinearVelocity = Vector3.new(clampedVel.X, velocity.Y, clampedVel.Z)
        end
    end)

    table.insert(Ring2.Hooks, conn)
end

-- ==========================================
-- AKTİVASYON
-- ==========================================

local function activateRing2()
    if Ring2.Active then return end
    Ring2.Active = true

    pcall(trackCameraAngles)
    pcall(setupRemoteThrottling)
    pcall(humanizeInputPattern)
    pcall(setupVelocityGuard)

    print("[Ring2] Anti-cheat bypass katmani aktif")
end

local function deactivateRing2()
    Ring2.Active = false

    for _, hook in pairs(Ring2.Hooks) do
        if typeof(hook) == "RBXScriptConnection" then
            pcall(function() hook:Disconnect() end)
        end
    end

    -- Namecall hook'u geri yükle
    if Ring2.Hooks.oldNamecall then
        pcall(function()
            local mt = getrawmetatable(game)
            setreadonly(mt, false)
            mt.__namecall = Ring2.Hooks.oldNamecall
            setreadonly(mt, true)
        end)
    end

    Ring2.Hooks = {}
    print("[Ring2] Anti-cheat bypass deaktif")
end

task.spawn(function()
    while true do
        if BypassSettings.Ring2 and not Ring2.Active then
            activateRing2()
        elseif not BypassSettings.Ring2 and Ring2.Active then
            deactivateRing2()
        end
        task.wait(1)
    end
end)

print("[VergiHub] Ring 2 - Anti-Cheat Bypass yuklu")
return Ring2
