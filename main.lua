-- DarkZeuss Hub v1.0
-- GitHub: https://github.com/AstralXCode/DarkZeuss
-- Load: loadstring(game:HttpGet("https://raw.githubusercontent.com/AstralXCode/DarkZeuss/main/main.lua"))()

local okWind, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)
if not okWind or not WindUI then
    warn("DarkZeuss: Gagal load WindUI - " .. tostring(WindUI))
    return
end

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

local function detectDevice()
    if not UIS.TouchEnabled then return "PC" end
    local checks = {
        function() local ok, v = pcall(getexecutorname) if ok then return nil end end,
        function() local ok, v = pcall(function() return (getgenv and getgenv() or {}).device_model end) if ok and v then return v end end,
        function() local ok, v = pcall(function() return (shared or {}).device_model end) if ok and v then return v end end,
        function() local ok, v = pcall(function() return (getgenv and getgenv() or {}).device end) if ok and v then return v end end,
        function() local ok, v = pcall(function() return (shared or {}).device end) if ok and v then return v end end,
        function() local ok, v = pcall(os.getenv, "MODEL") if ok and v then return v end end,
        function() local ok, v = pcall(os.getenv, "BRAND") if ok and v then return v .. " " .. (os.getenv("MODEL") or "") end end,
        function() local ok, v = pcall(function() return _G.BRAND end) if ok and v then return v end end,
        function() local ok, v = pcall(function() return _G.MODEL end) if ok and v then return v end end,
    }
    for _, fn in ipairs(checks) do
        local result = fn()
        if result then return result end
    end
    local res = workspace.CurrentCamera.ViewportSize
    if res.X >= 1400 and res.Y >= 3000 then return "Large Phone / Tablet"
    elseif res.X >= 1000 and res.Y >= 2300 then return "Phone (19.5:9)"
    else return "Android Device" end
end
local deviceModel = detectDevice()

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

WindUI:Notify({
    Title = "DarkZeuss",
    Content = "Library berhasil dijalankan",
    Duration = 2,
})
