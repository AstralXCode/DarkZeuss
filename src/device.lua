-- DarkZeuss - Device Detection Module
-- Load: loadstring(game:HttpGet("https://raw.githubusercontent.com/AstralXCode/DarkZeuss/main/src/device.lua"))()

local UIS = game:GetService("UserInputService")
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
