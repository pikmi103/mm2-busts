spawnerStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
spawnerStatusLabel.Parent = spawnerFrame

CreateButton(spawnerFrame, "Spawn High Tier (Tradable)", function()
	local count, total = 0, 0
	for _, entry in ipairs(WeaponCatalog) do
		if SpawnerHighTierSet[entry.rarity] then
			local amt = _randomAmount(entry.rarity, false)
			SpawnItem(entry.key, amt, "Weapons")
			count = count + 1
			total = total + amt
		end
	end
	spawnerStatusLabel.Text = ("Spawned %d weapons (%d items)"):format(count, total)
	spawnerStatusLabel.TextColor3 = Color3.fromRGB(120,255,160)
end)

CreateSpace(spawnerFrame)

CreateButton(spawnerFrame, "Purge untradables from inventory", function()
	local removed = PurgeBlockedFromInventory()
	spawnerStatusLabel.Text = ("Removed %d untradable weapon(s)"):format(removed)
	spawnerStatusLabel.TextColor3 = (removed > 0) and Color3.fromRGB(120,255,160) or Color3.fromRGB(255,200,120)
end)

CreateSpace(spawnerFrame)

local spawnerScrollFrame = Instance.new("ScrollingFrame")
spawnerScrollFrame.Size = UDim2.new(1, 0, 0, 120)
spawnerScrollFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
spawnerScrollFrame.BackgroundTransparency = 0.3
spawnerScrollFrame.BorderSizePixel = 0
spawnerScrollFrame.ScrollBarThickness = 6
spawnerScrollFrame.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 255)
spawnerScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
spawnerScrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
spawnerScrollFrame.Parent = spawnerFrame
Instance.new("UICorner", spawnerScrollFrame).CornerRadius = UDim.new(0, 5)
local ss = Instance.new("UIStroke", spawnerScrollFrame)
ss.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
ss.Color = Color3.fromRGB(80, 80, 120)
ss.Thickness = 1
local sl = Instance.new("UIListLayout", spawnerScrollFrame)
sl.FillDirection = Enum.FillDirection.Vertical
sl.SortOrder = Enum.SortOrder.LayoutOrder
sl.Padding = UDim.new(0, 2)
local sp = Instance.new("UIPadding", spawnerScrollFrame)
sp.PaddingTop = UDim.new(0, 3); sp.PaddingBottom = UDim.new(0, 3)
sp.PaddingLeft = UDim.new(0, 3); sp.PaddingRight = UDim.new(0, 3)

local spawnerButtons = {}
for _, entry in ipairs(WeaponCatalog) do
	local wKey, baseColor = entry.key, RarityTint[entry.rarity] or RarityTint.Common
	local label = entry.name .. (entry.chroma and " [Chroma]" or "") .. " (" .. entry.rarity .. " " .. entry.type .. ")"
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -6, 0, 22)
	btn.BackgroundColor3 = baseColor
	btn.BackgroundTransparency = 0.2
	btn.Text = label
	btn.Font = Enum.Font.SourceSans
	btn.TextSize = 12
	btn.TextColor3 = Color3.fromRGB(255,255,255)
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.TextTruncate = Enum.TextTruncate.AtEnd
	btn.Parent = spawnerScrollFrame
	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {
			BackgroundColor3 = baseColor:Lerp(Color3.fromRGB(255,255,255), 0.25)
		}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = baseColor}):Play()
	end)

	btn.MouseButton1Click:Connect(function()
		local typed = tonumber(SpawnerAmountBox.Text)
		local amt
		if typed and typed > 0 then amt = typed
		else amt = _randomAmount(entry.rarity, false) end
		SpawnItem(wKey, amt, "Weapons")
		spawnerStatusLabel.Text = ("Spawned %s x%d"):format(entry.name, amt)
		spawnerStatusLabel.TextColor3 = Color3.fromRGB(120,255,160)
		TweenService:Create(btn, TweenInfo.new(0.1), {
			BackgroundColor3 = Color3.fromRGB(0,150,100)
		}):Play()
		task.delay(0.2, function()
			TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = baseColor}):Play()
		end)
	end)

	spawnerButtons[#spawnerButtons+1] = {button = btn, entry = entry}
end

SpawnerSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
	local q = string.lower(SpawnerSearchBox.Text or "")
	for _, info in ipairs(spawnerButtons) do
		if q == "" then info.button.Visible = true
		else
			local e = info.entry
			local hay = string.lower(e.name .. " " .. e.key .. " " .. e.rarity .. " " .. e.type)
			info.button.Visible = string.find(hay, q, 1, true) ~= nil
		end
	end
end)

-- ============================================================
-- ПРАЙС-ТАБЛИЦА / ЦЕНЫ
-- ============================================================
local function normalizeWeaponName(s)
	s = string.lower(tostring(s or ""))
	s = string.gsub(s, "^c%.%s*", "chroma ")
	s = string.gsub(s, "(%s)c%.%s*", "%1chroma ")
	s = string.gsub(s, "['\u{2019}\"]", "")
	s = string.gsub(s, "%s+", " ")
	s = string.gsub(s, "^%s+", "")
	s = string.gsub(s, "%s+$", "")
	return s
end

local PlayerCalcPriceTable = {}
do
	local raw = {
		["Corrupt"]=600, ["C. Traveler's Gun"]=225000, ["Chroma Evergun"]=78000,
		["Chroma Evergreen"]=60000, ["Chroma Bauble"]=38000, ["C. Constellation"]=36000,
		["C. Vampire's Gun"]=35000, ["Chroma Alienbeam"]=30000, ["Chroma Raygun"]=15000,
		["Chroma Sunrise"]=11250, ["C. Snowcannon"]=8500, ["Chroma Blizzard"]=8000,
		["Chroma Sunset"]=6500, ["C. Snow Dagger"]=5750, ["Chroma Treat"]=4850,
		["C. Heart Wand"]=4750, ["Chroma Snowstorm"]=4250, ["Chroma Watergun"]=3400,
		["Chroma Sweet"]=2850, ["Chroma Ornament"]=2700, ["Gingerscope"]=17750,
		["Traveler's Axe"]=8400, ["Celestial"]=1725, ["Vampire's Axe"]=925,
		["Harvester"]=290, ["Icepiercer"]=190, ["Traveler's Gun"]=4500,
		["Evergun"]=3300, ["Constellation"]=2600, ["Turkey"]=2475,
		["Evergreen"]=2450, ["Alienbeam"]=2175, ["Vampire's Gun"]=1700,
		["Darkshot"]=1390, ["Darksword"]=1370, ["Raygun"]=1275,
		["Blossom"]=1180, ["Sakura"]=1170, ["Sunrise"]=1000,
		["Snowcannon"]=925, ["Bauble"]=900, ["Sunset"]=525,
		["Heart Wand"]=450, ["Soul"]=380, ["Spirit"]=370,
		["Flora"]=310, ["Bloom"]=300, ["Rainbow Gun"]=300,
		["Rainbow"]=290, ["Snow Dagger"]=260, ["Flowerwood Gun"]=205,
		["Flowerwood"]=200, ["Xenoknife"]=200, ["Xenoshot"]=200,
		["Watergun"]=185, ["Ocean"]=180, ["Waves"]=175,
		["Treat"]=170, ["Sweet"]=165, ["Blizzard"]=155,
		["Snowstorm"]=155, ["Bat"]=125, ["Borealis"]=105,
		["Australis"]=100, ["Candy"]=95, ["Heartblade"]=80,
	}
	for name, value in pairs(raw) do
		PlayerCalcPriceTable[normalizeWeaponName(name)] = { name = name, value = value }
	end
end

local PricedRarities = {
	Chroma=true, Godly=true, Ancient=true, Vintage=true,
	Unique=true, Classic=true, Legendary=true,
}

local function harvestProfile(raw)
	local out = {}
	if type(raw) ~= "table" or type(raw.Weapons) ~= "table" then return out end
	local owned = raw.Weapons.Owned
	if type(owned) ~= "table" then return out end
	for k, v in pairs(owned) do
		local key, amount = nil, 1
		if type(k) == "number" then
			if type(v) == "string" then key = v
			elseif type(v) == "table" then
				key = v.Name or v.ItemName or v.Key or v.Id
				amount = tonumber(v.Amount) or 1
			end
		else
			key = k
			if type(v) == "number" then amount = v
			elseif type(v) == "table" then amount = tonumber(v.Amount) or 1 end
		end
		if key and Sync and Sync.Weapons and Sync.Weapons[key]
		   and type(Sync.Weapons[key]) == "table"
		   and Sync.Weapons[key].ItemName then
			local data = Sync.Weapons[key]
			local rarity = data.Rarity or "Common"
			if data.Chroma == true then rarity = "Chroma" end
			table.insert(out, { Name = data.ItemName, Amount = amount, Rarity = rarity })
		end
	end
	return out
end

local function FetchPlayerInventory(player)
	if not player then return nil end
	if player == LocalPlayer then return harvestProfile(ProfileData) end
	local out = nil
	pcall(function()
		local remote = ReplicatedStorage.Remotes.Extras.GetFullInventory
		local raw = remote:InvokeServer(player)
		if type(raw) == "table" then out = harvestProfile(raw) end
	end)
	return out
end

local function CalculateInventoryValue(inv, playerNameForLog)
	if not inv then return 0, {} end
	local total, priced, skipped = 0, {}, 0
	for _, w in ipairs(inv) do
		local entry = PlayerCalcPriceTable[normalizeWeaponName(w.Name)]
		if entry and (not w.Rarity or PricedRarities[w.Rarity]) then
			local amt = w.Amount or 1
			total = total + entry.value * amt
			table.insert(priced, { name = entry.name, amount = amt, value = entry.value })
		else
			skipped = skipped + 1
		end
	end
	table.sort(priced, function(a, b)
		return (a.value * a.amount) > (b.value * b.amount)
	end)
	return total, priced
end

-- ============================================================
-- PLAYERS TAB
-- ============================================================
playersFrame.UIListLayout.Padding = UDim.new(0, 4)

local playersStatusLabel = Instance.new("TextLabel")
playersStatusLabel.Size = UDim2.new(1, 0, 0, 14)
playersStatusLabel.LayoutOrder = 1
playersStatusLabel.BackgroundTransparency = 1
playersStatusLabel.Text = "ready"
playersStatusLabel.Font = Enum.Font.SourceSans
playersStatusLabel.TextSize = 11
playersStatusLabel.TextColor3 = Color3.fromRGB(180,180,180)
playersStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
playersStatusLabel.Parent = playersFrame

local playersRefreshBtn = Instance.new("TextButton")
playersRefreshBtn.Size = UDim2.new(1, 0, 0, 22)
playersRefreshBtn.LayoutOrder = 2
playersRefreshBtn.BackgroundColor3 = Color3.fromRGB(80,80,130)
playersRefreshBtn.BackgroundTransparency = 0.2
playersRefreshBtn.Text = "Refresh values"
playersRefreshBtn.Font = Enum.Font.FredokaOne
playersRefreshBtn.TextSize = 12
playersRefreshBtn.TextColor3 = Color3.fromRGB(255,255,255)
playersRefreshBtn.Parent = playersFrame
Instance.new("UICorner", playersRefreshBtn).CornerRadius = UDim.new(0, 4)

local playersScroll = Instance.new("ScrollingFrame")
playersScroll.Size = UDim2.new(1, 0, 1, -50)
playersScroll.LayoutOrder = 4
playersScroll.BackgroundTransparency = 1
playersScroll.BorderSizePixel = 0
playersScroll.ScrollBarThickness = 6
playersScroll.ScrollBarImageColor3 = Color3.fromRGB(100,100,255)
playersScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
playersScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
playersScroll.Parent = playersFrame

local playersScrollLayout = Instance.new("UIListLayout", playersScroll)
playersScrollLayout.FillDirection = Enum.FillDirection.Vertical
playersScrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
playersScrollLayout.Padding = UDim.new(0, 4)

local playersScrollPadding = Instance.new("UIPadding", playersScroll)
playersScrollPadding.PaddingRight = UDim.new(0, 8)

local playerRows = {}

local function destroyAllRows()
	for _, child in pairs(playersScroll:GetChildren()) do
		if not (child:IsA("UIListLayout") or child:IsA("UIPadding")) then
			child:Destroy()
		end
	end
	playerRows = {}
end

local IDLE_HEADER_COLOR = Color3.fromRGB(50,50,70)

local function createPlayerRow(player)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 0, 30)
	container.BackgroundTransparency = 1
	container.Parent = playersScroll

	local header = Instance.new("TextButton")
	header.Size = UDim2.new(1, 0, 1, 0)
	header.BackgroundColor3 = IDLE_HEADER_COLOR
	header.BackgroundTransparency = 0.15
	header.Text = ""
	header.AutoButtonColor = false
	header.Parent = container
	Instance.new("UICorner", header).CornerRadius = UDim.new(0, 5)
	local hStroke = Instance.new("UIStroke", header)
	hStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	hStroke.Color = Color3.fromRGB(100,100,180)
	hStroke.Thickness = 1
	hStroke.Transparency = 0.4

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(0.6, -10, 1, 0)
	nameLabel.Position = UDim2.new(0, 8, 0, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = player.Name
	nameLabel.Font = Enum.Font.FredokaOne
	nameLabel.TextSize = 13
	nameLabel.TextColor3 = Color3.fromRGB(240,240,255)
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
	valLabel.TextColor3 = Color3.fromRGB(120,255,160)
	valLabel.TextXAlignment = Enum.TextXAlignment.Right
	valLabel.Parent = header

	local rowBlockBtn = Instance.new("TextButton")
	rowBlockBtn.Size = UDim2.new(0, 44, 0, 20)
	rowBlockBtn.Position = UDim2.new(1, -50, 0.5, -10)
	rowBlockBtn.BackgroundColor3 = Color3.fromRGB(180,70,70)
	rowBlockBtn.BackgroundTransparency = 0.1
	rowBlockBtn.Text = "Block"
	rowBlockBtn.Font = Enum.Font.SourceSansSemibold
	rowBlockBtn.TextSize = 11
	rowBlockBtn.TextColor3 = Color3.fromRGB(255,255,255)
	rowBlockBtn.ZIndex = 2
	rowBlockBtn.Parent = header
	Instance.new("UICorner", rowBlockBtn).CornerRadius = UDim.new(0, 4)

	rowBlockBtn.MouseButton1Click:Connect(function()
		rowBlockBtn.Text = "…"
		task.spawn(function()
			local ok, err = pcall(SilentBlockPlayer, player)
			if not ok then
				rowBlockBtn.Text = "err"
				rowBlockBtn.BackgroundColor3 = Color3.fromRGB(160,60,60)
			else
				rowBlockBtn.Text = "Blocked"
				rowBlockBtn.BackgroundColor3 = Color3.fromRGB(90,90,90)
			end
		end)
	end)

	local row = {
		player = player, container = container, header = header,
		nameLabel = nameLabel, valLabel = valLabel, rowBlockBtn = rowBlockBtn,
		inv = nil, total = -1,
	}

	header.MouseButton1Click:Connect(function()
		TradeTable.Player2.Player = player.Name
		PartnerUserBox.Text = player.Name
		setActiveTab("Control")
	end)

	return row
end

local function sortAndReflowPlayers()
	local rows = {}
	for _, r in pairs(playerRows) do table.insert(rows, r) end
	table.sort(rows, function(a, b) return a.total > b.total end)
	for i, r in ipairs(rows) do
		r.container.LayoutOrder = i
		local rank = (r.total > 0) and ("#" .. i .. " ") or ""
		r.nameLabel.Text = rank .. r.player.Name
	end
end

local function updatePlayerValue(row)
	row.valLabel.Text = "fetching…"
	row.valLabel.TextColor3 = Color3.fromRGB(200,200,200)

	local okFetch, invOrErr = pcall(FetchPlayerInventory, row.player)
	if not okFetch then
		row.inv = nil; row.total = -1; row.priced = {}
		row.valLabel.Text = "err"
		row.valLabel.TextColor3 = Color3.fromRGB(255,100,100)
		return
	end
	row.inv = invOrErr
	if not row.inv then
		row.total = -1; row.priced = {}
		row.valLabel.Text = "?"
		row.valLabel.TextColor3 = Color3.fromRGB(200,150,100)
		return
	end
	row.valLabel.Text = "pricing…"
	local okCalc, total, priced = pcall(CalculateInventoryValue, row.inv, row.player.Name)
	if not okCalc then
		row.valLabel.Text = "err"
		row.valLabel.TextColor3 = Color3.fromRGB(255,100,100)
		row.total = -1
		return
	end
	row.total = total
	row.priced = priced
	row.valLabel.Text = FormatValue(total)
	row.valLabel.TextColor3 = (total > 0) and Color3.fromRGB(120,255,160) or Color3.fromRGB(180,180,180)
end

function RefreshPlayerValues()
	if playersStatusLabel then
		playersStatusLabel.Text = "refreshing players…"
		playersStatusLabel.TextColor3 = Color3.fromRGB(180,220,255)
	end
	local pending = 0
	for _ in pairs(playerRows) do pending = pending + 1 end
	for _, row in pairs(playerRows) do
		task.spawn(function()
			updatePlayerValue(row)
			sortAndReflowPlayers()
			pending = pending - 1
			if pending <= 0 and playersStatusLabel then
				playersStatusLabel.Text = "ready"
				playersStatusLabel.TextColor3 = Color3.fromRGB(150,220,150)
			end
		end)
	end
end

playersRefreshBtn.MouseButton1Click:Connect(function() RefreshPlayerValues() end)

local function UpdatePlayers()
	destroyAllRows()
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local row = createPlayerRow(player)
			playerRows[player.Name] = row
			task.spawn(function()
				updatePlayerValue(row)
				sortAndReflowPlayers()
			end)
		end
	end
end

task.defer(UpdatePlayers)
Players.PlayerAdded:Connect(function() UpdatePlayers() end)
Players.PlayerRemoving:Connect(function() UpdatePlayers() end)
Players.ChildRemoved:Connect(function() UpdatePlayers() end)
