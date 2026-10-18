-- ============================================================
-- ЗАВИСИМОСТИ / СЕРВИСЫ
-- ============================================================
local Players            = game:GetService("Players")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local TweenService       = game:GetService("TweenService")
local UserInputService   = game:GetService("UserInputService")
local RunService         = game:GetService("RunService")
local HttpService        = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer or Players:GetPlayers()[1]

-- ============================================================
-- ДАННЫЕ / КАТАЛОГ (заглушки — подставь свои реальные)
-- ============================================================
Sync = Sync or { Weapons = {} }
ProfileData = ProfileData or { Weapons = { Owned = {} } }
WeaponCatalog = WeaponCatalog or {}

RarityTint = RarityTint or {
	Common    = Color3.fromRGB(120, 120, 120),
	Uncommon  = Color3.fromRGB(80, 180, 80),
	Rare      = Color3.fromRGB(80, 120, 220),
	Legendary = Color3.fromRGB(220, 160, 40),
	Vintage   = Color3.fromRGB(180, 90, 200),
	Classic   = Color3.fromRGB(200, 200, 80),
	Unique    = Color3.fromRGB(80, 200, 200),
	Ancient   = Color3.fromRGB(200, 100, 60),
	Godly     = Color3.fromRGB(240, 80, 80),
	Chroma    = Color3.fromRGB(255, 120, 200),
}

-- ============================================================
-- TRADE TABLE / UI-ССЫЛКИ (заглушки)
-- ============================================================
TradeTable = TradeTable or { Player2 = { Player = nil } }
PartnerUserBox = PartnerUserBox or Instance.new("TextBox")

-- ============================================================
-- УТИЛИТЫ (заглушки — подставь реальные)
-- ============================================================
local function FormatValue(v)
	v = tonumber(v) or 0
	if v >= 1e6 then return string.format("%.2fM", v / 1e6) end
	if v >= 1e3 then return string.format("%.1fK", v / 1e3) end
	return tostring(math.floor(v))
end

local function CreateSpace(parent)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, 0, 0, 6)
	f.BackgroundTransparency = 1
	f.Parent = parent
	return f
end

local function CreateButton(parent, text, callback)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, 0, 0, 24)
	b.BackgroundColor3 = Color3.fromRGB(80, 80, 130)
	b.BackgroundTransparency = 0.2
	b.Text = text
	b.Font = Enum.Font.SourceSansSemibold
	b.TextSize = 12
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.Parent = parent
	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 4); c.Parent = b
	if callback then b.MouseButton1Click:Connect(callback) end
	return b
end

local function createSettingRow(labelText, defaultText, parent)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 22)
	row.BackgroundTransparency = 1
	row.Parent = parent
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.5, 0, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = labelText
	lbl.Font = Enum.Font.SourceSans
	lbl.TextSize = 12
	lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = row
	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0.5, -4, 1, 0)
	box.Position = UDim2.new(0.5, 4, 0, 0)
	box.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
	box.Text = defaultText or ""
	box.Font = Enum.Font.SourceSans
	box.TextSize = 12
	box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.ClearTextOnFocus = false
	box.Parent = row
	local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, 3); c.Parent = box
	return box
end

-- Заглушки игровых действий — подставь реальную логику
function SpawnItem(key, amount, category)
	print(("[SpawnItem] %s x%d (%s)"):format(tostring(key), tonumber(amount) or 1, tostring(category)))
	return true
end

function OfferItemAnotherPlayer(key, category)
	print(("[OfferItemAnotherPlayer] %s (%s)"):format(tostring(key), tostring(category)))
	return true
end

function PurgeBlockedFromInventory()
	print("[PurgeBlockedFromInventory] called")
	return 0
end

function SilentBlockPlayer(player)
	print(("[SilentBlockPlayer] %s"):format(player and player.Name or "nil"))
	return true
end

function setActiveTab(name)
	print(("[setActiveTab] %s"):format(tostring(name)))
end

-- UI-фреймы (заглушки-контейнеры; в оригинале создавались раньше)
local function makeFrame()
	local f = Instance.new("Frame")
	f.Size = UDim2.new(0, 300, 0, 400)
	f.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	f.Parent = LocalPlayer:WaitForChild("PlayerGui")
	return f
end

local weaponFrame  = makeFrame()
local spawnerFrame = makeFrame()
local playersFrame = makeFrame()
playersFrame.UIListLayout = playersFrame.UIListLayout or (function()
	local l = Instance.new("UIListLayout"); l.Parent = playersFrame; return l
end)()

-- ============================================================
-- ДОПОЛНИТЕЛЬНЫЕ ОБЪЯВЛЕНИЯ ДЛЯ ОЧИЩЕННОГО КОДА
-- ============================================================
local weaponButtons = {}

-- Контейнер для кнопок оружия (в оригинале — скролл внутри weaponFrame)
local weaponScrollFrame = Instance.new("ScrollingFrame")
weaponScrollFrame.Size = UDim2.new(1, 0, 1, -30)
weaponScrollFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
weaponScrollFrame.BackgroundTransparency = 0.3
weaponScrollFrame.BorderSizePixel = 0
weaponScrollFrame.ScrollBarThickness = 6
weaponScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 255)
weaponScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
weaponScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
weaponScrollFrame.Parent = weaponFrame
do
	local lay = Instance.new("UIListLayout")
	lay.FillDirection = Enum.FillDirection.Vertical
	lay.SortOrder = Enum.SortOrder.LayoutOrder
	lay.Padding = UDim.new(0, 2)
	lay.Parent = weaponScrollFrame
	local pad = Instance.new("UIPadding")
	pad.PaddingTop = UDim.new(0, 3)
	pad.PaddingBottom = UDim.new(0, 3)
	pad.PaddingLeft = UDim.new(0, 3)
	pad.PaddingRight = UDim.new(0, 3)
	pad.Parent = weaponScrollFrame
end

-- Поле поиска для партнёрского оружия
ItemToAddPartnerBox = ItemToAddPartnerBox or Instance.new("TextBox")
ItemToAddPartnerBox.Parent = weaponFrame
ItemToAddPartnerBox.Size = UDim2.new(1, 0, 0, 22)
ItemToAddPartnerBox.PlaceholderText = "Search weapon..."
ItemToAddPartnerBox.Text = ""

-- ============================================================
-- ГЕНЕРАЦИЯ КНОПОК ОРУЖИЯ (бывший вырезанный фрагмент)
-- ============================================================
for _, entry in ipairs(WeaponCatalog) do
	local wKey = entry.key
	local baseColor = RarityTint[entry.rarity] or RarityTint.Common
	local label = entry.name .. (entry.chroma and " [Chroma]" or "") .. " (" .. entry.rarity .. " " .. entry.type .. ")"

	local weaponBtn = Instance.new("TextButton")
	weaponBtn.Size = UDim2.new(1, -6, 0, 22)
	weaponBtn.BackgroundColor3 = baseColor
	weaponBtn.BackgroundTransparency = 0.2
	weaponBtn.Text = label
	weaponBtn.Font = Enum.Font.SourceSans
	weaponBtn.TextSize = 12
	weaponBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	weaponBtn.TextXAlignment = Enum.TextXAlignment.Left
	weaponBtn.TextTruncate = Enum.TextTruncate.AtEnd
	weaponBtn.Parent = weaponScrollFrame

	local btnPad = Instance.new("UIPadding")
	btnPad.PaddingLeft = UDim.new(0, 6)
	btnPad.PaddingRight = UDim.new(0, 6)
	btnPad.Parent = weaponBtn

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 4)
	btnCorner.Parent = weaponBtn

	weaponBtn.MouseEnter:Connect(function()
		TweenService:Create(weaponBtn, TweenInfo.new(0.15), {BackgroundColor3 = baseColor:Lerp(Color3.fromRGB(255, 255, 255), 0.25)}):Play()
	end)

	weaponBtn.MouseLeave:Connect(function()
		TweenService:Create(weaponBtn, TweenInfo.new(0.15), {BackgroundColor3 = baseColor}):Play()
	end)

	weaponBtn.MouseButton1Click:Connect(function()
		local success = OfferItemAnotherPlayer(wKey, "Weapons")
		if success then
			TweenService:Create(weaponBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(0, 150, 100)}):Play()
		else
			TweenService:Create(weaponBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(150, 50, 50)}):Play()
		end
		task.delay(0.2, function()
			TweenService:Create(weaponBtn, TweenInfo.new(0.15), {BackgroundColor3 = baseColor}):Play()
		end)
	end)

	weaponButtons[#weaponButtons + 1] = {button = weaponBtn, entry = entry}
end

-- ============================================================
-- ТВОЙ ОЧИЩЕННЫЙ КОД
-- ============================================================
ItemToAddPartnerBox:GetPropertyChangedSignal("Text"):Connect(function() local q = string.lower(ItemToAddPartnerBox.Text or "") for _, info in ipairs(weaponButtons) do if q == "" then info.button.Visible = true else local e = info.entry local hay = string.lower(e.name .. " " .. e.key .. " " .. e.rarity .. " " .. e.type) info.button.Visible = string.find(hay, q, 1, true) ~= nil end end end)

local SpawnerRandomRanges = { Chroma = {1, 2}, Godly = {1, 5}, Ancient = {2, 6}, Unique = {2, 8}, Classic = {3, 10}, Legendary = {4, 12}, Vintage = {5, 15}, Rare = {8, 25}, Uncommon = {10, 40}, Common = {15, 60}, }

local SpawnerHighTierSet = { Chroma = true, Godly = true, Ancient = true, Unique = true, Classic = true, Legendary = true, Vintage = true, }

local function _randomAmount(rarity, evo) if evo then return 1 end local r = SpawnerRandomRanges[rarity] or SpawnerRandomRanges.Common return math.random(r[1], r[2]) end

local SpawnerAmountBox = createSettingRow("Amount per click (0 = random):", "0", spawnerFrame) CreateSpace(spawnerFrame)

local SpawnerSearchBox = createSettingRow("Search weapon:", "", spawnerFrame) CreateSpace(spawnerFrame)

local spawnerStatusLabel = Instance.new("TextLabel") spawnerStatusLabel.Size = UDim2.new(1, 0, 0, 15) spawnerStatusLabel.BackgroundTransparency = 1 spawnerStatusLabel.Text = "Click weapon to spawn:" spawnerStatusLabel.Font = Enum.Font.SourceSansSemibold spawnerStatusLabel.TextSize = 12 spawnerStatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100) spawnerStatusLabel.TextXAlignment = Enum.TextXAlignment.Left spawnerStatusLabel.Parent = spawnerFrame

local spawnHighTierBtn = CreateButton(spawnerFrame, "Spawn High Tier (Tradable)", function() local count, total = 0, 0 for _, entry in ipairs(WeaponCatalog) do if SpawnerHighTierSet[entry.rarity] then local amt = _randomAmount(entry.rarity, false) SpawnItem(entry.key, amt, "Weapons") count = count + 1 total = total + amt end end spawnerStatusLabel.Text = ("Spawned %d weapons (%d items)"):format(count, total) spawnerStatusLabel.TextColor3 = Color3.fromRGB(120, 255, 160) print(("[mm2run/spawner] High-tier bulk spawn: %d weapon types, %d items total"):format(count, total)) end)

CreateSpace(spawnerFrame)

CreateButton(spawnerFrame, "Purge untradables from inventory", function() local removed = PurgeBlockedFromInventory() spawnerStatusLabel.Text = ("Removed %d untradable weapon(s) -- see console"):format(removed) spawnerStatusLabel.TextColor3 = (removed > 0) and Color3.fromRGB(120, 255, 160) or Color3.fromRGB(255, 200, 120) end)

CreateSpace(spawnerFrame)

local spawnerScrollFrame = Instance.new("ScrollingFrame") spawnerScrollFrame.Size = UDim2.new(1, 0, 0, 120) spawnerScrollFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35) spawnerScrollFrame.BackgroundTransparency = 0.3 spawnerScrollFrame.BorderSizePixel = 0 spawnerScrollFrame.ScrollBarThickness = 6 spawnerScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 255) spawnerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0) spawnerScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y spawnerScrollFrame.Parent = spawnerFrame

local function _updateSpawnerScrollHeight() local offsetY = spawnerScrollFrame.AbsolutePosition.Y - spawnerFrame.AbsolutePosition.Y local available = spawnerFrame.AbsoluteSize.Y - offsetY - 4 spawnerScrollFrame.Size = UDim2.new(1, 0, 0, math.max(80, available)) end spawnerFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(_updateSpawnerScrollHeight) task.defer(_updateSpawnerScrollHeight)

do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 5) c.Parent = spawnerScrollFrame local s = Instance.new("UIStroke") s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border s.Color = Color3.fromRGB(80, 80, 120) s.Thickness = 1 s.Parent = spawnerScrollFrame local lay = Instance.new("UIListLayout") lay.FillDirection = Enum.FillDirection.Vertical lay.SortOrder = Enum.SortOrder.LayoutOrder lay.Padding = UDim.new(0, 2) lay.Parent = spawnerScrollFrame local pad = Instance.new("UIPadding") pad.PaddingTop = UDim.new(0, 3) pad.PaddingBottom = UDim.new(0, 3) pad.PaddingLeft = UDim.new(0, 3) pad.PaddingRight = UDim.new(0, 3) pad.Parent = spawnerScrollFrame end

local spawnerButtons = {} for _, entry in ipairs(WeaponCatalog) do local wKey = entry.key local baseColor = RarityTint[entry.rarity] or RarityTint.Common local label = entry.name .. (entry.chroma and " [Chroma]" or "") .. " (" .. entry.rarity .. " " .. entry.type .. ")"

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, -6, 0, 22)
btn.BackgroundColor3 = baseColor
btn.BackgroundTransparency = 0.2
btn.Text = label
btn.Font = Enum.Font.SourceSans
btn.TextSize = 12
btn.TextColor3 = Color3.fromRGB(255, 255, 255)
btn.TextXAlignment = Enum.TextXAlignment.Left
btn.TextTruncate = Enum.TextTruncate.AtEnd
btn.Parent = spawnerScrollFrame

local btnPad = Instance.new("UIPadding")
btnPad.PaddingLeft = UDim.new(0, 6)
btnPad.PaddingRight = UDim.new(0, 6)
btnPad.Parent = btn

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 4)
btnCorner.Parent = btn

btn.MouseEnter:Connect(function()
	TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = baseColor:Lerp(Color3.fromRGB(255, 255, 255), 0.25)}):Play()
end)
btn.MouseLeave:Connect(function()
	TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = baseColor}):Play()
end)

btn.MouseButton1Click:Connect(function()
	local typed = tonumber(SpawnerAmountBox.Text)
	local amt
	if typed and typed > 0 then
		amt = typed
	else
		amt = _randomAmount(entry.rarity, false)
	end
	SpawnItem(wKey, amt, "Weapons")
	spawnerStatusLabel.Text = ("Spawned %s x%d"):format(entry.name, amt)
	spawnerStatusLabel.TextColor3 = Color3.fromRGB(120, 255, 160)
	TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(0, 150, 100)}):Play()
	task.delay(0.2, function()
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = baseColor}):Play()
	end)
end)

spawnerButtons[#spawnerButtons + 1] = {button = btn, entry = entry}
end

SpawnerSearchBox:GetPropertyChangedSignal("Text"):Connect(function() local q = string.lower(SpawnerSearchBox.Text or "") for _, info in ipairs(spawnerButtons) do if q == "" then info.button.Visible = true else local e = info.entry local hay = string.lower(e.name .. " " .. e.key .. " " .. e.rarity .. " " .. e.type) info.button.Visible = string.find(hay, q, 1, true) ~= nil end end end)

local function harvestProfile(raw) local out = {} if type(raw) ~= "table" or type(raw.Weapons) ~= "table" then return out end local owned = raw.Weapons.Owned if type(owned) ~= "table" then return out end

for k, v in pairs(owned) do
	local key, amount = nil, 1
	if type(k) == "number" then

		if type(v) == "string" then
			key = v
		elseif type(v) == "table" then
			key = v.Name or v.ItemName or v.Key or v.Id
			amount = tonumber(v.Amount) or 1
		end
	else

		key = k
		if type(v) == "number" then amount = v
		elseif type(v) == "table" then amount = tonumber(v.Amount) or 1 end
	end

	if key and Sync.Weapons and Sync.Weapons[key]
	   and type(Sync.Weapons[key]) == "table"
	   and Sync.Weapons[key].ItemName then
		local data = Sync.Weapons[key]
		local rarity = data.Rarity or "Common"
		if data.Chroma == true then rarity = "Chroma" end
		table.insert(out, {
			Name = data.ItemName,
			Amount = amount,
			Rarity = rarity,
		})
	end
end
return out
end

local PricedRarities = { Chroma = true, Godly = true, Ancient = true, Vintage = true, Unique = true, Classic = true, Legendary = true, }

local function FetchPlayerInventory(player) if not player then return nil end

if player == game.Players.LocalPlayer then
	return harvestProfile(ProfileData)
end

local out = nil
pcall(function()
	local remote = game.ReplicatedStorage.Remotes.Extras.GetFullInventory
	local raw = remote:InvokeServer(player)
	if type(raw) == "table" then
		out = harvestProfile(raw)
	end
end)
return out
end

local function normalizeWeaponName(s) s = string.lower(tostring(s or ""))

s = string.gsub(s, "^c%.%s*", "chroma ")
s = string.gsub(s, "(%s)c%.%s*", "%1chroma ")

s = string.gsub(s, "['\u{2019}\"]", "")

s = string.gsub(s, "%s+", " ")
s = string.gsub(s, "^%s+", "")
s = string.gsub(s, "%s+$", "")
return s
end

local PlayerCalcPriceTable = {} do local raw = { ["Corrupt"] = 600, ["C. Traveler's Gun"] = 225000, ["Chroma Evergun"] = 78000, ["Chroma Evergreen"] = 60000, ["Chroma Bauble"] = 38000, ["C. Constellation"] = 36000, ["C. Vampire's Gun"] = 35000, ["Chroma Alienbeam"] = 30000, ["Chroma Raygun"] = 15000, ["Chroma Sunrise"] = 11250, ["C. Snowcannon"] = 8500, ["Chroma Blizzard"] = 8000, ["Chroma Sunset"] = 6500, ["C. Snow Dagger"] = 5750, ["Chroma Treat"] = 4850, ["C. Heart Wand"] = 4750, ["Chroma Snowstorm"] = 4250, ["Chroma Watergun"] = 3400, ["Chroma Sweet"] = 2850, ["Chroma Ornament"] = 2700, ["Gingerscope"] = 17750, ["Traveler's Axe"] = 8400, ["Celestial"] = 1725, ["Vampire's Axe"] = 925, ["Harvester"] = 290, ["Icepiercer"] = 190, ["Traveler's Gun"] = 4500, ["Evergun"] = 3300, ["Constellation"] = 2600, ["Turkey"] = 2475, ["Evergreen"] = 2450, ["Alienbeam"] = 2175, ["Vampire's Gun"] = 1700, ["Darkshot"] = 1390, ["Darksword"] = 1370, ["Raygun"] = 1275, ["Blossom"] = 1180, ["Sakura"] = 1170, ["Sunrise"] = 1000, ["Snowcannon"] = 925, ["Bauble"] = 900, ["Sunset"] = 525, ["Heart Wand"] = 450, ["Soul"] = 380, ["Spirit"] = 370, ["Flora"] = 310, ["Bloom"] = 300, ["Rainbow Gun"] = 300, ["Rainbow"] = 290, ["Snow Dagger"] = 260, ["Flowerwood Gun"] = 205, ["Flowerwood"] = 200, ["Xenoknife"] = 200, ["Xenoshot"] = 200, ["Watergun"] = 185, ["Ocean"] = 180, ["Waves"] = 175, ["Treat"] = 170, ["Sweet"] = 165, ["Blizzard"] = 155, ["Snowstorm"] = 155, ["Bat"] = 125, ["Borealis"] = 105, ["Australis"] = 100, ["Candy"] = 95, ["Heartblade"] = 80, } for name, value in pairs(raw) do PlayerCalcPriceTable[normalizeWeaponName(name)] = { name = name, value = value } end end

local function CalculateInventoryValue(inv, playerNameForLog) if not inv then return 0, {} end local total = 0 local priced = {} local skipped = 0

if playerNameForLog then
	print(("[mm2run] ----- %s: %d inventory items -----"):format(playerNameForLog, #inv))
end

for _, w in ipairs(inv) do
	local entry = PlayerCalcPriceTable[normalizeWeaponName(w.Name)]
	if entry and (not w.Rarity or PricedRarities[w.Rarity]) then
		local amt = w.Amount or 1
		local contribution = entry.value * amt
		total = total + contribution
		table.insert(priced, {
			name = entry.name,
			amount = amt,
			value = entry.value,
		})
		if playerNameForLog then
			print(("[mm2run]   [+] %s x%d  =  %s  (each %s)"):format(
				entry.name, amt, FormatValue(contribution), FormatValue(entry.value)))
		end
	else
		skipped = skipped + 1
		if playerNameForLog then
			local reason
			if entry then
				reason = "wrong rarity: " .. tostring(w.Rarity)
			else
				reason = "not in price table"
			end
			print(("[mm2run]   [-] %s x%d  (%s)"):format(
				tostring(w.Name), w.Amount or 1, reason))
		end
	end
end

if playerNameForLog then
	print(("[mm2run] ----- %s TOTAL: %s  (%d counted, %d ignored) -----"):format(
		playerNameForLog, FormatValue(total), #priced, skipped))
end

table.sort(priced, function(a, b)
	return (a.value * a.amount) > (b.value * b.amount)
end)
return total, priced
end

playersFrame.UIListLayout.Padding = UDim.new(0, 4)

local playersStatusLabel = Instance.new("TextLabel") playersStatusLabel.Size = UDim2.new(1, 0, 0, 14) playersStatusLabel.LayoutOrder = 1 playersStatusLabel.BackgroundTransparency = 1 playersStatusLabel.Text = "ready" playersStatusLabel.Font = Enum.Font.SourceSans playersStatusLabel.TextSize = 11 playersStatusLabel.TextColor3 = Color3.fromRGB(180, 180, 180) playersStatusLabel.TextXAlignment = Enum.TextXAlignment.Left playersStatusLabel.Parent = playersFrame

local playersRefreshBtn = Instance.new("TextButton") playersRefreshBtn.Size = UDim2.new(1, 0, 0, 22) playersRefreshBtn.LayoutOrder = 2 playersRefreshBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 130) playersRefreshBtn.BackgroundTransparency = 0.2 playersRefreshBtn.Text = "Refresh values" playersRefreshBtn.Font = Enum.Font.FredokaOne playersRefreshBtn.TextSize = 12 playersRefreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255) playersRefreshBtn.Parent = playersFrame do local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 4) c.Parent = playersRefreshBtn end

local playersScroll = Instance.new("ScrollingFrame") playersScroll.Size = UDim2.new(1, 0, 1, -50) playersScroll.LayoutOrder = 4 playersScroll.BackgroundTransparency = 1 playersScroll.BorderSizePixel = 0 playersScroll.ScrollBarThickness = 6 playersScroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 255) playersScroll.CanvasSize = UDim2.new(0, 0, 0, 0) playersScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y playersScroll.Parent = playersFrame

local playersScrollLayout = Instance.new("UIListLayout") playersScrollLayout.FillDirection = Enum.FillDirection.Vertical playersScrollLayout.SortOrder = Enum.SortOrder.LayoutOrder playersScrollLayout.Padding = UDim.new(0, 4) playersScrollLayout.Parent = playersScroll

local playersScrollPadding = Instance.new("UIPadding") playersScrollPadding.PaddingRight = UDim.new(0, 8) playersScrollPadding.Parent = playersScroll

local playerRows = {}

local function destroyAllRows() for _, child in pairs(playersScroll:GetChildren()) do if not (child:IsA("UIListLayout") or child:IsA("UIPadding")) then child:Destroy() end end playerRows = {} end

local IDLE_HEADER_COLOR = Color3.fromRGB(50, 50, 70)

local function createPlayerRow(player) local container = Instance.new("Frame") container.Size = UDim2.new(1, 0, 0, 30) container.BackgroundTransparency = 1 container.Parent = playersScroll

local header = Instance.new("TextButton")
header.Size = UDim2.new(1, 0, 1, 0)
header.BackgroundColor3 = IDLE_HEADER_COLOR
header.BackgroundTransparency = 0.15
header.Text = ""
header.AutoButtonColor = false
header.Parent = container

local hCorner = Instance.new("UICorner")
hCorner.CornerRadius = UDim.new(0, 5)
hCorner.Parent = header

local hStroke = Instance.new("UIStroke")
hStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
hStroke.Color = Color3.fromRGB(100, 100, 180)
hStroke.Thickness = 1
hStroke.Transparency = 0.4
hStroke.Parent = header

local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.new(0.6, -10, 1, 0)
nameLabel.Position = UDim2.new(0, 8, 0, 0)
nameLabel.BackgroundTransparency = 1
nameLabel.Text = player.Name
nameLabel.Font = Enum.Font.FredokaOne
nameLabel.TextSize = 13
nameLabel.TextColor3 = Color3.fromRGB(240, 240, 255)
nameLabel.TextXAlignment = Enum.TextXAlignment.Left
nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
nameLabel.Parent = header

local valLabel = Instance.new("TextLabel")
valLabel.Size = UDim2.new(0.4, -56, 1, 0)
valLabel.Position = UDim2.new(0.6, 0, 0, 0)
valLabel.BackgroundTransparency = 1
valLabel.Text = "…"
valLabel.Font = Enum.Font.FredokaOne
valLabel.TextSize = 12
valLabel.TextColor3 = Color3.fromRGB(120, 255, 160)
valLabel.TextXAlignment = Enum.TextXAlignment.Right
valLabel.Parent = header

local rowBlockBtn = Instance.new("TextButton")
rowBlockBtn.Size = UDim2.new(0, 44, 0, 20)
rowBlockBtn.Position = UDim2.new(1, -50, 0.5, -10)
rowBlockBtn.BackgroundColor3 = Color3.fromRGB(180, 70, 70)
rowBlockBtn.BackgroundTransparency = 0.1
rowBlockBtn.Text = "Block"
rowBlockBtn.Font = Enum.Font.SourceSansSemibold
rowBlockBtn.TextSize = 11
rowBlockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
rowBlockBtn.ZIndex = 2
rowBlockBtn.AutoButtonColor = true
rowBlockBtn.Parent = header
do
	local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 4) c.Parent = rowBlockBtn
end

rowBlockBtn.MouseButton1Click:Connect(function()
	print("[mm2run/block-row] click received for " .. player.Name)
	rowBlockBtn.Text = "…"
	task.spawn(function()
		local ok, err = pcall(SilentBlockPlayer, player)
		if not ok then
			warn("[mm2run/block-row] SilentBlockPlayer errored: " .. tostring(err))
			rowBlockBtn.Text = "err"
			rowBlockBtn.BackgroundColor3 = Color3.fromRGB(160, 60, 60)
		else
			rowBlockBtn.Text = "Blocked"
			rowBlockBtn.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
		end
	end)
end)

local row = {
	player = player,
	container = container,
	header = header,
	nameLabel = nameLabel,
	valLabel = valLabel,
	rowBlockBtn = rowBlockBtn,
	inv = nil,
	total = -1,
}

header.MouseButton1Click:Connect(function()
	TradeTable.Player2.Player = player.Name
	PartnerUserBox.Text = player.Name
	setActiveTab("Control")
end)

return row
end

local function sortAndReflowPlayers() local rows = {} for _, r in pairs(playerRows) do table.insert(rows, r) end table.sort(rows, function(a, b) return a.total > b.total end) for i, r in ipairs(rows) do r.container.LayoutOrder = i local rank = (r.total > 0) and ("#" .. i .. " ") or "" r.nameLabel.Text = rank .. r.player.Name end end

local function updatePlayerValue(row) row.valLabel.Text = "fetching…" row.valLabel.TextColor3 = Color3.fromRGB(200, 200, 200)

print(("[mm2run] === Fetching %s's inventory ==="):format(row.player.Name))

local okFetch, invOrErr = pcall(Fetch 
