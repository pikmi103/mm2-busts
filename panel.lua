local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local lp = Players.LocalPlayer
local out = {}
local function add(s) table.insert(out, s) end

-- 1) структура окон инвентаря / трейда
local KEYS = {"inventory", "trade", "item", "weapon"}
local function match(name)
    name = name:lower()
    for _, k in ipairs(KEYS) do
        if name:find(k, 1, true) then return true end
    end
end

local function dump(o, depth)
    if depth > 7 then return end
    local extra = ""
    if o:IsA("TextLabel") or o:IsA("TextButton") then extra = ' text="' .. o.Text .. '"' end
    if o:IsA("ImageLabel") or o:IsA("ImageButton") then extra = ' image="' .. o.Image .. '"' end
    add(string.rep("  ", depth) .. o.ClassName .. " " .. o.Name .. extra)
    local kids = o:GetChildren()
    for i, c in ipairs(kids) do
        if i > 6 then add(string.rep("  ", depth + 1) .. "... ещё " .. (#kids - 6)) break end
        dump(c, depth + 1)
    end
end

add("=== GUI ===")
for _, sg in ipairs(lp.PlayerGui:GetChildren()) do
    add("ScreenGui: " .. sg.Name .. " (Enabled=" .. tostring(sg.Enabled) .. ")")
    for _, d in ipairs(sg:GetDescendants()) do
        if d:IsA("GuiObject") and match(d.Name) and d.Parent and not match(d.Parent.Name) then
            dump(d, 1)
        end
    end
end

-- 2) база предметов (ищем, где хранится, например, "Seer")
add("")
add("=== DATABASE ===")
local seen = {}
local function show(t, path)
    add("Найдено: " .. path)
    for k, v in pairs(t) do
        if type(v) ~= "table" and type(v) ~= "function" then
            add("   " .. tostring(k) .. " = " .. tostring(v))
        end
    end
end
local function search(t, depth, path)
    if depth > 4 or seen[t] then return end
    seen[t] = true
    for k, v in pairs(t) do
        if k == "Seer" and type(v) == "table" then show(v, path .. "." .. k) end
        if v == "Seer" then show(t, path) end
        if type(v) == "table" then search(v, depth + 1, path .. "." .. tostring(k)) end
    end
end
for _, m in ipairs(RS:GetDescendants()) do
    if m:IsA("ModuleScript") then
        local ok, res = pcall(require, m)
        if ok and type(res) == "table" then search(res, 0, m:GetFullName()) end
    end
end

local text = table.concat(out, "\n")
if #text > 14000 then text = text:sub(1, 14000) .. "\n...[обрезано]" end
pcall(function() setclipboard(text) end)
print(text)
