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
local UIS = game:GetService("UserInputService")

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
local flyConn, flySpeed, flyAnchoredParts = nil, 50, nil

PlayerSection:Toggle({
    Title = "Fly",
    Desc = "Mode terbang (Anchored + CFrame)",
    Callback = function(enabled)
        if flyConn then flyConn:Disconnect() flyConn = nil end
        local char = LP.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end
        if enabled then
            hum.PlatformStand = true
            flyAnchoredParts = {}
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Anchored = true
                    table.insert(flyAnchoredParts, v)
                end
            end
            flyConn = game:GetService("RunService").Heartbeat:Connect(function()
                local c = LP.Character
                if not c then return end
                local r = c:FindFirstChild("HumanoidRootPart")
                local h = c:FindFirstChildOfClass("Humanoid")
                if not r or not h then return end
                local cf = workspace.CurrentCamera.CFrame
                local md = h.MoveDirection
                local lv = cf.LookVector
                local forward = Vector3.new(lv.X, 0, lv.Z).Unit
                local right = cf.RightVector
                local move = (right * -md.X + forward * -md.Z) * flySpeed + Vector3.new(0, lv.Y * flySpeed, 0)
                r.CFrame = r.CFrame + move * 0.03
                local flatLv = Vector3.new(lv.X, 0, lv.Z)
                if flatLv.Magnitude > 0.01 then
                    r.CFrame = CFrame.new(r.Position, r.Position + flatLv)
                end
            end)
        else
            hum.PlatformStand = false
            if flyAnchoredParts then
                for _, v in ipairs(flyAnchoredParts) do
                    v.Anchored = false
                end
                flyAnchoredParts = nil
            end
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

-- Combat tab (raw Instance UI karena WindUI Button/Input pake icon system yg mungkin gagal di Delta)
local CombatTab = Window:Tab({
    Title = "Combat",
    Icon = "lucide:sword",
})

local selectedTarget

local ok1, inputEl = pcall(CombatTab.Input, CombatTab, {
    Title = "Target Name",
    Desc = "Ketik nama pemain target",
    Placeholder = "username",
    Callback = function(v)
        selectedTarget = Players:FindFirstChild(v)
    end,
})

if not ok1 then
    -- Fallback: Input gagal, coba pake Paragraph + instruksi manual
    pcall(CombatTab.Paragraph, CombatTab, {
        Title = "Target Name",
        Desc = "Ketik manual di chat: /target <nama>",
    })
end

local function remoteSpam(target)
    local char = target.Character
    if not char then return end
    for _, v in ipairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") then
            pcall(v.FireServer, v, target, char, 9e9)
            pcall(v.FireServer, v, {Target = target, Damage = 9e9})
            pcall(v.FireServer, v, target.Name, 9e9)
            pcall(v.FireServer, v, {target, char, 9e9})
            pcall(v.FireServer, v, target.Name, char, 9e9)
            pcall(v.FireServer, v, char, 9e9)
        elseif v:IsA("RemoteFunction") then
            pcall(v.InvokeServer, v, target, char, 9e9)
            pcall(v.InvokeServer, v, target.Name, 9e9)
        end
    end
end

local ok2, btn1 = pcall(CombatTab.Button, CombatTab, {
    Title = "Kill Player",
    Desc = "Remote spam ke target",
    Callback = function()
        local target = selectedTarget
        if not target then
            WindUI:Notify({Title = "DarkZeuss", Content = "Isi nama target dulu!", Duration = 2})
            return
        end
        task.spawn(remoteSpam, target)
        WindUI:Notify({Title = "DarkZeuss", Content = "Kill executed on " .. target.Name, Duration = 2})
    end,
})

local ok3, btn2 = pcall(CombatTab.Button, CombatTab, {
    Title = "Kill All",
    Desc = "Remote spam ke SEMUA pemain",
    Callback = function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then
                task.spawn(remoteSpam, p)
            end
        end
        WindUI:Notify({Title = "DarkZeuss", Content = "Kill All executed!", Duration = 2})
    end,
})

-- Kalo Button gagal pake Icon, fallback ke raw Instance
if not ok2 or not ok3 then
    local sg = Instance.new("ScreenGui", game:GetService("CoreGui"))
    sg.Name = "DarkZeussCombat"
    sg.ResetOnSpawn = false
    local frame = Instance.new("Frame", sg)
    frame.Size = UDim2.new(0, 200, 0, 120)
    frame.Position = UDim2.new(0.5, -100, 0.65, -60)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    
    local uic = Instance.new("UICorner", frame)
    uic.CornerRadius = UDim.new(0, 8)
    
    local targetBox = Instance.new("TextBox", frame)
    targetBox.Size = UDim2.new(1, -20, 0, 30)
    targetBox.Position = UDim2.new(0, 10, 0, 8)
    targetBox.PlaceholderText = "Target username"
    targetBox.Text = ""
    targetBox.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    targetBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    targetBox.BorderSizePixel = 0
    
    local uic2 = Instance.new("UICorner", targetBox)
    uic2.CornerRadius = UDim.new(0, 6)
    
    local killBtn = Instance.new("TextButton", frame)
    killBtn.Size = UDim2.new(0.5, -12, 0, 34)
    killBtn.Position = UDim2.new(0, 10, 0, 46)
    killBtn.Text = "Kill"
    killBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    killBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    killBtn.BorderSizePixel = 0
    killBtn.Font = Enum.Font.GothamBold
    killBtn.TextSize = 14
    
    local uic3 = Instance.new("UICorner", killBtn)
    uic3.CornerRadius = UDim.new(0, 6)
    
    local killAllBtn = Instance.new("TextButton", frame)
    killAllBtn.Size = UDim2.new(0.5, -12, 0, 34)
    killAllBtn.Position = UDim2.new(0.5, 2, 0, 46)
    killAllBtn.Text = "Kill All"
    killAllBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
    killAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    killAllBtn.BorderSizePixel = 0
    killAllBtn.Font = Enum.Font.GothamBold
    killAllBtn.TextSize = 14
    
    local uic4 = Instance.new("UICorner", killAllBtn)
    uic4.CornerRadius = UDim.new(0, 6)
    
    killBtn.MouseButton1Click:Connect(function()
        selectedTarget = Players:FindFirstChild(targetBox.Text)
        if not selectedTarget then
            WindUI:Notify({Title = "DarkZeuss", Content = "Player tidak ditemukan!", Duration = 2})
            return
        end
        task.spawn(remoteSpam, selectedTarget)
        WindUI:Notify({Title = "DarkZeuss", Content = "Killed " .. selectedTarget.Name, Duration = 2})
    end)
    
    killAllBtn.MouseButton1Click:Connect(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then
                task.spawn(remoteSpam, p)
            end
        end
        WindUI:Notify({Title = "DarkZeuss", Content = "Kill All done!", Duration = 2})
    end)
end

WindUI:Notify({
    Title = "DarkZeuss",
    Content = "Library berhasil dijalankan",
    Duration = 2,
})
