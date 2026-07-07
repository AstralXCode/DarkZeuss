-- DarkZeuss Hub v1.0 - Core
-- Loader: https://github.com/AstralXCode/DarkZeuss

local okWind, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)
if not okWind or not WindUI then
    warn("DarkZeuss: Gagal load WindUI - " .. tostring(WindUI))
    return
end

local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local deviceModel = loadstring(game:HttpGet("https://raw.githubusercontent.com/AstralXCode/DarkZeuss/main/src/device.lua"))() or "Android"

local Window = WindUI:CreateWindow({
    Title = "DarkZeuss",
    Icon = "crown",
    Author = "v1.0 | by DarkZeuss",
    Folder = "DarkZeuss",
    ToggleKey = Enum.KeyCode.RightControl,
    User = {
        Enabled = true,
        Anonymous = false,
    },
})

-- Animated gradient on title
task.spawn(function()
    task.wait(3)
    local titleLabel
    local searchContainers = { game:GetService("CoreGui") }
    local ok, hui = pcall(gethui)
    if ok and hui then table.insert(searchContainers, hui) end
    if LP:FindFirstChild("PlayerGui") then table.insert(searchContainers, LP.PlayerGui) end
    for _, container in ipairs(searchContainers) do
        for _, gui in ipairs(container:GetChildren()) do
            if gui:IsA("ScreenGui") then
                local found = gui:FindFirstChildOfClass("TextLabel")
                while found do
                    if found.Text:match("DarkZeuss") then
                        titleLabel = found
                        break
                    end
                    found = gui:FindNextInstanceOfClass("TextLabel", found)
                end
                if not titleLabel then
                    local btn = gui:FindFirstChildOfClass("TextButton")
                    while btn do
                        if btn.Text:match("DarkZeuss") then
                            titleLabel = btn
                            break
                        end
                        btn = gui:FindNextInstanceOfClass("TextButton", btn)
                    end
                end
            end
            if titleLabel then break end
        end
        if titleLabel then break end
    end
    if not titleLabel then
        for _, child in ipairs(game:GetDescendants()) do
            if (child:IsA("TextLabel") or child:IsA("TextButton")) and child.Text:match("DarkZeuss") then
                titleLabel = child
                break
            end
        end
    end
    if not titleLabel then return end
    local grad = titleLabel:FindFirstChildOfClass("UIGradient")
    if not grad then
        grad = Instance.new("UIGradient")
        grad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(86, 156, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(156, 106, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(86, 200, 255)),
        })
        grad.Parent = titleLabel
    end
    local offset = 0
    while titleLabel and titleLabel.Parent do
        offset = offset + 0.008
        if offset > 1 then offset = offset - 1 end
        grad.Offset = offset
        task.wait()
    end
end)

local InfoTab = Window:Tab({
    Title = "Informasi",
    Icon = "lucide:info",
})
InfoTab:Select()

local DeviceSection = InfoTab:Section({
    Title = "Perangkat",
    Opened = true,
})

local para = DeviceSection:Paragraph({
    Title = "Informasi Perangkat",
    Desc = "Device: " .. deviceModel .. "\nIP: " .. "Tidak tersedia" .. "\nResolusi: " .. workspace.CurrentCamera.ViewportSize.X .. "x" .. workspace.CurrentCamera.ViewportSize.Y,
})

coroutine.wrap(function()
    local apis = {
        { url = "https://api.ipify.org?format=json", key = "ip" },
        { url = "https://httpbin.org/ip", key = "origin" },
        { url = "https://api.my-ip.io/ip.json", key = "ip" },
    }
    local H = game:GetService("HttpService")
    for _, api in ipairs(apis) do
        local ok, body = pcall(function() return game:HttpGet(api.url) end)
        if ok then
            local ok2, data = pcall(function() return H:JSONDecode(body) end)
            if ok2 and data and data[api.key] then
                para:SetDesc("Device: " .. deviceModel .. "\nIP: " .. data[api.key] .. "\nResolusi: " .. workspace.CurrentCamera.ViewportSize.X .. "x" .. workspace.CurrentCamera.ViewportSize.Y)
                return
            end
        end
    end
end)()

local MainTab = Window:Tab({
    Title = "Main",
    Icon = "lucide:zap",
})

local PlayerSection = MainTab:Section({
    Title = "Player",
    Opened = true,
})

PlayerSection:Slider({
    Title = "WalkSpeed",
    Desc = "Atur kecepatan jalan",
    Step = 1,
    Value = {
        Min = 16,
        Max = 120,
        Default = 16,
    },
    Callback = function(value)
        local character = LP.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.WalkSpeed = value end
    end,
})

-- Fly
local flyConn, flySpeed = nil, 50

PlayerSection:Toggle({
    Title = "Fly",
    Desc = "Mode terbang (arah kamera)",
    Callback = function(enabled)
        if flyConn then flyConn:Disconnect() flyConn = nil end
        local char = LP.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if enabled then
            flyConn = game:GetService("RunService").Heartbeat:Connect(function()
                local c = LP.Character
                if not c then return end
                local r = c:FindFirstChild("HumanoidRootPart")
                local h = c:FindFirstChildOfClass("Humanoid")
                if not r or not h then return end
                h.PlatformStand = true
                local lv = workspace.CurrentCamera.CFrame.LookVector
                r.Velocity = Vector3.new(lv.X * flySpeed, lv.Y * flySpeed, lv.Z * flySpeed)
            end)
        else
            local h = char:FindFirstChildOfClass("Humanoid")
            if h then h.PlatformStand = false end
        end
    end,
})

PlayerSection:Slider({
    Title = "Fly Speed",
    Desc = "Kecepatan terbang",
    Step = 1,
    Value = {
        Min = 10,
        Max = 200,
        Default = 50,
    },
    Callback = function(value) flySpeed = value end,
})

-- Kill
local CombatSection = MainTab:Section({
    Title = "Combat",
    Opened = true,
})

local selectedTarget

local playerNames = {}
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LP then table.insert(playerNames, p.Name) end
end

CombatSection:Dropdown({
    Title = "Target",
    Desc = "Pilih pemain target",
    Values = playerNames,
    Callback = function(v)
        selectedTarget = Players:FindFirstChild(v)
    end,
})

CombatSection:Button({
    Title = "Kill Player",
    Desc = "Serang target (BreakJoints + Remote spam)",
    Callback = function()
        local target = selectedTarget
        if not target then
            WindUI:Notify({Title = "DarkZeuss", Content = "Pilih target dulu!", Duration = 2})
            return
        end
        local char = target.Character
        if not char then return end
        char:BreakJoints()
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = 0 end
        for _, v in ipairs(game:GetDescendants()) do
            if v:IsA("RemoteEvent") then
                pcall(v.FireServer, v, target, target.Character, 9999)
            elseif v:IsA("RemoteFunction") then
                pcall(v.InvokeServer, v, target, target.Character, 9999)
            end
        end
        WindUI:Notify({Title = "DarkZeuss", Content = "Kill executed on " .. target.Name, Duration = 2})
    end,
})

WindUI:Notify({
    Title = "DarkZeuss",
    Content = "Library berhasil dijalankan",
    Duration = 2,
})
