-- Sorts bags!

local BagSorter = {
    name = "BagSorter",
    version = "1.0",
    description = "Sorts bags based on customizable criteria",
}

--|-------------------|--
--|   Local Helpers   |--
--|-------------------|--

local function ToSortMap(inlist)
    local built = {}
    
    for k,v in ipairs(inlist) do
        built[v] = k
    end
    
    return built
end

local function ExtractItemId(itemLink)
    local itemString = string.match(itemLink, "item[%-?%d:]+")
    local itemId = string.match(itemString, "item:(%d+):")
    
    return tonumber(itemId)
end

--|---------------------|--
--|   Local Constants   |--
--|---------------------|--

-- TODO make this customizable via in-game addon config window
local FAVORITES_SORTING = ToSortMap({
    6948,  -- Hearthstone

    -- Fishing Poles --
    6256,  -- Fishing Pole
    12225, -- Blump Family Fishing Pole
    6365,  -- Strong Fishing Pole
    6366,  -- Darkwood Fishing Pole
    6367,  -- Big Iron Fishing Pole
    19970, -- Arcanite Fishing Pole

    -- Pickaxes & Hammers --
    2901,  -- Mining Pick
    778,   -- Kobold Excavation Pick
    1959,  -- Cold Iron Pick
    756,   -- Tunnel Pick
    20723, -- Brann's Trusty Pick
    5956,  -- Blacksmith Hammer

    -- Healing Potions --
    118,   -- Minor Healing Potion
    858,   -- Lesser Healing Potion
    929,   -- Healing Potion
    1710,  -- Greater Healing Potion
    3928,  -- Superior Healing Potion
    13446, -- Major Healing Potion

    -- Mana Potions --
    2455,  -- Minor Mana Potion
    3385,  -- Lesser Mana Potion
    3827,  -- Mana Potion
    6149,  -- Greater Mana Potion
    13443, -- Superior Mana Potion
})

local TRADE_GOODS_SORTING = ToSortMap({
    -- Cloths --
    2589,  -- Linen Cloth
    2592,  -- Wool Cloth
    4306,  -- Silk Cloth
    4338,  -- Mageweave Cloth
    
    -- Bolts --
    2996,  -- Bolt of Linen Cloth
    2997,  -- Bolt of Woolen Cloth
    4305,  -- Bolt of Silk Cloth
    4339,  -- Bolt of Mageweave Cloth
    
    -- Ores (Common) --
    2770,  -- Copper Ore
    2771,  -- Tin Ore
    2772,  -- Iron Ore
    3857,  -- Coal
    3858,  -- Mithril Ore
    10620, -- Thorium Ore
    
    -- Ores (Uncommon) --
    2775,  -- Silver Ore
    2776,  -- Gold Ore
    7911,  -- Truesilver Ore

    -- Bars (Common) --
    2840,  -- Copper Bar
    3576,  -- Tin Bar
    2841,  -- Bronze Bar
    3575,  -- Iron Bar
    3859,  -- Steel Bar
    3860,  -- Mithril Bar
    3861,  -- Blacksteel Bar
    12359, -- Thorium Bar

    -- Bars (Uncommon) --
    2842,  -- Silver Bar
    3577,  -- Gold Bar
    6037,  -- Truesilver Bar
    12360, -- Arcanite Bar

    -- Stones --
    2835,  -- Rough Stone
    2836,  -- Coarse Stone
    2838,  -- Heavy Stone
    7912,  -- Solid Stone
    12365, -- Dense Stone

    -- Grinding Stones --
    3470,  -- Rough Grinding Stone
    3478,  -- Coarse Grinding Stone
    3486,  -- Heavy Grinding Stone
    7966,  -- Solid Grinding Stone
    12644, -- Dense Grinding Stone

    -- Leathers --
    2934,  -- Ruined Leather Scraps
    2318,  -- Light Leather
    2319,  -- Medium Leather
    4234,  -- Heavy Leather
    4304,  -- Thick Leather
    8170,  -- Rugged Leather
    17012, -- Core Leather

    -- Hides (Uncured) --
    783,   -- Light Hide
    4232,  -- Medium Hide
    4235,  -- Heavy Hide
    8169,  -- Thick Hide
    8171,  -- Rugged Hide

    -- Hides (Cured) --
    4231,  -- Cured Light Hide
    4233,  -- Cured Medium Hide
    4236,  -- Cured Heavy Hide
    8172,  -- Cured Thick Hide
    15407, -- Cured Rugged Hide
})

--|-------------------------|--
--|   Filtering & Sorting   |--
--|-------------------------|--

local function SortDefault(a, b)
    local infoA = a[3]
    local infoB = b[3]

    if infoA[1] == infoB[1] then
        _, countA = GetContainerItemInfo(a[1], a[2])
        _, countB = GetContainerItemInfo(b[1], b[2])
        
        return countA > countB
    else
        return infoA[1] > infoB[1]
    end
end

-- TODO add checks for equipment (equippable armor/weapons)
local function IsEpicEquipment(itemInfo)
    local itemRarity = itemInfo[4]
    return itemRarity == 4
end

local function IsRareEquipment(itemInfo)
    local itemRarity = itemInfo[4]
    return itemRarity == 3
end

local function IsUncommonEquipment(itemInfo)
    local itemRarity = itemInfo[4]
    return itemRarity == 2
end

local function IsCommonEquipment(itemInfo)
    local itemRarity = itemInfo[4]
    return itemRarity == 1
end

local function IsPoorEquipment(itemInfo)
    local itemRarity = itemInfo[4]
    return itemRarity == 0
end

local function IsConsumable(itemInfo)
    local itemType = itemInfo[7]
    return itemType == "Consumable"
end

local function IsQuest(itemInfo)
    local itemType = itemInfo[7]
    return itemType == "Quest"
end

local function IsTool(itemInfo)
    local itemType = itemInfo[7]
    return itemType == "Key" -- TODO
end

local function IsFavorite(itemInfo)
    return FAVORITES_SORTING[itemInfo[1]] ~= nil
end
local function SortFavorite(a, b)
    local valA = FAVORITES_SORTING[a[3][1]] or -1
    local valB = FAVORITES_SORTING[b[3][1]] or -1
    
    if valA == valB then
        return SortDefault(a, b)
    end
    return valA < valB
end

local function IsTradeGood(itemInfo)
    local itemType = itemInfo[7]
    return itemType == "Trade Goods"
end
local function SortTradeGood(a, b)
    local valA = TRADE_GOODS_SORTING[a[3][1]] or -1
    local valB = TRADE_GOODS_SORTING[b[3][1]] or -1
    
    if valA == valB then
        return SortDefault(a, b)
    end
    return valA < valB
end

--|--------------------------|--
--|   BagSorter Public API   |--
--|--------------------------|--

function BagSorter:OnUpdate(elapsed)
    if self.queue and self.queuePos <= #self.queue then
        self:ProcessSwapQueue()
    end
end

function BagSorter:ProcessSwapQueue()
    -- Keep doing swaps until we're locked out and need to wait
    while true do
        local cur = self.queue[self.queuePos]
        if not cur then
            LogMessage("Sorting finished!")
            break -- We reached end of the queue!
        end

        local _, _, locked = GetContainerItemInfo(cur[1], cur[2])

        if not locked then
            -- We're not locked out! Pick up the slot and keep going
            PickupContainerItem(cur[1], cur[2])
            self.queuePos = self.queuePos + 1
        else
            break
        end
    end
end

function BagSorter:GetItemInfo(itemLink)
    local itemId = ExtractItemId(itemLink)

    -- https://vanilla-wow.fandom.com/wiki/API_GetItemInfo
    return {itemId, GetItemInfo(itemLink)}
end

function BagSorter:GetSortSublists()
    -- TODO make this configurable via in-game addons options screen
    return {
        -- First element is filtered list of slots, second is chooser, third is subsorter
        {{}, IsFavorite,          SortFavorite},
        {{}, IsTool,              SortDefault},
        {{}, IsConsumable,        SortDefault},
        {{}, IsQuest,             SortDefault},
        {{}, IsTradeGood,         SortTradeGood},
        {{}, IsEpicEquipment,     SortDefault},
        {{}, IsRareEquipment,     SortDefault},
        {{}, IsUncommonEquipment, SortDefault},
        {{}, IsCommonEquipment,   SortDefault},
        {{}, IsPoorEquipment,     SortDefault},

        -- Last sublist is the catch-all
        {{}, function(p) return true end, SortDefault},
    }
end

function BagSorter:SortBags(input)
    LogMessage("Sorting bags...")

    ClearCursor()

    local sublists = self:GetSortSublists()

    self.slotMap = {}

    -- First pass: build out filtered sublists
    for bagid = 0, 4 do
        for slotid = 1, GetContainerNumSlots(bagid) do
            local link = GetContainerItemLink(bagid, slotid)

            local info = nil
            if link then
                info = self:GetItemInfo(link)
            end

            local key = ('%s:%s'):format(bagid, slotid)
            self.slotMap[key] = {bagid, slotid, info}

            if info then
                -- Check against each sublist
                for _, sublist in pairs(sublists) do
                    -- If this item passes the sublist filter func
                    if sublist[2](info) then
                        table.insert(sublist[1], self.slotMap[key])
                        break
                    end
                end
            end
        end
    end

    -- Second pass: sort each sublist via their subsorters and concatenate onto master list
    local merged = {}
    for _, sublist in pairs(sublists) do
        -- Invoke subsorter on sublist
        table.sort(sublist[1], sublist[3])

        -- Add to master list
        for _, item in pairs(sublist[1]) do
            table.insert(merged, item)
        end
    end

    local curItemIndex = 1
    local curItem = merged[curItemIndex]

    self.queue = {}
    self.queuePos = 1

    -- Now perform selection sort (using the merged master list)
    for bagid = 0, 4 do
        for slotid = 1, GetContainerNumSlots(bagid) do
            if curItem then
                -- Now move next item into its target slot
                self:QueueSwapItems(curItem[1], curItem[2], bagid, slotid)

                curItemIndex = curItemIndex + 1
                curItem = merged[curItemIndex]
            end
        end
    end

    -- Do the first iteration immediately.
    self:ProcessSwapQueue()
end

function BagSorter:QueueSwapItems(fromBag, fromSlot, toBag, toSlot)
    -- Optimization: Don't swap a stack with itself!
    if fromBag == toBag and fromSlot == toSlot then
        --print("Skipping: " .. tostring(fromBag) .. ":" .. tostring(fromSlot).. " (same slot)")
        return false
    end

    --print("Swapping: " .. tostring(fromBag) .. ":" .. tostring(fromSlot) .. " with " .. tostring(toBag) .. ":" .. tostring(toSlot))

    local fromKey = ('%s:%s'):format(fromBag, fromSlot)
    local toKey = ('%s:%s'):format(toBag, toSlot)
    local fromItem = self.slotMap[fromKey]
    local toItem = self.slotMap[toKey]

    -- Validation: Can't swap two empty stacks
    if not fromItem[3] and not toItem[3] then
        LogError("Attempted to swap two empty slots!")
        return false
    end

    -- Optimization: Don't swap stacks that have the same ID and stack count
    if fromItem[3] and toItem[3] then
        if fromItem[3][1] == toItem[3][1] then
            _, countFrom = GetContainerItemInfo(fromItem[1], fromItem[2])
            _, countTo = GetContainerItemInfo(toItem[1], toItem[2])
            if countFrom == countTo then
                --print("Skipping: " .. tostring(fromBag) .. ":" .. tostring(fromSlot) .. " (same item & quantity)")
                return false
            end
        end
    end

    -- Queue the slot swapping actions
    if not fromItem[3] then
        table.insert(self.queue, {toBag, toSlot, toItem[3]})       -- Pick up item in 'to' slot, storing it under cursor
        table.insert(self.queue, {fromBag, fromSlot, fromItem[3]}) -- Place item under cursor in 'from' slot
    else
        table.insert(self.queue, {fromBag, fromSlot, fromItem[3]}) -- Pick up item in 'from' slot, storing it under cursor
        table.insert(self.queue, {toBag, toSlot, toItem[3]})       -- Place item under cursor in 'to' slot
    end

    --if fromItem[3] and toItem[3] then
    --    print("    Swap: " .. tostring(fromItem[3][1]) .. " & " .. tostring(toItem[3][1]))
    --end

    -- Update mappings in lookup table
    fromItem[1] = toBag
    fromItem[2] = toSlot
    toItem[1] = fromBag
    toItem[2] = fromSlot
    self.slotMap[toKey] = fromItem
    self.slotMap[fromKey] = toItem

    return true
end

--|-------------------------|--
--|   Plugin Registration   |--
--|-------------------------|--

Daddy:RegisterPlugin("BagSorter", BagSorter)
Daddy:RegisterSubcommand("sortbags", function(input) BagSorter:SortBags(input) end, "Sorts bags according to customizable criteria")
