-- MM2 Visual Panel (только визуально, только для тебя)
-- Вкладки: Выдача / Инвентарь / Трейд / Скин

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local lp = Players.LocalPlayer

-- ====== СПИСОК ГОДЛИ (редактируй под себя) ======
local GODLIES = {
    "Traveler's Gun", "Evergun", "Constellation", "Evergreen", "Alienbeam",
    "Turkey", "Raygun", "Vampire's Gun", "Darkshot", "Darksword",
    "Blossom", "Sakura", "Sunrise", "Snowcannon", "Bauble",
    "Soul", "Sunset", "Spirit", "Rainbow Gun", "Flora",
    "Rainbow", "Xenoknife", "Xenoshot", "Bloom", "Heart Wand",
    "Snowstorm", "Blizzard", "Ocean", "Waves", "Flowerwood Gun",
    "Flowerwood", "Snow Dagger", "Watergun", "Icecream", "Treat",
    "Sweet", "Borealis", "Australis", "Bat", "Beachy",
    "Sands", "Candy", "Ornament", "Pearlshine", "Pearl",
    "Heartblade", "Red Luger", "Phantom", "Spectre", "Candleflame",
    "Darkbringer", "Elderwood Blade", "Elderwood Revolver", "Iceblaster", "Makeshift",
    "Lightbringer", "Sugar", "Green Luger", "Laser", "Amerilaser",
    "Hallowgun", "Shark", "Nightblade", "Luger", "Icebeam",
    "Swirly Gun", "Plasmabeam", "Blaster", "Ginger Luger", "Pixel",
    "Battleaxe II", "Gemstone", "Iceflake", "Old Glory", "Plasmablade",
    "Slasher", "Vampire's Edge", "Minty", "Virtual", "Nebula",
    "Deathshard", "Lugercane", "Jinglegun", "Gingerblade", "Eternalcane",
    "Cookiecane", "Battleaxe", "Gingermint", "Swirly Blade", "Tides",
    "Spider", "Frostsaber", "Fang", "Heat", "Clockwork",
    "Chill", "Eternal III", "Eternal IV", "Hallow's Blade", "Hallow's Edge",
    "Handsaw", "Bioblade", "Ice Shard", "Xmas", "Saw",
    "Pumpking", "Ice Dragon", "Boneblade", "Ghostblade", "Prismatic",
    "Eternal", "Eternal II", "Frostbite", "Eggblade", "Flames",
    "Snowflake", "Winter's Edge", "Peppermint", "Cookieblade", "Blue Seer",
    "Purple Seer", "Red Seer", "Seer", "Orange Seer", "Yellow Seer"
}

local inventory = {}
local ui = {}

-- ====== ВСПОМОГАТЕЛЬНОЕ ======
local function make(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props) do o[k] = v end
    o.Parent = parent
    return o
end

local function corner(o, r) make("UICorner", {CornerRadius = UDim.new(0, r or 8)}, o) end

local function button(parent, text, size, pos, color)
    local b = make("TextButton", {
        Text = text, Size = size, Position = pos or UDim2.new(),
        BackgroundColor3 = color or Color3.fromRGB(55, 55, 75),
        TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamMedium,
        TextSize = 14, AutoButtonColor = true,
    }, parent)
    corner(b, 6)
    return b
end

local function scroll(parent, size, pos)
    local s = make("ScrollingFrame", {
        Size = size, Position = pos, BackgroundColor3 = Color3.fromRGB(25, 25, 35),
        BorderSizePixel = 0, ScrollBarThickness = 4, CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, parent)
    corner(s, 6)
    make("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, s)
    make("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4)}, s)
    return s
end

local function clear(s)
    for _, c in ipairs(s:GetChildren()) do
        if c:IsA("GuiButton") or c:IsA("TextLabel") then c:Destroy() end
    end
end

local function notify(text)
    local l = make("TextLabel", {
        Text = text, Size = UDim2.new(0, 320, 0, 36), Position = UDim2.new(0.5, -160, 0, -50),
        BackgroundColor3 = Color3.fromRGB(35, 120, 70), TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold, TextSize = 14,
    }, ui.gui)
    corner(l, 8)
    l:TweenPosition(UDim2.new(0.5, -160, 0, 20), "Out", "Quad", 0.3, true)
    task.delay(2.5, function() l:Destroy() end)
end

-- ====== GUI ======
local gui = make("ScreenGui", {Name = "MM2VisualPanel", ResetOnSpawn = false})
ui.gui = gui
pcall(function() gui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not gui.Parent then gui.Parent = lp:WaitForChild("PlayerGui") end

local main = make("Frame", {
    Size = UDim2.new(0, 460, 0, 380), Position = UDim2.new(0.5, -230, 0.5, -190),
    BackgroundColor3 = Color3.fromRGB(18, 18, 26), BorderSizePixel = 0,
}, gui)
corner(main, 10)

local title = make("TextLabel", {
    Text = "MM2 Visual Panel  (RShift — скрыть)", Size = UDim2.new(1, 0, 0, 32),
    BackgroundColor3 = Color3.fromRGB(30, 30, 45), TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold, TextSize = 14,
}, main)
corner(title, 10)

-- перетаскивание за заголовок
do
    local dragging, startPos, startInput
    title.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging, startPos, startInput = true, main.Position, i.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - startInput
            main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

UIS.InputBegan:Connect(function(i, gp)
    if not gp and i.KeyCode == Enum.KeyCode.RightShift then main.Visible = not main.Visible end
end)

-- вкладки
local tabs, pages = {}, {}
local tabNames = {"Выдача", "Инвентарь", "Трейд", "Скин"}
for idx, name in ipairs(tabNames) do
    local b = button(main, name, UDim2.new(0.25, -6, 0, 28), UDim2.new((idx - 1) * 0.25, 4, 0, 38))
    local page = make("Frame", {
        Size = UDim2.new(1, -16, 1, -80), Position = UDim2.new(0, 8, 0, 72),
        BackgroundTransparency = 1, Visible = idx == 1,
    }, main)
    tabs[name], pages[name] = b, page
    b.MouseButton1Click:Connect(function()
        for n, p in pairs(pages) do p.Visible = (n == name) end
    end)
end

-- ====== ВКЛАДКА: ИНВЕНТАРЬ ======
local invList = scroll(pages["Инвентарь"], UDim2.new(1, 0, 1, 0), UDim2.new())
local function refreshInventory()
    clear(invList)
    if #inventory == 0 then
        make("TextLabel", {Text = "Пусто", Size = UDim2.new(1, 0, 0, 28), BackgroundTransparency = 1,
            TextColor3 = Color3.fromRGB(150, 150, 150), Font = Enum.Font.Gotham, TextSize = 14}, invList)
    end
    for i, item in ipairs(inventory) do
        local row = button(invList, "★ " .. item .. "  (Godly)", UDim2.new(1, -8, 0, 30), nil, Color3.fromRGB(120, 60, 160))
        row.MouseButton1Click:Connect(function()
            table.remove(inventory, i)
            refreshInventory()
            notify("Удалено: " .. item)
        end)
    end
end

-- ====== ВКЛАДКА: ВЫДАЧА ======
local search = make("TextBox", {
    PlaceholderText = "Поиск...", Text = "", Size = UDim2.new(1, 0, 0, 28),
    BackgroundColor3 = Color3.fromRGB(35, 35, 50), TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.Gotham, TextSize = 14, ClearTextOnFocus = false,
}, pages["Выдача"])
corner(search, 6)

local giveList = scroll(pages["Выдача"], UDim2.new(1, 0, 1, -66), UDim2.new(0, 0, 0, 34))
local function refreshGive()
    clear(giveList)
    local q = search.Text:lower()
    for _, name in ipairs(GODLIES) do
        if q == "" or name:lower():find(q, 1, true) then
            local b = button(giveList, "+ " .. name, UDim2.new(1, -8, 0, 28), nil, Color3.fromRGB(60, 80, 140))
            b.MouseButton1Click:Connect(function()
                table.insert(inventory, name)
                refreshInventory()
                notify("Выдано: " .. name)
            end)
        end
    end
end
search:GetPropertyChangedSignal("Text"):Connect(refreshGive)

local giveAll = button(pages["Выдача"], "Выдать ВСЕ годли", UDim2.new(1, 0, 0, 28), UDim2.new(0, 0, 1, -28), Color3.fromRGB(35, 120, 70))
giveAll.MouseButton1Click:Connect(function()
    for _, n in ipairs(GODLIES) do table.insert(inventory, n) end
    refreshInventory()
    notify("Выданы все годли")
end)

-- ====== ВКЛАДКА: ТРЕЙД (визуальный) ======
local tradePage = pages["Трейд"]
local playerList = scroll(tradePage, UDim2.new(0.4, -4, 1, 0), UDim2.new())
local tradeTarget
local offerMine, offerTheirs = {}, {}

local tradeBox = make("Frame", {
    Size = UDim2.new(0.6, -4, 1, 0), Position = UDim2.new(0.4, 4, 0, 0),
    BackgroundColor3 = Color3.fromRGB(25, 25, 35), Visible = false,
}, tradePage)
corner(tradeBox, 6)

local tradeTitle = make("TextLabel", {
    Text = "", Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1,
    TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 13,
}, tradeBox)

local mineList = scroll(tradeBox, UDim2.new(0.5, -6, 1, -90), UDim2.new(0, 4, 0, 26))
local theirList = scroll(tradeBox, UDim2.new(0.5, -6, 1, -90), UDim2.new(0.5, 2, 0, 26))
local mineLabel = make("TextLabel", {Text = "", Size = UDim2.new(1, -8, 0, 20), Position = UDim2.new(0, 4, 1, -62),
    BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(190, 190, 190), Font = Enum.Font.Gotham, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left}, tradeBox)

local function refreshTrade()
    clear(mineList); clear(theirList)
    for i, item in ipairs(inventory) do
        local on = table.find(offerMine, i) ~= nil
        local b = button(mineList, (on and "✔ " or "") .. item, UDim2.new(1, -6, 0, 24), nil,
            on and Color3.fromRGB(35, 120, 70) or Color3.fromRGB(70, 50, 100))
        b.TextSize = 12
        b.MouseButton1Click:Connect(function()
            local pos = table.find(offerMine, i)
            if pos then table.remove(offerMine, pos) else table.insert(offerMine, i) end
            refreshTrade()
        end)
    end
    for _, name in ipairs(GODLIES) do
        local on = table.find(offerTheirs, name) ~= nil
        local b = button(theirList, (on and "✔ " or "") .. name, UDim2.new(1, -6, 0, 24), nil,
            on and Color3.fromRGB(35, 120, 70) or Color3.fromRGB(60, 80, 140))
        b.TextSize = 12
        b.MouseButton1Click:Connect(function()
            local pos = table.find(offerTheirs, name)
            if pos then table.remove(offerTheirs, pos) else table.insert(offerTheirs, name) end
            refreshTrade()
        end)
    end
    mineLabel.Text = ("Отдаёшь: %d  |  Получаешь: %d"):format(#offerMine, #offerTheirs)
end

local accept = button(tradeBox, "Accept (визуально)", UDim2.new(0.5, -6, 0, 28), UDim2.new(0, 4, 1, -32), Color3.fromRGB(35, 120, 70))
local decline = button(tradeBox, "Decline", UDim2.new(0.5, -6, 0, 28), UDim2.new(0.5, 2, 1, -32), Color3.fromRGB(150, 50, 50))

accept.MouseButton1Click:Connect(function()
    table.sort(offerMine, function(a, b) return a > b end)
    for _, idx in ipairs(offerMine) do table.remove(inventory, idx) end
    for _, name in ipairs(offerTheirs) do table.insert(inventory, name) end
    offerMine, offerTheirs = {}, {}
    tradeBox.Visible = false
    refreshInventory()
    notify("Трейд с " .. (tradeTarget or "?") .. " принят")
end)
decline.MouseButton1Click:Connect(function()
    offerMine, offerTheirs = {}, {}
    tradeBox.Visible = false
    notify("Трейд отклонён")
end)

local function refreshPlayers(list, onPick)
    clear(list)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp then
            local b = button(list, p.DisplayName, UDim2.new(1, -8, 0, 28))
            b.MouseButton1Click:Connect(function() onPick(p) end)
        end
    end
end

local function refreshTradePlayers()
    refreshPlayers(playerList, function(p)
        tradeTarget = p.Name
        tradeTitle.Text = "Трейд с " .. p.DisplayName
        offerMine, offerTheirs = {}, {}
        tradeBox.Visible = true
        refreshTrade()
    end)
end

-- ====== ВКЛАДКА: КОПИЯ СКИНА ======
local skinPage = pages["Скин"]
local skinList = scroll(skinPage, UDim2.new(1, 0, 1, -34), UDim2.new())
make("TextLabel", {
    Text = "Клик по игроку — копирует его нож/пистолет себе (виден только тебе)",
    Size = UDim2.new(1, 0, 0, 28), Position = UDim2.new(0, 0, 1, -28), BackgroundTransparency = 1,
    TextColor3 = Color3.fromRGB(170, 170, 170), Font = Enum.Font.Gotham, TextSize = 12,
}, skinPage)

local function copyTools(p)
    local count = 0
    local sources = {p.Character, p:FindFirstChildOfClass("Backpack")}
    for _, src in ipairs(sources) do
        if src then
            for _, t in ipairs(src:GetChildren()) do
                if t:IsA("Tool") then
                    local ok, clone = pcall(function() return t:Clone() end)
                    if ok and clone then
                        clone.Name = t.Name
                        clone.Parent = lp:FindFirstChildOfClass("Backpack")
                        count += 1
                    end
                end
            end
        end
    end
    notify(count > 0 and ("Скопировано предметов: " .. count) or "У игрока нет видимых предметов")
end

local function refreshSkinPlayers()
    refreshPlayers(skinList, copyTools)
end

for name, b in pairs(tabs) do
    b.MouseButton1Click:Connect(function()
        if name == "Трейд" then refreshTradePlayers()
        elseif name == "Скин" then refreshSkinPlayers()
        elseif name == "Инвентарь" then refreshInventory()
        elseif name == "Выдача" then refreshGive() end
    end)
end
Players.PlayerAdded:Connect(function() refreshTradePlayers(); refreshSkinPlayers() end)
Players.PlayerRemoving:Connect(function() task.wait(0.2); refreshTradePlayers(); refreshSkinPlayers() end)

refreshGive(); refreshInventory(); refreshTradePlayers(); refreshSkinPlayers()
notify("MM2 Visual Panel загружен")
