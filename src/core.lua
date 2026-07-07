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
local flyConn, flyBp, flyBg, flySpeed = nil, nil, nil, 50
local BP_MAX = 9e9

PlayerSection:Toggle({
    Title = "Fly",
    Desc = "Mode terbang (BodyPosition)",
    Callback = function(enabled)
        if flyConn then flyConn:Disconnect() flyConn = nil end
        if flyBp then flyBp:Destroy() flyBp = nil end
        if flyBg then flyBg:Destroy() flyBg = nil end
        local char = LP.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if enabled then
            flyBp = Instance.new("BodyPosition")
            flyBp.MaxForce = Vector3.new(BP_MAX, BP_MAX, BP_MAX)
            flyBp.P = BP_MAX
            flyBp.D = BP_MAX * 0.3
            flyBp.Position = hrp.Position
            flyBp.Parent = hrp

            flyBg = Instance.new("BodyGyro")
            flyBg.MaxTorque = Vector3.new(BP_MAX, BP_MAX, BP_MAX)
            flyBg.P = BP_MAX
            flyBg.D = BP_MAX * 0.3
            flyBg.CFrame = hrp.CFrame
            flyBg.Parent = hrp

            flyConn = game:GetService("RunService").Heartbeat:Connect(function()
                local c = LP.Character
                if not c then return end
                local r = c:FindFirstChild("HumanoidRootPart")
                local h = c:FindFirstChildOfClass("Humanoid")
                if not r or not h or not flyBp or not flyBg then return end
                local md = h.MoveDirection
                local cf = workspace.CurrentCamera.CFrame
                local lv = cf.LookVector
                local forward = Vector3.new(lv.X, 0, lv.Z).Unit
                local right = cf.RightVector
                local move = (right * md.X + forward * -md.Z) * flySpeed + Vector3.new(0, lv.Y * flySpeed, 0)
                flyBp.Position = flyBp.Position + move * 0.03
                local flatLv = Vector3.new(lv.X, 0, lv.Z)
                if flatLv.Magnitude > 0.01 then
                    flyBg.CFrame = CFrame.new(r.Position, r.Position + flatLv)
                end
            end)
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

-- Combat tab
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
    pcall(CombatTab.Paragraph, CombatTab, {
        Title = "Target Name",
        Desc = "Ketik manual di chat: /target <nama>",
    })
end

local damageKeywords = {"hit", "damage", "take", "attack", "deal", "harm", "hurt", "kill", "remove", "health", "hp", "dmg", "explosion", "bullet", "melee", "sword", "gun", "projectile"}
local cachedRemotes = {}
do
    for _, v in ipairs(game:GetDescendants()) do
        if (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) then
            local nameLower = v.Name:lower()
            local isDamage = false
            for _, kw in ipairs(damageKeywords) do
                if nameLower:find(kw, 1, true) then
                    isDamage = true
                    break
                end
            end
            if isDamage then
                table.insert(cachedRemotes, v)
            end
        end
    end
end

local function stealthKill(target)
    local char = target.Character
    if not char then return end
    local args = {
        {target, char, math.random(50, 999)},
        {Target = target, Damage = math.random(50, 999)},
        {target.Name, math.random(50, 999)},
        {char, math.random(50, 999)},
        {target, math.random(50, 999)},
        {[1] = target, [2] = math.random(50, 999)},
    }
    for _, remote in ipairs(cachedRemotes) do
        local arg = args[math.random(#args)]
        if remote:IsA("RemoteEvent") then
            task.spawn(function()
                task.wait(math.random() * 0.3)
                pcall(remote.FireServer, remote, unpack(arg))
            end)
        else
            task.spawn(function()
                task.wait(math.random() * 0.3)
                pcall(remote.InvokeServer, remote, unpack(arg))
            end)
        end
    end
end

local ok2, btn1 = pcall(CombatTab.Button, CombatTab, {
    Title = "Kill Player",
    Desc = "Serang target",
    Callback = function()
        local target = selectedTarget
        if not target then
            WindUI:Notify({Title = "DarkZeuss", Content = "Isi nama target dulu!", Duration = 2})
            return
        end
        stealthKill(target)
        WindUI:Notify({Title = "DarkZeuss", Content = "Kill executed on " .. target.Name, Duration = 2})
    end,
})

local ok3, btn2 = pcall(CombatTab.Button, CombatTab, {
    Title = "Kill All",
    Desc = "Serang SEMUA pemain",
    Callback = function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then
                stealthKill(p)
            end
        end
        WindUI:Notify({Title = "DarkZeuss", Content = "Kill All executed!", Duration = 2})
    end,
})

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
        stealthKill(selectedTarget)
        WindUI:Notify({Title = "DarkZeuss", Content = "Killed " .. selectedTarget.Name, Duration = 2})
    end)

    killAllBtn.MouseButton1Click:Connect(function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LP then
                stealthKill(p)
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
