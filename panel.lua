-- MM2 Visual Panel (только визуально, только для тебя)
-- Вкладки: Выдача / Инвентарь / Трейд / Скин / Отладка

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

local inventory = {}   -- список названий, которые "лежат" у тебя
local ui = {}

local GOLD = Color3.fromRGB(255, 200, 40)
local CARD = Color3.fromRGB(70, 40, 110)
local GREEN = Color3.fromRGB(35, 120, 70)

-- ====== ВСПОМОГАТЕЛЬНОЕ ======
local function make(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props) do o[k] = v end
    o.Parent = parent
    return o
end

local function corner(o, r) make("UICorner", {CornerRadius = UDim.new(0, r or 8)}, o) end

local function stroke(o, color, th)
    make("UIStroke", {
        Color = color or GOLD, Thickness = th or 1.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, o)
end

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

local function label(parent, text, size, pos, ts, color, align)
    return make("TextLabel", {
        Text = text, Size = size, Position = pos or UDim2.new(), BackgroundTransparency = 1,
        TextColor3 = color or Color3.new(1, 1, 1), Font = Enum.Font.GothamMedium,
        TextSize = ts or 13, TextXAlignment = align or Enum.TextXAlignment.Left,
    }, parent)
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

local function gridScroll(parent, size, pos)
    local s = make("ScrollingFrame", {
        Size = size, Position = pos, BackgroundColor3 = Color3.fromRGB(25, 25, 35),
        BorderSizePixel = 0, ScrollBarThickness = 4, CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, parent)
    corner(s, 6)
    make("UIGridLayout", {
        CellSize = UDim2.new(0, 82, 0, 62), CellPadding = UDim2.new(0, 4, 0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, s)
    make("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4)}, s)
    return s
end

local function clear(s)
    for _, c in ipairs(s:GetChildren()) do
        if c:IsA("GuiObject") then c:Destroy() end
    end
end

-- карточка годли для окон панели
local function card(parent, name, onClick, selected)
    local b = make("TextButton", {
        Text = "", AutoButtonColor = true,
        BackgroundColor3 = selected and GREEN or CARD,
    }, parent)
    corner(b, 6)
    stroke(b, GOLD, 1.5)
    label(b, "GODLY", UDim2.new(1, 0, 0, 14), UDim2.new(), 10, GOLD, Enum.TextXAlignment.Center).Font = Enum.Font.GothamBold
    local n = label(b, name, UDim2.new(1, -6, 1, -16), UDim2.new(0, 3, 0, 14), 12, Color3.new(1, 1, 1), Enum.TextXAlignment.Center)
    n.TextWrapped = true
    if onClick then b.MouseButton1Click:Connect(onClick) end
    return b
end

local function makeDraggable(handle, frame)
    local dragging, startPos, startInput
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            dragging, startPos, startInput = true, frame.Position, i.Position
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - startInput
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
end

-- ====== GUI ======
local gui = make("ScreenGui", {Name = "MM2VisualPanel", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling})
ui.gui = gui
pcall(function() gui.Parent = (gethui and gethui()) or game:GetService("CoreGui") end)
if not gui.Parent then gui.Parent = lp:WaitForChild("PlayerGui") end

local function notify(text)
    local l = make("TextLabel", {
        Text = text, Size = UDim2.new(0, 340, 0, 36), Position = UDim2.new(0.5, -170, 0, -50),
        BackgroundColor3 = GREEN, TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold, TextSize = 14, ZIndex = 50,
    }, gui)
    corner(l, 8)
    l:TweenPosition(UDim2.new(0.5, -170, 0, 20), "Out", "Quad", 0.3, true)
    task.delay(2.5, function() l:Destroy() end)
end

-- ====== НАСТОЯЩИЙ ИНВЕНТАРЬ MM2 (визуальная подмена) ======
local nativeCont, nativeTpl

local function isRealItem(o)
    return o:IsA("GuiObject")
        and not o:GetAttribute("FakeGodly")
        and o:FindFirstChildWhichIsA("TextLabel", true) ~= nil
end

local function findContainer()
    local pg = lp:FindFirstChildOfClass("PlayerGui")
    if not pg then return end
    local best, bestTpl, bestN = nil, nil, 0
    for _, d in ipairs(pg:GetDescendants()) do
        if d:IsA("ScrollingFrame") then
            local n = d:GetFullName():lower()
            if n:find("inventory") or n:find("weapon") or n:find("items") then
                local c, first = 0, nil
                for _, ch in ipairs(d:GetChildren()) do
                    if isRealItem(ch) then
                        c += 1
                        first = first or ch
                    end
                end
                if c > bestN then best, bestTpl, bestN = d, first, c end
            end
        end
    end
    return best, bestTpl
end

local function countFakes(cont)
    local n = 0
    for _, ch in ipairs(cont:GetChildren()) do
        if ch:GetAttribute("FakeGodly") then n += 1 end
    end
    return n
end

local function clearFakes(cont)
    for _, ch in ipairs(cont:GetChildren()) do
        if ch:GetAttribute("FakeGodly") then ch:Destroy() end
    end
end

local function makeFakeCard(tpl, name, order)
    local c
    if tpl then
        c = tpl:Clone()
        for _, d in ipairs(c:GetDescendants()) do
            if d:IsA("LocalScript") or d:IsA("Script") then d:Destroy() end
        end
        local lbl = c:FindFirstChildWhichIsA("TextLabel", true)
        if lbl then lbl.Text = name end
        c.Visible = true
    else
        c = make("Frame", {Size = UDim2.new(0, 100, 0, 100), BackgroundColor3 = CARD}, nil)
        corner(c, 6)
        local t = label(c, name, UDim2.new(1, -6, 1, -6), UDim2.new(0, 3, 0, 3), 12, Color3.new(1, 1, 1), Enum.TextXAlignment.Center)
        t.TextWrapped = true
    end
    c:SetAttribute("FakeGodly", true)
    c.Name = "Fake_" .. order
    pcall(function() c.LayoutOrder = -10000 + order end)
    pcall(function() stroke(c, GOLD, 2) end)
    return c
end

local function injectNative()
    local cont, tpl = nativeCont, nativeTpl
    if not (cont and cont.Parent) then
        cont, tpl = findContainer()
        nativeCont, nativeTpl = cont, tpl
    end
    if not cont then return false end
    clearFakes(cont)
    for i, name in ipairs(inventory) do
        makeFakeCard(tpl, name, i).Parent = cont
    end
    return true
end

task.spawn(function()
    while gui.Parent do
        task.wait(1.5)
        if #inventory > 0 then
            if not (nativeCont and nativeCont.Parent) or countFakes(nativeCont) ~= #inventory then
                pcall(injectNative)
            end
        end
    end
end)

-- ====== ГЛАВНОЕ ОКНО ======
local main = make("Frame", {
    Size = UDim2.new(0, 460, 0, 380), Position = UDim2.new(0.5, -230, 0.5, -190),
    BackgroundColor3 = Color3.fromRGB(18, 18, 26), BorderSizePixel = 0,
}, gui)
corner(main, 10)

local title = make("TextLabel", {
    Text = "MM2 Visual Panel", Size = UDim2.new(1, 0, 0, 32),
    BackgroundColor3 = Color3.fromRGB(30, 30, 45), TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.GothamBold, TextSize = 14,
}, main)
corner(title, 10)
makeDraggable(title, main)

local hideBtn = button(main, "—", UDim2.new(0, 28, 0, 24), UDim2.new(1, -34, 0, 4), Color3.fromRGB(150, 50, 50))
hideBtn.ZIndex = 5
hideBtn.MouseButton1Click:Connect(function() main.Visible = false end)

-- плавающая кнопка показать/скрыть
local toggle = button(gui, "MM2", UDim2.new(0, 46, 0, 46), UDim2.new(0, 12, 0.5, -23), Color3.fromRGB(120, 60, 160))
toggle.Font = Enum.Font.GothamBold
toggle.TextSize = 13
make("UICorner", {CornerRadius = UDim.new(1, 0)}, toggle)
stroke(toggle, GOLD, 2)
makeDraggable(toggle, toggle)
toggle.MouseButton1Click:Connect(function() main.Visible = not main.Visible end)

UIS.InputBegan:Connect(function(i, gp)
    if not gp and i.KeyCode == Enum.KeyCode.RightShift then main.Visible = not main.Visible end
end)

local tabs, pages = {}, {}
local tabNames = {"Выдача", "Инвентарь", "Трейд", "Скин", "Отладка"}
for idx, name in ipairs(tabNames) do
    local b = button(main, name, UDim2.new(1 / #tabNames, -6, 0, 28), UDim2.new((idx - 1) / #tabNames, 4, 0, 38))
    b.TextSize = 12
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
local invPage = pages["Инвентарь"]
label(invPage, "Клик по карточке — убрать из инвентаря", UDim2.new(1, 0, 0, 18), UDim2.new(), 12, Color3.fromRGB(170, 170, 170))
local invGrid = gridScroll(invPage, UDim2.new(1, 0, 1, -22), UDim2.new(0, 0, 0, 22))

local refreshTrade -- объявлено ниже
local function refreshInventory()
    clear(invGrid)
    if #inventory == 0 then
        label(invGrid, "Пусто", UDim2.new(1, 0, 0, 28), UDim2.new(), 14, Color3.fromRGB(150, 150, 150))
    end
    for i, item in ipairs(inventory) do
        card(invGrid, item, function()
            table.remove(inventory, i)
            refreshInventory()
            notify("Удалено: " .. item)
        end)
    end
    pcall(injectNative)
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

local giveAll = button(pages["Выдача"], "Выдать ВСЕ годли", UDim2.new(1, 0, 0, 28), UDim2.new(0, 0, 1, -28), GREEN)
giveAll.MouseButton1Click:Connect(function()
    for _, n in ipairs(GODLIES) do table.insert(inventory, n) end
    refreshInventory()
    notify("Выданы все годли")
end)

-- ====== ОКНО ТРЕЙДА ======
local trade = {active = false, partner = nil, mine = {}, theirs = {}, myOk = false, theirOk = false, lockUntil = 0, token = 0}

local tradeWin = make("Frame", {
    Size = UDim2.new(0, 560, 0, 410), Position = UDim2.new(0.5, -280, 0.5, -205),
    BackgroundColor3 = Color3.fromRGB(18, 18, 26), BorderSizePixel = 0, Visible = false, ZIndex = 20,
}, gui)
corner(tradeWin, 10)
stroke(tradeWin, GOLD, 2)

local tTitle = make("TextLabel", {
    Text = "Trade", Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = Color3.fromRGB(30, 30, 45),
    TextColor3 = Color3.new(1, 1, 1), Font = Enum.Font.GothamBold, TextSize = 14, ZIndex = 21,
}, tradeWin)
corner(tTitle, 10)
makeDraggable(tTitle, tradeWin)

label(tradeWin, "Ты отдаёшь (клик — убрать)", UDim2.new(0.5, -12, 0, 16), UDim2.new(0, 8, 0, 36), 12)
local offerMineGrid = gridScroll(tradeWin, UDim2.new(0.5, -12, 0, 110), UDim2.new(0, 8, 0, 54))
label(tradeWin, "Ты получаешь (клик — убрать)", UDim2.new(0.5, -12, 0, 16), UDim2.new(0.5, 4, 0, 36), 12)
local offerTheirGrid = gridScroll(tradeWin, UDim2.new(0.5, -12, 0, 110), UDim2.new(0.5, 4, 0, 54))

label(tradeWin, "Твой инвентарь (клик — добавить)", UDim2.new(0.5, -12, 0, 16), UDim2.new(0, 8, 0, 170), 12)
local srcMineGrid = gridScroll(tradeWin, UDim2.new(0.5, -12, 0, 150), UDim2.new(0, 8, 0, 188))
label(tradeWin, "Предметы партнёра (клик — добавить)", UDim2.new(0.5, -12, 0, 16), UDim2.new(0.5, 4, 0, 170), 12)
local tSearch = make("TextBox", {
    PlaceholderText = "Поиск...", Text = "", Size = UDim2.new(0.5, -12, 0, 22), Position = UDim2.new(0.5, 4, 0, 188),
    BackgroundColor3 = Color3.fromRGB(35, 35, 50), TextColor3 = Color3.new(1, 1, 1),
    Font = Enum.Font.Gotham, TextSize = 12, ClearTextOnFocus = false,
}, tradeWin)
corner(tSearch, 6)
local srcTheirGrid = gridScroll(tradeWin, UDim2.new(0.5, -12, 0, 124), UDim2.new(0.5, 4, 0, 214))

local myStatus = label(tradeWin, "", UDim2.new(0.5, -12, 0, 18), UDim2.new(0, 8, 0, 344), 12, Color3.fromRGB(200, 200, 200))
local theirStatus = label(tradeWin, "", UDim2.new(0.5, -12, 0, 18), UDim2.new(0.5, 4, 0, 344), 12, Color3.fromRGB(200, 200, 200))
local acceptBtn = button(tradeWin, "Accept", UDim2.new(0.5, -12, 0, 30), UDim2.new(0, 8, 0, 370), GREEN)
local declineBtn = button(tradeWin, "Decline", UDim2.new(0.5, -12, 0, 30), UDim2.new(0.5, 4, 0, 370), Color3.fromRGB(150, 50, 50))

local function updateStatus()
    myStatus.Text = trade.myOk and "Ты: принял ✔" or "Ты: не принял"
    theirStatus.Text = (trade.partner and trade.partner.DisplayName or "Партнёр") .. (trade.theirOk and ": принял ✔" or ": не принял")
    local left = math.ceil(trade.lockUntil - os.clock())
    if left > 0 then
        acceptBtn.Text = "Accept (" .. left .. ")"
    else
        acceptBtn.Text = trade.myOk and "Отменить принятие" or "Accept"
    end
end

local function resetAccepts()
    trade.myOk, trade.theirOk = false, false
    trade.lockUntil = os.clock() + 3
    trade.token += 1
    updateStatus()
end

function refreshTrade()
    if not trade.active then return end
    clear(offerMineGrid); clear(offerTheirGrid); clear(srcMineGrid); clear(srcTheirGrid)

    for k, idx in ipairs(trade.mine) do
        card(offerMineGrid, inventory[idx] or "?", function()
            table.remove(trade.mine, k)
            resetAccepts(); refreshTrade()
        end, true)
    end
    for k, name in ipairs(trade.theirs) do
        card(offerTheirGrid, name, function()
            table.remove(trade.theirs, k)
            resetAccepts(); refreshTrade()
        end, true)
    end
    for i, item in ipairs(inventory) do
        if not table.find(trade.mine, i) then
            card(srcMineGrid, item, function()
                table.insert(trade.mine, i)
                resetAccepts(); refreshTrade()
            end)
        end
    end
    local q = tSearch.Text:lower()
    for _, name in ipairs(GODLIES) do
        if q == "" or name:lower():find(q, 1, true) then
            card(srcTheirGrid, name, function()
                table.insert(trade.theirs, name)
                resetAccepts(); refreshTrade()
            end)
        end
    end
    updateStatus()
end
tSearch:GetPropertyChangedSignal("Text"):Connect(refreshTrade)

local function closeTrade()
    trade.active = false
    trade.token += 1
    tradeWin.Visible = false
end

local function completeTrade()
    local idxs = {}
    for _, i in ipairs(trade.mine) do table.insert(idxs, i) end
    table.sort(idxs, function(a, b) return a > b end)
    for _, i in ipairs(idxs) do table.remove(inventory, i) end
    for _, name in ipairs(trade.theirs) do table.insert(inventory, name) end
    local who = trade.partner and trade.partner.DisplayName or "?"
    closeTrade()
    refreshInventory()
    notify("Трейд с " .. who .. " завершён")
end

acceptBtn.MouseButton1Click:Connect(function()
    if not trade.active then return end
    if os.clock() < trade.lockUntil then return end
    if trade.myOk then
        trade.myOk, trade.theirOk = false, false
        trade.token += 1
        updateStatus()
        return
    end
    if #trade.mine == 0 and #trade.theirs == 0 then
        notify("Добавь предметы в трейд")
        return
    end
    trade.myOk = true
    updateStatus()
    local tok = trade.token
    task.delay(math.random(10, 25) / 10, function()
        if trade.active and trade.token == tok and trade.myOk then
            trade.theirOk = true
            updateStatus()
            task.delay(0.7, function()
                if trade.active and trade.token == tok and trade.myOk and trade.theirOk then
                    completeTrade()
                end
            end)
        end
    end)
end)

declineBtn.MouseButton1Click:Connect(function()
    closeTrade()
    notify("Трейд отклонён")
end)

task.spawn(function()
    while gui.Parent do
        task.wait(0.25)
        if trade.active then pcall(updateStatus) end
    end
end)

local function openTrade(p)
    trade.active = true
    trade.partner = p
    trade.mine, trade.theirs = {}, {}
    trade.myOk, trade.theirOk = false, false
    trade.lockUntil = 0
    trade.token += 1
    tTitle.Text = "Trade with " .. p.DisplayName
    tSearch.Text = ""
    tradeWin.Visible = true
    refreshTrade()
end

-- входящий запрос
local function showIncoming(p)
    local pop = make("Frame", {
        Size = UDim2.new(0, 320, 0, 84), Position = UDim2.new(0.5, -160, 0, 70),
        BackgroundColor3 = Color3.fromRGB(30, 30, 45), ZIndex = 40,
    }, gui)
    corner(pop, 10)
    stroke(pop, GOLD, 2)
    local t = label(pop, p.DisplayName .. " хочет обменяться", UDim2.new(1, -16, 0, 30), UDim2.new(0, 8, 0, 6), 14, Color3.new(1, 1, 1), Enum.TextXAlignment.Center)
    t.ZIndex = 41
    local yes = button(pop, "Принять", UDim2.new(0.5, -12, 0, 30), UDim2.new(0, 8, 0, 44), GREEN)
    local no = button(pop, "Отклонить", UDim2.new(0.5, -12, 0, 30), UDim2.new(0.5, 4, 0, 44), Color3.fromRGB(150, 50, 50))
    yes.ZIndex, no.ZIndex = 41, 41
    yes.MouseButton1Click:Connect(function() pop:Destroy(); openTrade(p) end)
    no.MouseButton1Click:Connect(function() pop:Destroy() end)
    task.delay(15, function() if pop.Parent then pop:Destroy() end end)
end

-- ====== ВКЛАДКА: ТРЕЙД ======
local tradePage = pages["Трейд"]
local playerList = scroll(tradePage, UDim2.new(0.5, -4, 1, 0), UDim2.new())
local selLabel = label(tradePage, "Выбери игрока слева", UDim2.new(0.5, -4, 0, 40), UDim2.new(0.5, 4, 0, 0), 13, Color3.fromRGB(200, 200, 200), Enum.TextXAlignment.Center)
selLabel.TextWrapped = true
local sendBtn = button(tradePage, "Отправить трейд", UDim2.new(0.5, -4, 0, 34), UDim2.new(0.5, 4, 0, 50), GREEN)
local incBtn = button(tradePage, "Входящий запрос", UDim2.new(0.5, -4, 0, 34), UDim2.new(0.5, 4, 0, 92), Color3.fromRGB(60, 80, 140))
local tradeTarget

sendBtn.MouseButton1Click:Connect(function()
    if not tradeTarget then notify("Сначала выбери игрока") return end
    local p = tradeTarget
    notify("Запрос отправлен: " .. p.DisplayName)
    task.delay(1.5, function()
        notify(p.DisplayName .. " принял запрос")
        openTrade(p)
    end)
end)
incBtn.MouseButton1Click:Connect(function()
    if not tradeTarget then notify("Сначала выбери игрока") return end
    showIncoming(tradeTarget)
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
        tradeTarget = p
        selLabel.Text = "Выбран: " .. p.DisplayName
    end)
end

-- ====== ВКЛАДКА: КОПИЯ СКИНА ======
local skinPage = pages["Скин"]
local skinList = scroll(skinPage, UDim2.new(1, 0, 1, -34), UDim2.new())
label(skinPage, "Клик по игроку — копирует его нож/пистолет себе (виден только тебе)",
    UDim2.new(1, 0, 0, 28), UDim2.new(0, 0, 1, -28), 12, Color3.fromRGB(170, 170, 170))

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

-- ====== ВКЛАДКА: ОТЛАДКА ======
local dbgPage = pages["Отладка"]
local dbgText = make("TextLabel", {
    Text = "Нажми «Проверить», чтобы увидеть, нашёл ли скрипт окно инвентаря игры.\nОткрой инвентарь в игре и держи там хотя бы один свой предмет.",
    Size = UDim2.new(1, 0, 1, -40), BackgroundColor3 = Color3.fromRGB(25, 25, 35),
    TextColor3 = Color3.fromRGB(200, 200, 200), Font = Enum.Font.Code, TextSize = 12,
    TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Top,
}, dbgPage)
corner(dbgText, 6)

local dbgBtn = button(dbgPage, "Проверить инвентарь игры", UDim2.new(1, 0, 0, 32), UDim2.new(0, 0, 1, -32), Color3.fromRGB(60, 80, 140))
dbgBtn.MouseButton1Click:Connect(function()
    nativeCont, nativeTpl = nil, nil
    local cont, tpl = findContainer()
    nativeCont, nativeTpl = cont, tpl
    if cont then
        dbgText.Text = table.concat({
            "Контейнер найден:", cont:GetFullName(), "",
            "Образец предмета: " .. (tpl and tpl.Name or "нет"),
            "Подмен сейчас: " .. countFakes(cont),
            "В твоём списке: " .. #inventory,
        }, "\n")
        print("[MM2Panel] container:", cont:GetFullName())
    else
        dbgText.Text = "Окно инвентаря не найдено.\nОткрой инвентарь в игре (с хотя бы одним предметом) и нажми кнопку снова."
    end
end)

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
